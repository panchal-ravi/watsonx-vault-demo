Okay, If you want to securely pass the user token, you can consider the following approach:
Enable the Secure Embed Flow

 Follow the instructions here: Enabling Secure Embed Flow

Provide the public key (referred to as client_public_key) that will be used by Orchestrate to verify the JWTs issued by your Application.

Alternatively, if you want the user token to be encrypted you can generate a JWT in your App Server with a user_payload that includes the user token.

Sign the JWT using your private key (RSA 4096-bit).

Provide the corresponding public key as client_public_key.

Encrypt the user_payload (containing the user token)

 Use the IBM-provided public key to encrypt the sensitive fields in the user_payload.
 Reference: Encrypting Sensitive Data in AI Chat
 
Once configured, you can securely call the private wxO APIs using your signed JWT:
curl 'https://dl.watson-orchestrate.ibm.com/mfe_home_archer/api/v1/orchestrate/agents/<agent-id>' \
  -H 'authorization: Bearer <Client_JWT>' \
  -H 'x-ibm-wo-orchestrate-id: <WXO_Tenant_ID>' \
  -H 'x-ibm-wo-user-id: <sub_from_your_JWT>'
This approach effectively leverages the Secure Embed flow, but without using the UI. It’s secure because:
Authentication is handled via the client_public_key registered with Orchestrate.
The user_payload, which contains the user token, is encrypted and can only be decrypted by Orchestrate.
I’m guessing this should work for your usecase, if you want the user token to be propagated to the tools that need it. (edited) 