# Frequently Used Commands 

1. Disable subnet private endpoint policies using Azure CLI.
```
az network vnet subnet update \ 
  --name default \ 
  --resource-group myResourceGroup \ 
  --vnet-name myVirtualNetwork \ 
  --disable-private-endpoint-network-policies true
```
