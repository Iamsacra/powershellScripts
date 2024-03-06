$wmi = Get-WmiObject -Class Win32_OperatingSystem -ComputerName 127.0.0.1 -ErrorAction Stop
$uptime = (Get-Date).Subtract($wmi.ConvertToDateTime($wmi.LastBootUpTime))
   
$formattedUptime = "{0:D2}:{1:D2}:{2:D2}" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

Write-Output "$env:Computername uptime: $formattedUptime"