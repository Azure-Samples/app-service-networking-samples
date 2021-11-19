# Project Name

This project contains a sample setup for playing with Azure App Service networking features. 

## Features

This project framework provides the following features:

* Feature 1
* Feature 2
* ...

## Getting Started

### Prerequisites

(ideally very short, if any)

- OS
- Library version
- ...

### Installation

The below walk-through contains the steps for creating a resource group in Azure and the steps needed to set up your deployment secret in your GitHub repository. 
You will need the latest version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed to execute these steps.

1. Define environment variables.

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

1. In the same manner add 2 additional secrets: _SQL_USERNAME_ and _SQL_PASSWORD_ and give them a value of your choice. Make sure you make the SQL password complex enough. 

1. Inspect the [infradeploy.yml](.github/workflows/infradeploy.yml) file and update any environment variables at the top of the file to reflect your environment. 

1. In your GitHub repo, navigate to *Actions* and select the *deploy-app-svc-networking-sample* action. 

1. Select *Run workflow* > *Run workflow*. 

1. This will start a new workflow run and deploy the necessary infrastructure. 

1. Double check in the Azure Portal that all resources got deployed correctly and are up and running. 

### Quickstart
(Add steps to get up and running quickly)

1. git clone [repository clone url]
2. cd [respository name]
3. ...


## Demo

A demo app is included to show how to use the project.

To run the demo, follow these steps:

(Add steps to start up the demo)

1.
2.
3.

## Resources

(Any additional resources or related projects)

- Link to supporting information
- Link to similar sample
- ...
