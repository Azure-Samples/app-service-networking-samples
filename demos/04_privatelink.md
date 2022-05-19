# Private Link

With a private endpoint you can create a private IP address for your app service in your virtual network. Once you do this, the public access to your app service is removed.
The big difference between private endpoints and service endpoints is that private endpoints also allow you to connect to your app service from on-prem systems over site to site VPN or ExpressRoute connections. Additionaly you can connect to your app service over virtual network peering, and even global virtual network peering. Service endpoints don't give you this capability.

Once you create a private endpoint, additional DNS settings need to be made. Your _myapp.azurewebsites.net_ now needs to point to _myapp.privatelink.azurewebsites.net_, which in its turn points to your private IP address. Either you can use the DNS capabilities on the virtual network which can create the necessary DNS records for you in a private DNS zone (which we'll also use in the demo walkthrough). Or you can decide to run your own DNS, in that case you need to configure the DNS records for the new privatelink DNS name. You will also need to perform additional DNS config in case you want to connect from on-prem systems to your app service or over peered networks. You can find more details in [this docs article on Azure Private Endpoint DNS configuration](https://docs.microsoft.com/azure/private-link/private-endpoint-dns).

![Private endpoint](../media/private%20link2.svg)

## Demo Walkthrough

In this walkthrough you will create a private endpoint for your app service.

- In the Azure Portal, navigate to your app service.
- In the overview screen select the URL of your app service and open the site in a new tab.
- Select the _Networking_ menu for your app service.
- Select _Private endpoints_.
- Select _Add_.
- In the flyout fill out the following values:
  - **Name**: appSvcPE
  - **Subscription**: leave this value at your current subscription
  - **Virtual network**: appsvcnetworkingdemo
  - **Subnet**: PLSubnet
  - **Integrate with private DNS zone**: Yes
- Select _OK_.
- Once the private enpoint has been created, refresh your applications web page, you're web app can not be found anymore.

> [NOTE]
> If you don't get a 403 Forbidden message, refresh the screen again a couple of times. It might take some time for this change to take effect.
> As an alternative you can open the website in a new anonymous browser window.

- In the Azure Portal, navigate to the resource group that holds your app service.
- Notice that a _Private endpoint_ and a _Private DNS Zone_ were created in the resource group.
- Select the _private endpoint_ resource.
- Select the _Network interface_ link in the overview screen.
- Take note of the _Private IP address_.
- Navigate back to the resource group and now select the _Private DNS zone_.
- In the overview screen you will notice an A record pointing to the private IP address of the private endpoint for both the regular site of your web app and for the .scm site.

> [NOTE]
> Additionaly overall Azure DNS will have added a configuration that points from yourwebapp.azurewebsites.net to yourwebapp.privatelink.azurewebsites.net.

### Application Gateway
- Navigate back to the resource group, select the Public IP Address resource. This IP address is associated with the application gateway in the resource group.
- Copy the IP address.
- Open a new browser tab and paste the IP address.
- You will be able to access the web app through the IP address of the application gateway (as both resources use the same VNET).

> [NOTE]
> To enable access to your web app through the application gateway, the demo setup uses _host header override_ in the application gateway. You should never use this for production workloads. Instead you should properly configure a custom domain for your app service and use this customer domain to access your appservice. [This link](https://docs.microsoft.com/azure/application-gateway/troubleshoot-app-service-redirection-app-service-url#alternate-solution-use-a-custom-domain-name) describes how to properly configure a custom domain on app service in combination with application gateway.

### Azure Front Door
To enable Azure Front Door to reach the web app through the private link, you need to configure the origin to use private link as per stepts below (for details: [check this link](https://docs.microsoft.com/azure/frontdoor/standard-premium/how-to-enable-private-link-web-app)):
- In the Azure Portal, Navigate to your front door instance
- In the overview, locate the Origin Groups and click on the ´backendOriginGroup´
- Click on the three dot located in the right side and click on ´Configure origin group´
- Click on the origin for the app service web app
- Check the ´Enable Private Link service´
- Select ´Region´ where the app service is deployed
- Select *Sites* as the ´Target sub resource´
- Add a request message (e.g.: "Private link access from Azure Front Door")
- Apply and update the origin
- Once saved and updated, navigate to your app service.
- In the overview screen select the URL of your app service and open the site in a new tab.
- Select the _Networking_ menu for your app service.
- Select _Private endpoints_.
- You will see a new private endpoint that needs to be approved with the request message you provided in the previous step (*Private link access from Azure Front Door*)

Once you have approved the Private Link it will take few minutes to the configuration to be propagated, then you will be able to reach the web app thru front door. 

> [NOTE]
> Notice that in this walkthrough we do not remove the private endpoint configurations, removing it puts the demo walkthrough in a _in limbo_ state where it takes a while for the public URL of the app to be back available. Since we don't want to let you wait for this, we will leave the private endpoint in place.

You now have a good overview of the options you have for locking down the inbound traffic for app service. In the next demo walkthroughs, you will lock down outbound traffic.

Previous guide: [Service Endpoints](03_serviceendpoints.md)
Next guide: [Hybrid Connections](05_Hybirdconnections.md)
