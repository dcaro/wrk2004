# PART 2 - Automate the process

In this part you will create an Azure Function that will set the capacity of the web application to the value passed.

We will use the PowerShell script that we have built in the first part of this lab.

## Connect to Azure with Azure CLI (for those who used Azure PowerShell in part 1)
Search (click the magnifying glass in the start bar) for **cmd** and open the  Windows Command Prompt. Type the following command. 
```CLI
az login
```
This will open the browser and ask you to login. Enter the username(`@lab.CloudPortalCredential(User1).Username`) and password(`@lab.CloudPortalCredential(User1).Password`) when prompted to connect to Azure.

Go back to the **command prompt** window. Shortly, you should see the account information displayed.

## Create an Elastic Premium Plan for FunctionApp
From the command prompt run the following Azure CLI command to create an Elastic Premium plan in the PowerShell resource group

```CLI
az functionapp plan create -g @lab.CloudResourceGroup(PSRG).Name -n wrk2004plan-@lab.LabInstance.Id --min-instances 1 --max-burst 10 --sku EP1
```

## Create an Azure Storage Account
Create an Azure Storage Account to use as the function store.

Run this command in the cmd window.
```CLI
az storage account create -n wrk2004store@lab.LabInstance.Id -g @lab.CloudResourceGroup(PSRG).Name -l eastus --sku Standard_LRS
```

## Create an Azure Function App
We can now use the plan above to create an Azure Function App using the Azure CLI.

Run this command in the cmd window.

```CLI
az functionapp create -g @lab.CloudResourceGroup(PSRG).Name  -p wrk2004plan-@lab.LabInstance.Id -n wrk2004func-@lab.LabInstance.Id -s wrk2004store@lab.LabInstance.Id --runtime powershell
```

Wait until the deployment has completed before proceeding to the next step. It will take couple of minutes to complete.

## Connect to Azure with Azure PowerShell (only for those who used Azure CLI in part 1)
Launch **PowerShell 6**
- Click on the start menu and type `PowerShell 6`
- Click on "PowerShell 6 (x64)"
From the PowerShell prompt type the following command then press "Enter".

```PowerShell
Install-Module -Name Az -Force
```
The installation will take couple of minutes to complete.

From the PowerShell prompt, type the following command and follow the instructions.

```PowerShell
Connect-AzAccount
```
Open the browser of your choice and go to +++http://aka.ms/devicelogin+++. Use following values to authenticate against Azure:

userName
    ```@lab.CloudPortalCredential(User1).Username```

Password
    ```@lab.CloudPortalCredential(User1).Password```

Close the window once the authentication has completed and go back to the **PowerShell** window, yyou should see the account information displayed.

## Assign permissions to the function app
The following steps will give the Function App permissions to modify the Web App that we have create previously.
From your PowerShell prompt, run the following to open Visual Studio Code :
```PowerShell
code perm.ps1
```
Enter the following into VSCode.
```PowerShell
$webAppName = "wrk2004-@lab.LabInstance.Id"
$webResourceGroupName="@lab.CloudResourceGroup(CLIRG).Name"
$functionAppName = "wrk2004func-@lab.LabInstance.Id"
$funcresourceGroupName="@lab.CloudResourceGroup(PSRG).Name"
#Get AppPlan for webApp
$AppSvcPlanId=(Get-AzWebApp -Name $webAppName -ResourceGroupName $webresourceGroupName).ServerFarmId
$WebAppId=(Get-AzWebApp -Name $webAppName -ResourceGroupName $webresourceGroupName).Id
#Enable MSI and get MSI Id of the function
$functionApp=Set-AzWebApp -AssignIdentity $true -Name $functionAppName -ResourceGroupName $funcresourceGroupName
# Assign the LOD owner role for the function App to the app service plan
New-AzRoleAssignment -ObjectId $functionApp.Identity.PrincipalId -RoleDefinitionName "LOD Owner" -Scope $AppSvcPlanId
New-AzRoleAssignment -ObjectId $functionApp.Identity.PrincipalId -RoleDefinitionName "LOD Owner" -Scope $WebAppId
```
Save the file in VSCode. From the PowerShell prompt, execute the above script by running it as below
```PowerShell
./perm.ps1
```

## Create a PowerShell function app that will allow to manage the scale of a website

The function app is really a place where you can create functions that will run code.

- From the Azure portal, click on the function app that you have created earlier wrk2004func-@lab.LabInstance.Id (Note: you may have to refresh your page to see it)
- Click on the **+** sign next to **Function** on the left blade.
- Click on **In-portal** then **Continue**
- Click on **Webhook + API** then **Create**

> **NOTES:**
>
> - You can try to not look at the solution below and write the code yourself
> - For practicality, use this command to get the code of the function on locally

Go to you PowerShell session and type the following

```PowerShell
Invoke-WebRequest "https://raw.githubusercontent.com/dcaro/wrk2004/master/run.ps1" -OutFile ./run.ps1
```

Open the file with notepad

```PowerShell
notepad ./run.ps1
```

Select all the content and copy it with "Ctrl + C"

- Go to your browser and replace the content of the **run.ps1** in your browser with the content of the file that you have just copied.

- Click on **Test** on the right of the page
- Change the settings on the page as follows:
  - HTTP method: GET
  - Add parameter: sku = S2
  - Add parameter: WebAppName = wrk2004-@lab.LabInstance.Id
  - Add parameter: ResourceGRoup = @lab.CloudResourceGroup(PSRG).Name
  
- Click **Save and run**

Browse to the web app in the resource group and click "Scale up" in the left blade.

Go to the production tab, the P1V2 princing tier should be selected.

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
