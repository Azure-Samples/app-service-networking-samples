# VNet integration

VNet integration will route all outbound calls from your app service through a subnet in your virtual network. You need to make sure this subnet is large enough to hold th maximum scale out you plan for your app service plan. 

![VNet integration](../media/VNet%20integration.svg)

## Demo Walkthrough

In this walkthrough you initially lock down access to the backend database by adding a private link to the database. This will break connectivity from your app service to the backend database. Next you will route the outbound calls from the app service through a subnet in a VNet and hence restore connectivity to the backend database. 

- Navigate to your web app.

> [NOTE]
> In case you only just finished the private link walkthrough, this will be through the public IP address of the application gateway. In case you did not follow that walkthrough, you can use the public URL associated with your app service. 

- Select the SQL menu at the top of the app. We will use this page to make a call to the backend SQL server database.
- Select _Submit_
- In the Response output, notice that the app service connected to the backend database over a public IP address.  
- Navigate back to the Azure Portal and the resource group.
- Select the _SQL server.
- Select _Private endpoint connections_ from the menu.
- Select _Private endpoint_.
- Fill out the following values:
  - **Subscription**: will already be set to your current subscription.
  - **Resource group**: will already hold the name of the current resource group.
  - **Name**: sqlPE
  - **Region**: select the same region as the one you choose for your other resources.
- Select _Next: Resource_.
- Fill out the following values:
  - **Connection method**: leave on _Connect to an Azure resource in my directory_.
  - **Subscription**: will already be set to your current subscription.
  - **Resource type**: Microsoft.Sql/servers.
  - **Resource**: Select the name of your appservicenetworkingdemo database server.
  - **Target sub-resource**: sqlServer.
- Select _Next: Configuration_.
- Fill out the following values:
  - **Virtual network**: appsvcnetworkingdemo.
  - **Subnet**: appsvcnetworkingdemo/PLSubnet.
  - **Integrate with private DNS zone**: Yes.
    - **Configuration name**: Leave as is.
    - **Subscription**: will already be set to your current subscription.
    - **Resource group**: appsvcnetworkingdemo.
- Select _Next: Tags_.
- Select _Next: Review + create_.
- Select _Create_.
- Once the complete private endpoint deployment is finished, navigate back to your web app.
- Select _Submit_ for resubmitting the query to the backend SQL database.
- Notice that you are still able to connect to the backend database and that the connection is still made over a public IP address.

> [NOTE]
> Unlike the behavior you saw when you created a private endpoint for your web app earlier, where you weren't able to access the web app over a public IP anymore, for an Azure SQL Server this private endpoint setup behaves differently. Azure SQL database has additional settings available for locking down access to it. We will further lock down access to the database in the next steps.

- In the Azure portal, navigate back to the SQL Server resource.
- Select _Firewalls and virtual networks_ from the menu.
- Select the _Deny public network access_ checkbox.

> [NOTE]
> Also notice the _Allow Azure services and resources to access this server_ setting which is set to _Yes_. This setting makes that all Azure services (in all customers subscriptions, so not only your own subscription!) to still access your database server from a networking perspective. Selecting the _Deny public network access_ also disallows access to all Azure services.

- Select _Save_.
- Navigate back to your web app.
- Select _Submit_ for resubmitting the query to the backend SQL database.
- Notice that you are no longer able to access the backend database from the web app.
- In the Azure portal, navigate to your App Service resource.
- Select the _Networking_ menu.
- Select _VNet integration_.
- Select _Add VNet_.
- Fill out the following values:
  - **Subscription**: will already be set to your current subscription.
  - **Virtual network**: appsvcnetworkingdemo.
  - **Subnet**: Select Existing.
  - **Subnet**: IntegrationSubnet.
- Select _OK_.
- Navigate back to your web app.
- Select _Submit_ for resubmitting the query to the backend SQL database.

> [NOTE]
> It might be that you still get the message on your SQL server not being available. If you do retry the submit or retry refreshing the page. It might take a bit for the VNet integration to take effect.

- Notice that you are again able to connect to the backend database. Also note that you are now coming in over a private IP address. This private IP address will be within the IP range of the IntegrationSubnet.

You now have a setup where you connect inbound to your app service over Application Gateway and where the web app connects to its backend database through VNet integration and to a private IP address. 

Previous guide: [Gateway required VNet integration](06_GWrequiredVNetintegration.md)
Next guide: [ASE v3](08_ASEv3.md)
