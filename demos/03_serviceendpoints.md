# Service Endpoints

With Service Endpoints, you can restrict access to your app service to 1 or more specific subnets in your Azure Virtual Network. This works for all Virtual networks in the same region.
A typical setup using Service Endpoints is for an app service that is fronted by an Application Gateway. Any inbound traffic then first needs to hit the application gateway, before its allowed to hit the app service.

![Service Endpoints](../media/service%20endpoints.svg)

## Demo Walkthrough

In this walkthrough you will configure your app service to restrict access to only allow calls coming from your Application Gateway.

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

- In the Azure Portal, navigate to the Public IP Address. This IP address is associated with the application gateway in the resource group.
- Copy the IP address.
- Open a new browser tab and paste the IP address.
- You will be able to access the web app through the IP address of the application gateway.

> [NOTE]
> To enable access to your web app through the application gateway, the demo setup uses _host header override_ in the application gateway. You should never use this for production workloads. Instead you should properly configure a custom domain for your app service and use this customer domain to access your appservice. [This link](https://docs.microsoft.com/azure/application-gateway/troubleshoot-app-service-redirection-app-service-url#alternate-solution-use-a-custom-domain-name) describes how to properly configure a custom domain on app service in combination with application gateway.

- In the Azure portal, navigate back to your app service networking screen for the access restrictions.
- Remove the rule you created.

Previous guide: [Access/IP Restrictions](02_IPrestrictions.md)
Next guide: [Private Link](04_privatelink.md)
