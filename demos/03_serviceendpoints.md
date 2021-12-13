# Service Endpoints

With Service Endpoints, you can restrict access to your app service to 1 or more specific subnets in your Azure Virtual Network. This works for all Virtual networks in the same region.
A typical setup using Service Endpoints is for an app service that is fronted by an Application Gateway. Any inbound traffic then first needs to hit the application gateway, before its allowed to hit the app service.

## Demo Walkthrough

- In the Azure Portal, navigate to your app service.
- In the overview screen select the URL of your app service and open the site in a new tab.
- Select the _Networking_ menu for your app service.
- Select _Access restriction_.
- Select _Add rule_.
- Create a new rule with the following values:
  - **Name**: Only allow App GW
  - **Action**: Allow
  - **Priority**: 100
  - **Type**: Virtual Network
  - **Subscription**: Select your current subscription.
  - **Virtual Network**: appsvcnetworkingdemo
  - **Subnet**: AppGwSubnet
- Select _Add rule_.
- Notice that by adding this rule an implicit _Deny All_ is added as a last rule in the rule list.
- Go back to the tab that has your website open. Refresh this tab, you should get a _403 Forbidden_.

> [NOTE]
> If you don't get a 403 Forbidden message, refresh the screen again a couple of times. It might take some time for this change to take effect.
> As an alternative you can open the website in a new anonymous browser window. 

> [NOTE]
> You could try and access your website now through application gateway (similar as what you did with Front Door in the previous walkthrough). The application gateway of the demo setup has a frontend IP address associated with it. However, since you are accessing your web app through an IP address and not throug a domain name, app service will block this call as well. Please refer to [TODO](find a link) on how to configure this. 

Previous guide: [Service Endpoints](03_serviceendpoints.md)
Next guide: [Private Link](04_privatelink.md)