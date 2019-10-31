# PART1 - Create your script to deploy a web application

At the end of this part you will have a script that will create an deploy a web application in the resource group that you have been provided.

## Configure your environment

Under the "Resources" tab you can find the credentials giving you access to a resource group in Azure.

### Install the Azure module for PowerShell

- Launch `PowerShell 6`

    Click on the start menu and type `PowerShell 6`

- From the PowerShell prompt type the followin command.

    ```PowerShell
    Install-Module -Name Az -Force
    ```

The installation will that couple of minutes to complete.

> **TIP**: With PowerShell you can use `<TAB>` to auto-complete your command or the parameters.

### Connect to your Azure environment

From the PowerShell prompt, type the following command and follow the instructions.

```PowerShell
Connect-AzAccount
```

Open the browser of your choice and go to [http://aka.ms/devicelogin](http://aka.ms/devicelogin)

Use following values to authenticate against Azure:

    userName = @lab.CloudPortalCredential(User1).Username
    Password = @lab.CloudPortalCredential(User1).Password

Go back to the **PowerShell** window. Shortly you should see the account information displayed

### Discover the cmdlet to use to create a Web App

To find which command is needed to create a web app, we will use the `Get-Help` command that is native to PowerShell.

```PowerShell
# Find the command to use to create a webapp
Get-help webpp
```

You will be displayed all the cmdlets that contains `webapp`, about 51 commands. Let's filter only thoses that start with "New.
In PowerShell "New" is used to create new resources, "Set" is used to modify an existin resource. More informations about this at the following location: [Approved verbs for PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-6)

```PowerShell
# Refine the command
get-help webapp | where { $_.Name -like "New*"}
```

It looks like that `New-AzWebApp` is the cmdlet that we need. Let's open the documentation associated.

```PowerShell
# Open the web page with the latest documentation
get-help New-AzWebApp -online
```

### Use the documentation to create the webapp

> **NOTE:** With the page previously open, try to not read below and use the documenation to write the command to create the web app.

The following command will create the web app in your assigned resource group.

```PowerShell
$webappName="wrk2004-@lab.LabInstance.Id"
$resourceGroupName=@lab.CloudResourceGroup(PSRG).Name
New-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName -Location eastus
```

## Escape Hatches

An escape hatch allows to access capabilities of an Azure resource that is not available in the command line. We will learn here how us escape hatches in the command line of your choice.

The web app that we have just created can be disabled but this is not feasible in the portal. You'll learn in the next steps how to do it.

### Disable/Enable the Web App

The following commands will disable the Web App that you have just created.

```PowerShell
Set-AzResource -ResourceGroupName $resourceGroupName -ResourceName $webAppName -ResourceType Microsoft.Web/sites -Properties @{enabled = "False"}
```

Now let's enable the web app again.

```PowerShell
Set-AzResource -ResourceGroupName $resourceGroupName -ResourceName $webAppName -ResourceType Microsoft.Web/sites -Properties @{enabled = "True"}
```

We can use the same mechanism to scale the web application

### Scale the plan to Q1

```PowerShell
Set-AzResource -ResourceGroupName $resourceGroupName -ResourceName $webAppName -ResourceType Microsoft.Web/serverFarms -Sku @{ Name = "Q1"}
```

Note that the command fails because the SKU "Q1" is not supported.
The next section will teach how to perform error handling.

## Errors handling

1. Use the Resolve-AzError in the command line

You will see the informations associated to your last command.

```PowerShell
Resolve-AzError -Last
```

Get the error message itself
```PowerShell
(Resolve-AzError -Last).message
```

1. Let's build a script that will do the work but not fail on the error.

Open VSCode and copy the following test in a file name scaleweb.ps1

```PowerShell
$webappName="wrk2004-@lab.LabInstance.Id"
$resourceGroupName=@lab.CloudResourceGroup(PSRG).Name
$ErrorActionPreference = "Stop"
try {
    Set-AzResource -ResourceGroupName $resourceGroupName -ResourceName $webAppName -ResourceType Microsoft.Web/serverFarms -Sku @{ Name = "Q1"} -force
}
catch [Microsoft.Azure.Commands.ResourceManager.Cmdlets.Entities.ErrorResponses.ErrorResponseMessageException] {
     "An error happened when setting up the webapp`n" + $_.Exception.Message
}
catch {
    $_.Exception.GetType().Name
}
```

Press F5 to run the script in debug mode.
