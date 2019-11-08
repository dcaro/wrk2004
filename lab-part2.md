# PART 2 - Deploy an Azure Function App using the Azure CLI

**NOTE** This assumes that you have completed the part 1 of this lab using Azure CLI. This will not work for those who completed the lab using Azure PowerShell (Instructions for part 2 are in the PowerShell manual itself).

In this part you will create an Azure Function that will set the scaling capacity of the web application to the value passed.

## Install Azure PowerShell
Launch **PowerShell 6**
- Click on the start menu and type `PowerShell 6`
- Click on "PowerShell 6 (x64)"
From the PowerShell prompt type the following command then press "Enter".

```PowerShell
Install-Module -Name Az -Force
```
The installation will take couple of minutes to complete.Move on to the next step (you will come back to PowerShell later).

## Create an Elastic Premium Plan for FunctionApp
Go back to the **Command Prompt** Window From the command prompt run the following Azure CLI command to create an Elastic Premium plan in the PS resource group

```CLI
az functionapp plan create -g @lab.CloudResourceGroup(PSRG).Name -n wrk2004plan-@lab.LabInstance.Id --min-instances 1 --max-burst 10 --sku EP1
```

## Create an Azure Storage Account
Create an Azure Storage Account to use as the function store.

Run this command in the **Command Prompt** window.
```CLI
az storage account create -n wrk2004store@lab.LabInstance.Id -g @lab.CloudResourceGroup(PSRG).Name -l eastus --sku Standard_LRS
```

## Create an Azure Function App
We can now use the plan above to create an Azure Function App using the Azure CLI.

Run this command in the **cmd** window.

```CLI
az functionapp create -g @lab.CloudResourceGroup(PSRG).Name  -p wrk2004plan-@lab.LabInstance.Id -n wrk2004func-@lab.LabInstance.Id -s wrk2004store@lab.LabInstance.Id --runtime powershell
```

Wait until the deployment has completed before proceeding to the next step. It will take couple of minutes to complete.

## Connect to Azure with Azure PowerShell 
Go to the **PowerShell** prompt, and type the following command and follow the instructions.

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
The following steps will give the Function App permissions to modify the Web App that we have created previously.
From your PowerShell prompt, ensure you are currently in **C:\Users\LabUser**. Execute this PowerShell script:

```PowerShell
.\Documents\WRK2004\webAppandFunction.ps1
```

## Create a PowerShell function app that will allow to manage the scale of a website

The function app is really a place where you can create functions that will run code.
- In the browser where you logged into the tools, goto - `http://portal.azure.com` and sign in
- From the Azure portal search box on top, search for `wrk2004func-@lab.LabInstance.Id` Select the one with the **lightning** icon.
- Click on the **+** sign next to **Function** on the left blade.
- Scroll down and click on **In-portal** then **Continue**
- Scroll up and Click on **Webhook + API** then **Create**

Go to your PowerShell prompt and type the following

```PowerShell
Invoke-WebRequest "https://raw.githubusercontent.com/dcaro/wrk2004/master/run.ps1" -OutFile ./run.ps1
```

Open the file with notepad

```PowerShell
notepad ./run.ps1
```

Select all the content **"CTRL+A"** and copy it with **"Ctrl + C"**

- Go to your browser and replace the content of the **run.ps1** in your browser with the content of the file that you have just copied using **CTRL+V**. Click Save on top to save this as the script to run in Azure Functions.  
- Click on **Test** on the right of the page
- Change the settings on the page as follows:
  - HTTP method: **GET**
  - Add parameter: **Sku** = **S2**
  - Add parameter: **WebAppName** = `wrk2004-@lab.LabInstance.Id`
  - Add parameter: **ResourceGroupName** = `@lab.CloudResourceGroup(CLIRG).Name`
- Click **Run**

Scroll to the left to look at the logs in the console blade. This will take a minute or so to run. If this succeeds, the Output window should show you a message that the SKU has changed. 

Browse to the app service plan blade in the portal by searching for `wrk2004-@lab.LabInstance.Id` in the top search box. Once this page loads, Search for **"Scale up"** in the left blade search box. 

Select **"Scale up"** and select the **Production** tab. If the function worked, the **S2** pricing tier should be selected. As we created one with a different tier (**F1** or Free for CLI) in part 1, you have successfully completed the lab!

## Summary
Congratulations, you have created an  Azure function app using Azure CLI. This automates the management of resources in Azure using Azure CLI with Azure Functions and Azure PowerShell!

In this lab you have completed the following tasks:
- Create an Azure Function app that runs PowerShell using the Azure CLI with related Storage account and App service plan.
- Give permissions to the Azure Function to modify the web app plan using Azure PowerShell
- Write PowerShell code with error handling that modifies the service plan
