FROM mcr.microsoft.com/powershell:7.0.0-rc.2-debian-buster-slim

RUN apt-get update && \
    apt-get install -y git && \
    apt-get install -y hub

COPY UpdateMono.ps1 /

ENTRYPOINT [ "pwsh", "/UpdateMono.ps1" ]
