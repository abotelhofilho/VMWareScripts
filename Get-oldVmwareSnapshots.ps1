## Import VMware powershell modules
Import-Module VMware.VimAutomation.core
Import-Module VMware.VimAutomation.Cis.Core
## Connect to vCenter
## This is a read-only account, that's why I don't care that the password is in plainText.  Can't wait for future Antonino to have a problem
Connect-VIServer -Server vcenter-01.dchvm.int.wpi.edu -User "psro@vsphere.local" -Password 'sillyWabb1t%052020' -Protocol https | Out-Null
## Get snapshots for ALL VMs
$ohSnaps = get-vm | Get-Snapshot
## Set 15 days ago date var
$15DaysAgo = (get-date).addDays(-15)
## Filter for snapshots that are older than 15 days and export to CSV
$oldSnaps = $ohsnaps | Where-Object Created -lt $15DaysAgo | Select-Object VM,Name,Description,Created | Sort-Object Created
## Export oldSnaps var to CSV and email it
$today = get-date
$path = $env:systemroot+"\temp\"
$fileName = $path+'\snapshots_'+$Today.tostring("MM-dd-yyyy")+".csv"
$oldSnaps | Export-Csv $Filename -NoTypeInformation
$mailrcpt = "vmwarealerts@wpi.edu"
$from = $env:computername
Send-MailMessage -To "$mailrcpt" -Subject "VMware snapshots older than 15 days - $Today" -From "$from@wpi.edu" -Body "VMware snapshots older than 15 days - $Today" -SmtpServer "smtp.wpi.edu" -Attachments $fileName