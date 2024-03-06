$name = Read-Host -Prompt "Enter the name for the certificate (e.g., CN=Cert)"
$password = Read-Host -Prompt "Enter the password for the certificate" -AsSecureString
$saveLocation = Read-Host "Enter the location to save the Certificate (e.g., C:\Temp)"

while (!(Test-Path -Path $saveLocation) -or !(Test-Path -Path $saveLocation -PathType Container)) {
    Write-Host "The specified location '$saveLocation' does not exist or is not a valid directory or you don't have write permissions."
    $saveLocation = Read-Host "Please enter a valid location to save the Certificate (e.g., C:\Temp)"
}

try {
    $notAfter = (Get-Date).AddYears(1)
    $cert = New-SelfSignedCertificate -DnsName $name -NotAfter $notAfter -FriendlyName $name -ErrorAction Stop

    $savePath = Join-Path -Path $saveLocation -ChildPath "$name.pfx"
    Export-PfxCertificate -Cert $cert -FilePath $savePath -Password $password

    Write-Host "Self-signed certificate '$name' has been created and saved to $savePath."
    Write-Host "Please make sure to secure and manage this certificate file properly."
    Read-Host "Press Enter to continue..."
} catch {
    Write-Host "Error occurred while generating the certificate: $_"
    Write-Host "Please try running as an Administrator..."
}



