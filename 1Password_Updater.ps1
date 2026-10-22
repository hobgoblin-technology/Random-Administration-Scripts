#####################################
# 1Password MSIX Update Check       #
# Author: River Collins             #
# Date: 10/22/2026                  #
#####################################


# Set target 1Password version here
$targetVersion = [version]"8.12.42.36"

# Installs 1Password if not present, otherwise it gets the version
if (Get-AppxPackage AgileBits.1Password) {
    $1passVersion = [version](Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq AgileBits.1Password).version
} else {
    Invoke-WebRequest -Uri "https://c.1password.com/dist/1P/win8/1PasswordSetup-latest.msixbundle" -OutFile "C:\temp\1PasswordSetup-latest.msixbundle"
    Add-AppxProvisionedPackage -Online -PackagePath "C:\temp\1PasswordSetup-latest.msixbundle" -SkipLicense
    Write-Host "1Password was not found, but is now installed"
    exit 0
}
switch ($1passVersion) {
    # If the version of 1Password is less than the target, it will download the newest installer and update
    (-lt $targetVersion) {
        Invoke-WebRequest -Uri "https://c.1password.com/dist/1P/win8/1PasswordSetup-latest.msixbundle" -OutFile "C:\temp\1PasswordSetup-latest.msixbundle"
        Add-AppxProvisionedPackage -Online -PackagePath "C:\temp\1PasswordSetup-latest.msixbundle" -SkipLicense
        Write-Host "1Password Updated"
        exit 0
    }
    # If the version of 1Password is greater than or equal to the target, it does nothing
    (-ge $targetVersion) {
        Write-Host "1Password already up to date"
        exit 0
    }
    # If it reaches this default statement, something's wrong with the above logic
    default {
        Write-Error "Something unexpected happened"
        exit 1
    }
}
