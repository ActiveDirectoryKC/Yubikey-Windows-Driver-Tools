<#
.SYNOPSIS
Checks the status of the Yubico driver and/or toggles driver debug.

.DESCRIPTION
Way too much code to do the following (optional each).
1. Check the status of the driver. If the drvier status is not accurate, prompt to enable debug logging.
2. Enable/Disable debug logging. 

.PARAMETER DebugOn
Enables yubico driver debugging.

.PARAMETER DebugOff
Disables yubico driver debugging.

.EXAMPLE
PS> Test-YubicoDriverStatus
Checks for driver status, returns the status, and if the status is invalid, prompts to set the debug mode.

.EXAMPLE
PS> Test-YubicoDriverStatus -DebugOn
Enables debugging on the Yubico driver which will be placed in C:\Logs. 

.NOTES
.VERSION 1.0
Created By: ActiveDirectoryKC.NET
Created On: 06/13/2024

.REFERENCE
https://support.yubico.com/hc/en-us/articles/360015654560-Deploying-the-YubiKey-Minidriver-to-Workstations-and-Servers
#>
[CmdletBinding(DefaultParameterSetName="None")]
param(
    [Parameter(Mandatory=$true,ParameterSetName="DebugOn")]
    [switch]$DebugOn,
    [Parameter(Mandatory=$true,ParameterSetName="DebugOff")]
    [switch]$DebugOff
)
$YubicoDriverDebugProperty = @{
    Path = "HKLM:\Software\Yubico\ykmd"
    PropertyName = "DebugOn"
}

$YubicoDriverDebugReg = Get-ItemProperty -Path $YubicoDriverDebugProperty.Path -Name $YubicoDriverDebugProperty.PropertyName -ErrorAction Ignore

function SetYubicoDriverDebug
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateRange(0,1)]
        [int]$State
    )

    $Message = "{0} yubico driver debugging ('HKLM:\Software\Yubico\ykmd!DebugOn={1}')"
    $StateMsg = ""

    if( $State )
    {
        $StateMsg = "Enabled"
    }
    else
    {
        $StateMsg = "Disabled"
    }

    try
    {
        if( !($YubicoDriverDebugReg) -or ($YubicoDriverDebugReg."$($YubicoDriverDebugProperty.PropertyName)" -ne $State) )
        {
            if( !(Get-Item -Path $YubicoDriverDebugProperty.Path -ErrorAction Ignore) )
            {
                $YBDriverDebugRegInstallStatus = cmd /c "reg import YubicoDriverDebug.reg"
                if( $YBDriverDebugRegInstallStatus )
                {
                    Write-Host -Object "Created the registry key '$($YubicoDriverDebugProperty.Path)'" -ForegroundColor Cyan
                }
            }

            Set-ItemProperty -Path $YubicoDriverDebugProperty.Path -Name $YubicoDriverDebugProperty.PropertyName -Value $State -ErrorAction Stop
            Write-Host -Object ($Message -f $StateMsg,$State) -ForegroundColor Cyan
        }
        else
        {
            Write-Host -Object "Yubico driver debug logging already set to '$State' - Continuing" -ForegroundColor Cyan
            return $null
        }
    }   
    catch
    {
        Write-Error -Message "Failed to $($Message -f $StateMsg,$State) - $($PSItem.Exception.Message)"
        throw $PSitem`
    }
}

$YubicoDriverStatus = Get-WindowsDriver -Online | Where-Object {($_.ProviderName -like "Yubico") -and ($_.ClassName -like "SmartCard") -and ($_.Version -like "*")} | Select-Object -Property ProviderName,ClassName,Version
$YubicoDriverStatus

if( $PSCmdlet.ParameterSetName -eq 'None' )
{
    if( $YubicoDriverStatus.ProviderName -ne 'Yubico' -and $YubicoDriverStatus.ClassName -ne 'SmartCard' )
    {
        Write-Host -Object "" # Newline
        Write-Error -Message "Yubi device not detected as smart card - $($YubicoDriverStatus | Format-List -Property *)"

        if( $YubicoDriverDebugReg.DebugOn -ne 1)
        {
            $EnableDriverDebugPrompt = (Read-Host -Prompt "Would you like to enable debug logging on the yubico driver [Y]es|[N]o?") 
            switch -regex ($EnableDriverDebugPrompt)
            {
                "y|Y|yes|Yes" {  
                    SetYubicoDriverDebug -State 1
                }
                default { Write-Host -Object "User elected not to turn on debugging - Exiting" -ForegroundColor Cyan; return $null }
            }
        }
    }
}
else
{
    if( $PSBoundParameters.ContainsKey("DebugOn") )
    {
        SetYubicoDriverDebug -State 1
    }
    else
    {
        SetYubicoDriverDebug -State 0
    }
}



