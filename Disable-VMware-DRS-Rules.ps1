## Import VMware powershell modules
Import-Module VMware.VimAutomation.core
Import-Module VMware.VimAutomation.Cis.Core

## null credentials variable.  Guarantees that the variable is “empty\null” in case it has been used on the same powershell session on a different script or task
$Credentials = $null

## Prompt for credentials
$Credentials = Get-Credential

## Connect to vCenter
Connect-VIServer -Server vcenter-01.dchvm.int.wpi.edu -Credential $Credentials -Protocol https | Out-Null

## List ALL cluster so you can grab the name of the cluster you want to work on
Get-Cluster

## Disable all DRS rules in a cluster
Get-Cluster -Name "<insert cluster name>" | Get-DrsRule | Set-DrsRule -Enabled $false

## Enable all DRS rules in a cluster
Get-Cluster -Name "<insert cluster name>" | Get-DrsRule | Set-DrsRule -Enabled $true
