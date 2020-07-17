

function Get-Artifact {
    # Write-Host -ForegroundColor Yellow "Get US sandbox artifact url for current version (Latest)"
    # Get-BCArtifactUrl -country "us"

    #Write-Host -ForegroundColor Yellow "Get all US sandbox artifact urls"
    #Get-BCArtifactUrl  -select All -version "16.0" -country "us"

    Write-Host -ForegroundColor Yellow "Get US sandbox artifact url for a version closest to 16.0.11240.12188"
    Get-BCArtifactUrl -country "us" -version "16.0.11240.12188" -select Closest

    # Write-Host -ForegroundColor Yellow "Get latest 16.1 US sandbox artifact url"
    # Get-BCArtifactUrl -country "us" -version "16.1"

    #Write-Host -ForegroundColor Yellow "Get latest 15.x US sandbox artifact url"
    #Get-BCArtifactUrl -country "us" -version "15"

    #Write-Host -ForegroundColor Yellow "Get all North America NAV and Business Central artifact urls"
    #Get-BCArtifactUrl -country "us" -version "15"  -select All
    
}

function Get-NavArtifact {
    [CmdletBinding()]
    param ($navVersion, $countryCode)

    Write-Host -ForegroundColor Yellow "Get all NAV " + $navVersion + " " + $countryCode + " artifact Urls"
    (Get-NavArtifactUrl -nav 2017 -country $countryCode -select all).count

    Write-Host -ForegroundColor Yellow "Get latest NA onprem artifact Url"
    Get-BCArtifactUrl -country $countryCode -type OnPrem
}


function FunctionName {
    
    PS c:\temp> Download-Artifacts -artifactUrl (Get-BCArtifactUrl -country "us") -includePlatform

    Downloading application artifact /sandbox/16.2.13509.14082/us
    Downloading C:\Users\freddyk\AppData\Local\Temp\9f550271-a1c8-4125-96c5-2b781e2b9a3e.zip
    Unpacking application artifact
    c:\bcartifacts.cache\sandbox\16.2.13509.14082\us
    https://bcartifacts.azureedge.net/sandbox/16.2.13509.14082/platform
    Downloading platform artifact /sandbox/16.2.13509.14082/platform
    Downloading C:\Users\freddyk\AppData\Local\Temp\45959ba6-b934-470f-9603-8867135a3dcd.zip
    Unpacking platform artifact
    Downloading Prerequisite Components
    Downloading c:\bcartifacts.cache\sandbox\16.2.13509.14082\platform\Prerequisite Components\Open XML SDK 2.5 for Microsoft Office\OpenXMLSDKv25.msi
    Downloading c:\bcartifacts.cache\sandbox\16.2.13509.14082\platform\Prerequisite Components\Microsoft Report Viewer 2015\ReportViewer.msi
    Downloading c:\bcartifacts.cache\sandbox\16.2.13509.14082\platform\Prerequisite Components\IIS URL Rewrite Module\rewrite_2.0_rtw_x64.msi
    Downloading c:\bcartifacts.cache\sandbox\16.2.13509.14082\platform\Prerequisite Components\Microsoft Report Viewer 2015\SQLSysClrTypes.msi
    c:\bcartifacts.cache\sandbox\16.2.13509.14082\platform
}

function Get-Image {
    param ($version)
    $artifactUrl = Get-BCArtifactUrl -country 'us' -version $version
    New-BcImage -artifactUrl $artifactUrl -imageName myownimage:latest
    docker images
    docker inspect myownimage:latest
}


function FunctionName {

    Remove-NavContainer test
    Measure-Command {
        $artifactUrl = Get-BCArtifactUrl -version 16.1 -select Latest -country us
        $credential = New-Object pscredential 'admin', (ConvertTo-SecureString -String 'P@ssword1' -AsPlainText -Force)
        New-NavContainer `
            -accept_eula `
            -containerName test `
            -artifactUrl $artifactUrl `
            -Credential $credential `
            -auth UserPassword `
            -updateHosts `
            -imagename myown
    }
}


MyImage -version '16.0.11240.12188'
#Get-NavArtifact(2017, 'na')

#Download-Artifacts -artifactUrl (Get-BCArtifactUrl -country "us") -includePlatform
#Download-Artifacts -artifactUrl "https://bcartifacts.azureedge.net/sandbox/15.4.41023.43755/us" -basePath "D:\Artifacts\"  -includePlatform
#Get-Artifact

