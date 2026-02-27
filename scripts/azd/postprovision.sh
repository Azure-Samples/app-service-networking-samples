#!/usr/bin/env sh
set -eu

resource_group="${AZURE_RESOURCE_GROUP:-}"

if [ -z "$resource_group" ]; then
  echo "AZURE_RESOURCE_GROUP is not set. Run azd provision/up first." >&2
  exit 1
fi

deployment_name="$(az deployment group list --resource-group "$resource_group" --query "[?properties.provisioningState=='Succeeded'] | sort_by(@, &properties.timestamp)[-1].name" --output tsv)"

if [ -z "$deployment_name" ]; then
  echo "No successful deployment found in resource group '$resource_group'." >&2
  exit 1
fi

web_site_host_name="$(az deployment group show --resource-group "$resource_group" --name "$deployment_name" --query properties.outputs.webSiteHostName.value --output tsv)"

if [ -z "$web_site_host_name" ]; then
  echo "Failed to retrieve webSiteHostName from deployment outputs." >&2
  exit 1
fi

web_app_name="${web_site_host_name%%.*}"
principal_id="$(az webapp identity show --resource-group "$resource_group" --name "$web_app_name" --query principalId --output tsv)"

if [ -z "$principal_id" ]; then
  echo "Failed to retrieve managed identity principalId for web app '$web_app_name'." >&2
  exit 1
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
template_sql_path="$repo_root/deploy/mi.sql"
output_sql_path="$repo_root/deploy/dbuser.sql"

sed "s/accountName/$principal_id/g" "$template_sql_path" > "$output_sql_path"

echo "Generated SQL grant script: $output_sql_path"
echo "Execute the generated script against the sample SQL database to grant web app managed identity access."