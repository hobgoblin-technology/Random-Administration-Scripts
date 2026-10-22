#####################################
# 1Password MSIX Update Check       #
# Author: River Collins             #
# Date: 10/22/2026                  #
#####################################
$targetVersion = [version]"8.12.42.36"

if (Get-AppxPackage AgileBits.1Password) {
    $1passVersion = [version](Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq AgileBits.1Password).version
} else {
    Invoke-WebRequest -Uri "https://c.1password.com/dist/1P/win8/1PasswordSetup-latest.msixbundle" -OutFile "C:\temp\1PasswordSetup-latest.msixbundle"
    Add-AppxProvisionedPackage -Online -PackagePath "C:\temp\1PasswordSetup-latest.msixbundle" -SkipLicense
    $1passVersion = [version](Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq AgileBits.1Password).version
}
switch ($1passVersion) {
    (-lt $targetVersion) {
        Invoke-WebRequest -Uri "https://c.1password.com/dist/1P/win8/1PasswordSetup-latest.msixbundle" -OutFile "C:\temp\1PasswordSetup-latest.msixbundle"
        Add-AppxProvisionedPackage -Online -PackagePath "C:\temp\1PasswordSetup-latest.msixbundle" -SkipLicense
        Write-Host "1Password Updated"
        exit 0
    }
    (-ge $targetVersion) {
        Write-Host "1Password already up to date"
        exit 0
    }
    default {
        Write-Host "Something unexpected happened"
        exit 1
    }
}
