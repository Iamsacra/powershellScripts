# Start-sleep -seconds 15
# set-executionpolicy remotesigned
$Disk=Get-BitLockerVolume | Where-Object -property volumeType -eq 'OperatingSystem' | Select-Object -Property mountPoint
Enable-Bitlocker -MountPoint $Disk.Mountpoint -RecoveryPasswordProtector -SkipHardwareTest

# Disk Encryption without pin
Enable-BitLocker -MountPoint $Disk.Mountpoint -EncryptionMethod Aes256 -RecoveryPasswordProtector -SkipHardwareTest -ErrorAction SilentlyContinue

# Get Password and save it on temp
$recoveryPasswordC = (Get-BitLockerVolume -MountPoint "C").KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' } | Select-Object -ExpandProperty RecoveryPassword -First 1
if ($recoveryPasswordC) {
    "C: $recoveryPasswordC" | Add-Content -Path C:\temp\$env:Computername-pin.txt
}

# Function to check if a drive is a USB drive
function IsUsbDrive($disk) {
    $usbBusTypes = @('USB')
    return $usbBusTypes -contains $disk.BusType
}

# Get disk information
$diskInfo = Get-Disk | Select-Object MediaType, BusType, @{Label='DiskLetter';Expression={(Get-Partition -DiskNumber $_.Number).DriveLetter}}

foreach ($disk in $diskInfo) {
    $isUsbDrive = IsUsbDrive $disk
    $finalDisk = "$($disk.DiskLetter):" -replace '\s', ''
	
    if (-not $isUsbDrive -and $finalDisk -ne "C:" -and $finalDisk -ne "") {
        # Enable BitLocker
        $DataDisk = Get-BitLockerVolume | Where-Object { $.VolumeType -eq 'Data' -and $.MountPoint -eq $finalDisk }
		if ($DataDisk) {
			Enable-BitLocker -MountPoint $DataDisk.MountPoint -RecoveryPasswordProtector -SkipHardwareTest
		}

		# Get RecoveryPassword
		if ($DataDisk) {
			$recoveryPasswordD = $DataDisk.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' } | Select-Object -ExpandProperty RecoveryPassword -First 1
			if ($recoveryPasswordD) {
				"$finalDisk $recoveryPasswordD" | Add-Content -Path C:\temp\$env:Computername-pin.txt
			}
		}
    }
}

for ($letter = 67; $letter -le 90; $letter++) {
    $driveLetter = [char]$letter + ":"


    if ($driveLetter -eq 'C:') {
        continue
    }

    # Checks if drive exists
    if (Test-Path -Path "$driveLetter\") {
        Enable-BitLockerAutoUnlock -MountPoint $driveLetter
    } else {
        continue
    }
}

#Try each server from location
$destinations = @(
    # Write Network Destination here...
)

foreach ($destination in $destinations) {
    try {
        Copy-Item -Path "C:\temp\$env:Computername-pin.txt" -Destination $destination -ErrorAction Stop
        Write-Host "Copy successful to $destination"
        break
    }
    catch {
        Write-Host "Unable to write to $destination"
        Write-Host "Trying the next destination..."
    }
}

#Remove file from C:\temp
Write-Host "Removing $env:Computername-pin.txt from C:\temp..."
Remove-Item "C:\temp\$env:Computername-pin.txt"