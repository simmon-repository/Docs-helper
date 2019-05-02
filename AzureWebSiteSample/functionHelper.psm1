    
$ErrorActionPreference = "Stop"

$WebAppApiVersion = "2015-08-01"

## WebHostingPlan operations

# Example call: ListAppServicePlans MyResourceGroup
Function ListAppServicePlans($ResourceGroupName)
{
    Find-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -ApiVersion 2015-11-01
}

# Example call: GetAppServicePlan MyResourceGroup MyWHP
Function GetAppServicePlan($ResourceGroupName, $PlanName)
{
    Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -Name $PlanName -ApiVersion $WebAppApiVersion
}

# Example call: CreateAppServicePlan MyResourceGroup "North Europe" MyHostingPlan
Function CreateAppServicePlan($ResourceGroupName, $Location, $PlanName, $SkuName = "F1", $SkuTier = "Free")
{
    $fullObject = @{
        location = $Location
        sku = @{
            name = $SkuName
            tier = $SkuTier
        }
    }

    New-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -Name $PlanName -IsFullObject -PropertyObject $fullObject -ApiVersion $WebAppApiVersion -Force
}

# Example call: DeleteWebApp MyResourceGroup MySite
Function DeleteAppServicePlan($ResourceGroupName, $PlanName)
{
    Remove-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -Name $PlanName -ApiVersion $WebAppApiVersion -Force
}



## Site operations

# Example call: ListWebApps MyResourceGroup
Function ListWebApps($ResourceGroupName)
{
    Find-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites -ApiVersion 2015-11-01
}

# Example call: GetWebApp MyResourceGroup MySite
Function GetWebApp($ResourceGroupName, $SiteName)
{
    Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites -Name $SiteName -ApiVersion $WebAppApiVersion
}

# Example call: CreateWebApp MyResourceGroup "North Europe" MySite DefaultServerFarm
Function CreateWebApp($ResourceGroupName, $Location, $SiteName, $PlanName)
{
    New-AzureRmResource -ResourceGroupName $ResourceGroupName -Location $Location -ResourceType Microsoft.Web/sites -Name $SiteName -PropertyObject @{ webHostingPlan = $PlanName } -ApiVersion $WebAppApiVersion -Force
}

# Example call: DeleteWebApp MyResourceGroup MySite
Function DeleteWebApp($ResourceGroupName, $SiteName)
{
    Remove-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites -Name $SiteName -ApiVersion $WebAppApiVersion -Force
}

# Example call: $planId = GetSiteAppServicePlanId MyResourceGroup MySite
Function GetSiteAppServicePlanId($ResourceGroupName, $SiteName)
{
    $site = GetWebApp $ResourceGroupName $SiteName
    $site.Properties.serverFarmId
}


## Site config operations

# Example call: GetWebAppConfig MyResourceGroup MySite
Function GetWebAppConfig($ResourceGroupName, $SiteName)
{
    Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/web -ApiVersion $WebAppApiVersion
}

# Example call: SetWebAppConfig MyResourceGroup MySite $ConfigObject
Function SetWebAppConfig($ResourceGroupName, $SiteName, $ConfigObject)
{
    Set-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/web -PropertyObject $ConfigObject -ApiVersion $WebAppApiVersion -Force
}

# Example call: $phpVersion = GetPHPVersion MyResourceGroup MySite
Function GetPHPVersion($ResourceGroupName, $SiteName)
{
    $config = GetWebAppConfig $ResourceGroupName $SiteName
    $config.Properties.phpVersion
}

# Example call: SetPHPVersion MyResourceGroup MySite 5.6
Function SetPHPVersion($ResourceGroupName, $SiteName, $PHPVersion)
{
    SetWebAppConfig $ResourceGroupName $SiteName @{ "phpVersion" = $PHPVersion }
}


## App Settings

# Example call: GetWebAppAppSettings MyResourceGroup MySite
Function GetWebAppAppSettings($ResourceGroupName, $SiteName)
{
    $res = Invoke-AzureRmResourceAction -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/appsettings -Action list -ApiVersion $WebAppApiVersion -Force
    $res.Properties
}

# Example call: SetWebAppAppSettings MyResourceGroup MySite @{ key1 = "val1"; key2 = "val2" }
Function SetWebAppAppSettings($ResourceGroupName, $SiteName, $AppSettingsObject)
{
    New-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/appsettings -PropertyObject $AppSettingsObject -ApiVersion $WebAppApiVersion -Force
}


## Connection Strings

# Example call: GetWebAppConnectionStrings MyResourceGroup MySite
Function GetWebAppConnectionStrings($ResourceGroupName, $SiteName)
{
    $res = Invoke-AzureRmResourceAction -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/connectionstrings -Action list -ApiVersion $WebAppApiVersion -Force
    $res.Properties
}

# Example call: SetWebAppConnectionStrings MyResourceGroup MySite @{ conn1 = @{ Value = "Some connection string"; Type = 2  } }
Function SetWebAppConnectionStrings($ResourceGroupName, $SiteName, $ConnectionStringsObject)
{
    New-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/connectionstrings -PropertyObject $ConnectionStringsObject -ApiVersion $WebAppApiVersion -Force
}


## Slot settings

# Example call: GetSlotSettings MyResourceGroup MySite
Function GetSlotSettings($ResourceGroupName, $SiteName)
{
    $res = Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/slotConfigNames -ApiVersion $WebAppApiVersion
    $res.Properties
}

