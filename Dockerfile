FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Download the latest self-hosted integration runtime installer into the SHIR folder
COPY SHIR C:/SHIR/

RUN curl -L 'https://go.microsoft.com/fwlink/?linkid=839822&clcid=0x409' --output C:/SHIR/SHIR.msi

RUN ["powershell", "C:/SHIR/build.ps1"]

ENTRYPOINT ["powershell", "C:/SHIR/setup.ps1"]

ENV SHIR_WINDOWS_CONTAINER_ENV True

HEALTHCHECK --start-period=120s CMD ["powershell", "C:/SHIR/health-check.ps1"]
