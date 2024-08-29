Azure Data Factory Integration Runtime in Windows Container Sample
=======
This repo contains the sample for running the Azure Data Factory Integration Runtime in Windows Container

Support SHIR version: 5.0 or later

For more information about Azure Data Factory, see [https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime](https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime)

# QuickStart
1. Prepare [Windows for containers](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce)
2. Build the Windows container image in the project folder
```bash
> docker build . -t <image-name> [--build-arg="INSTALL_JDK=true"]
```
### __Arguments list__
|Name|Necessity|Default|Description|
|---|---|---|---|
| `INSTALL_JDK` | Optional | `false` | The flag to install Microsoft's JDK 11 LTS. |
3. Run the container with specific arguments by passing environment variables
```bash
> docker run -d -e AUTH_KEY=<ir-authentication-key> \
    [-e NODE_NAME=<ir-node-name>] \
    [-e ENABLE_HA={true|false}] \
    [-e HA_PORT=<port>] \
    [-e ENABLE_AE={true|false}] \
    [-e AE_TIME=<expiration-time-in-seconds>] \
    [-e TZ=<time-zone-name>] \
    <image-name>
```
### __Arguments list__
|Name|Necessity|Default|Description|
|---|---|---|---|
| `AUTH_KEY` | Required | | The authentication key for the self-hosted integration runtime. |
| `NODE_NAME` | Optional | `hostname` | The specified name of the node. |
| `ENABLE_HA` | Optional | `false` | The flag to enable high availability and scalability.<br/> It supports up to 4 nodes registered to the same IR when `HA` is enabled, otherwise only 1 is allowed. If set to true and in a kubernetes cluster - consider setting [spec.template.spec.dnsConfig.searches](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#hostname-and-name-resolution) to `service`.`namespace`.`svc.cluster.local` to allow intra-pod communications |
| `HA_PORT` | Optional | `8060` | The port to set up a high availability cluster. |
| `ENABLE_AE` | Optional | `false` | The flag to enable offline nodes auto-expiration.<br/> If enabled, the node will be marked as expired when it has been offline for timeout duration defined by `AE_TIME`. |
| `AE_TIME` | Optional | `600` |  The expiration timeout duration for offline nodes in seconds. <br/>Should be no less than 600 (10 minutes). |
| `TZ` | Optional | `UTC` | Valid values can be found as Id from the command `Get-TimeZone -List` |

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
