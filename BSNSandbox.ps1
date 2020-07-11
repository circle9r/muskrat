#Set-Variable -Name password -Option Constant -Value ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force

function BCSandbox {
        [CmdletBinding()]
        param ($containerName, $imageName)
        $password = ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force
        $credential = New-Object PSCredential 'twbook', $password
        $licenseFile = 'D:\Binn\fin.flf'
                      
        New-BCContainer -accept_eula `
                -accept_outdated `
                -licenseFile $licenseFile `
                -imageName $imageName `
                -credential $credential `
                -updatehosts `
                -EnableTaskScheduler:$false `
                -containerName $containerName
}

function NAVSandbox {
        [CmdletBinding()]
        param ($containerName, $imageName)
        $password = ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force
        $credential = New-Object PSCredential 'twbook', password
        $licenseFile = 'D:\Binn\fin.flf'
        
        New-BCContainer -accept_eula -accept_outdated -includeCSide `
                -licenseFile $licenseFile `
                -credential $credential `
                -imageName $imageName `
                -containerName $containerName        
}

function Set-NewUser {
        [CmdletBinding()]
        param ($containerName, $userName, $userPassword, $authenticationEmail)
        
        $password = ConvertTo-SecureString -String $userPassword -AsPlainText -Force
        $credential = New-Object PSCredential $userName, $password

        New-BCContainerBCUser -Credential $credential `
                -AuthenticationEmail $authenticationEmail `
                -containerName $containerName `
                -ChangePasswordAtNextLogOn 0
}

function Import-Tests {
        [CmdletBinding()]
        param ($containerName)
        
        $password = ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force
        $credential = New-Object PSCredential 'twbook', $password 

        Import-TestToolkitToBCContainer -containerName $containerName -credential $credential 
}

function Get-Tests {
        [CmdletBinding()]
        param ($containerName)

        $password = ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force
        $credential = New-Object PSCredential 'twbook', $password
        $xunitResultsFile = "c:\programdata\navcontainerhelper\results.xml"
        $tests = Get-TestsFromBCContainer `
                -containerName $containerName `
                -credential $credential `
                -testSuite 'DEFAULT' `
                -ignoreGroups
        $first = $true
        $tests | ForEach-Object {
                Run-TestsInBCContainer `
                        -containerName $containerName `
                        -credential $credential `
                        -XUnitResultFileName $xunitResultsFile `
                        -AppendToXUnitResultFile:(!$first) `
                        -testCodeunit $_.Id
                $first = $false        
        }
}

#Get-NavContainerAppInfo -containerName 'BISON' -symbolsOnly
#Import-NavContainerLicense -licenseFile 'D:\Binn\fin.flf' -containerName $containername


# NAVSandbox TEST2 'mcr.microsoft.com/businesscentral/onprem:14.7.37609.0-na' 
# BCSandbox TEST2 'mcr.microsoft.com/businesscentral/onprem:14.7.37609.0-na' 
#Set-NewUser Test2 'hrbook' 'hrbook06' 'thomas.book@bison.com'
Import-Tests Bison