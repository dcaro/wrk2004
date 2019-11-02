using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$sku = $request.Query.Sku
$webAppName = $request.Query.WebAppName
$resourceGroupName = $Request.Query.ResourceGroupName

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
    catch {
        Resolve-AzError
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