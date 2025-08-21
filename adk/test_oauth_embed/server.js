#!/usr/bin/env node

/**
 * Node.js OAuth2 Authorization Code Flow Server
 * Integrates Azure AD authentication with Watson Orchestrate JWT creation
 */

const express = require('express');
const path = require('path');
const crypto = require('crypto');
const axios = require('axios');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const RSA = require('node-rsa');
const { v4: uuid } = require('uuid');
const cookieParser = require('cookie-parser');
require('dotenv').config();

// Optional auto-open browser functionality
let open;
try {
    open = require('open');
} catch (error) {
    console.warn('⚠️  Open package not available - browser will not auto-open');
}

const app = express();
const PORT = process.env.SERVER_PORT || 8080;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname)));

// Configuration from environment variables
const CONFIG = {
    tenant_id: process.env.AZURE_TENANT_ID,
    client_id: process.env.AZURE_CLIENT_ID,
    client_secret: process.env.AZURE_CLIENT_SECRET,
    scope_name: process.env.AZURE_SCOPE_NAME,
    redirect_uri: process.env.REDIRECT_URI || `http://localhost:${PORT}/callback`,
    auth_endpoint: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}/oauth2/v2.0/authorize`,
    token_endpoint: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}/oauth2/v2.0/token`
};

const WATSON_CONFIG = {
    orchestration_id: process.env.WATSON_ORCHESTRATION_ID,
    agent_id: process.env.WATSON_AGENT_ID,
    agent_environment_id: process.env.WATSON_AGENT_ENVIRONMENT_ID,
    host_url: process.env.WATSON_HOST_URL || 'https://dl.watson-orchestrate.ibm.com'
};

// JWT Configuration
const TIME_45_DAYS = 1000 * 60 * 60 * 24 * 45;

// Load keys (you'll need to create these)
let PRIVATE_KEY, IBM_PUBLIC_KEY;
try {
    PRIVATE_KEY = fs.readFileSync(path.join(__dirname, 'keys/private_key.pem'));
    IBM_PUBLIC_KEY = fs.readFileSync(path.join(__dirname, 'keys/ibm_public_key.pem'));
} catch (error) {
    console.warn('⚠️  JWT keys not found. JWT creation will be disabled.');
    console.warn('   Create keys in keys/ directory to enable JWT functionality.');
}

// In-memory session store (use Redis/database in production)
const sessions = new Map();

/**
 * Validate required environment variables
 */
function validateConfig() {
    const required = [
        'AZURE_TENANT_ID', 'AZURE_CLIENT_ID', 'AZURE_CLIENT_SECRET', 
        'AZURE_SCOPE_NAME', 'WATSON_ORCHESTRATION_ID', 'WATSON_AGENT_ID', 
        'WATSON_AGENT_ENVIRONMENT_ID'
    ];
    
    const missing = required.filter(key => !process.env[key]);
    
    if (missing.length > 0) {
        console.error('❌ Missing required environment variables:');
        missing.forEach(key => console.error(`   - ${key}`));
        console.error('💡 Please check your .env file.');
        return false;
    }
    return true;
}

/**
 * Generate PKCE code verifier and challenge
 */
function generatePKCE() {
    const codeVerifier = crypto.randomBytes(32).toString('base64url');
    const codeChallenge = crypto.createHash('sha256').update(codeVerifier).digest('base64url');
    return { codeVerifier, codeChallenge };
}

/**
 * Generate state parameter for CSRF protection
 */
function generateState() {
    return crypto.randomBytes(32).toString('hex');
}

/**
 * Create Watson Orchestrate JWT
 */
function createWatsonJWT(userInfo, sessionId, accessToken) {
    if (!PRIVATE_KEY || !IBM_PUBLIC_KEY) {
        throw new Error('JWT keys not available');
    }

    const anonymousUserId = `azure-${userInfo.sub || userInfo.oid}`;
    
    const jwtContent = {
        sub: anonymousUserId,
        iss: 'azure-oauth-server', // Add issuer
        aud: 'watson-orchestrate', // Add audience
        iat: Math.floor(Date.now() / 1000), // Add issued at
        woUserId: userInfo.preferred_username || userInfo.upn,
        woTenantId: userInfo.tid,
        user_payload: {
            custom_message: 'Authenticated via Azure AD',
            name: userInfo.name || userInfo.preferred_username,
            custom_user_id: userInfo.oid || userInfo.sub,
            sso_token: accessToken,
            email: userInfo.email || userInfo.preferred_username,
            tenant_id: userInfo.tid
        }
    };

    // Encrypt user payload
    if (jwtContent.user_payload) {
        const dataString = JSON.stringify(jwtContent.user_payload);
        const utf8Data = Buffer.from(dataString, 'utf-8');
        const rsaKey = new RSA(IBM_PUBLIC_KEY);
        jwtContent.user_payload = rsaKey.encrypt(utf8Data, 'base64');
    }

    const token = jwt.sign(jwtContent, PRIVATE_KEY, {
        algorithm: 'RS256',
        expiresIn: '1h'
    });
    
    // Debug: Validate JWT format
    const parts = token.split('.');
    console.log(`🔍 JWT Debug:`);
    console.log(`   - Parts count: ${parts.length} (should be 3)`);
    console.log(`   - Header length: ${parts[0]?.length || 0}`);
    console.log(`   - Payload length: ${parts[1]?.length || 0}`);
    console.log(`   - Signature length: ${parts[2]?.length || 0}`);
    console.log(`   - Format valid: ${parts.length === 3 ? '✅' : '❌'}`);
    
    return token;
}

