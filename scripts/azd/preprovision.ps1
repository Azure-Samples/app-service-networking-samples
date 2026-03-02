$ErrorActionPreference = 'Stop'

function ConvertFrom-Base64Url {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Value
  )

  $padded = $Value.Replace('-', '+').Replace('_', '/')
  switch ($padded.Length % 4) {
    2 { $padded += '==' }
    3 { $padded += '=' }
  }

  $bytes = [Convert]::FromBase64String($padded)
  return [Text.Encoding]::UTF8.GetString($bytes)
}

$aadUsername = ''
$aadSid = ''

try {
  $tokenJson = azd auth token --output json | ConvertFrom-Json
  $accessToken = if ($tokenJson.token) { $tokenJson.token } else { [string]$tokenJson }

  if (-not [string]::IsNullOrWhiteSpace($accessToken)) {
    $parts = $accessToken.Split('.')
    if ($parts.Length -ge 2) {
      $claims = ConvertFrom-Base64Url -Value $parts[1] | ConvertFrom-Json
      $aadSid = [string]$claims.oid

      if (-not [string]::IsNullOrWhiteSpace($claims.upn)) {
        $aadUsername = [string]$claims.upn
      }
      elseif (-not [string]::IsNullOrWhiteSpace($claims.preferred_username)) {
        $aadUsername = [string]$claims.preferred_username
      }
    }
  }
}
catch {
}

if ([string]::IsNullOrWhiteSpace($aadUsername) -or [string]::IsNullOrWhiteSpace($aadSid)) {
  $aadUsername = az ad signed-in-user show --query userPrincipalName --output tsv
  $aadSid = az ad signed-in-user show --query id --output tsv
}

if ([string]::IsNullOrWhiteSpace($aadUsername) -or [string]::IsNullOrWhiteSpace($aadSid)) {
  throw 'Failed to resolve signed-in Azure AD user information. Run azd auth login first. If using Azure CLI fallback, run az login and ensure Microsoft Graph permissions are available.'
}

azd env set AAD_USERNAME $aadUsername
azd env set AAD_SID $aadSid

Write-Host "AAD values set in azd environment for user: $aadUsername"