

$serverInstance = ""  
$appDatabaseName = ""  
$tenantDatabaseName = ""  
$tenantId = ""  

### You should not need to modify any variables below this line ###  
  
# Create a new server instance for the requested tenant.  
New-NAVServerInstance -ServerInstance $tenantId -ManagementServicesPort 7045  
  
# Dismount the requested tenant from the multitenant server instance.  
Dismount-NAVTenant -ServerInstance $serverInstance -Tenant $tenantId  
  
# Remove any application tables from the tenant database if these were not already removed.  
Remove-NAVApplication -DatabaseName $tenantDatabaseName  
  
# Copy the application tables from the current application database to the tenant database.  
Export-NAVApplication -DatabaseName $appDatabaseName -DestinationDatabaseName $tenantDatabaseName  
  
# Reconfigure the CustomSettings.config file for the new server instance to use the tenant database.  
Set-NAVServerConfiguration -ServerInstance $tenantId -KeyName DatabaseName -KeyValue $tenantDatabaseName -WarningAction Ignore  
  
# Reconfigure the CustomSettings.config to use single-tenant mode.  
# Set-NAVServerConfiguration -ServerInstance $serverInstance -KeyName Multitenant -KeyValue false -WarningAction Ignore  
  
# Start the new server instance if it is not running.  
Set-NAVServerInstance -ServerInstance $tenantId -Start  
  
# Dismount all tenants on the new server instance that are not using the current tenant database.  
Get-NAVTenant -ServerInstance $tenantId | where { $_.Database -ne $tenantDatabaseName } | foreach { Dismount-NAVTenant -ServerInstance $tenantId -Tenant $_.Id }  
  
Write-Host "Operation complete." -foregroundcolor cyan  
  