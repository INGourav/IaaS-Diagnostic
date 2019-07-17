#Paste Storage Account that you want to use for Diagnostic log collection
#Need to Edit
$storageAccountName= 'teststorage'

#Paste Storage Account Resource Group Name
#Need to Edit
$storageAccountRG= 'test-storage-rg'

#Paste Storage Account Location
#Need to Edit
$storageAccountLocation= 'Canada Central'

#Paste VMs Resource Group for all you want to enable Memory Diagnostic
#Need to Edit
$VMRG= 'test-vm-rg'

#Storing Storage Account Infomration into Variable that would be later on by the same script 
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $storageAccountRG -Name $storageAccountName


# if the extension has existed, just skip
function Enable-LinuxDiagnosticsExtension($rsgName,$rsgLocation,$vmId,$vmName){
    $extensionType="LinuxDiagnostic"
    $extensionName = "LinuxDiagnostic"
    $vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rsgName
    $extension = $vm.Extensions | Where-Object -Property 'VirtualMachineExtensionType' -eq $extensionType
    if($extension -and $extension.ProvisioningState -eq 'Succeeded'){
        Write-Host "just skip,due to diagnostics extension had been installed in VM: "$vmName " before,you can update the diagnostics settings via portal or powershell cmdlets by yourself"
        return
    }
    Write-Host "start to install the diagnostics extension for linux VM"
    

#Fectcing Storage Account Key to use for data storation and enablment of Diagnostic logs
    $storageName = $storageAccountName
    Write-Host "storageName:" $storageName
    $storageAccount = Get-Azurermstorageaccount -ResourceGroupName $storageAccountRG -StorageAccountName $storageAccountName
    #$storageAccount = $storageAccount
    $storageKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRG -Name $storageName;
    $storageKey = $storageKeys[0].Value;
    Write-Host "storageKey:" $storageKey

    $xmlCfgContentForLinux ='<WadCfg><DiagnosticMonitorConfiguration overallQuotaInMB="4096"><DiagnosticInfrastructureLogs scheduledTransferPeriod="PT1M" scheduledTransferLogLevelFilter="Warning"/><PerformanceCounters scheduledTransferPeriod="PT1M"><PerformanceCounterConfiguration counterSpecifier="\Memory\AvailableMemory" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\PercentAvailableMemory" sampleRate="PT15S" unit="Percent"><annotation displayName="Mem. percent available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\UsedMemory" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory used" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\PercentUsedMemory" sampleRate="PT15S" unit="Percent"><annotation displayName="Memory percentage" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\PercentUsedByCache" sampleRate="PT15S" unit="Percent"><annotation displayName="Mem. used by cache" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\PagesPerSec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Pages" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\PagesReadPerSec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Page reads" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\PagesWrittenPerSec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Page writes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\AvailableSwap" sampleRate="PT15S" unit="Bytes"><annotation displayName="Swap available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\PercentAvailableSwap" sampleRate="PT15S" unit="Percent"><annotation displayName="Swap percent available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\UsedSwap" sampleRate="PT15S" unit="Bytes"><annotation displayName="Swap used" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\PercentUsedSwap" sampleRate="PT15S" unit="Percent"><annotation displayName="Swap percent used" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor\PercentIdleTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU idle time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor\PercentUserTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU user time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor\PercentNiceTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU nice time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor\PercentPrivilegedTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU privileged time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor\PercentInterruptTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU interrupt time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor\PercentDPCTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU DPC time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor\PercentProcessorTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU percentage guest OS" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor\PercentIOWaitTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU IO wait time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\BytesPerSecond" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk total bytes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\ReadBytesPerSecond" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk read guest OS" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\WriteBytesPerSecond" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk write guest OS" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\TransfersPerSecond" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk transfers" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\ReadsPerSecond" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk reads" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\WritesPerSecond" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk writes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\AverageReadTime" sampleRate="PT15S" unit="Seconds"><annotation displayName="Disk read time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\AverageWriteTime" sampleRate="PT15S" unit="Seconds"><annotation displayName="Disk write time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\AverageTransferTime" sampleRate="PT15S" unit="Seconds"><annotation displayName="Disk transfer time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk\AverageDiskQueueLength" sampleRate="PT15S" unit="Count"><annotation displayName="Disk queue length" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\NetworkInterface\BytesTransmitted" sampleRate="PT15S" unit="Bytes"><annotation displayName="Network out guest OS" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\NetworkInterface\BytesReceived" sampleRate="PT15S" unit="Bytes"><annotation displayName="Network in guest OS" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\NetworkInterface\PacketsTransmitted" sampleRate="PT15S" unit="Count"><annotation displayName="Packets sent" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\NetworkInterface\PacketsReceived" sampleRate="PT15S" unit="Count"><annotation displayName="Packets received" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\NetworkInterface\BytesTotal" sampleRate="PT15S" unit="Bytes"><annotation displayName="Network total bytes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\NetworkInterface\TotalRxErrors" sampleRate="PT15S" unit="Count"><annotation displayName="Packets received errors" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\NetworkInterface\TotalTxErrors" sampleRate="PT15S" unit="Count"><annotation displayName="Packets sent errors" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\NetworkInterface\TotalCollisions" sampleRate="PT15S" unit="Count"><annotation displayName="Network collisions" locale="en-us"/></PerformanceCounterConfiguration></PerformanceCounters><Metrics resourceId="'+$vmId+'"><MetricAggregation scheduledTransferPeriod="PT1H"/><MetricAggregation scheduledTransferPeriod="PT1M"/></Metrics></DiagnosticMonitorConfiguration></WadCfg>'

    $xmlCfgPath =Join-Path $deployExtensionLogDir "linuxxmlcfg.xml";

    Out-File -FilePath $xmlCfgPath -force -Encoding utf8 -InputObject $xmlCfgContentForLinux

    $encodingXmlCfg =  [System.Convert]::ToBase64String([system.Text.Encoding]::UTF8.GetBytes($xmlCfgContentForLinux));

    $vmLocation = $storageAccountLocation
    $settingsString = '{
            "StorageAccount": "'+$storageName+'",
            "xmlCfg": "'+$encodingXmlCfg+'"
    }'
    $settingsStringPath = Join-Path $deployExtensionLogDir "linuxsettings.json"

    Out-File -FilePath $settingsStringPath -Force -Encoding utf8 -InputObject $settingsString
    
    $extensionPublisher = 'Microsoft.OSTCExtensions'
    $extensionVersion = "2.3"
    $privateCfg = '{
    "storageAccountName": "'+$storageName+'",
    "storageAccountKey": "'+$storageKey+'"
}'
    $extensionType = "LinuxDiagnostic"
    Set-AzureRmVMExtension -ResourceGroupName $rsgName -VMName $vmName -Name $extensionName -Publisher $extensionPublisher -ExtensionType $extensionType -TypeHandlerVersion $extensionVersion -Settingstring $settingsString -ProtectedSettingString $privateCfg -Location $vmLocation
  
}


