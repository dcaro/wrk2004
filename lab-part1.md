# PART1 - Create your script to deploy a web application

## Your environment

You have been provided credentials for your subscription
Connect to your subscription:

## Create your first script

In this exercise you will create a Azure PowerShell script that will deploy a simple Web Application.

1. Install the latest module for Azure PowerShell 

```PowerShell
Install-Module -Name Az
```

Approve the installation with "A", the installation will that couple of minutes.

1. Connect to your azure environment

- Open PowerShell 6 (be sure to use powershell 6 and not Windows PowerShell)
- Connect-AzAccount and follow the instructions on the screen.
- Use the following values to authenticate against Azure:

```PowerShell
    userName = @lab.CloudPortalCredential(User1).Username
    Password = @lab.CloudPortalCredential(User1).Password
```

## Let's create the Web Application

1. Discover the cmdlet to use to create a Web App.

    ```PowerShell
    # Find the command to use to create a webapp
    Get-help webpp

    # Refine the command
    get-help webapp | where { $_.Name -like "New-*"}

    # Go Online to get the latest
    get-help New-AzWebApp -online
    ```

1. Create the webapp

    ```PowerShell
    $webappName="wrk2004-@lab.LabInstance.Id"
    $resourceGroupName=@lab.CloudResourceGroup(PSRG).Name
    New-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName -Location eastus
    ```

## Escape Hatches

We can disable the web app but this capability is not exposed in the portal. We'll have to use a more elaborated solution consisting in using escape hatches.

### Disable/Enable the Web App

```PowerShell
Set-AzResource -ResourceGroupName $resourceGroupName -ResourceName $webAppName -ResourceType Microsoft.Web/sites -Properties @{enabled = "False"}
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
