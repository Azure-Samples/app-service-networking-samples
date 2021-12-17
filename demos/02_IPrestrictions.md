# Access/IP Restrictions

With Access Restrictions you have the ability to deny or allow certain IP addresses or address ranges access to your app service. You also have the ability to deny or allow traffic based on HTTP Headers. In the demo walkthrough you will learn when this might be useful.

![Access Restrictions](../media/access%20restrictions.svg)

## Demo Walkthrough

You will first block access to your app service for calls coming from a specific IP address.

- In the Azure Portal, navigate to your app service.
- In the overview screen select the URL of your app service and open the site in a new tab. Your website is currently accessible.
- In the Azure portal, select the _Networking_ menu for your app service.
- Select _Access restriction_.
- Select _Add rule_.
- Create a new rule with the following values:
  - **Name**: BlockMyIP
  - **Action**: Deny
  - **Priority**: 100
  - **Type**: IPv4
  - **IP Address Block**: Look up your current IP address with [whatsmyip](https://www.whatsmyip.org/) and fill out that IP address.
- Select _Add rule_.
- Notice that by adding this rule an implicit _Deny All_ is added as a last rule in the rule list.
- Go back to the tab that has your website open. Refresh this tab, you should get a _403 Forbidden_.

> [NOTE]
> If you don't get a 403 Forbidden message, refresh the screen again a couple of times. It might take some time for this change to take effect.
> As an alternative you can open the website in a new anonymous browser window.

- Change the URL from yourappservicename.azurewebsites.net to yourappservicename.scm.azurewebsites.net. This is the management site for your web application. It is protected by SSO. Your browser can still reach this page.
- Navigate back to the Azure portal and the App Service networking screen with the access restriction you just created. Notice that there is an additional tab on this site for the yourappservicename.scm.azurewebsites.net URL you just visited. You can also add access restrictions for your .scm site.
- Delete the rule you just created. You can do this by clicking the 3 dots at the end of the line with the rule and selecting _Remove_.
- Double check that you can again directly access your website.

You will now block access to your app service to allow only calls that are made through your Azure Front Door instance.

- In the Azure portal navigate to the front door instance that got created.
- In the overview screen of your front door instance, copy the _Front Door ID_. This is a GUID identifying your specific Azure Front Door instance.
- Navigate back to your app service networking screen for the access restrictions.
- Select _Add rule_.
- Create a new rule with the following values:
  - **Name**: Allow only FD
  - **Action**: Allow
  - **Priority**: 100
  - **Type**: Service Tag
  - **Service Tag**: AzureFrontDoor.Backend
  - **X-Azure-FDID**: Paste the Front Door ID you copied earlier
- Select _Add rule_.

> [NOTE]
> The rule you just created will allow only calls coming from the Azure Front Door backend IP addresses. You do this by selecting the Azure Front Door service tag, which contains the list of Front Door IP addresses.
> Since Front door is a multi-tenant service you also need to restrict incoming calls to be coming from _your_ Azure Front Door configuration. This is why you additionaly add the X-Azure-FDID header check in the rule.

- Go back to the tab that has your website open. Refresh this tab, you should get a _403 Forbidden_.

> [NOTE]
> If you don't get a 403 Forbidden message, refresh the screen again a couple of times. It might take some time for this change to take effect.
> As an alternative you can open the website in a new anonymous browser window.

- In the Azure portal, navigate to your Front Door instance.
- On the overview page, select the _Frontend host_ URL. You will be able to reach the website through this URL.
- Any user of your application will now need to first pass through your Front Door, which you can configure with a Web Application Firewall, before they visit your application.
- In the Azure portal, navigate back to your app service networking screen for the access restrictions.
- Remove the rule you created.

In the next walkthrough you will perform a similar setup, but for Application Gateway.

Previous guide: [Out of the box networking](01_outofthebox.md)
Next guide: [Service Endpoints](03_serviceendpoints.md)
