# PART 2 - Automate the process

In this part you will create an Azure Function that will set the capacity of the web application to the value passed.

We will use the PowerShell script that we have built in the first part of this lab.

## Create an Azure Function App

We are going to use the Azure Portal to create the Function App

<!-- To be replaced with CLI script or PowerShell with the Function App preview module -->

### Connect to Azure with a browser

- Open a browser and navigate to [https://portal.azure.com](https://portal.azure.com)
- Login using the credentials that have been provided:
  - username: @lab.CloudPortalCredential(User1).Username
  - password: @lab.CloudPortalCredential(User1).Password
- Under **Navigate** click on **Resource groups**
- Click on the resource group @lab.CloudResourceGroup(PSRG).Name

### Create an Azure Function App for PowerShell

- From the Azure Portal, click **Add** and type "Function App" in the search box.
- Click **Create**
- In the _Basics_ tab enter the following informations:
  - Name = wrk2004func-@lab.LabInstance.Id
  - Runtime stack = PowerShell core
- Click on **Next: Hosting**
  - Under the Windows Plan name, click **Create new**
  - Type the following plan nane wrk2004plan-@lab.LabInstance.Id
  - Change the plan type for **Premium (Preview)**
- Click on **Review + create**
- Click on **Create**

Wait until the deployment has completed before proceeding to the next step. It will take couple of minutes to complete.

## Assign permissions to the function app

The following steps will give the Function App permissions to modify the Web App that we have create previously.
From your PowerShell command, run the following commands:

```PowerShell
$webAppName = "wrk2004-@lab.LabInstance.Id"
$functionAppName = "wrk2004func-@lab.LabInstance.Id"
$resourceGroupName=@lab.CloudResourceGroup(PSRG).Name
#Get AppPlan for webApp
$AppSvcPlanId=(Get-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName).ServerFarmId
#Enable MSI and get MSI Id of the function
$functionApp=Set-AzWebApp -AssignIdentity $true -Name $functionAppName -ResourceGroupName $resourceGroupName
# Assign the LOD owner role for the function App to the app service plan
New-AzRoleAssignment -ObjectId $functionApp.Identity.PrincipalId -RoleDefinitionName "LOD Owner" -Scope $AppSvcPlanId
```

## Create a PowerShell function app that will allow to manage the scale of a website

```PowerShell
$sku = $request.Query.Sku
$ErrorActionPreference = "Stop"

try {
    Set-AzResource -ResourceGroupName @lab.CloudResourceGroup(PSRG).Name -ResourceName wrk2004plan-@lab.LabInstance.Id -ResourceType Microsoft.Web/serverFarms -Sku @{ Name = "$Sku"} -Force
    $body = "WebSite $name status is now $status"
}
catch [Microsoft.Azure.Commands.ResourceManager.Cmdlets.Entities.ErrorResponses.ErrorResponseMessageException] {
    $body = "Unsupported SKU"
}

$status = [HttpStatusCode]::OK
```

Click the **Run** button.


Change the parameters as follows:

- name= wrk2004-@lab.LabInstance.Id
- value= P1V2

Browse to the web app in the resource group and click "Scale up" in the left blade.
Under production, the P1V2 princing tier should be selected.

## Test if the errors handling works

Click **Save** on the top bar.
Click on **Test** on the right blade.

Under "Query" fill the fields as follows:

- name= wrk2004-@lab.LabInstance.Id
- value= Q1

The Output window will display the following message:

```
Unsupported SKU
```

## Bonus Lab, enable / disable the website

```PowerShell
$name = $Request.Query.Name
$enabled = $request.Query.Enabled
$sku = $request.Query.Sku
$ErrorActionPreference = "Stop"

try {
    Set-AzResource -ResourceGroupName PSRGlod10427823 -ResourceName $name -ResourceType Microsoft.Web/sites -Properties @{enabled = "$enabled"} -Force
    Set-AzResource -ResourceGroupName PSRGlod10427823 -ResourceName $name -ResourceType Microsoft.Web/serverFarms -Sku @{ Name = "$Sku"} -Force
    $body = "WebSite $name status is now $status with a Sku $Sku"
}
catch [Microsoft.Azure.Commands.ResourceManager.Cmdlets.Entities.ErrorResponses.ErrorResponseMessageException] {
    $ErrorMessage =  (Resolve-AzError -Last).Message
    $body = "The following error occured $ErrorMessage"
}

$status = [HttpStatusCode]::OK
```
