FROM mcr.microsoft.com/powershell:7.0.0-rc.2-debian-buster-slim

RUN apt-get update && \
    apt-get install -y git && \
    apt-get install -y hub && \
    apt-get install -y curl

COPY Run.ps1 /

ENTRYPOINT [ "pwsh", "/Run.ps1" ]
