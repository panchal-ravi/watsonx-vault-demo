# WatsonX with Hashicorp Vault Steps

## enable secure embedded flow

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