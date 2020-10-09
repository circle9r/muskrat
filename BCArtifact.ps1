

function Get-Artifact {
    # Write-Host -ForegroundColor Yellow "Get US sandbox artifact url for current version (Latest)"
    # Get-BCArtifactUrl -country "us"

    #Write-Host -ForegroundColor Yellow "Get all US sandbox artifact urls"
    #Get-BCArtifactUrl  -select All -version "16.0" -country "us"

    Write-Host -ForegroundColor Yellow "Get US sandbox artifact url for a version closest to " $MyImage
    Get-BCArtifactUrl -country "us" -version $MyImage -select Closest

    # Write-Host -ForegroundColor Yellow "Get latest 16.1 US sandbox artifact url"
    # Get-BCArtifactUrl -country "us" -version "16.1"

    #Write-Host -ForegroundColor Yellow "Get latest 15.x US sandbox artifact url"
    #Get-BCArtifactUrl -country "us" -version "15"

    #Write-Host -ForegroundColor Yellow "Get all North America NAV and Business Central artifact urls"
    #Get-BCArtifactUrl -country "us" -version "15"  -select All

}

function Get-NavArtifact {
    Write-Host -ForegroundColor Yellow "Get latest NA onprem artifact Url"
    Get-BCArtifactUrl -country 'na' -type OnPrem -version $MyImage  -select Closest
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




#System Application
$MyImage = '16.5.15897.17019'
Get-NavArtifact


Download-Artifacts -artifactUrl "https://bcartifacts.azureedge.net/onprem/16.5.15897.15953/na" -includePlatform -basePath "C:\Artifacts\"
#Download-Artifacts -artifactUrl "https://bcartifacts.azureedge.net/sandbox/15.4.41023.43755/us" -basePath "C:\Artifacts\"  -includePlatform
#Get-Artifact

#Download-Artifacts -artifactUrl "https://bcartifacts.azureedge.net/onprem/16.3.14085.14238/us" -basePath "D:\Artifacts\"  -includePlatform
