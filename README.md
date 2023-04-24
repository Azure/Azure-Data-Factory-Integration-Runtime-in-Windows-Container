Azure Data Factory Integration Runtime in Windows Container Sample
=======
This repo contains the sample for running the Azure Data Factory Integration Runtime in Windows Container

Support SHIR version: 5.0 or later

For more information about Azure Data Factory, see [https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime](https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime)

# QuickStart
1. Prepare [Windows for containers](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce)
2. Build the Windows container image in the project folder
```bash 
> docker build . -t <image-name>
```
3. Run the container with specific arguments by passing environment variables
```bash
> docker run -d -e AUTH_KEY=<ir-authentication-key> \
    [-e NODE_NAME=<ir-node-name>] \
    [-e ENABLE_HA={true|false}] \
    [-e HA_PORT=<port>] \
    [-e ENABLE_AE={true|false}] \
    [-e AE_TIME=<expiration-time-in-seconds>] \
    <image-name>
```
### __Arguments list__
|Name|Description|Default
|---|---|---|
| `AUTH_KEY` | Required, the authentication key for the self-hosted integration runtime. | None
| `NODE_NAME` | Optional, the specified name of the node. | hostname |
| `ENABLE_HA` | Optional, the flag to enable high availability. | false |
| `HA_PORT` | Optional, the port for high availability. | 8060 |
| `ENABLE_AE` | Optional, the flag to enable offline nodes auto-expiration.<br/> Only works when `ENABLE_HA=true`. | false |
| `AE_TIME` | Optional, the expiration time for offline nodes in seconds. <br/>Should be no less than 600. | 600 | 

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
