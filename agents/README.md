# WatsonX with Hashicorp Vault Steps

## enable secure embedded flow
See https://developer.watson-orchestrate.ibm.com/manage/channels

```
export WXO_API_KEY=<>
export WXO_INSTANCE_ID=<>

chmod u+x enable_secure_embedded.sh   
./enable_secure_embedded.sh
```

## install WatsonX Orchestrate ADK

https://developer.watson-orchestrate.ibm.com/getting_started/installing

## Create ADK environment add WatsonX Orchrestrate

```
orchestrate env add -n watsonxdemo -u https://api.dl.watson-orchestrate.ibm.com/instances/$WXO_INSTANCE_ID -t mcsp
```

## Activate environment

```
orchestrate env activate watsonxdemo
```


## Create test agent - greetings

### Import test tool
```
# from tools folder 
cd ./agents/tools
orchestrate tools import --kind python -f greetings_tool.py
```

### Import test agent using tool
```
cd ..
orchestrate agents import -f greetings.yaml
```

## Deploy agent via UI

* Build > Agent Builder
* Deploy
* ensure status is live

Currently is not possible to deploy agent via cli, to enable live agent need to deploy via UI


## Export secure embed web script
https://developer.watson-orchestrate.ibm.com/manage/channels

```
orchestrate channels webchat embed --agent-name=greetings
```

Note the output here is incomplete

```
            <script>
                window.wxOConfiguration = {
                    orchestrationID: 
"20250818-2250-0903-906c-a26b84d378cd_20250818-2250-2466-2080-dc6415c827cd"
,
                    hostURL: "https://dl.watson-orchestrate.ibm.com",
                    rootElementID: "root",
                    showLauncher: true,
                    chatOptions: {
            agentId: "e1599f44-6586-4c4c-9690-ad4631508a5a",
            agentEnvironmentId: "cb24aa31-7d0b-447b-8a4b-116d0ff591a1"
        }
                };

                setTimeout(function () {
                    const script = document.createElement('script');
                    script.src = 
`${window.wxOConfiguration.hostURL}/wxochat/wxoLoader.js?embed=true`;
                    script.addEventListener('load', function () {
                        wxoLoader.init();
                    });
                    document.head.appendChild(script);
                }, 0);
            </script>
```

To pass SSO token via Web application

* createJWT on Web app
* pass user token into .user_payload
* encrypt payload with RSA keys IBM public keys
* sign JWT with private key


### example
```
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
```

# Confugure on-behalf flow

```
cd ./agents/tools
orchestrate connections import -f greetings_connection.yaml
```

## connections.yaml
```
spec_version: v1
kind: connection
app_id: greetings
environments:
  live:
    kind: oauth_auth_on_behalf_of_flow
    type: member
    sso: true
    server_url: https://login.microsoftonline.com/788d8595-3c0f-4d77-beda-ca1bb0715ede/oauth2/v2.0/token
    idp_config:
      header:
        content-type: application/x-www-form-urlencoded
      body:
        requested_token_use: on_behalf_of
        requested_token_type: urn:ietf:params:oauth:token-type:access_token
    app_config:
      header:
        content-type: application/x-www-form-urlencoded
      body:
        grant_type: urn:ietf:params:oauth:grant-type:jwt-bearer
```

## set-identity-provider
orchestrate connections set-identity-provider \
  --app-id greetings \
  --env live \
  --url https://login.microsoftonline.com/788d8595-3c0f-4d77-beda-ca1bb0715ede/oauth2/v2.0/token \
  --client-id 5c3790ba-90d7-48e0-ac13-b11cb6631913 \
  --client-secret 7TZ8Q~Ob3xYHwUXMFgZE....... \
  --scope api://6a40d9e9-49b5-415b-91a8-67488d2eeff1/Products.Read \
  --grant-type=urn:ietf:params:oauth:grant-type:jwt-bearer


