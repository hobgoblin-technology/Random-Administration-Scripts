#####################################
# 1Password MSIX Update Check       #
# Author: River Collins             #
# Date: 10/22/2026                  #
#####################################


# Set target 1Password version here
$targetVersion = [version]"8.12.42.36"

# Stores 1Password object for future reuse
$1passObj = Get-AppxProvisionedPackage -Online | Where-Object Displayname -eq AgileBits.1Password

Function Download-1Pass{
    # Creates NinjaRMM\Temp directory if it's not there
    if ( !( Test-Path -PathType Container "C:\NinjaRMM\Temp" ) ) {
        Write-Host "Creating directory C:\NinjaRMM\Temp"
        New-Item -ItemType Directory -Path "C:\NinjaRMM\Temp" | Out-Null
    }

    # Uses a web session to download the file for performance
    (New-Object System.Net.WebClient).DownloadFile("https://c.1password.com/dist/1P/win8/1PasswordSetup-latest.msixbundle","C:\NinjaRMM\Temp\1PasswordSetup-latest.msixbundle")

    #Installs package for all users
    Add-AppxProvisionedPackage -Online -PackagePath "C:\NinjaRMM\Temp\1PasswordSetup-latest.msixbundle" -SkipLicense
}

# Installs 1Password if not present, otherwise it gets the version
if ($1passObj) {
    $1passVersion = [version]$1passObj.version
} else {
    try {
        Download-1Pass
        Write-Host "1Password was not found, but is now installed"
        exit 0
    }catch{
        Write-Error "Error occurred while downloading"
        exit 1
    }
}
if ($1passVersion -ge $targetVersion) {
    # If the version of 1Password is greater than or equal to the target, it does nothing
    Write-Host "1Password already up to date"
    exit 0
    
}else {
    # If the version is less than the target, download and reinstall
    try {
        Download-1Pass
        Write-Host "1Password has been updated"
        exit 0
    }catch{
        Write-Error "Error occurred while downloading update"
        exit 1
    }
}
