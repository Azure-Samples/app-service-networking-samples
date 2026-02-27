$ErrorActionPreference = 'Stop'

$resourceGroup = $env:AZURE_RESOURCE_GROUP

if ([string]::IsNullOrWhiteSpace($resourceGroup)) {
  throw 'AZURE_RESOURCE_GROUP is not set. Run azd provision/up first.'
}

$deploymentName = az deployment group list --resource-group $resourceGroup --query "[?properties.provisioningState=='Succeeded'] | sort_by(@, &properties.timestamp)[-1].name" --output tsv

if ([string]::IsNullOrWhiteSpace($deploymentName)) {
  throw "No successful deployment found in resource group '$resourceGroup'."
}

$webSiteHostName = az deployment group show --resource-group $resourceGroup --name $deploymentName --query properties.outputs.webSiteHostName.value --output tsv

if ([string]::IsNullOrWhiteSpace($webSiteHostName)) {
  throw 'Failed to retrieve webSiteHostName from deployment outputs.'
}

$webAppName = $webSiteHostName.Split('.')[0]
$principalId = az webapp identity show --resource-group $resourceGroup --name $webAppName --query principalId --output tsv

if ([string]::IsNullOrWhiteSpace($principalId)) {
  throw "Failed to retrieve managed identity principalId for web app '$webAppName'."
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$templateSqlPath = Join-Path $repoRoot 'deploy\mi.sql'
$outputSqlPath = Join-Path $repoRoot 'deploy\dbuser.sql'

$content = Get-Content -Path $templateSqlPath -Raw
$content = $content.Replace('accountName', $principalId)
Set-Content -Path $outputSqlPath -Value $content

Write-Host "Generated SQL grant script: $outputSqlPath"
Write-Host 'Execute the generated script against the sample SQL database to grant web app managed identity access.'