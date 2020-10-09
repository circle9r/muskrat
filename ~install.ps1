#Get-ExecutionPolicy -List
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
get-command -Module navcontainerhelper
Install-Module -Name navcontainerhelper -Force
Write-NavContainerHelperWelcomeText