# PART1 - Create your script to deploy a web application

At the end of this part you will have a script that will create and deploy a web application in the resource group that you have been provided.

## Configure your environment

Under the "Resources" tab you can find the credentials giving you access to a resource group in Azure.

### Install the Azure module for PowerShell

- Launch **PowerShell 6**

    Click on the start menu and type `PowerShell 6`

- From the PowerShell prompt type the following command.

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

Go back to the **Terminal** window. Shortly you should see the account information displayed

### Discover the command to use to create a Web App

To find which command is needed to create a web app, we will use the **Get-Help** command that is native to PowerShell.

```PowerShell
Get-help webpp
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

Keep the page open.

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

We will learn how to use escape hatches using PowerShell cmdlets based of the `AzResource` (`New-AzResource` for example) or using the `az resource` commands in the Azure CLI.

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

Now let's enable the web app.

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

## Summary

Congratulations, you have successfully managed Azure resources with Azure PowerShell or Azure CLI.

In this lab, you have completed the following tasks:

- Authenticate against Azure
- Create a web app
- Use a generic command for operations not supported yet in the tools
- Make your script resilent to errors

In the next part of the lab we will learn how to automate the Azure PowerShell script that you have just created with Functions.
