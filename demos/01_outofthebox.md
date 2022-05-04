# Out of the Box Networking in Azure App Service

Out of the box app service makes use of a shared incoming IP address for all customers. From this incoming IP address the call is routed to Front End (FE) nodes that act as a load balancer. These FE nodes forward the incoming request to worker nodes specific for each customer, based on the incoming domain name.

For outgoing calls, from your app service instance to any other services, the internal IP address from your worker nodes gets translated (NATted) to a list of shared outgoing IP addresses. This means that these outgoing IP addresses are not safe to use in case you want to lock down traffic to a backend database for instance to only your app service worker instances. In a later demo, you will learn how to lock down this traffic.

![out of the box networking in app service](../media/default%20behavior.svg)

## Demo Walkthrough

In this demo you will learn where to find the default networking settings of your app service.

- In the Azure Portal, navigate to your app service.
- In the _Overview_ screen notice the URL for your app service. This is the domain name app services will use to route incoming calls to the correct worker nodes for this specific app service instance.
- Select the URL of your app service, this opens your app service in an additional browser tab.
- You are now seeing the [Inspector Gadget](https://github.com/jelledruyts/inspectorgadget) application that got deployed to your app service. This application is very useful for inspecting the internal behavior of your app service. On its start page it already gives you useful data on the incoming request, any HTTP headers that got send to your app, environment variables being used, ...
    > There is a [new tool](https://azure.github.io/AppService/2021/04/13/Network-and-Connectivity-Troubleshooting-Tool.html) under *Diagnose and Solve Problems* that will help to diagnose and understand the networking configuration of our web app (currently more powerfull for Windows app services than Linux). 
- Select the SQL menu at the top of the app. We will use this page to make a call to the backend SQL server database.
- Select _Submit_
- In the Response output, notice that the app service connected to the backend database over a public IP address.  
- Navigate back to the Azure Portal.
- Select the _Properties_ menu for your app service.
- Notice the Virtual IP address for your app service. This is the shared inbound IP address.
- Notice the Outbound IP addresses and additional outbound IP addresses for your app service. These are the shared IP addresses that app services will NAT your worker node IP address to for outgoing calls. The address you saw in your app when you submitted a query to your database should be in one of these lists.
- Select the _Networking_ menu for your app service. Notice that the networking features for app service in this screen are split between features for inbound traffic and for outbound traffic.

In the next walkthroughs, you will learn how to further lock down the inbound and the outbound communication paths of your app service. We will start with how to lock down inbound requests.

Next guide: [Access/IP Restrictions](02_IPrestrictions.md)
