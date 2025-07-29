# latest beta version of ADK

```bash
pip install --upgrade ibm-watsonx-orchestrate==1.8.0b1
```

```bash
#beta
pip install --upgrade ibm-watsonx-orchestrate-1.9.0b0
orchestrate --version
```

# API connectivity to WatsonX Saas

```bash
orchestrate env add -n watsonxdemo -u https://api.dl.watson-orchestrate.ibm.com/instances/20250714-0709-5414-209e-b6b83c9152dc -t mcsp
orchestrate env activate watsonxdemo 
```

```bash
orchestrate connections add --app-id watsonxdemo
orchestrate connections import --file ../adk-vault-connection-onbehalf.yaml
```

```bash
export CLIENTSEC=
orchestrate connections set-identity-provider \
  --app-id watsonxdemo \
  --env live \
  --url https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token \
  --client-id ced4c4a3-fdbf-4796-8999-2d7e8c7afae3 \
  --client-secret $CLIENTSEC \
  --scope api://$SCOPE/vault.secrets.read \
  --grant-type=urn:ietf:params:oauth:grant-type:jwt-bearer
```



```bash
export CLIENTSEC=
orchestrate connections set-identity-provider \
  --app-id vault_auth_code \
  --env live \
  --url https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token \
  --client-id ced4c4a3-fdbf-4796-8999-2d7e8c7afae3 \
  --client-secret $CLIENTSEC \
  --scope api://$SCOPE/vault.secrets.read \
  --grant-type=urn:ietf:params:oauth:grant-type:jwt-bearer
```