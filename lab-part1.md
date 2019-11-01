# PART1 - Create your script to deploy a web application

At the end of this part you will have a script that will create and deploy a web application in the resource group that you have been provided.

## Configure your environment

Under the "Resources" tab you can find the credentials giving you access to a resource group in Azure.

### Install the command line tool

- Launch `PowerShell 6`

    Click on the start menu and type `PowerShell 6`

#### Azure PowerShell

- From the PowerShell prompt type the followin command.

    ```PowerShell
    Install-Module -Name Az -Force
    ```

The installation will take couple of minutes to complete.

> **TIP**: With PowerShell you can use `<TAB>` to auto-complete your command or the parameters.

#### Azure CLI
> **NOTE:** We have already installed the CLI in this lab environment, so you can skip this step if using the Lab.

You can install the Azure CLI using PowerShell. Start PowerShell as administrator and run the following command:
```PowerShell
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

### Connect to your Azure environment

#### Azure PowerShell

From the PowerShell prompt, type the following command and follow the instructions.

```PowerShell
Connect-AzAccount
```

#### Azure CLI

From the Windows Command Prompt, type the following command and follow the instructions.
```Shell
az login
```

#### Connect

Open the browser of your choice and go to [http://aka.ms/devicelogin](http://aka.ms/devicelogin)

Use following values to authenticate against Azure:

    userName = @lab.CloudPortalCredential(User1).Username
    Password = @lab.CloudPortalCredential(User1).Password

Go back to the **Terminal** window. Shortly you should see the account information displayed

### Discover the command to use to create a Web App

#### Azure PowerShell
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

Keep the page open.

##### Use the documentation to create the webapp

> **NOTE:** With the page from the help documentation still open, try to not read below and use the documenation to write the command to create the web app.

The following command will create the web app in your assigned resource group.

```PowerShell
$webappName="wrk2004-@lab.LabInstance.Id"
$resourceGroupName=@lab.CloudResourceGroup(PSRG).Name
New-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName -Location eastus
```
#### Azure CLI
To find which command is needed to create a web app, we will use the `az find` command that uses an AI that reads documentation, web content and usage to provide you the most relevant commands.

```Shell
# Find the command to use to create a webapp
az find webapp
```
You will be displayed the most common ways to create and use web apps today. We have recently created a simpler command to create a webapp
with your app code. You can try the following to learn more about this command.

```Shell
# Find the command to use to create a webapp
az find "az webapp up"
```
##### Create a webapp with app code

First place the app code into a folder to upload from 
```Shell
git clone https://github.com/Azure-Samples/python-docs-hello-world
cd python-docs-hello-world
```

The following command will let you view details of the app that will be created, without actually running the operation
```Shell
az webapp up --sku F1 -n wrk2004-@lab.LabInstance.Id -l eastus -g @lab.CloudResourceGroup(PSRG).Name --dryrun
```

The following command will then create the web app in your assigned resource group and upload the code from your local folder. (this will take a few minutes)
```bash
az webapp up --sku F1 -n wrk2004-@lab.LabInstance.Id -l eastus -g @lab.CloudResourceGroup(PSRG).Name
```

## Escape Hatches 

An 'escape hatch' is a workaround that allows to access capabilities of an Azure resource that is not available in the command line. 

We will learn how to use escape hatches using PowerShell cmdlets based of the `AzResource` (`New-AzResource` for example) or using the `az resource` commands in the Azure CLI.

The web app that you have just created can be disabled but this is not feasible in the portal. In the next steps you will learn how to do it.

### Disable/Enable the Web App
> NOTE: Azure CLI users can skip to the next section on Feedback. We will see a usage of the `az resource create` escape hatch for the Azure CLI in part 2 of this lab. 

#### Azure PowerShell
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
> NOTE: Azure CLI users can skip to the next section on Diagnostics.

#### Azure PowerShell
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
> NOTE: Azure CLI users can skip to the next section on Diagnostics.

#### Azure PowerShell

In this section you will write a script that will do the work but not fail on the error.
We will use the `Try`, `Catch` blocks to handle errors in the script.

- Launch VSCode from the taskbar
- Click **File / New File**
- Type the following code

```PowerShell
$webappName="wrk2004-@lab.LabInstance.Id"
$resourceGroupName=@lab.CloudResourceGroup(PSRG).Name
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
- Name the file `scaleWebApp.ps1`
- Save the file
- Run the script by pressing `F5`

The result from the script will appear in the terminal window on the bottom of VSCode.


## Diagnostics

#### Azure CLI

### Stream logs in the command line
You can access the console logs generated from inside the app and the container in which it runs.

You can turn on logging with the following command
```Shell
az webapp log config -n wrk2004-@lab.LabInstance.Id -g @lab.CloudResourceGroup(PSRG).Name --docker-container-logging filesystem
```
You can then view recent logs with the following command (refresh the webapp to generate recent logs)
```Shell
az webapp log tail -n wrk2004-@lab.LabInstance.Id  -g @lab.CloudResourceGroup(PSRG).Name
```
To stop log streaming at any time, type Ctrl+C.

## Feedback
> NOTE: Azure PowerShell users can skip to the Summary.
#### Azure CLI
If you find errors that are based on actual issues or would like to provide feedback on a command, we provide an enhanced command called `az feedback`. 

```Shell
az feedback
```
Pick any command from your history (esp. failures). This should open up GitHub with a well formatted error (switch to preview to look at the formatting). Exit out of GitHub (don't submit the issue). 



## Summary

Congratulations, you have successfully managed Azure resources with Azure PowerShell or Azure CLI.

In this lab, you have completed the following tasks:

- Authenticate against Azure
- Create a web app
- Use a generic command for operations not supported yet and make your script resilent to errors in Azure PowerShell
- Understand how to find commands, view diagnostics logs and provide feedback in the Azure CLI. 

In the next part of the lab we will learn how to automate the Azure PowerShell script that you have just created using Azure CLI with Functions.
