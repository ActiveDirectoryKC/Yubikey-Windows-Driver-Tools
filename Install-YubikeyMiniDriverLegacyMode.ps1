<#
.SYNOPSIS 
Installs the latest Yubikey minidriver from the share.

.DESCRIPTION
Installs the latest Yubikey minidriver from the share if that version is newer than the existing. 
Includes the LEGACY_MODE switch on the install to support remote Yubikeys.
Requires the Yubikey minidriver to be downloaded and stored in the same directory as this script.
Link to Yubikey minidriver: https://www.yubico.com/support/download/smart-card-drivers-tools/

.PARAMETER Reboot
Informs the script to automatically reboot. 

.NOTES
Created By: ActiveDirectoryKC.NET
Created On: 06/13/2024
Updated On: 07/09/2024
Version: 0.9.1

.TODO
- Include checks if the prompt to do the install is elevated.
- Incorporate downloading and updating the Yubikey drivers from their webpage. 

.CHANGELOG
0.9.1
    Added -Force to force an install even if install is detected. 
    Fixed an issue with the Reboot section. Now works correctly.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Reboot,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

Write-Host -Object "Installing Yubikey Minidriver" -ForegroundColor Cyan

Set-Location -Path $PSScriptRoot

$CurrentVersion = ""
$CurrentInstaller = (Get-ChildItem -Filter "Yubikey-Minidriver*") -as [System.Array] | Sort-Object -Descending BaseName | Select-Object -First 1
$YubiKeyDrivers = Get-CimInstance -Query "SELECT * FROM Win32_Product WHERE Vendor = 'Yubico AB'" -ErrorAction Ignore
$CurrentInstallerVersionInfo = Get-Item -Path $CurrentInstaller | Select-Object -ExpandProperty VersionInfo

<# 
    ## TODO: Need to play with this more.
    $YubicoDriverPage = Invoke-WebRequest -Uri "https://www.yubico.com/support/download/smart-card-drivers-tools/" -UseBasicParsing
    $YubicoDriverLink = ($YubicoDriverPage.Links | Where-Object { $_ -like "*YubiKey Minidriver for 64-bit systems – Windows Installer*" }).href

    if( (Split-Path -Path $YubicoDriverLink -Leaf) -gt $CurrentInstaller.BaseName )
    {
        Invoke-WebRequest -UseBasicParsing -Uri $YubicoDriverLink -OutFile "$(Split-Path -Path $YubicoDriverLink -Leaf)"
        $CurrentInstaller = (Get-ChildItem -Path .\ -Filter "Yubikey-Minidriver*") -as [System.Array] | Sort-Object -Descending BaseName | Select-Object -First 1
    }

    ## TODO: Upload new version to the Public share.
#>

# Discover the current installed version
<#
    Yubico decided in their infinite knowledge to not specify the version number on their drivers. 
    They also decided NOT to include a latest release package/portal/etc.
#>
if( $CurrentInstallerVersionInfo.ProductVersion ) 
{ 
    $CurrentVersion = $CurrentInstallerVersionInfo.ProductVersion 
}
elseif( $CurrentInstallerVersionInfo.FileVersion ) 
{ 
    $CurrentVersion = $CurrentInstallerVersionInfo.FileVersion 
}
else
{
    $CurrentVersion = $CurrentInstaller.Basename.split('-') | Where-Object { $_ -match "(?:(\d+)\.)?(?:(\d+)\.)?(?:(\d+)\.\d+)" }
}

if( $PSBoundParameters.ContainsKey("Force") -or (!$YubiKeyDrivers -or !$CurrentVersion -or ($YubiKeyDrivers.Version -lt $CurrentVersion) ) )
{
    try
    {
        msiexec /i $CurrentInstaller INSTALL_LEGACY_NODE=1 /passive /log C:\temp\YubiKey-Minidriver.log
        Write-Host -Object "Yubikey Minidriver Installed/Updated" -ForegroundColor Green
    }
    catch
    {
        Write-Error -Message "Failed to install the Yubikey Minidriver - $($PSItem.Exception.Message)"
        Write-Host -Object "Log file can be found at 'C:\temp\YubiKey-Minidriver.log'"
        throw $PSItem
    }
}
else
{
    Write-Host -Object "Driver already installed at the current version"
    return $null
}

if( !$PSBoundParameters.ContainsKey("Reboot") )
{
    $RebootPrompt = Read-Host "The system needs to reboot after the install. Do you want to reboot now [Y]es|[N]o?"

    switch -regex ($RebootPrompt) 
    {
        "y|Y|yes|Yes" { Write-Host -Object "Restarting computer in 60 seconds..."; Restart-Computer -Delay 60 -Force }
        default { Write-Host "User chose not to reboot at this time - System will need rebooted before the minidriver can be used" }
    }
}
else
{
    Write-Host -Object "Restarting computer in 60 seconds..."
    Start-Sleep -Seconds 60
    Restart-Computer -Force
}