# PART1 - Create your script to deploy a web application

At the end of this part you will have a script that will create and deploy a web application in the resource group that you have been provided.

## Configure your environment

To connect to the Virtual Machine, use the following credentials:

UserName: `@lab.VirtualMachine(WRK2004).Username`
Password: `@lab.VirtualMachine(WRK2004).Password`

> **NOTE**: In the "Resources" tab you have the user names and passwords that you will needt to complete this lab.

### Install the Azure module for PowerShell

Launch **PowerShell 6**

- Click on the start menu and type `PowerShell 6`
- Click on "PowerShell 6 (x64)"

From the PowerShell prompt type the following command then press "Enter".

```PowerShell
Install-Module -Name Az -Force
```

The installation will take couple of minutes to complete.

> **TIP**: With PowerShell you can use **TAB** to auto-complete your command or the parameters.

### Connect to your Azure environment

From the PowerShell prompt, type the following command and follow the instructions.

```PowerShell
Connect-AzAccount
```

Open the browser of your choice and go to +++http://aka.ms/devicelogin+++

Use following values to authenticate against Azure:

userName
    ```@lab.CloudPortalCredential(User1).Username```

Password
    ```@lab.CloudPortalCredential(User1).Password```

Close the window once the authentiction has completed and go back to the **PowerShell** window, yyou should see the account information displayed.

### Discover the command to use to create a Web App

To find which command is needed to create a web app, we will use the **Get-Help** command that is native to PowerShell.

```PowerShell
Get-help webapp
```

You will be displayed all the cmdlets that contains **webapp**, about 51 commands. Let's filter only thoses that start with **New**.
In PowerShell "New" is used to create new resources, "Set" is used to modify an existin resource. More informations about this at the following location: [Approved verbs for PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-6)

```PowerShell
get-help webapp | where { $_.Name -like "New*"}
```

It looks like that **New-AzWebApp** is the cmdlet that we need. The following command will open the latest documentation associated with the command.

```PowerShell
get-help New-AzWebApp -online
```

Keep the page open, you will need it for the next part of the lab.

### Use the documentation to create the webapp

> **NOTE:** With the page from the help documentation still open, try to not read below and use the documenation to write the command to create the web app.

The following command will create the web app in your assigned resource group.

```PowerShell
$webappName="wrk2004-@lab.LabInstance.Id"
$resourceGroupName="@lab.CloudResourceGroup(PSRG).Name"
New-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName -Location eastus
```

This will take a minute to complete.

## Escape Hatches

An 'escape hatch' is a workaround that allows to access capabilities of an Azure resource that is not available in the command line. 

We will learn how to use escape hatches using PowerShell cmdlets based of the **AzResource** (**New-AzResource** for example).

The web app that you have just created can be disabled but this is not feasible in the portal. In the next steps you will learn how to do it.

### Disable/Enable the Web App

The following command will disable the Web App that you have just created.

```PowerShell
Set-AzResource -ResourceGroupName $resourceGroupName -ResourceName $webAppName -ResourceType Microsoft.Web/sites -Properties @{enabled = "False"}
```

Browse to the page of the web app to see that is has been disabled.

```PowerShell
Start-Process ("http://"+(Get-AzWebApp -Name wrk2004-@lab.LabInstance.Id).DefaultHostName )
```

Go back to PowerShell and let's enable the web app.

```PowerShell
Set-AzResource -ResourceGroupName $resourceGroupName -ResourceName $webAppName -ResourceType Microsoft.Web/sites -Properties @{enabled = "True"}
```

Refresh the page of the web app and see that it has been enabled again.

```PowerShell
Start-Process ("http://"+(Get-AzWebApp -Name wrk2004-@lab.LabInstance.Id).DefaultHostName )
```

We can use the same mechanism to scale the web application

#### Scale the plan to Q1

In this part of the lab, you will scale the website by changing the SKU of the plan. In Azure this means changing the SKU of the server farm that is used by the web app.
The following code will try to change the SKU of the plan to "Q1".

