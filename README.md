# App Service Networking Samples

This project contains a sample setup for playing with Azure App Service networking features.

## Features

This project provides the following features:

- Base setup for a web application and database.
- VNet with several subnets.
- Application gateway installed in the application gateway subnet and with a public IP address associated to it, and a backend pool for the web app.
- Azure Front Door service with a backend pool for the web app.
- Walkthroughs of several networking setups and explanation for Azure App Service.

The below drawing illustrates this setup:

![Initial setup](media/initial%20setup.svg)

## Getting Started

### Prerequisites

- An Azure Account.
- (Optional) A fork of this GitHub repository in your own account and with the capability of executing GitHub actions (public repository access is needed for this).
- The latest [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) version installed. Azure Cloud Shell can also be used as an alternative for the script steps in case Azure CLI is not installed.

### Installation

#### Option 1: Using GitHub Actions

The below walkthrough contains the steps for creating a resource group in Azure and the steps needed to set up your deployment secret in your GitHub repository.

1. In a command prompt or in Azure Cloud Shell, define environment variables.

    ```bash
    RESOURCE_GROUP='appsvcnetworkingdemo'
    LOCATION=westus
    ```

1. Login to your Azure account and make sure the correct subscription is active.

    ```bash
    az login
    az account list -o table
    az account set <your-subscription-id>
    ```

1. Create a resource group for all necessary resources.

    ```bash
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```

1. Copy the resource group ID which is outputted in the previous step to a new environment variable.

    ```bash
    RESOURCE_GROUP_ID=<resource group ID from previous output>
    ```

1. Create a service principal and give it access to the resource group.

    ```bash
    az ad sp create-for-rbac \
      --name appsvcnetworkingdemo \
      --role Contributor \
      --scopes $RESOURCE_GROUP_ID \
      --sdk-auth
    ```

1. Copy the full output from this command.

1. In your GitHub repo navigate to *Settings* > *Secrets* and select *New Repository Secret*.

1. Name the secret *AZURE_CREDENTIALS* and paste the output from the 'az ad sp create-for-rbac' command in the value textbox.

1. Select *Add Secret*.

1. In your command prompt, query the object id for your user account:

    ```bash
    az ad user show --id <accountname@domain.extension> --query objectId -o tsv
    ```

1. In your GitHub repo add an additional secret: *AAD_USERNAME* and give it the value of your username accountname@domain.extension.  

1. In your GitHub repo add an additional secret: *AAD_SID* and give it the value of the object id you just obtained.  

1. Inspect the [infradeploy.yml](.github/workflows/infradeploy.yml) file and update any environment variables at the top of the file to reflect your environment.

1. In your GitHub repo, navigate to *Actions* and select the *deploy-app-svc-networking-sample* action.

    **NOTE:** In case you see a message that says *Workflows aren't being run on this forked repository*, select the *I understand my workflows, go ahead and enable them* button.

1. Select *Run workflow* > *Run workflow*.

1. This will start a new workflow run and deploy the necessary infrastructure.

1. Double check in the Azure Portal that all resources got deployed correctly and are up and running.

1. In the Azure Portal in your resource group, navigate to the *Deployments* menu. Select the last deployment and next select *outputs*.

1. Copy the value of the *principalId* value.

1. In the Azure Portal, navigate to the *sample* SQL database and open *Query Editor*.

1. Select *Login as your username*.

1. Copy the sql script from [mi.sql](deploy/mi.sql) in the query editor window and replace each instance of the *accountName* by the *principalId* value you just copied.

1. Execute the script.

To check whether the installation was done correctly:

1. In the Azure portal, navigate to the App Service that got deployed.

1. Select the URL of the App Service to navigate to the web application. The application will display info on your incoming request, configuration of the app, environment variables, ...

1. Select the *SQL* menu tab at the top of the application. This will display a page for connecting to a backend database.

1. Select *Submit*. This should give you a response on the same page with an access token and an output indicating you successfully logged in to the database by using a managed identity and from a public IP address.

#### Option 2: Deploy directly from your workstation

You can use the bash script below to deploy the necessary resources directly from your workstation using the Azure CLI.

This script also generates a `dbuser.sql` file which you can use to grant the managed identity of the web app access to the database (for example, using sqlcmd or the SQL query editor in the Azure portal).

