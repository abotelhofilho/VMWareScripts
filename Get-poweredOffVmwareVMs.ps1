## Import VMware powershell modules
Import-Module VMware.VimAutomation.core
Import-Module VMware.VimAutomation.Cis.Core

$vCenter = '<Enter vCenter FQDN>'

## Connect to vCenter
## I use a read-only local vCenter account, that's why I don't care that the password is in plainText.
## if you are concerned, please go ahead and fork it and change it to work to your desire.
Connect-VIServer -Server $vCenter -User "<username>" -Password '<enter password>' -Protocol https | Out-Null

## Make report of poweredOff VMs (I didn't make this "report" section
$Report = @()
$VMs = get-vm | Where-object {$_.powerstate -eq "poweredoff"}
$Datastores = Get-Datastore | Select-Object Name, Id
$PowerOffEvents = Get-VIEvent -Entity $VMs -MaxSamples ([int]::MaxValue) | Where-Object {$_ -is [VMware.Vim.VmPoweredOffEvent]} | Group-Object -Property {$_.Vm.Name}
foreach ($VM in $VMs) {
    $lastPO = ($PowerOffEvents | Where-Object { $_.Group[0].Vm.Vm -eq $VM.Id }).Group | Sort-Object -Property CreatedTime -Descending | Select-Object -First 1
    $row = "" | Select-Object VMName,Powerstate,OS,Host,Cluster,Datastore,NumCPU,MemMb,DiskGb,PoweredOffTime,PoweredOffBy
    $row.VMName = $vm.Name
    $row.Powerstate = $vm.Powerstate
    $row.OS = $vm.Guest.OSFullName
    $row.Host = $vm.VMHost.name
    $row.Cluster = $vm.VMHost.Parent.Name
    $row.Datastore = $Datastores | Where-Object{$_.Id -eq ($vm.DatastoreIdList | Select-Object -First 1)} | Select-Object -ExpandProperty Name
    $row.NumCPU = $vm.NumCPU
    $row.MemMb = $vm.MemoryMB
    $row.DiskGb = Get-HardDisk -VM $vm | Measure-Object -Property CapacityGB -Sum | Select-Object -ExpandProperty Sum
    $row.PoweredOffTime = $lastPO.CreatedTime
    $row.PoweredOffBy   = $lastPO.UserName
    $report += $row
}

## Export and send report over email
$smtpServer = '<Enter open relay SMTP server FQDN>' ## if your smtp relay uses authentication, please edit the Send-MailMessage command accordingly
$today = get-date
$path = $env:systemroot+"\temp\"
$fileName = $path+'\poweredOffVMs_'+$Today.tostring("MM-dd-yyyy")+".csv"
$30DaysAgo = (get-date).addDays(-30)
$report = $report | Where-Object PoweredOffTime -lt $30DaysAgo
$report | Sort-Object PoweredOffTime -Descending | Select-Object VMName,Powerstate,OS,Cluster | Export-Csv $fileName -NoTypeInformation
$mailrcpt = "<Enter Email receipient>"
$from = $env:computername
Send-MailMessage -To "$mailrcpt" -Subject "VMware poweredOffVMs older than 30 days - $Today" -From "$from" -Body "VMware poweredOffVMs older than 30 days - $Today" -SmtpServer "$smtpServer" -Attachments $fileName
