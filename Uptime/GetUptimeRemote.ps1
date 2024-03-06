param(
    [string]$ComputerName
)

function Get-Uptime-Remote {
    param(
        [string]$ComputerName
    )

    $wmi = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
    $uptime = (Get-Date).Subtract($wmi.ConvertToDateTime($wmi.LastBootUpTime))
   
    $formattedUptime = "{0:D2}:{1:D2}:{2:D2}" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

    Write-Output "$ComputerName uptime: $formattedUptime"
}

if (-not $ComputerName) {
    Write-Error "Please provide a computer name using -ComputerName parameter."
    exit 1
}

Get-Uptime-Remote -ComputerName $ComputerName