# Example call: SetSlotSettings MyResourceGroup MySite @{ appSettingNames = @("Setting1"); connectionStringNames = @("Conn1","Conn2") }
Function SetSlotSettings($ResourceGroupName, $SiteName, $SlotSettingsObject)
{
    New-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/slotConfigNames -PropertyObject $SlotSettingsObject -ApiVersion $WebAppApiVersion -Force
}



## Deployment related operations

# Example call: DeployCloudHostedPackage MyResourceGroup "West US" MySite https://auxmktplceprod.blob.core.windows.net/packages/Bakery.zip
Function DeployCloudHostedPackage($ResourceGroupName, $Location, $SiteName, $packageUrl)
{
    New-AzureRmResource -ResourceGroupName $ResourceGroupName -Location $Location -ResourceType Microsoft.Web/sites/Extensions -Name $SiteName/MSDeploy -PropertyObject @{ "packageUri" = $packageUrl } -ApiVersion $WebAppApiVersion -Force
}

# Example call: GetPublishingProfile MyResourceGroup "MySite
Function GetPublishingProfile($ResourceGroupName, $SiteName)
{
    $ParametersObject = @{
	    format = "xml"
    }

    Invoke-AzureRmResourceAction -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites -ResourceName $SiteName -Action publishxml -Parameters $ParametersObject -ApiVersion $WebAppApiVersion -Force
}

# Example call: GetPublishingCredentials MyResourceGroup "MySite
Function GetPublishingCredentials($ResourceGroupName, $SiteName)
{
    $resource = Invoke-AzureRmResourceAction -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName $SiteName/publishingcredentials -Action list -ApiVersion 2015-08-01 -Force
    $resource.Properties
}

# Deploy from an external git repo
Function HookupExternalGitRepo($ResourceGroupName, $SiteName, $repoUrl)
{
    $props = @{
        RepoUrl = $repoUrl
        Branch = "master"
        IsManualIntegration = true
    }

    New-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/SourceControls -Name $SiteName/Web -PropertyObject $props -ApiVersion $WebAppApiVersion -Force
}

# Get the list of git deployments
Function GetGitDeployments($ResourceGroupName, $SiteName)
{
    Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Deployments -Name $SiteName -ApiVersion $WebAppApiVersion
}


## Site extension operations

# Example call: ListWebAppSiteExtensions MyResourceGroup MySite
Function ListWebAppSiteExtensions($ResourceGroupName, $SiteName)
{
    Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/siteextensions -Name $SiteName -ApiVersion $WebAppApiVersion -IsCollection
}

# Example call: InstallSiteExtension MyResourceGroup MySite filecounter
Function InstallSiteExtension($ResourceGroupName, $SiteName, $Name)
{
    New-AzureRmResource -ResourceGroupName $ResourceGroupName -Location $Location -ResourceType Microsoft.Web/sites/siteextensions -Name $SiteName/$Name -PropertyObject @{} -ApiVersion $WebAppApiVersion -Force
}

# Example call: UninstallSiteExtension MyResourceGroup MySite filecounter
Function UninstallSiteExtension($ResourceGroupName, $SiteName, $Name)
{
    Remove-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/siteextensions -Name $SiteName/$Name -ApiVersion $WebAppApiVersion -Force
}


## Certificate operations

# Example call: UploadCert MyResourceGroup "North Europe" foo.pfx "MyPassword!" MyTestCert
Function UploadCert($ResourceGroupName, $Location, $PfxPath, $PfxPassword, $CertName)
{
    # Read the raw bytes of the pfx file
    $pfxBytes = get-content $PfxPath -Encoding Byte

    $props = @{
        PfxBlob = [System.Convert]::ToBase64String($pfxBytes)
        Password = $PfxPassword
    }

    New-AzureRmResource -Location $Location -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/certificates -Name $CertName -PropertyObject $props -ApiVersion $WebAppApiVersion -Force
}

# Example call: DeleteCert MyResourceGroup MyCert
Function DeleteCert($ResourceGroupName, $CertName)
{
    Remove-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/certificates -Name $CertName -ApiVersion $WebAppApiVersion -Force
}


## Premium Add-Ons

Function GetWebAppAddons($ResourceGroupName, $SiteName)
{
    Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/premieraddons -Name $SiteName -ApiVersion $WebAppApiVersion -IsCollection
}

Function AddZrayAddon($ResourceGroupName, $Location, $SiteName, $Name, $PlanName)
{
    $plan = @{
        name = $PlanName
        publisher = "zend-technologies"
        product = "z-ray"
    }

    New-AzureRmResource -ResourceGroupName $ResourceGroupName -Location $Location -ResourceType Microsoft.Web/sites/premieraddons -Name $SiteName/$Name -Properties @{} -PlanObject $plan -ApiVersion $WebAppApiVersion -Force
}

Function RemoveWebAppAddon($ResourceGroupName, $SiteName, $Name)
{
    Remove-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/premieraddons -Name $SiteName/$Name -ApiVersion $WebAppApiVersion -Force
}

## Sync repository

Function SyncWebApp($ResourceGroupName, $SiteName)
{
    Invoke-AzureRmResourceAction -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites -Name $SiteName  -Action sync -ApiVersion $WebAppApiVersion -Force
}
