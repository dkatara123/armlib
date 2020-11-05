# ARM Templates Library (ARMTL)

## **Terminology**

**Azure Resource Manager (ARM)** is the deployment and management service for Azure. It provides a management layer that enables you to create, update, and delete resources in your Azure account. You use management features, like access control, locks, and tags, to secure and organize your resources after deployment.

**Resource** - A manageable item that is available through Azure. Virtual machines, storage accounts, web apps, databases, and virtual networks are examples of resources. Resource groups, subscriptions, management groups, and tags are also examples of resources.

**Resource Group** - A container that holds related resources for an Azure solution. The resource group includes those resources that you want to manage as a group. You decide which resources belong in a resource group based on what makes the most sense for your organization. See Resource groups.

**Resource Provider** - A service that supplies Azure resources. For example, a common resource provider is Microsoft.Compute, which supplies the virtual machine resource. Microsoft.Storage is another common resource provider. See Resource providers and types.

**Resource Manager Template** - A JavaScript Object Notation (JSON) file that defines one or more resources to deploy to a resource group, subscription, management group, or tenant. The template can be used to deploy the resources consistently and repeatedly. See Template deployment overview.

**Declarative Syntax** - Syntax that lets you state "Here is what I intend to create" without having to write the sequence of programming commands to create it. The Resource Manager template is an example of declarative syntax. In the file, you define the properties for the infrastructure to deploy to Azure. 

## **UseCase**

ARMTL will help us build a robust automation framework for repeatable deployments and bring standarized approach for managing and building infrastructure and governance on Azure platform. Automation decreases the chance of human error that can create risk, so both IT operations and security best practices should be automated as much as possible to reduce human errors (while ensuring skilled humans govern and audit the automation). It also helps saving considerable cost by preventing users to deploy resources with minimum possible configurations. 

ARMTL contributes more or less to all the aspects on [security design principles](https://docs.microsoft.com/en-us/azure/architecture/framework/security/security-principles) and helps us securely architect system hosted on cloud platform which is secure by default.


## Library Design


