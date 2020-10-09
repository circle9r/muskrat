![GitHub Logo](/images/muskrat-rodent-besides-a-river.jpg)
# PowerShell Scripts for Business Central

**run PowerShell as local Administrator**

## Install Docker
* Install-Module DockerMsftProvider -Force
* Install-Package Docker -ProviderName DockerMsftProvider -Force
* Restart-Computer

## Install navcontainerhelper
* get-command -Module navcontainerhelper
* Write-NavContainerHelperWelcomeText
* install-module navcontainerhelper -force
