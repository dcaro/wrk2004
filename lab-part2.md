# PART 2 - Automate the process

In this part you will create an Azure Function that will set the capacity of the web application to the value passed.

We will use the PowerShell script that we have built in the first part of this lab.

## Escape Hatch 
Login to Azure CLI per instructions in Lab 1.

In the first part, you saw how to use Azure PowerShell escape hatch to enable/disable a webapp.

In this part, you will now use the escape hatch to create a preview Premium App Service Plan that is not yet supported in Azure CLI. This is needed to run an Azure Function with the PowerShell runtime.

### Create a preview Premium App Service Plan
From the command prompt run the following Azure CLI command using the `az resource create` escape hatch to specify the preview Premium plan.

```Shell
az resource create 
-g @lab.CloudResourceGroup(PSRG).Name  
-n wrk2004plan-@lab.LabInstance.Id 
-p '{
  "kind": "app",
  "location": "East US",
  "properties": {},
  "sku": {
      "name": "P1",
      "tier": "Premium",
      "size": "P1",
      "family": "P",
      "capacity": 1
  }
}'
--resource-type Microsoft.Web/serverfarms 
--is-full-object  -l eastus
```

## Create an Azure Storage Account
Create an Azure Storage Account to use as the function store.

Run this command in the cmd window.
```Shell
az storage account create -n wrk2004store-@lab.LabInstance.Id -g @lab.CloudResourceGroup(PSRG).Name -l eastus --sku Standard_LRS
```

## Create an Azure Function App
We can now use the plan above to create an Azure Function App using the Azure CLI.

Run this command in the cmd window.

```Shell
az functionapp create -g @lab.CloudResourceGroup(PSRG).Name  -p wrk2004plan-@lab.LabInstance.Id -n wrk2004func-@lab.LabInstance.Id -s wrk2004store-@lab.LabInstance.Id --runtime 'powershell'
```

Wait until the deployment has completed before proceeding to the next step. It will take couple of minutes to complete.

## Assign permissions to the function app
Login to PowerShell per instructions in Lab 1. 

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

The function app is really a place where you can create functions that will run code.

- From the Azure portal, click on the function app that you have created earlier wrk2004func-@lab.LabInstance.Id (Note: you may have to refresh your page to see it)
- Click on the **+** sign next to **Function** on the left blade.
- Click on **In-portal** then **Continue**
- Click on **Webhook + API** then **Create**

Replace the code in the `run.ps1` file with the code below.

> **NOTE:** You can try to not look at the code below and do it yourself.

- Replace the code in the `run.ps1` file with the code below.

```PowerShell
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$sku = $request.Query.Sku
$webAppName = "wrk2004-@lab.LabInstance.Id"

if (-not $sku) {
    $sku = $Request.Body.Sku
}

$ErrorActionPreference = "Stop"
if ($sku) {
    try {
        $AppSvcPlanId=(Get-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName).ServerFarmId
        Set-AzResource -ResourceId $AppSvcPlanID -Sku @{ Name = "$Sku"} -Force
        $body = "WebSite $WebAppName status is now running with SKU $sku"
    }
    catch [Microsoft.Azure.Commands.ResourceManager.Cmdlets.Entities.ErrorResponses.ErrorResponseMessageException] {
        $body = "Unsupported SKU"
    }

    $status = [HttpStatusCode]::OK
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = "Please pass a name on the query string or in the request body."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
```

- Click on **Test** on the right of the page
- Change the settings on the page as follows:
  - HTTP method: GET
  - Add parameter: sku = P1V2
- Click **Save and run**

Browse to the web app in the resource group and click "Scale up" in the left blade.
Under production, the P1V2 princing tier should be selected.

## Test if the errors handling works

Under "Query" change the parameters to sku = Q1
The Output window will display the following message:

```
Unsupported SKU
```

## Bonus Lab, add the ability to enable / disable the website

In this unguided exercise, create a new a function that will allow to enable / disable your website.

The function should accept the following parameters:

- The name of the web app
- The end state, "enabled" and "disabled" should be the only authorized values

## Summary

Congratulations, you have created an  Azure function app using Azure CLI. This automates the management of resources in Azure using Azure PowerShell!

In this lab you have completed the following tasks:

- Create an Azure Function app that runs PowerShell using the Azure CLI with related Storage account and App service plan.
- Give permissions to the Azure Function to modify the web app plan
- Write PowerShell code with error handling that modifies the service plan
