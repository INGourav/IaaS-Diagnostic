#This script will delete old extension for Diagnostic
$vmList = Get-Azurermvm -ResourceGroupName "RG-of-VMs"

    foreach($vm in $vmList){
        $status= Get-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
        if ($status.Statuses[1].DisplayStatus -ne "VM running")
        {
            Write-Host $vm.Name" is not running. Skip."
            continue 
        }
        else {
            Write-Host " deleting extension on vm" $vm.Name
            Remove-AzureRmVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name 'Microsoft.Insights.VMDiagnosticsSettings' -force -verbose
           #This line will remove newer version of extension which directly installed with the name IaaSDiagnostic, you can comment this if do not want to unistall so
           Remove-AzureRmVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name 'IaaSDiagnostic' -force -verbose
        }
}
