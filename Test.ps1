####Test
$requri = "https://fa-e2evc.azurewebsites.net/api/orchestrators/Orchestration"

#Test to build a new ADC Single Node
#$body = @{type="new";vmsize="standard";vmname="myctxadc";osversion="121";adctype="single";vnetname="vnet-e2evc";subnetName="subnet1"}  | ConvertTo-Json #standard, large, xlarge - 2016,2019,2022
#Test to build a new ADC H/A Node
#$body = @{type="new";vmsize="standard";email="leee.jeffries@leeejeffries.com";version="2016"}  | ConvertTo-Json #standard, large, xlarge - 2016,2019,2022
##Test to query an ADCs details
#$body = @{type="query";vmname="myctxadc"}  | ConvertTo-Json #vmname is mandatory
#Test to remove an ADC
#$body = @{type="remove";vmname="HVGUMDJZOA"}  | ConvertTo-Json #vmname is mandatory

#### Block of code to send the web request ####
try {
    $initialresp = Invoke-RestMethod -Uri $requri -Body $body -Method Post -ContentType "application/json" -UseBasicParsing
    $checkUri = $initialresp.statusQuerygetUri
    write-host $checkUri
    $status = ""
    while($status -ne "Completed") {
        Start-Sleep 15
        $checkresp = Invoke-RestMethod -Uri $checkUri -Method Get
        $status = $checkresp.runtimeStatus
        write-host "$([System.DateTime]::Now.ToLongTimeString()) $status"
        $checkresp
    }
} catch {
    #Tell me the function app is broken and the actual error
    "You broke your function app"
    $Error
}

#### Block of code to send the web request ####