```PowerShell
Set-AzResource -ResourceGroupName $resourceGroupName -ResourceName $webAppName -ResourceType Microsoft.Web/serverFarms -Sku @{ Name = "Q1"}
```

> NOTE: The command above is expected to fail. You will learn in the next section how to read the error message.

## Error handling

### Understand the errors in the command line

The following command will display the informations associated to the last error.

```PowerShell
Resolve-AzError -Last
```

You can see all the errors that you had in your session by running the following command.

```PowerShell
Resolve-AzError
```

Let's obtain the error message itsefl with the following command.

```PowerShell
(Resolve-AzError -Last).message
```

### Putting it together

In this section you will write a script that will do the work but not fail on the error.
We will use the `Try`, `Catch` blocks to handle errors in the script.

- Launch VSCode from the taskbar
- Click **File / New File**
- Type the following code

```PowerShell
$webappName="wrk2004-@lab.LabInstance.Id"
$resourceGroupName="@lab.CloudResourceGroup(PSRG).Name"
$AppSvcPlanId=(Get-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName).ServerFarmId
$ErrorActionPreference = "Stop"
try {
    Set-AzResource -ResourceId $AppSvcPlanID -Sku @{ Name = "Q1"} -force
}
catch [Microsoft.Azure.Commands.ResourceManager.Cmdlets.Entities.ErrorResponses.ErrorResponseMessageException] {
     "An error happened when setting up the webapp`nError was `n" + $_.Exception.Message
}
catch {
    $_.Exception.GetType().Name
}
```

- Click **File / Save**
- Use the name `scaleWebApp.ps1`
- Save the file
- Run the script by pressing **F5**

The result from the script will appear in the terminal window on the bottom of VSCode.

## Summary of part 1

Congratulations, you have successfully managed Azure resources with Azure PowerShell or Azure CLI.

In this lab, you have completed the following tasks:

- Authenticate against Azure
- Create a web app
- Use a generic command for operations not supported yet in the tools
- Make your script resilent to errors

In the next part of the lab we will learn how to automate the Azure PowerShell script that you have just created with Functions.

# PART 2 - Automate the process

In this part you will create an Azure Function that take the name of a webApp and a SKU and will change it.

We will use the PowerShell script that we have built in the first part of this lab.

## Create the Azure Function

Login to Azure CLI per instructions in Lab 1.

In the first part, you saw how to use Azure PowerShell escape hatch to enable/disable a webapp.

In this part, you will now use the escape hatch to create a preview Premium App Service Plan that is not yet supported in Azure CLI. This is needed to run an Azure Function with the PowerShell runtime.

### Create a preview Premium App Service Plan

From the command prompt run the following Azure CLI command using the `az resource create` escape hatch to specify the preview Premium plan.

```Shell
az resource create -g @lab.CloudResourceGroup(PSRG).Name -n wrk2004plan-@lab.LabInstance.Id -p @.\Documents\ep1.json --resource-type Microsoft.Web/serverfarms --is-full-object -l eastus
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

The following steps will give the Function App permissions to modify the Web App that we have create previously.
From your PowerShell command, run the following commands:

```PowerShell
$webAppName = "wrk2004-@lab.LabInstance.Id"
$functionAppName = "wrk2004func-@lab.LabInstance.Id"
$resourceGroupName="@lab.CloudResourceGroup(PSRG).Name"
#Get AppPlan for webApp
$AppSvcPlanId=(Get-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName).ServerFarmId
#Enable MSI and get MSI Id of the function
$functionApp=Set-AzWebApp -AssignIdentity $true -Name $functionAppName -ResourceGroupName $resourceGroupName
# Assign the LOD owner role for the function App to the app service plan
New-AzRoleAssignment -ObjectId $functionApp.Identity.PrincipalId -RoleDefinitionName "LOD Owner" -Scope $AppSvcPlanId
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

> **NOTE:** For simplicity of use, the code below is in the **run.ps1** file in the **Documents** folder. 

```PowerShell
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$sku = $request.Query.Sku
$webAppName = $request.Query.WebAppName

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