function Enable-WindowsDiagnosticsExtension($rsgName,$rsgLocation,$vmId,$vmName){
    $extensionName = "IaaSDiagnostics"
    $extensionType = "IaaSDiagnostics"
   
    $extension = Get-AzureRmVMDiagnosticsExtension -ResourceGroupName $rsgName -VMName $vmName | Where-Object -Property ExtensionType -eq $extensionType
    if($extension -and $extension.ProvisioningState -eq 'Succeeded'){
        Write-Host "just skip,due to diagnostics extension had been installed in VM: "$vmName " before,you can update the diagnostics settings via portal or powershell cmdlets by yourself"
        return
    }
    Write-Host "start to install the diagnostics extension for windows VM"

        $storageName = $storageAccountName
        Write-Host "storageName:" $storageName
        $storageAccount = $storageAccount
        $storageKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRG -Name $storageAccountName;
        $storageKey = $storageKeys[0].Value;
        Write-Host "storageKey:" $storageKey  

        $vmLocation = $rsgLocation

        $extensionTemplate = '{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Compute/virtualMachines/extensions",
            "name": "'+$vmName+'/'+$extensionName+'",
            "apiVersion": "2016-04-30-preview",
            "location": "'+$vmLocation+'",
            "properties": {
                "publisher": "Microsoft.Azure.Diagnostics",
                "type": "IaaSDiagnostics",
                "typeHandlerVersion": "1.5",
                "autoUpgradeMinorVersion": true,
                "protectedSettings": {
                    "storageAccountName": "'+$storageName+'",
                    "storageAccountKey": "'+$storageKey+'",
                    "storageAccountEndPoint": "https://core.windows.net"
                },
                "settings": {
                    "StorageAccount": "'+$storageName+'",
                    "WadCfg": {
                        "DiagnosticMonitorConfiguration": {
                            "overallQuotaInMB": 5120,
                            "Metrics": {
                                "resourceId": "'+$vmId+'",
                                "MetricAggregation": [
                                    {
                                        "scheduledTransferPeriod": "PT1H"
                                    },
                                    {
                                        "scheduledTransferPeriod": "PT1M"
                                    }
                                ]
                            },
                            "DiagnosticInfrastructureLogs": {
                                "scheduledTransferLogLevelFilter": "Error",
                                "scheduledTransferPeriod": "PT1M"
                            },
                            "PerformanceCounters": {
                                "scheduledTransferPeriod": "PT1M",
                                "PerformanceCounterConfiguration": [
                                    {
                                        "counterSpecifier": "\\Processor Information(_Total)\\% Processor Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Processor Information(_Total)\\% Privileged Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Processor Information(_Total)\\% User Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Processor Information(_Total)\\Processor Frequency",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\System\\Processes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(_Total)\\Thread Count",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(_Total)\\Handle Count",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\System\\System Up Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\System\\Context Switches/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\System\\Processor Queue Length",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\% Committed Bytes In Use",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\Available Bytes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\Committed Bytes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\Cache Bytes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\Pool Paged Bytes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\Pool Nonpaged Bytes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\Pages/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\Page Faults/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(_Total)\\Working Set",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(_Total)\\Working Set - Private",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\% Disk Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\% Disk Read Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\% Disk Write Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\% Idle Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Bytes/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Read Bytes/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Write Bytes/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Transfers/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Reads/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Writes/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk sec/Read",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk sec/Write",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk Queue Length",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\% Free Space",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\LogicalDisk(_Total)\\Free Megabytes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Network Interface(*)\\Bytes Total/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Network Interface(*)\\Bytes Sent/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Network Interface(*)\\Bytes Received/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Network Interface(*)\\Packets/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Network Interface(*)\\Packets Sent/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Network Interface(*)\\Packets Received/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Network Interface(*)\\Packets Outbound Errors",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Network Interface(*)\\Packets Received Errors",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Exceptions(w3wp)\\# of Exceps Thrown / sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Interop(w3wp)\\# of marshalling",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Jit(w3wp)\\% Time in Jit",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Loading(w3wp)\\Current appdomains",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Loading(w3wp)\\Current Assemblies",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Loading(w3wp)\\% Time Loading",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Loading(w3wp)\\Bytes in Loader Heap",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR LocksAndThreads(w3wp)\\Contention Rate / sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR LocksAndThreads(w3wp)\\Current Queue Length",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Memory(w3wp)\\# Gen 0 Collections",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Memory(w3wp)\\# Gen 1 Collections",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Memory(w3wp)\\# Gen 2 Collections",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Memory(w3wp)\\% Time in GC",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Memory(w3wp)\\# Bytes in all Heaps",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Networking(w3wp)\\Connections Established",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Networking 4.0.0.0(w3wp)\\Connections Established",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\.NET CLR Remoting(w3wp)\\Remote Calls/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Application Restarts",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Applications Running",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Requests Current",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Request Execution Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Requests Queued",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Requests Rejected",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Request Wait Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Requests Disconnected",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Worker Processes Running",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET\\Worker Process Restarts",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Application Restarts",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Applications Running",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Requests Current",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Request Execution Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Requests Queued",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Requests Rejected",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Request Wait Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Requests Disconnected",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Worker Processes Running",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET v4.0.30319\\Worker Process Restarts",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Anonymous Requests",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Anonymous Requests/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache Total Entries",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache Total Turnover Rate",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache Total Hits",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache Total Misses",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache Total Hit Ratio",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache API Entries",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache API Turnover Rate",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache API Hits",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache API Misses",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Cache API Hit Ratio",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Output Cache Entries",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Output Cache Turnover Rate",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Output Cache Hits",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Output Cache Misses",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Output Cache Hit Ratio",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Compilations Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Debugging Requests",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Errors During Preprocessing",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Errors During Compilation",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Errors During Execution",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Errors Unhandled During Execution",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Errors Unhandled During Execution/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Errors Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Errors Total/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Pipeline Instance Count",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Request Bytes In Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Request Bytes Out Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests Executing",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests Failed",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests Not Found",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests Not Authorized",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests In Application Queue",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests Timed Out",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests Succeeded",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Requests/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Sessions Active",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Sessions Abandoned",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Sessions Timed Out",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Sessions Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Transactions Aborted",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Transactions Committed",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Transactions Pending",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Transactions Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Applications(__Total__)\\Transactions/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Anonymous Requests",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Anonymous Requests/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache Total Entries",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache Total Turnover Rate",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache Total Hits",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache Total Misses",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache Total Hit Ratio",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache API Entries",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache API Turnover Rate",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache API Hits",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache API Misses",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Cache API Hit Ratio",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Output Cache Entries",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Output Cache Turnover Rate",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Output Cache Hits",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Output Cache Misses",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Output Cache Hit Ratio",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Compilations Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Debugging Requests",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Errors During Preprocessing",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Errors During Compilation",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Errors During Execution",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Errors Unhandled During Execution",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Errors Unhandled During Execution/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Errors Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Errors Total/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Pipeline Instance Count",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Request Bytes In Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Request Bytes Out Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests Executing",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests Failed",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests Not Found",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests Not Authorized",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests In Application Queue",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests Timed Out",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests Succeeded",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Requests/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Sessions Active",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Sessions Abandoned",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Sessions Timed Out",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Sessions Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Transactions Aborted",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Transactions Committed",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Transactions Pending",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Transactions Total",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\ASP.NET Apps v4.0.30319(__Total__)\\Transactions/Sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(w3wp)\\% Processor Time",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(w3wp)\\Virtual Bytes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(w3wp)\\Private Bytes",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(w3wp)\\Thread Count",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Process(w3wp)\\Handle Count",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Web Service(_Total)\\Bytes Total/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Web Service(_Total)\\Current Connections",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Web Service(_Total)\\Total Method Requests/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\Web Service(_Total)\\ISAPI Extension Requests/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:Buffer Manager\\Page reads/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:Buffer Manager\\Page writes/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:Buffer Manager\\Checkpoint pages/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:Buffer Manager\\Lazy writes/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:Buffer Manager\\Buffer cache hit ratio",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:Buffer Manager\\Database pages",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:Memory Manager\\Total Server Memory (KB)",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:Memory Manager\\Memory Grants Pending",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:General Statistics\\User Connections",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:SQL Statistics\\Batch Requests/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:SQL Statistics\\SQL Compilations/sec",
                                        "sampleRate": "PT60S"
                                    },
                                    {
                                        "counterSpecifier": "\\SQLServer:SQL Statistics\\SQL Re-Compilations/sec",
                                        "sampleRate": "PT60S"
                                    }
                                ]
                            },
                            "WindowsEventLog": {
                                "scheduledTransferPeriod": "PT1M",
                                "DataSource": [
                                    {
                                        "name": "Application!*[Application[(Level=1 or Level=2 or Level=3)]]"
                                    },
                                    {
                                        "name": "System!*[System[(Level=1 or Level=2 or Level=3)]]"
                                    },
                                    {
                                        "name": "Security!*[System[(band(Keywords,4503599627370496))]]"
                                    }
                                ]
                            },
                            "Directories": {
                                "scheduledTransferPeriod": "PT1M"
                            }
                        }
                    }
                }
            }
        }
    ]
}'
    $extensionTemplatePath = Join-Path $deployExtensionLogDir "extensionTemplateForWindows.json";
    Out-File -FilePath $extensionTemplatePath -Force -Encoding utf8 -InputObject $extensionTemplate
    New-AzureRmResourceGroupDeployment -ResourceGroupName $rsgName -TemplateFile $extensionTemplatePath
}

