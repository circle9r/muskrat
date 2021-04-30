#Set-Variable -Name password -Option Constant -Value ConvertTo-SecureString -String "COREi5vPro0" -AsPlainText -Force
function Get-Artifact {
        # Write-Host -ForegroundColor Yellow "Get US sandbox artifact url for current version (Latest)"
        # Get-BCArtifactUrl -country "us"

        #Write-Host -ForegroundColor Yellow "Get all US sandbox artifact urls"
       # Get-BCArtifactUrl  -select All -version "16.0" -country "us"

        Write-Host -ForegroundColor Yellow "Get US sandbox artifact url for a version closest to " $MyImage
        Get-BCArtifactUrl -country "us" -version $MyImage -select Closest

        #Write-Host -ForegroundColor Yellow "Get latest 14.1 US sandbox artifact url"
        #Get-BCArtifactUrl -country "ch" -version "14.1" -select All

        #Write-Host -ForegroundColor Yellow "Get latest 15.x US sandbox artifact url"
        #Get-BCArtifactUrl -country "us" -version "15"

        #Write-Host -ForegroundColor Yellow "Get all North America NAV and Business Central artifact urls"
        #Get-BCArtifactUrl -country "us" -version "15"  -select All


}

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

        #Remove-CompanyInBCContainer -containerName $containerName -CompanyName 'CRONUS Mexico S.A.'
        #Remove-CompanyInBCContainer -containerName $containerName -CompanyName 'CRONUS Canada, Inc.'

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

        BCOn

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
                $artifactUrl = Get-BCArtifactUrl -country "us" -version $version -select closest
                New-BCContainer `
                        -accept_eula `
                        -containerName $containerName `
                        -artifactUrl $artifactUrl `
                        -Credential $credential `
                        -auth UserPassword `
                        -updateHosts

        }
}

New-Variable -name 'myUserName' -Value 'twbook' -Force
New-Variable -name 'myPassword' -Value "COREi5vPro0" -Force
New-Variable -Name 'licenseFile' -Visibility Public -Value 'C:\Binn\fin.flf' -Force
$version = '17.0.0.0'
$containerName = 'Bison'


NewBCSandboxFromArtifact $containerName $version
Import-BCContainerLicense -licenseFile $licenseFile -containerName $containerName -Verbose -restart
Set-NewUser  $containerName 'testuser' 'Bison01!' 'testuser@bisonok.com'
Import-Tests $containerName

#import-App $Name 'C:\binn\source\repos\condor\Bison\.alpackages\Rand Group_Bison Oilfield Services_1.1.0.88.app'
# Get-NavContainerAppInfo -containerName 'Bison' -symbolsOnly






