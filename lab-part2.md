# PART 2 - Automate the process

In this part we will create an Azure Function that can be called to scale out your web application.
We will run the PowerShell script that we have built previoulsy in an Azure Function.

## Create an Azure function

Create a Function Apop in the resource group t@lab.CloudResourceGroup(PSRG).Name using the portal with the following characteristics:

- Name = wrk2004func-@lab.LabInstance.Id
- Runtime = PowerShell core
- Plan Type = Premium (Preview)

## Assign permissions to the function app

The following steps will give the Function App permissions to modify the Web App that we have create previously.
From your PowerShell command, run the following commands:

```PowerShell
$webAppName = "wrk2004-@lab.LabInstance.Id"
$functionAppName = "wrk2004func-@lab.LabInstance.Id"
#Get AppPlan for webApp
$AppSvcPlanId=(Get-AzWebApp -Name $webAppName -ResourceGroupName $resGroup).ServerFarmId
#Enable MSI and get MSI Id of the function
$functionApp=Set-AzWebApp -AssignIdentity $true -Name $functionAppName -ResourceGroupName $resGroup
# Assign the LOD owner role for the function App to the app service plan
New-AzRoleAssignment -ObjectId $functionApp.Identity.PrincipalId -RoleDefinitionName "LOD Owner" -Scope $AppSvcPlanId
```

## Create a PowerShell function app that will allow to manage the scale of a website

```PowerShell
$name = $Request.Query.Name
$sku = $request.Query.Sku
$ErrorActionPreference = "Stop"

try {
    Set-AzResource -ResourceGroupName PSRGlod10427823 -ResourceName $name -ResourceType Microsoft.Web/serverFarms -Sku @{ Name = "$Sku"} -Force
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
