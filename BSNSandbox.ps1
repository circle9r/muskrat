#Set-Variable -Name password -Option Constant -Value ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force

function New-BCSandbox {
        [CmdletBinding()]
        param ($containerName, $imageName)
        $password = ConvertTo-SecureString -String $myPassword -AsPlainText -Force
        $credential = New-Object PSCredential $myUserName, $password
                
        Write-Host -ForegroundColor Yellow 'My Credential: ' $credential.UserName
        Write-Host -ForegroundColor Yellow 'Container: : ' $containerName

        New-BCContainer -accept_eula `
                -accept_outdated `
                -licenseFile $licenseFile `
                -imageName $imageName `
                -auth NavUserPassword `
                -credential $credential `
                -updatehosts `
                -EnableTaskScheduler:$false `
                -containerName $containerName
                
        Remove-CompanyInBCContainer -containerName $containerName -CompanyName 'CRONUS Mexico S.A.'
        Remove-CompanyInBCContainer -containerName $containerName -CompanyName 'CRONUS Canada, Inc.'

        Move-Shortcuts($containerName)

        Write-Host -ForegroundColor Yellow 'Container Created: : ' $containerName
}

function New-BCSandbox-HostSQL {
        [CmdletBinding()]
        param ($containerName, $imageName)
        $password = ConvertTo-SecureString -String $myPassword -AsPlainText -Force
        $credential = New-Object PSCredential $myUserName, $password
                
        Write-Host -ForegroundColor Yellow 'My Credential: ' $credential.UserName
        Write-Host -ForegroundColor Yellow 'Container: : ' $containerName

        $DatabaseName = 'BC_BSN_DEV'

        New-BCContainer `
                -accept_eula `
                -accept_outdated `
                -containerName $containerName `
                -imageName $imageName `
                -updateHosts `
                -auth NavUserPassword `
                -credential $credential `
                -databaseServer 'congo' `
                -databaseInstance 'SQL2019' `
                -databaseName 'Financialsus' `
                -databaseCredential $dbcredentials
    
        #New-NavContainerNavUser -containerName $containerName -Credential $credential -ChangePasswordAtNextLogOn:$false -PermissionSetId SUPER
        Move-Shortcuts($containerName)

        Write-Host -ForegroundColor Yellow 'Container Created: : ' $containerName
}

function New-NAVSandbox {
        [CmdletBinding()]
        param ($containerName, $imageName)
        $password = ConvertTo-SecureString -String $myPassword -AsPlainText -Force
        $credential = New-Object PSCredential $myUserName, $password
                
        Write-Host -ForegroundColor Yellow 'My Credential: ' $credential.UserName
        Write-Host -ForegroundColor Yellow 'Container: : ' $containerName
        
        New-NavContainer `
                -accept_eula `
                -accept_outdated `
                -includeCSide `
                -auth NavUserPassword `
                -licenseFile $licenseFile `
                -credential $credential `
                -imageName $imageName `
                -containerName $containerName

        Move-Shortcuts($containerName)        

        Remove-CompanyInBCContainer -containerName $containerName -CompanyName 'CRONUS Mexico S.A.'
        Remove-CompanyInBCContainer -containerName $containerName -CompanyName 'CRONUS Canada, Inc.'

        Move-Shortcuts($containerName)

        Write-Host -ForegroundColor Yellow 'Container Created: : ' $containerName
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
        $password = ConvertTo-SecureString -String $myPassword -AsPlainText -Force
        $credential = New-Object PSCredential $myUserName, $password
        
        Import-TestToolkitToBCContainer -containerName $containerName -credential $credential 
}

function  Import-App {
        param ($containerName, $appFullPathFile)        
        $password = ConvertTo-SecureString -String $myPassword -AsPlainText -Force
        $credential = New-Object PSCredential $myUserName, $password
 
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
                Move-Item -Path $lnkWebFile -Destination $destination -Force -
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
        
function NewBCSandboxFromArtifact {
        param ($containerName, $version)
        $password = ConvertTo-SecureString -String $myPassword -AsPlainText -Force
        $credential = New-Object PSCredential $myUserName, $password
        
        Remove-NavContainer $containerName
        Measure-Command {
            $artifactUrl = Get-BCArtifactUrl -version $version -select Latest -country us            
            New-BCContainer `
                -accept_eula `
                -containerName $containerName `
                -artifactUrl $artifactUrl `
                -Credential $credential `
                -auth UserPassword `
                -updateHosts `
                -imagename myown
        }
}

New-Variable -name 'myUserName' -Value 'twbook' -Force
New-Variable -name 'myPassword' -Value "COREi5vPro0" -Force
New-Variable -Name 'licenseFile' -Visibility Public -Value 'D:\Binn\fin.flf' -Force

#$MyImage = '16.3.14085.14287'
#Import-Tests Bison
#NewBCSandboxFromArtifact wombat '16.3'

#New-BCSandbox Bison 'mcr.microsoft.com/businesscentral/onprem:16.3.14085.14238-na'
#Import-App -containerName Bison -appFullPathFile 'D:\Repos\condor\Bison\.alpackages\Rand Group_Bison Oilfield Services_1.1.0.87.app'

Set-NewUser wombat 'hrbook' 'hrbook06' 'thomas.book@bisonok.com'

#Get-NavContainerAppInfo -containerName 'BISON' -symbolsOnly
Import-NavContainerLicense -licenseFile 'D:\Binn\fin.flf' -containerName wombat



