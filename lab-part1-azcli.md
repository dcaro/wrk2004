# PART1 - Deploy a web app with the Azure CLI

At the end of this part you will deploy a web application in the resource group that you have been provided.

### Login to the lab machine
Click on the lab window and enter the password `@lab.VirtualMachine(WRK2004).Password` to login to the lab.

### Connect to your Azure environment
Search (click the magnifying glass in the start bar) for **cmd** and open the  Windows Command Prompt. Type the following command. 
```cmd
az login
```
This will open the browser and ask you to login. Enter the username(`@lab.CloudPortalCredential(User1).Username`) and password(`@lab.CloudPortalCredential(User1).Password`) when prompted to connect to Azure.

Go back to the **command prompt** window. Shortly, you should see the account information displayed.

### Discover the command to use to deploy a Web App
To find the command needed to deploy a web app, we will use the `az find` command that uses an AI that reads Azure documentation, usage and web content to provide you the most relevant commands and parameters.

```cmd
az find webapp
```
You will be displayed the most common ways to create and use web apps today. We have recently created a simpler command to deploy a webapp with your app code. You can try the following to learn more about this command.

```cmd
az find "az webapp up"
```
### Retrieve the app code to deploy
First place the app code into a folder to upload from 
```cmd
git clone https://github.com/Azure-Samples/python-docs-hello-world
```
Then go to the newly created app folder.
```cmd
cd python-docs-hello-world
```
### Set defaults for Azure CLI commands to reuse
#### Set global defaults
Run az configure to understand the global defaults configured for your Azure CLI client, so you don't have to explicitly specify things like output format, resource group, location, etc across any of your commands.

```cmd
az configure
```
Press y to change the settings. Enter 5 to select yaml as the output format, then press enter multiple times until you get back to the command prompt to accept defaults for the other settings.

#### Get local defaults
Besides the above, we have recently added an option to create different local defaults for certain common parameters that typically  differ across different environments like resource group and location. 

List the local defaults for this newly created folder (there shouldn't be any, yet.)
```cmd
az configure --list-defaults --scope local
```
### Deploy the web app
The following command will let you view details of the Azure web app instance that will be created, without actually running the operation
```cmd
az webapp up --sku F1 -n wrk2004-@lab.LabInstance.Id -l eastus -g @lab.CloudResourceGroup(CLIRG).Name --dryrun
```

The following command will then create the web app in your assigned resource group and upload the code from your local folder. (this will take a few minutes)
```cmd
az webapp up --sku F1 -n wrk2004-@lab.LabInstance.Id -l eastus -g @lab.CloudResourceGroup(CLIRG).Name
```
Copy the Url property returned by this command or type this into the browser to go to the deployed web app - +++http://wrk2004-@lab.LabInstance.Id.azurewebsites.net+++ You should see Hello World! in the browser.

Rerun az configure to list local defaults configured by the up command.
```cmd
az configure --list-defaults --scope local
```
### Change and redeploy the app
You can now make some changes to the app code and redeploy.
```cmd
code application.py 
```
In the Visual Studio Code window that opens, change the string "Hello World!" to anything else of your choice (like "Goodbye Ignite!"). Then click File - Save to save this file. 

You can now rerun az webapp up without any parameters. 
```cmd
az webapp up
```
As it is idempotent and incremental, it will only redeploy the app and make no other changes to the existing webapp. Refresh the browser that shows Hello World!. You should now see the new string that you had entered in code.

### Stream logs in the command line
You can access the console logs generated from inside the app and the container in which it runs. 
```Shell
az webapp log tail -n wrk2004-@lab.LabInstance.Id  -g @lab.CloudResourceGroup(CLIRG).Name
```
To stop log streaming at any time, type Ctrl+C. Refresh the webapp in the browser to generate more logs)

## Feedback
If you find errors that are based on actual issues or would like to provide feedback on a command, we provide an enhanced command called `az feedback`. 

```Shell
az feedback
```
Pick any command from your history (esp. failures). 

(Optional) Skip this step if you don't want to sign in to Github. This will open up GitHub and you will have to sign in.  Then a well formatted issue (switch to preview to look at the formatting) will be generated. Look to see that all values have been redacted to protect your private data. Exit out of GitHub (don't submit the issue). 

## Summary
Congratulations, you have successfully managed Azure resources with the Azure CLI.

In this lab, you have completed the following tasks:

- Authenticate against Azure
- Deploy a web app
- Configure local and global defaults
- Understand how to find commands, view diagnostics logs and provide feedback. 

In the next part of the lab we will learn how to automate the Azure PowerShell script that you have just created using Azure CLI to create PowerShell Functions.
