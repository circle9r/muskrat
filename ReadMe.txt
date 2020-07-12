

$credential = New-Object pscredential 'admin', (ConvertTo-SecureString -String 'P@ssword1' -AsPlainText -Force)
$dbcredentials = New-Object PSCredential -ArgumentList 'sa', $credential.Password
New-BCContainer `
    -accept_eula `
    -containerName $containerName `
    -imageName $imageName `
    -updateHosts `
    -auth UserPassword `
    -Credential $credential `
    -databaseServer 'host.containerhelper.internal' `
    -databaseInstance '' `
    -databaseName $DatabaseName `
    -databaseCredential $dbcredentials
    
New-NavContainerNavUser -containerName $containerName -Credential $credential -ChangePasswordAtNextLogOn:$false -PermissionSetId SUPER