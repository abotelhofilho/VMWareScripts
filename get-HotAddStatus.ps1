## Import VMware powershell modules
Import-Module VMware.VimAutomation.core
Import-Module VMware.VimAutomation.Cis.Core
## Connect to vCenter
## This is a read-only account, that's why I don't care that the password is in plainText.  Can't wait for future Antonino to have a problem
Connect-VIServer -Server vcenter-01.dchvm.int.wpi.edu -User "psro@vsphere.local" -Password 'sillyWabb1t%052020' -Protocol https | Out-Null
$today = get-date
$path = 'C:\tmp'
$LogFile = $path+'\CPU_Memory_hotaAddEnabled_'+$Today.tostring("MM-dd-yyyy")+".csv"

$Result = (Get-VM | select-object ExtensionData).ExtensionData.config | Select-Object Name, MemoryHotAddEnabled, CpuHotAddEnabled, CpuHotRemoveEnabled
$Result | Export-Csv -NoTypeInformation $LogFile