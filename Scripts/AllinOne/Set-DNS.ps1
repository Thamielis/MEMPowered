$cred = Get-Credential -Credential eskonr\eswar
$ErrorActionPreference = "Inquire"
Get-Content .\servers.txt| `
ForEach-Object {
 if (Test-Connection $_ ) {
  $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -Credential $cred -Computername  $_ -ErrorAction SilentlyContinue | Where-Object {$_.IPEnabled -eq "True"}
  Foreach($NIC in $NICs) {
$DNSServers = "10.166.56.20","128.230.127.62"
$NIC.SetDNSServerSearchOrder($DNSServers)
$NIC.SetDynamicDNSRegistration("TRUE")
}                
}
}