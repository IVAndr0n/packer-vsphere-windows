# ------------------------------------------------------------------------------
# Name:           initialize.ps1
# Description:    Basic Windows settings to run a Packer build
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

$host.ui.RawUI.WindowTitle = 'Basic Windows settings to run a Packer build'

$ErrorActionPreference = 'Stop'

# Switching network connection to private mode (required for WinRM firewall rules)
if ([System.Environment]::OSVersion.Version -ge [System.Version]('6.1')) {
    if ($PSVersionTable.PSVersion.Major -ge 4) {
        $connectionProfile = Get-NetConnectionProfile
        While ($connectionProfile.Name -eq 'Identifying...') {
            Start-Sleep -Seconds 10
            $connectionProfile = Get-NetConnectionProfile
        }
        Set-NetConnectionProfile -Name $connectionProfile.Name -NetworkCategory Private
    }
    else {
        $networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'))
        $connections = $networkListManager.GetNetworkConnections()
        foreach ($connection in $connections) {
            $network = $connection.GetNetwork()
            $name = $network.GetName()
            $category = $network.GetCategory()
            Write-Host "$name category was previously set to $category"
            $network.SetCategory(1)
            Write-Host "$name changed to category $($network.GetCategory())"
        }
    }
}

# Enabling WinRM service
& winrm quickconfig -quiet
& winrm set winrm/config/service '@{AllowUnencrypted="true"}'
& winrm set winrm/config/service/auth '@{Basic="true"}'

# Allowing Windows Remote Management (HTTP - Inbound) rule on firewall
& netsh advfirewall firewall set rule name="@FirewallAPI.dll,-30253" new enable=yes action=allow remoteip=any
& netsh advfirewall set currentprofile settings remotemanagement enable