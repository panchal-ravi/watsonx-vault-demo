# OAuth2 Authorization Code Flow Web App

This web ap## Installation & Setup

1. **Install Python Dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

2. **Configure Environment Variables**:

   Copy the example environment file and update with your values:

   ```bash
   cp .env.example .env
   ```

   Edit `.env` file with your actual configuration:

   ```bash
   # Azure AD (Entra ID) Configuration
   AZURE_TENANT_ID=your-tenant-id-here
   AZURE_CLIENT_ID=your-client-id-here
   AZURE_CLIENT_SECRET=your-client-secret-here
   AZURE_SCOPE_NAME=your-scope-name-here

   # Watson Orchestrate Configuration
   WATSON_ORCHESTRATION_ID=your-orchestration-id-here
   WATSON_AGENT_ID=your-agent-id-here
   WATSON_AGENT_ENVIRONMENT_ID=your-agent-environment-id-here

   # Server Configuration (optional)
   REDIRECT_URI=http://localhost:8080/callback
   SERVER_PORT=8080
   ```tes a complete OAuth2 authorization code flow with Azure AD (Entra ID) integration, featuring Watson Orchestrate embedded chat.

## Features

- 🔐 **OAuth2 Authorization Code Flow** with PKCE (RFC 7636)
- 🏢 **Azure Active Directory (Entra ID) Integration** for enterprise authentication
-  **Watson Orchestrate Embedded Chat** with authenticated session
- 🌐 **Complete Web Interface** with real-time status updates

## Configuration Details

### Azure AD Configuration

- **Tenant ID**: `788d8595-3c0f-4d77-beda-ca1bb0715ede`
- **Client ID**: `ced4c4a3-fdbf-4796-8999-2d7e8c7afae3`
- **Scope**: `hashicorp-vault-app-99f8d671/.default`
- **Redirect URI**: `http://localhost:8080/callback`

### Watson Orchestrate Configuration

- **Orchestration ID**: `20250818-2250-0903-906c-a26b84d378cd_20250818-2250-2466-2080-dc6415c827cd`
- **Agent ID**: `e1599f44-6586-4c4c-9690-ad4631508a5a`
- **Agent Environment ID**: `cb24aa31-7d0b-447b-8a4b-116d0ff591a1`
- **Host URL**: `https://dl.watson-orchestrate.ibm.com`

## Files

- `server.py` - Complete OAuth2 flow server with Azure AD integration
- `requirements.txt` - Python dependencies
- `.env.example` - Example environment variables file
- `.env` - Your actual environment variables (create from .env.example)
- `.gitignore` - Git ignore file (excludes .env from version control)
- `index.html` - Static HTML page (legacy)
- `README.md` - This documentation

## Security Features

- 🔒 **Environment Variables** - Sensitive data stored securely in `.env` file
- 🚫 **Git Protection** - `.env` file excluded from version control
- 🔐 **PKCE (Proof Key for Code Exchange)** - Prevents authorization code interception
- 🛡️ **State Parameter** - CSRF protection during OAuth2 flow
- 🎫 **JWT Token Validation** - Secure token handling
- 🔑 **Session Management** - Secure authenticated session handling

## Installation & Setup

1. **Install Python Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Verify Configuration**: 
   Check the `CONFIG` dictionary in `server.py` and update if needed:
   ```python
   CONFIG = {
       'tenant_id': 'your-tenant-id',
       'client_id': 'your-client-id',
       'client_secret': 'your-client-secret',
       # ... other settings
   }
   ```
## How to Run

### Option 1: OAuth2 Flow Server (Recommended)

1. **Install Python Dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

2. **Verify Configuration**: 
   Check the `CONFIG` dictionary in `server.py` and update if needed:

   ```python
   CONFIG = {
       'tenant_id': 'your-tenant-id',
       'client_id': 'your-client-id',
       'client_secret': 'your-client-secret',
       # ... other settings
   }
   ```

3. **Run the Server**:

   ```bash
   python server.py
   ```

4. **Access the Application**:
   - Server starts on: `http://localhost:8080`
   - Browser opens automatically
   - Click "Login with Azure AD" to start OAuth2 flow

### Option 2: Using Python's Built-in Server

If you prefer using Python's built-in server:

```bash
python -m http.server 8000
```

Then open `http://localhost:8000/index.html` in your browser.

### Option 3: Direct File Access

You can also open `index.html` directly in your browser, but some features might not work due to CORS restrictions.

## OAuth2 Flow Process

1. **Home Page**: Access the main interface at `http://localhost:8080`
2. **Authorization**: Click "Login with Azure AD" to start OAuth2 flow
3. **Azure AD Login**: Authenticate with your Azure AD credentials
4. **Callback Processing**: Server exchanges authorization code for tokens
5. **Token Display**: View user information and token details
6. **Watson Orchestrate**: Chat widget loads with authenticated session

## API Endpoints

- `GET /` - Main application page
- `GET /login` - Initiate OAuth2 authorization flow
- `GET /callback` - Handle OAuth2 callback with authorization code

## Security Features

- **PKCE (Proof Key for Code Exchange)** - Prevents authorization code interception
- **State Parameter** - CSRF protection during OAuth2 flow
- **JWT Token Validation** - Secure token handling (production requires signature verification)
- **Session Management** - Secure authenticated session handling

## Troubleshooting

### Common Issues

1. **Missing Environment Variables**: 
   - Error: "Missing required environment variables"
   - Solution: Copy `.env.example` to `.env` and update with your values

2. **Import Error for packages**: 
   - Error: `ModuleNotFoundError: No module named 'dotenv'` or similar
   - Solution: Install dependencies with `pip install -r requirements.txt`

3. **OAuth2 Callback Error**: 
   - Ensure redirect URI in Azure AD matches exactly: `http://localhost:8080/callback`
   - Check `REDIRECT_URI` in your `.env` file

4. **Authentication Failed**: 
   - Verify Azure AD configuration in `.env` file
   - Ensure the Azure AD application has the required scopes configured
   - Check that tenant ID, client ID, and client secret are correct

5. **Watson Orchestrate Not Loading**: 
   - Check browser console for JavaScript errors
   - Verify Watson configuration in `.env` file

## What to Expect

1. **Authentication Flow**: Complete OAuth2/OIDC flow with Azure AD
2. **Token Display**: View decoded ID token and user information  
3. **Secure Chat**: Watson Orchestrate widget with authenticated session access
