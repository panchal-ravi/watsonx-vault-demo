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