/**
 * Routes
 */

// Home page
app.get('/', (req, res) => {
    const sessionId = req.cookies.session_id;
    const session = sessionId ? sessions.get(sessionId) : null;
    
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Initiate OAuth2 login
app.get('/login', (req, res) => {
    const { codeVerifier, codeChallenge } = generatePKCE();
    const state = generateState();
    
    // Store PKCE and state in session
    const sessionId = uuid();
    sessions.set(sessionId, { 
        codeVerifier, 
        state, 
        timestamp: Date.now() 
    });
    
    // Set session cookie
    res.cookie('session_id', sessionId, { 
        httpOnly: true, 
        maxAge: 10 * 60 * 1000 // 10 minutes
    });
    
    const params = new URLSearchParams({
        client_id: CONFIG.client_id,
        response_type: 'code',
        redirect_uri: CONFIG.redirect_uri,
        scope: `openid profile email ${CONFIG.scope_name}`,
        state: state,
        code_challenge: codeChallenge,
        code_challenge_method: 'S256'
    });
    
    const authUrl = `${CONFIG.auth_endpoint}?${params.toString()}`;
    console.log(`🔐 Redirecting to Azure AD: ${authUrl}`);
    
    res.redirect(authUrl);
});

// OAuth2 callback
app.get('/callback', async (req, res) => {
    try {
        const { code, state, error, error_description } = req.query;
        const sessionId = req.cookies.session_id;
        
        if (error) {
            throw new Error(`OAuth2 error: ${error} - ${error_description}`);
        }
        
        if (!code || !state || !sessionId) {
            throw new Error('Missing required parameters');
        }
        
        const session = sessions.get(sessionId);
        if (!session || session.state !== state) {
            throw new Error('Invalid state parameter - possible CSRF attack');
        }
        
        console.log(`🔑 Received authorization code: ${code.substring(0, 20)}...`);
        
        // Exchange code for tokens
        const tokenResponse = await axios.post(CONFIG.token_endpoint, new URLSearchParams({
            grant_type: 'authorization_code',
            client_id: CONFIG.client_id,
            client_secret: CONFIG.client_secret,
            code: code,
            redirect_uri: CONFIG.redirect_uri,
            code_verifier: session.codeVerifier
        }), {
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });
        
        const { access_token, id_token } = tokenResponse.data;
        
        // Decode ID token to get user info
        const userInfo = jwt.decode(id_token);
        console.log(`✅ User authenticated: ${userInfo.name || userInfo.preferred_username}`);
        
        // Update session with user info and tokens
        session.access_token = access_token;
        session.id_token = id_token;
        session.user_info = userInfo;
        session.authenticated = true;
        sessions.set(sessionId, session);
        
        // Generate Watson JWT if keys available
        let watsonJWT = null;
        try {
            if (PRIVATE_KEY && IBM_PUBLIC_KEY) {
                watsonJWT = createWatsonJWT(userInfo, sessionId, access_token);
                session.watson_jwt = watsonJWT;
                sessions.set(sessionId, session);
                console.log(`🎫 Watson JWT created successfully`);
                console.log(`   - Token length: ${watsonJWT.length} characters`);
                console.log(`   - Token preview: ${watsonJWT.substring(0, 100)}...`);
            }
        } catch (jwtError) {
            console.warn(`⚠️  Watson JWT creation failed: ${jwtError.message}`);
            console.error(jwtError.stack);
        }
        
        // Render success page with Watson Orchestrate
        res.send(generateSuccessPage(userInfo, watsonJWT, tokenResponse.data));
        
    } catch (error) {
        console.error(`❌ Callback error: ${error.message}`);
        res.status(500).send(generateErrorPage(error.message));
    }
});

// API endpoint to get current JWT
app.get('/api/jwt', (req, res) => {
    const sessionId = req.cookies.session_id;
    const session = sessionId ? sessions.get(sessionId) : null;
    
    if (!session || !session.authenticated) {
        return res.status(401).json({ error: 'Not authenticated' });
    }
    
    try {
        if (!session.watson_jwt && PRIVATE_KEY && IBM_PUBLIC_KEY) {
            session.watson_jwt = createWatsonJWT(session.user_info, sessionId, session.access_token);
            sessions.set(sessionId, session);
        }
        
        if (session.watson_jwt) {
            res.json({ jwt: session.watson_jwt });
        } else {
            res.status(500).json({ error: 'JWT creation not available' });
        }
    } catch (error) {
        console.error(`JWT creation error: ${error.message}`);
        res.status(500).json({ error: 'Failed to create JWT' });
    }
});

// API endpoint to get Watson configuration
app.get('/api/watson-config', (req, res) => {
    res.json({
        orchestrationID: WATSON_CONFIG.orchestration_id,
        hostURL: WATSON_CONFIG.host_url,
        agentId: WATSON_CONFIG.agent_id,
        agentEnvironmentId: WATSON_CONFIG.agent_environment_id
    });
});

// API endpoint to get user info
app.get('/api/user', (req, res) => {
    const sessionId = req.cookies.session_id;
    const session = sessionId ? sessions.get(sessionId) : null;
    
    if (!session || !session.authenticated) {
        return res.status(401).json({ error: 'Not authenticated' });
    }
    
    res.json({
        user: session.user_info,
        authenticated: true,
        hasWatsonJWT: !!session.watson_jwt
    });
});

// API endpoint to validate JWT format
app.get('/api/validate-jwt', (req, res) => {
    const sessionId = req.cookies.session_id;
    const session = sessionId ? sessions.get(sessionId) : null;
    
    if (!session || !session.authenticated || !session.watson_jwt) {
        return res.status(401).json({ error: 'No JWT available' });
    }
    
    const token = session.watson_jwt;
    const parts = token.split('.');
    
    try {
        const header = JSON.parse(Buffer.from(parts[0], 'base64url').toString());
        const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString());
        
        res.json({
            valid: parts.length === 3,
            parts_count: parts.length,
            header: header,
            payload: {
                ...payload,
                user_payload: payload.user_payload ? '[ENCRYPTED]' : null
            },
            signature_length: parts[2]?.length || 0,
            format: 'JWS Compact Serialization',
            structure: `${parts[0].substring(0, 20)}...${parts[1].substring(0, 20)}...${parts[2].substring(0, 20)}...`
        });
    } catch (error) {
        res.status(500).json({ 
            error: 'JWT parsing failed', 
            message: error.message,
            parts_count: parts.length 
        });
    }
});

// Logout
app.get('/logout', (req, res) => {
    const sessionId = req.cookies.session_id;
    if (sessionId) {
        sessions.delete(sessionId);
    }
    res.clearCookie('session_id');
    res.redirect('/');
});

/**
 * Generate success page HTML
 */
function generateSuccessPage(userInfo, watsonJWT, tokenData) {
    return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication Successful - Watson Orchestrate</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { max-width: 900px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .success { background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px; padding: 15px; margin-bottom: 20px; }
        .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px; padding: 15px; margin-bottom: 20px; }
        pre { background-color: #f8f9fa; border: 1px solid #e9ecef; border-radius: 4px; padding: 15px; overflow-x: auto; font-size: 12px; }
        .back-button { display: inline-block; background-color: #0066cc; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; margin-top: 20px; }
        #root { 
            min-height: 400px; 
            max-height: 600px;
            width: 100%;
            max-width: 800px;
            border: 2px dashed #ddd; 
            border-radius: 8px; 
            padding: 20px; 
            margin: 30px auto 0 auto; 
            text-align: center; 
            color: #666; 
            position: relative;
            overflow: hidden;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Authentication Successful!</h1>
        
        <div class="success">
            <h2>✅ OAuth2 Flow Completed</h2>
            <p>Successfully authenticated with Azure AD and obtained tokens.</p>
            ${watsonJWT ? '<p><strong>Watson JWT:</strong> Created successfully for secure chat access.</p>' : ''}
        </div>
        
        ${!watsonJWT ? '<div class="warning"><p>⚠️ Watson JWT not created (missing keys). Chat will use placeholder token.</p></div>' : ''}
        
        <h3>User Information</h3>
        <pre>${JSON.stringify(userInfo, null, 2)}</pre>
        
        <h3>Token Information</h3>
        <pre>${JSON.stringify({
            token_type: tokenData.token_type,
            expires_in: tokenData.expires_in,
            scope: tokenData.scope,
            access_token: tokenData.access_token?.substring(0, 50) + '...',
            id_token_present: !!tokenData.id_token,
            watson_jwt_present: !!watsonJWT
        }, null, 2)}</pre>
        
        <a href="/" class="back-button">← Back to Home</a>
        
        <div id="root">
            Watson Orchestrate is loading with authenticated access...
        </div>
    </div>
    
    <script>
        // Enhanced Watson Orchestrate configuration with authentication
        function preSendHandler(event) {
            if (event?.message?.content) {
                console.log('Pre-send:', event.message.content);
            }
        }

        function sendHandler(event) {
            console.log('Send event:', event);
        }

        function preReceiveHandler(event) {
            event?.content?.map((element) => {
                if (element?.text?.includes('assistant')) {
                    element.text = element.text.replace('assistant', 'Agent');
                }
            });
        }

        function receiveHandler(event) {
            console.log('Received event:', event);
        }

        function onLoad(instance) {
            console.log('Watson Orchestrate loaded:', instance);
            instance.on('chatstarted', (instance) => {
                window.wxoChatInstance = instance;
            });
            instance.on('pre:send', preSendHandler);
            instance.on('send', sendHandler);
            instance.on('pre:receive', preReceiveHandler);
            instance.on('receive', receiveHandler);
        }

        // Fetch current JWT from server
        async function fetchJWT() {
            try {
                const response = await fetch('/api/jwt');
                if (response.ok) {
                    const data = await response.json();
                    return data.jwt;
                }
            } catch (error) {
                console.warn('Failed to fetch JWT:', error);
            }
            return '${watsonJWT || '<CLIENT_JWT_GOES_HERE>'}';
        }

        // Initialize Watson Orchestrate
        async function initWatsonOrchestrate() {
            const token = await fetchJWT();
            
            window.wxOConfiguration = {
                clientVersion: 'latest',
                orchestrationID: "${WATSON_CONFIG.orchestration_id}",
                hostURL: "${WATSON_CONFIG.host_url}",
                rootElementId: "root",
                layout: 'embedded',
                showLauncher: false,
                isFullPageChat: false,
                height: '500px',
                width: '100%',
                token: token,
                chatOptions: {
                    onLoad: onLoad,
                    agentId: "${WATSON_CONFIG.agent_id}",
                    agentEnvironmentId: "${WATSON_CONFIG.agent_environment_id}",
                    isFullscreen: false,
                    height: '500px'
                }
            };

            const script = document.createElement('script');
            script.src = \`\${window.wxOConfiguration.hostURL}/wxochat/wxoLoader.js?embed=true\`;
            script.addEventListener('load', function () {
                console.log('Watson Orchestrate script loaded');
                wxoLoader.init();
            });
            script.addEventListener('error', function () {
                console.error('Failed to load Watson Orchestrate script');
            });
            document.head.appendChild(script);
        }

        // Initialize when page loads
        initWatsonOrchestrate();
    </script>
</body>
</html>`;
}

/**
 * Generate error page HTML
 */
function generateErrorPage(error) {
    return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication Error</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px; padding: 15px; }
        .back-button { display: inline-block; background-color: #0066cc; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>❌ Authentication Error</h1>
        <div class="error">
            <h2>Authentication Failed</h2>
            <p><strong>Error:</strong> ${error}</p>
        </div>
        <a href="/" class="back-button">← Try Again</a>
    </div>
</body>
</html>`;
}

/**
 * Start server
 */
function startServer() {
    if (!validateConfig()) {
        process.exit(1);
    }
    
    console.log('🔧 Node.js OAuth2 + Watson Orchestrate Server');
    console.log('=' .repeat(50));
    console.log('✅ Configuration validated');
    console.log('📋 Configuration:');
    console.log(`   - Tenant ID: ${CONFIG.tenant_id}`);
    console.log(`   - Client ID: ${CONFIG.client_id}`);
    console.log(`   - Scope: ${CONFIG.scope_name}`);
    console.log(`   - Redirect URI: ${CONFIG.redirect_uri}`);
    console.log(`   - Watson Orchestration ID: ${WATSON_CONFIG.orchestration_id}`);
    console.log(`   - JWT Keys: ${PRIVATE_KEY && IBM_PUBLIC_KEY ? '✅ Available' : '❌ Not found'}`);
    
    app.listen(PORT, () => {
        console.log(`\n🚀 Server running on http://localhost:${PORT}`);
        console.log(`📱 Open your browser to: http://localhost:${PORT}`);
        console.log(`🔒 OAuth2 callback: ${CONFIG.redirect_uri}`);
        console.log(`\n💡 Make sure your .env file is configured`);
        console.log(`🛑 Press Ctrl+C to stop\n`);
        
        // Auto-open browser if available
        if (open && typeof open === 'function') {
            try {
                open(`http://localhost:${PORT}`);
            } catch (error) {
                console.warn('⚠️  Could not auto-open browser:', error.message);
            }
        }
    });
}

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('\n🛑 Server shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('\n🛑 Server stopped');
    process.exit(0);
});

if (require.main === module) {
    startServer();
}

module.exports = app;
