#Get-ExecutionPolicy -List
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#get-command -Module BcContainerHelper
Install-Module -Name BcContainerHelper -AllowClobber




#Uninstall-Module NavContainerHelper