param($params)

#Allow detailed tracing
Set-PSDebug -Trace 1

write-verbose "Entering check.ps1"
$ErrorActionPreference = "Stop"

#Get VM Details
$vmDetails = Get-AzVM -Name $($params.vmname)
if ($vmDetails) {Write-Host "Found VM - $($vmDetails.Name)"} else {Write-Host "VM Not Found"}
if ($vmDetails) {$vmExists = 1} else {$vmExists = 0}

if ($vmExists -eq 1) {
    $publicIPs = $(Get-AZResource -ResourceGroupName $params.rg -Tag @{ADCDeploy="PublicIP"} | Select-Object -ExpandProperty Name) | ForEach-Object {Get-AzPublicIpAddress -Name $_ | Select-Object -ExpandProperty IPAddress}
    Write-Host $publicIPs
}

#Output the results of the script
$details = @{VMExists = $vmExists; IPAddresses = $publicIPs}
$output = @{ScriptOutput = $details}

$output