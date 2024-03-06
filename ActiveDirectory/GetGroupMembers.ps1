$OU = Read-Host "Enter the OU distinguished name (e.g., OU=Users,DC=domain,DC=com)"
$GroupName = Read-Host "Enter the name of the group (example: GroupName)"
$Group = Get-ADGroup -Filter { Name -eq $GroupName } -SearchBase $OU

if ($Group) {
    $GroupMembers = Get-ADGroupMember -Identity $Group
    $GroupMembers | Select-Object Name, SamAccountName | Format-Table -AutoSize
    Write-Output "Members of group $GroupName in OU $OU displayed on the screen."

    $saveOption = Read-Host "Do you wan't to save to a CSV? (Y/n)"

    if ($saveOption -eq "y" -or [string]::IsNullOrEmpty($saveOption)) {
        $saveLocation = Read-Host "Enter the location to save the CSV file (e.g., C:\Temp)"

        if (Test-Path -Path $saveLocation -PathType Container) {
            $savePath = Join-Path -Path $saveLocation -ChildPath "$GroupName.csv"
            $GroupMembers | Select-Object Name, SamAccountName | Export-Csv -Path $savePath -NoTypeInformation
            Write-Output "Members of group $GroupName in OU $OU saved to $savePath."
        } else {
            Write-Host "The specified location '$saveLocation' does not exist or is not a valid directory."
        }

    } else {
        Write-Host "Group $GroupName not found in $OU"
    }
} else {
    Read-Host "Press Enter to continue..."
}