# ------------------------------------------------------------------------------
# Name:           install-vmtools.ps1
# Description:    Installs VMware Tools and runs re-attempts if the service fail on the first attempt
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

$host.ui.RawUI.WindowTitle = 'Installs VMware Tools and runs re-attempts if the service fail on the first attempt'

$ErrorActionPreference = 'Stop'

<# # Check if VMWare Tools is already installed
if (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName -match 'VMware Tools'}) {
    Write-Host -ForegroundColor Green 'VMware Tools is already installed'
    exit
} #>

# Set the current working directory to the CD-ROM that corresponds to the VMWare Tools ISO
Set-Location E:

# Checking the VMware Tools installation file
if (-not (Test-Path -Path '.\setup*.exe')) {
    Write-Host -ForegroundColor Red 'VMware Tools setup file not found'
    exit
}

# Installing VMWare Tools. Attempt #1
if ($env:PROCESSOR_ARCHITECTURE -eq 'x86') {
    $architecture = '32-bit'
    $setup = 'setup.exe'
}
else {
    $architecture = '64-bit'
    $setup = 'setup64.exe'
}
Write-Host "Installing VMware Tools on $architecture OS architecture"
Start-Process $setup -ArgumentList '/s /v "/qn REBOOT=R"' -Wait

# After the installation is finished, check to see if the 'VMTools' service enters the 'RUNNING' state every 2 seconds for 10 seconds
$Running = $false
$iRepeat = 0

while (-not $Running -and $iRepeat -lt 5) {
    Start-Sleep -s 2
    Write-Host 'Checking VMware Tools service status'
    $Service = Get-Service 'VMTools' -ErrorAction SilentlyContinue
    $Servicestatus = $Service.Status

    if ($ServiceStatus -ne 'Running') {
        $iRepeat++
        Write-Host -ForegroundColor Red 'VMware Tools service NOT started'
    }
    else {
        $Running = $true
        Write-Host -ForegroundColor Green 'VMware Tools installed correctly'
        Start-Sleep -Seconds 4
    }
}

# If the service never goes into the 'RUNNING' state, reinstall VMware Tools
if (-not $Running) {
    Write-Host "Uninstalling VMware Tools on $architecture OS architecture"
    Start-Process $setup -ArgumentList '/S /v "/qn REBOOT=R REMOVE=ALL"' -Wait

    # Installing VMWare Tools. Attempt #2
    Write-Host "Reinstalling VMware Tools on $architecture OS architecture"
    Start-Process $setup -ArgumentList '/s /v "/qn REBOOT=R"' -Wait

    # Checking if the 'VMTools' service is in the 'RUNNING' state
    Write-Host 'Checking VMware Tools service status'
    $iRepeat = 0
    while (-not $Running -and $iRepeat -lt 5) {
        Start-Sleep -s 2
        $Service = Get-Service 'VMTools' -ErrorAction SilentlyContinue
        $ServiceStatus = $Service.Status

        if ($ServiceStatus -ne 'Running') {
            $iRepeat++
        }
        else {
            $Running = $true
            Write-Host -ForegroundColor Green 'VMware Tools installed correctly'
            Start-Sleep -Seconds 4
        }
    }

    # If after the reinstall, the service is still not 'RUNNING', the installation is unsuccessful
    if (-not $Running) {
        Write-Host -ForegroundColor Red 'VMware Tools NOT installed correctly'
        Start-Sleep -Seconds 300
    }
}