# Access/IP Restrictions

With Access Restrictions you have the ability to deny or allow certain IP addresses or address ranges access to your app service. You also have the ability to deny or allow traffic based on HTTP Headers. In the demo walkthrough you will learn when this might be useful. 

## Demo Walkthrough

You will first block access to your app service for calls coming from a specific IP address.

- In the Azure Portal, navigate to your app service.
- Select the _Networking_ menu for your app service. 
- Select _Access restriction_.
- Select _Add rule_.
- Create a new rule with the following values: 
  - **Name**: BlockMyIP
  - **Action**: Deny
  - **Priority**: 100
  - **Type**: IPv4
  - **IP Address Block**: Look up your current IP address with [whatsmyip](https://www.whatsmyip.org/) and fill out that IP address.
- Select _Add_rule. 



Previous guide: [Out of the box networking](01_outofthebox.md)
Next guide: [Service Endpoints](03_serviceendpoints.md)