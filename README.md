# Project Name

This project contains a sample setup for playing with Azure App Service networking features. 

## Features

This project provides the following features:

* Base setup for a web application and database. It also contains the following components for the walkthroughs: 
  * VNet with several subnets.
  * Application gateway installed in the application gateway subnet and with a public IP address associated to it. 
  * Azure Front Door service.

The below drawing illustrates this setup: 

![Initial setup](media/initial%20setup.svg)

* Walkthroughs of several networking setups and explanation for Azure App Service. 

## Getting Started

### Prerequisites

- Azure Account
- A fork of this GitHub repository in your own account and with the capability of executing GitHub actions (public repository access is needed for this)
- latest [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version installed. Azure Cloud Shell can also be used as an alternative for the script steps in case Azure CLI is not installed. 

### Installation

The below walk-through contains the steps for creating a resource group in Azure and the steps needed to set up your deployment secret in your GitHub repository. 
You will need the latest version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed to execute these steps.

1. In a command prompt, define environment variables.

```bash
RESOURCE_GROUP='appsvcnetworkingdemo'
LOCATION=westus
```

1. Login to your Azure account and make sure the correct subscription is active. 

```azurecli
az login
az account list -o table
az account set <your-subscription-id>
```

1. Create a resource group for all necessary resources.

```azurecli
az group create --name $RESOURCE_GROUP --location $LOCATION
```

1. Copy the resource group ID which is outputted in the previous step to a new environment variable.

```azurecli
RESOURCE_GROUP_ID=<resource group ID from previous output>
```

1. Create a service principal and give it access to the resource group.

```azure cli
az ad sp create-for-rbac \
  --name appsvcnetworkingdemo \
  --role Contributor \
  --scopes $RESOURCE_GROUP_ID \
  --sdk-auth
```

1. Copy the full output from this command. 

1. In your GitHub repo navigate to *Settings* > *Secrets* and select *New Repository Secret*.

1. Name the secret _AZURE_CREDENTIALS_ and paste the output from the 'az ad sp create-for-rbac' command in the value textbox.

1. Select *Add Secret*.

1. In your command prompt, query the object id for your user account: 

```azure cli
az ad user show --id <accountname@domain.extension> --query objectId -o tsv
```

1. In your GitHub repo add an additional secret: _AAD_USERNAME_ and give it the value of your username accountname@domain.extension.  

1. In your GitHub repo add an additional secret: _AAD_SID_ and give it the value of the object id you just obtained.  

1. Inspect the [infradeploy.yml](.github/workflows/infradeploy.yml) file and update any environment variables at the top of the file to reflect your environment. 

1. In your GitHub repo, navigate to *Actions* and select the *deploy-app-svc-networking-sample* action. 

1. Select *Run workflow* > *Run workflow*. 

1. This will start a new workflow run and deploy the necessary infrastructure. 

1. Double check in the Azure Portal that all resources got deployed correctly and are up and running. 

1. In the Azure Portal in your resource group, navigate to the _Deployments_ menu. Select the last deployment and next select _outputs_. 

1. Copy the value of the _principalId_ value.

1. In the Azure Portal, navigate to the _sample_ SQL database and open _Query Editor_.

1. Select _Login as your username_.

1. Copy the sql script from [mi.sql](deploy/mi.sql) in the query editor window and replace each instance of the _accountName_ by the principalId value you just copied. 

1. Execute the script. 

To check whether the installation was done correctly: 

1. In the Azure portal, navigate to the App Service that got deployed. 

1. Select the URL of the App Service to navigate to the web application.

1. In the web application select the SQL menu and check the _Use Azure Managed Identity to connect to the database_ box. 

1. Select _Submit_. This should give you a response on the same page with an access token and an output indicating you successfully logged in to the database by using a managed identity and from a public IP address. 


## Demo

TODO

## Resources

### Azure Architecture Center

- [Web app private connectivity to Azure SQL database](https://docs.microsoft.com/azure/architecture/example-scenario/private-web-app/private-web-app)
- [Multi-region web app with private connectivity to database](https://docs.microsoft.com/azure/architecture/example-scenario/sql-failover/app-service-private-sql-multi-region)

### App Service Docs

- [App Service networking features](https://docs.microsoft.com/azure/app-service/networking-features)
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

- [How to set up Private Link for Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview#how-to-set-up-private-link-for-azure-sql-database)
- [Azure SQL Firewall](https://docs.microsoft.com/en-us/azure/azure-sql/database/firewall-create-server-level-portal-quickstart)

### Networking

- [Integrate Azure services with virtual networks for network isolation](https://docs.microsoft.com/azure/virtual-network/vnet-integration-for-azure-services)
- [Private link resources](https://docs.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource)
- [Virtual Network service endpoints](https://docs.microsoft.com/azure/virtual-network/virtual-network-service-endpoints-overview)
- [Azure Private Link frequently asked questions (FAQ)](https://docs.microsoft.com/azure/private-link/private-link-faq#what-is-the-difference-between-a-service-endpoints-and-a-private-endpoints)