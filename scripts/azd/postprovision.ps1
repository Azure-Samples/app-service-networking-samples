$ErrorActionPreference = 'Stop'

$resourceGroup = $env:AZURE_RESOURCE_GROUP

$webSiteHostName = $env:webSiteHostName

if ([string]::IsNullOrWhiteSpace($webSiteHostName)) {
  throw 'Failed to retrieve webSiteHostName from deployment outputs.'
}

$webAppName = $webSiteHostName.Split('.')[0]
$principalId = $env:principalId

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