$deployExtensionLogDir = split-path -parent $MyInvocation.MyCommand.Definition

#Storing VM list that have to go for Diagnostic Enablement

$vmList = $null
if($targetVmName -and $targetRsgName){
    Write-Host "you have input the rsg name:" $targetRsgName " vm's name:" $targetVmName
    $vmList = Get-AzureRmVM -Name $targetVmName -ResourceGroupName $targetRsgName
} else {
    Write-Host "you have not input the target vm's name and will retrieve all vms"
    #$vmList = Get-AzureRmVM 
     $vmList = Get-Azurermvm -ResourceGroupName $VMRG
}

if($vmList){
    foreach($vm in $vmList){
        $status= Get-AzureRmVM -ResourceGroupName $VMRG -Name $vm.Name -Status
        if ($status.Statuses[1].DisplayStatus -ne "VM running")
        {
            Write-Host $vm.Name" is not running. Skip."
            continue 
        }
        $rsgName = $vm.ResourceGroupName;
        $rsg = Get-AzureRmResourceGroup -Name $rsgName
        $rsgLocation = $vm.Location;

        $vmId = $vm.Id
        $vmName = $vm.Name
        Write-Host "vmId:" $vmId
        Write-Host "vmName:" $vmName

        $osType = $vm.StorageProfile.OsDisk.OsType
        Write-Host "OsType:" $osType

        if($osType -eq 0){
            Write-Host "this vm type is windows"
            Enable-WindowsDiagnosticsExtension -rsgName $rsgName -rsgLocation $rsgLocation -vmId $vmId -vmName $vmName
        } else {
            Write-Host "this vm type is linux"
            Enable-LinuxDiagnosticsExtension -rsgName $rsgName -rsgLocation $rsgLocation -vmId $vmId -vmName $vmName
        }
    }
} else {
    Write-Host "no vms exist"
}

#Source of Script: - https://helpdesk.kaseya.com/hc/en-gb/articles/115002525972-How-To-Enable-Azure-Diagnostics-For-VMs-Using-PowerShell-Script-
# Thanks to Christine Pando for creating this wonderful script, I have added counter for Memory and Customized it as per bulk requirement based on subscription 
