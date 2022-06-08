param($params)

#Allow detailed tracing
Set-PSDebug -Trace 0

write-verbose "Entering build.ps1"
$global:erroractionpreference = 1

# Complete the parameter object for the ARM Template Build 
$paramObj = @{`
    virtualMachineName=$params.vmname;`
    virtualMachineSize=$params.ADCSize;`
    ADCVersion=$params.OSVersion;`
    adminUsername=$params.localAdminName;`
    adminPassword=$params.localAdminPassword;`
    virtualNetworkName=$params.vmVnet;`
    vnetResourceGroup=$params.rg;`
    subnetName=$params.vmSubnet;`
}   

#Check if the Resource Group Exists, if it doesn't create it with a tag of ADCDeployed = Resouce
if (!(Get-AZResourceGroup -Name $params.rg -ErrorAction SilentlyContinue)) {New-AzResourceGroup -Name $params.rg -Location $params.location}

# Deploy the Citrix ADC
If ($params.ADCType -eq "HA") {
    New-AzResourceGroupDeployment -Name "ADCDeploy-$(Get-Date -Format 'ddMMyyyyHHmm')" -ResourceGroupName "rg-e2evc" -TemplateUri "https://raw.githubusercontent.com/leeej84/Azure_ADC_Deploy/main/ARM/singleNicADCHA.json" -TemplateParameterObject  $paramObj -Verbose
} else {
    New-AzResourceGroupDeployment -Name "ADCDeploy-$(Get-Date -Format 'ddMMyyyyHHmm')" -ResourceGroupName "rg-e2evc" -TemplateUri "https://raw.githubusercontent.com/leeej84/Azure_ADC_Deploy/main/ARM/singleNicADCExpress.json" -TemplateParameterObject  $paramObj -Verbose
}

#ADC Deployment Completed
#Send back the public IP and login details
#If VMExists - also query Public IP's in the RG
$publicIPs = $(Get-AZResource -ResourceGroupName $params.rg -Tag @{ADCDeploy="PublicIP"} | Select-Object -ExpandProperty Name) | ForEach-Object {Get-AzPublicIpAddress -Name $_ | Select-Object -ExpandProperty IPAddress}

#Get-AZResource where tag equals ADCDeploy - PublicIP
Write-Host "Finished creating ADCs"

#Output the results of the script
$output = @{ScriptOutput = "Virtual Machine Created Successfully - VMName: $($params.vmname) - Login Name: $($params.localAdminName) - Password: $($params.localAdminPassword) - Public IPs: $($publicIPs) - SAVE THIS INFORMATION"}

$output