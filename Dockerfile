FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Download the latest self-hosted integration runtime installer into the SHIR folder
COPY SHIR C:/SHIR/

ADD https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.17.8186.1.msi C:/SHIR/

RUN ["powershell", "C:/SHIR/build.ps1"]

ENTRYPOINT ["powershell", "C:/SHIR/setup.ps1"]

ENV SHIR_WINDOWS_CONTAINER_ENV True

HEALTHCHECK --start-period=120s CMD ["powershell", "C:/SHIR/health-check.ps1"]
