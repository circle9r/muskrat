#Set-Variable -Name password -Option Constant -Value ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force

function New-BCSandbox {
        [CmdletBinding()]
        param ($containerName, $imageName)
                      
        New-BCContainer -accept_eula `
                -accept_outdated `
                -licenseFile $licenseFile `
                -imageName $imageName `
                -credential $credential `
                -updatehosts `
                -EnableTaskScheduler:$false `
                -containerName $containerName

        Move-Shortcuts($containerName)
}

function New-BCSandbox-HostSQL {
        [CmdletBinding()]
        param ($containerName, $imageName)

        $DatabaseName = 'BC_BSN_DEV'

        New-BCContainer `
                -accept_eula `
                -accept_outdated `
                -containerName $containerName `
                -imageName $imageName `
                -updateHosts `
                -credential $credential `
                -databaseServer 'congo' `
                -databaseInstance 'SQL2019' `
                -databaseName 'Financialsus' `
                -databaseCredential $dbcredentials
    
        #New-NavContainerNavUser -containerName $containerName -Credential $credential -ChangePasswordAtNextLogOn:$false -PermissionSetId SUPER
        Move-Shortcuts($containerName)
}


function New-NAVSandbox {
        [CmdletBinding()]
        param ($containerName, $imageName)
        
        New-NavContainer -accept_eula -accept_outdated -includeCSide `
                -licenseFile $licenseFile `
                -credential $credential `
                -imageName $imageName `
                -containerName $containerName

        Move-Shortcuts($containerName)        
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

        Move-Shortcuts($containerName)
}

function Import-Tests {
        [CmdletBinding()]
        param ($containerName)
        
        Import-TestToolkitToBCContainer -containerName $containerName -credential $credential 
}

function  Import-App {
        param ($containerName, $appFullPathFile)        

        $containerName = 'Bison'
        $rootPath = 'D:\Repos\Bison\.alpackages\Rand Group_Bison Oilfield Services_1.1.0.82.app'

        Publish-NavContainerApp -containerName $containerName `
                -appFile $appFullPathFile `
                -install `
                -sync `
                -skipVerification `
                -syncMode ForceSync `
                -useDevEndpoint `
                -credential $credential

}

function Move-Shortcuts {
        param ($containerName)

        $desktopPath = [environment]::getfolderpath('Desktop')
        $lnkWebFile = $desktopPath + '\' + $containerName + ' Web Client.lnk'
        $lnkCommandFile = $desktopPath + '\' + $containerName + ' Command Prompt.lnk'
        $lnkPowerShellFile = $desktopPath + '\' + $containerName + ' PowerShell Prompt.lnk'

        $destination = $desktopPath + '\Docker Shortcuts\' + $containerName

        New-Item -Path $destination -ItemType Directory -Force
        if (Test-Path -Path $lnkWebFile) {
                Move-Item -Path $lnkWebFile -Destination $destination -Force
        }
        if (Test-Path -Path $lnkCommandFile) {
                Move-Item -Path $lnkCommandFile -Destination $destination -Force
        }
        if (Test-Path -Path $lnkPowerShellFile) {
                Move-Item -Path $lnkPowerShellFile -Destination $destination -Force
        }
}


function Get-Tests {
        [CmdletBinding()]
        param ($containerName)

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

$password = ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force
$cred = New-Object PSCredential 'twbook', $password

New-Variable -Name 'licenseFile' -Visibility Public -Value 'D:\Binn\fin.flf' -Force
New-Variable -Name 'credential' -Visibility Public -Value $cred -Force

#Get-NavContainerAppInfo -containerName 'BISON' -symbolsOnly
#Import-NavContainerLicense -licenseFile 'D:\Binn\fin.flf' -containerName $containername

# NAVSandbox TEST2 'mcr.microsoft.com/businesscentral/onprem:14.7.37609.0-na' 
# BCSandbox TEST2 'mcr.microsoft.com/businesscentral/onprem:14.7.37609.0-na' 
New-BCSandbox Bison15 'mcr.microsoft.com/businesscentral/onprem:15.4.41023.41345-na'
#Set-NewUser Test2 'hrbook' 'hrbook06' 'thomas.book@bison.com'
#Import-Tests Bison
#Import-App Bison 'D:\Repos\Bison\.alpackages\Rand Group_Bison Oilfield Services_1.1.0.82.app'
#New-BCSandbox-HostSQL Bison2 'mcr.microsoft.com/businesscentral/sandbox:15.4.41023.43755-us'
