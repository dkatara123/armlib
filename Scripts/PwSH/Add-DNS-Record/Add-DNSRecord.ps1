$csv = Import-Csv -Path "C:\Users\shabuddinkhan\Downloads\Add-DNS-Record\Add-DNS-Record\KCONP.csv"
$resourceGroupName = "rgp-use-spectrum-core-management-dv1"
$priveZoneName = "kconp.local"
$csv | ForEach-Object {
    $Records = @()
    $Records += New-AzPrivateDnsRecordConfig -IPv4Address $csv.PRIVATEIP
    New-AzPrivateDnsRecordSet -Name $csv.VMNAME `
        -RecordType A `
        -ResourceGroupName $resourceGroupName `
        -TTL 3600 `
        -ZoneName $priveZoneName `
        -PrivateDnsRecords $Records -WhatIf
}
