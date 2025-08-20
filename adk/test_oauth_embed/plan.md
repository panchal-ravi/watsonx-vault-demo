# create a local website using python to test watsonx embedded workflow  

* embed this script to test

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

