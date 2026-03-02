#!/usr/bin/env sh
set -eu

aad_username=""
aad_sid=""

if token_raw="$(azd auth token --output json 2>/dev/null)"; then
  claims_json="$(python -c 'import sys, json, base64
raw=sys.stdin.read().strip()
try:
    obj=json.loads(raw)
    token=obj.get("token", raw)
except Exception:
    token=raw
parts=token.split(".")
if len(parts) < 2:
    print("{}")
    raise SystemExit(0)
payload=parts[1] + "=" * (-len(parts[1]) % 4)
decoded=base64.urlsafe_b64decode(payload.encode("utf-8")).decode("utf-8")
print(decoded)
' <<EOF
$token_raw
EOF
)"
  aad_sid="$(python -c 'import json,sys
claims=json.loads(sys.stdin.read() or "{}")
print(claims.get("oid", ""))
' <<EOF
$claims_json
EOF
)"
  aad_username="$(python -c 'import json,sys
claims=json.loads(sys.stdin.read() or "{}")
print(claims.get("upn") or claims.get("preferred_username") or "")
' <<EOF
$claims_json
EOF
)"
fi

if [ -z "$aad_username" ] || [ -z "$aad_sid" ]; then
  aad_username="$(az ad signed-in-user show --query userPrincipalName --output tsv)"
  aad_sid="$(az ad signed-in-user show --query id --output tsv)"
fi

if [ -z "$aad_username" ] || [ -z "$aad_sid" ]; then
  echo "Failed to resolve signed-in Azure AD user information. Run azd auth login first. If using Azure CLI fallback, run az login and ensure Microsoft Graph permissions are available." >&2
  exit 1
fi

azd env set AAD_USERNAME "$aad_username"
azd env set AAD_SID "$aad_sid"

echo "AAD values set in azd environment for user: $aad_username"