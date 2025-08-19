### Pre-requisites
- Setup application in Auth0 for client_credentials flow

### Test OAuth2 flow using curl

```
curl --request POST \
  --url https://AUTH0-DOMAIN.us.auth0.com/oauth/token \
  --header 'content-type: application/json' \
  --data '{
    "client_id":"CLIENT_ID",
    "client_secret":"CLIENT_SECRET",
    "audience":"https://AUTH0-DOMAIN.us.auth0.com/api/v2/",
    "grant_type":"client_credentials"
  }'
```
Set JWT_TOKEN variable with value from the above output
```sh
JWT_TOKEN=<COPY_YOUR_JWT_TOKEN_HERE>
```

### Setup Vault
```sh
vault auth enable jwt

vault write auth/jwt/role/watsonx \
    policies="metrics" \
    user_claim="sub" \
    role_type="jwt" \
    bound_audiences="https://AUTH0_DOMAIN.us.auth0.com/api/v2/" \
    bound_subject="<COPY_SUBJECT_FROM_JWT_TOKEN_HERE>"
```
### Test Vault login using JWT auth method
```sh
vault write auth/jwt/login role=default jwt=$obo_access_token
```