```bash
#!/bin/bash

# Define parameters.
RESOURCE_GROUP=appsvcnetworkingdemo
LOCATION=westus
SUBSCRIPTION_ID=<YOUR SUBSCRIPTION ID>

# Log in.
az login

az account list -o table
az account set -s $SUBSCRIPTION_ID

# Create the deployment resource group.
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Download the deployment bicep file (Azure CLI cannot deploy remote bicep files today).
wget https://raw.githubusercontent.com/Azure-Samples/app-service-networking-samples/main/deploy/main.bicep

# Get current user information for setting up SQL admin.
AAD_USERNAME=$(az ad signed-in-user show --query userPrincipalName --output tsv)
AAD_SID=$(az ad signed-in-user show --query id --output tsv)

# Deploy the bicep file.
az deployment group create \
  --name $RESOURCE_GROUP \
  --resource-group $RESOURCE_GROUP \
  --template-file ./main.bicep \
  --parameters name=$RESOURCE_GROUP aadUsername=$AAD_USERNAME aadSid=$AAD_SID

# Retrieve the name of the App Service managed identity.
APPSVC_IDENTITY=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $RESOURCE_GROUP \
  --query properties.outputs.principalId.value --output tsv)

# Create a SQL file to execute on the database which grants access to the App Service managed identity.
cat <<EOT> dbuser.sql
CREATE USER [$APPSVC_IDENTITY] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$APPSVC_IDENTITY];
ALTER ROLE db_datawriter ADD MEMBER [$APPSVC_IDENTITY];
ALTER ROLE db_ddladmin ADD MEMBER [$APPSVC_IDENTITY];
GO;
EOT

# Optional: allow the local IP address to pass through the SQL firewall.
SQLSERVER_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $RESOURCE_GROUP \
  --query properties.outputs.sqlserverName.value --output tsv)
LOCAL_IP="`wget -qO- http://ipinfo.io/ip`"
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQLSERVER_NAME \
  --name AllowLocalIP \
  --start-ip-address $LOCAL_IP \
  --end-ip-address $LOCAL_IP

# MANUAL ACTION:
# Use sqlcmd or the SQL query editor in the Azure portal to execute the above SQL file on the database.
```

## Demos

These demos work best if you follow them one by one. They walk you through a full setup going from using out of the box networking to the option you have for extra locking down app service for incoming requests and next for outgoing requests.

1. [Out of the Box Networking](demos/01_outofthebox.md)

### Locking down incoming traffic

1. [Access/IP Restrictions](demos/02_IPrestrictions.md)
1. [Service Endpoints](demos/03_serviceendpoints.md)
1. [Private Link](demos/04_privatelink.md)

### Locking down outgoing traffic

1. [Hybrid Connections](demos/05_Hybirdconnections.md)
1. [Gateway required VNet integration](demos/06_GWrequiredVNetintegration.md)
1. [(Regional) VNet integration](demos/07_RegionalVNetintegration.md)

### Special case

1. [ASEv3](demos/08_ASEv3.md)

## Resources

### Azure Architecture Center

- [Web app private connectivity to Azure SQL database](https://docs.microsoft.com/azure/architecture/example-scenario/private-web-app/private-web-app)
- [Multi-region web app with private connectivity to database](https://docs.microsoft.com/azure/architecture/example-scenario/sql-failover/app-service-private-sql-multi-region)

### App Service Docs

- [App Service networking features](https://docs.microsoft.com/azure/app-service/networking-features)
- [Inbound and outbound IP addresses in Azure App Service](https://docs.microsoft.com/azure/app-service/overview-inbound-outbound-ips)
- [Regional VNet integration](https://docs.microsoft.com/azure/app-service/web-sites-integrate-with-vnet#regional-vnet-integration)
- [App Service private endpoints](https://docs.microsoft.com/azure/app-service/networking/private-endpoint)
- [Hybrid connections](https://docs.microsoft.com/azure/app-service/app-service-hybrid-connections)

### WAF

- [Application Gateway overview](https://docs.microsoft.com/azure/application-gateway/overview)
- [Azure Front Door overview](https://docs.microsoft.com/azure/frontdoor/front-door-overview)
- [WAF overview](https://docs.microsoft.com/azure/web-application-firewall/overview)
- [Application Gateway integration with service endpoints](https://docs.microsoft.com/azure/app-service/networking/app-gateway-with-service-endpoints)
- [Front Door FDID header](https://docs.microsoft.com/azure/frontdoor/front-door-faq#how-do-i-lock-down-the-access-to-my-backend-to-only-azure-front-door-)

### Azure SQL Docs

- [How to set up Private Link for Azure SQL Database](https://docs.microsoft.com/azure/azure-sql/database/private-endpoint-overview#how-to-set-up-private-link-for-azure-sql-database)
- [Azure SQL Firewall](https://docs.microsoft.com/azure/azure-sql/database/firewall-create-server-level-portal-quickstart)

### Networking

- [Integrate Azure services with virtual networks for network isolation](https://docs.microsoft.com/azure/virtual-network/vnet-integration-for-azure-services)
- [Private link resources](https://docs.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource)
- [Virtual Network service endpoints](https://docs.microsoft.com/azure/virtual-network/virtual-network-service-endpoints-overview)
- [Azure Private Link frequently asked questions (FAQ)](https://docs.microsoft.com/azure/private-link/private-link-faq#what-is-the-difference-between-a-service-endpoints-and-a-private-endpoints)
- [Azure Private Endpoint DNS configuration](https://docs.microsoft.com/azure/private-link/private-endpoint-dns)
- [Private Endpoint DNS Integration Scenarios](https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-Scenarios)
