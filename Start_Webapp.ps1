Param(
    $ARM_SUBSCRIPTION_ID = "",
    $ARM_TENANT_ID = "",
    $ARM_CLIENT_ID = "",
    $ARM_CLIENT_SECRET = "",
    $WebAppConfigurations = @{
        "RG1" = @("WebApp1", "WebApp2");
        "RG2" = @("WebApp1");
        "RG3" = @("WebApp1", "WebApp2", "WebApp3")
    }
)

function authAzure {
    $SecureStringPwd = $ARM_CLIENT_SECRET | ConvertTo-SecureString -AsPlainText -Force
    $pscredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ARM_CLIENT_ID, $SecureStringPwd
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $ARM_TENANT_ID
    Set-AzContext -SubscriptionId $ARM_SUBSCRIPTION_ID
    StartWebApps $WebAppConfigurations
}

function StartWebApps($WebAppConfigurations) {
    foreach ($resourceGroup in $WebAppConfigurations.Keys) {
        $webApps = $WebAppConfigurations[$resourceGroup]
        $resourceGroupName = $resourceGroup

        foreach ($webAppName in $webApps) {
            $webApp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName
            
            if (!$webApp) {
                Write-Output "Web App $webAppName not found in resource group $resourceGroupName"
                continue
            }

            if ($webApp.State -eq "Running") {
                Write-Output "Web App $webAppName is already running"
            }
            else {
                Start-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName
                Write-Output "Started Web App $webAppName in resource group $resourceGroupName"
            }
        }
    }
}
authAzure
