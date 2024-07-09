# Yubikey Windows Driver Tools
After setting up a Yubikey to be a SmartCard, after attempting to use it to login via RDP, you may receive an error "Requested Key Container is not Available". The solution to this is to install the Yubikey Minidriver in LEGACY_MODE which allows for passthrough for RDP. (https://support.yubico.com/hc/en-us/articles/360013717720-Smart-Card-Logon-Over-RDP-Fails-with-Requested-Key-Container-is-not-Available)

If you already have the minidriver installed, this can overwrite the install but that does not always work. You may need to uninstall the minidriver first and then reboot before trying again.

This repo contains two scripts
- Install-YubiKeyMiniDriverLegacyMode.ps1 which is used to install the Minidriver.
- Test-YubicoDriverStatus.ps1 which is used to test installation and detection of the Yubikey. 

### DISCLAIMER
I am not in any way affiliated with Yubico or any of their affiliates. This is my own discovery and these scripts were written solely by me with no coordination with them. Use them at your your own peril. 

## Install-YubikeyMiniDriverLegacyMode.ps1
### SYNOPSIS 
Installs the latest Yubikey minidriver from the share.

### DESCRIPTION
Installs the latest Yubikey minidriver from the share if that version is newer than the existing, includes the LEGACY_MODE switch on the install to support remote Yubikeys. Requires the Yubikey minidriver to be downloaded and stored in the same directory as this script.
Link to Yubikey minidriver: https://www.yubico.com/support/download/smart-card-drivers-tools/

## PARAMETERS
#### PARAMETER Reboot
Informs the script to automatically reboot. 

#### PARAMETER Force
Forces the script to install the minidriver over an existing installation.

### NOTES
- Created By: ActiveDirectoryKC.NET
- Created On: 06/13/2024
- Updated On: 07/09/2024
- Version: 0.9.1

#### TODO
- Include checks if the prompt to do the install is elevated.
- Incorporate downloading and updating the Yubikey drivers from their webpage. 

#### CHANGELOG
0.9.1
    Added -Force to force an install even if install is detected. 
    Fixed an issue with the Reboot section. Now works correctly.

## Test-YubicoDriverStatus.ps1
### SYNOPSIS
Checks the status of the Yubico driver and/or toggles driver debug.

### DESCRIPTION
Way too much code to do the following (optional each).
1. Check the status of the driver. If the drvier status is not accurate, prompt to enable debug logging.
2. Enable/Disable debug logging. 

### PARAMETERS
#### PARAMETER DebugOn
Enables yubico driver debugging.

#### PARAMETER DebugOff
Disables yubico driver debugging.

### EXAMPLES
#### EXAMPLE
    PS> Test-YubicoDriverStatus
Checks for driver status, returns the status, and if the status is invalid, prompts to set the debug mode.

#### EXAMPLE
    PS> Test-YubicoDriverStatus -DebugOn
Enables debugging on the Yubico driver which will be placed in C:\Logs. 

### NOTES
#### VERSION 1.0
- Created By: ActiveDirectoryKC.NET
- Created On: 06/13/2024
- Updated On: 07/09/2024

#### REFERENCE
https://support.yubico.com/hc/en-us/articles/360015654560-Deploying-the-YubiKey-Minidriver-to-Workstations-and-Servers
