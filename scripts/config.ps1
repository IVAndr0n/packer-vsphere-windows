# ------------------------------------------------------------------------------
# Name:           config.ps1
# Description:    Advanced Windows settings for Packer build
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

$host.ui.RawUI.WindowTitle = 'Advanced Windows settings for Packer build'

$ErrorActionPreference = 'Stop'

$os = Get-WmiObject Win32_OperatingSystem

Write-Host '...Enable built-in administrator and require password change at first login'
# Important! For the 'Require password change..' option to be enabled with the 'net user %username% /LOGONPASSWORDCHG:YES' command,
# the PasswordExpires and PasswordChangeable parameters must be set to TRUE.
$localAdministrator = (Get-WmiObject Win32_UserAccount -Namespace "root\cimv2" -Filter "SID like 'S-1-5-%-500'").name
& wmic USERACCOUNT WHERE "Name='$localAdministrator'" set PasswordExpires=TRUE > $null
& wmic USERACCOUNT WHERE "Name='$localAdministrator'" set PasswordChangeable=TRUE > $null
& wmic USERACCOUNT WHERE "Name='$localAdministrator'" set Disabled=FALSE > $null
& net user $localAdministrator /LOGONPASSWORDCHG:YES > $null

Write-Host "...Disabling password expiration for $env:BUILDUSER user"
$buildUser = $env:BUILDUSER
& wmic USERACCOUNT WHERE "Name='$buildUser'" set PasswordExpires=FALSE > $null

# Windows-7
if ($os.ProductType -eq '1' -and $os.Version -eq '6.1.7601') {
    # Disabling full-screen notification 'Your Windows 7 PC is out of support' in Windows Registry for '$buildUser'
    $keyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\EOSNotify'
    if (Test-Path -Path $keyPath) {
      $property = Get-ItemProperty -Path $keyPath -Name 'DiscontinueEOS' -ErrorAction SilentlyContinue
      if ($null -ne $property) {
        Set-ItemProperty -Path $keyPath -Name 'DiscontinueEOS' -Value '1' | Out-Null
      }
      else {
        New-ItemProperty -Path $keyPath -Name 'DiscontinueEOS' -Type 'DWord' -Value '1' -Force | Out-Null
      }
    }

    # Disabling full-screen notification 'Your Windows 7 PC is out of support' tasks in Task Scheduler for All users
    [Reflection.Assembly]::LoadWithPartialName('Microsoft.Win32.TaskScheduler') | Out-Null
    $tasks = @('\Microsoft\Windows\Setup\EOSNotify', '\Microsoft\Windows\Setup\EOSNotify2')
    foreach ($task in $tasks) {
        $taskService = New-Object -ComObject Schedule.Service
        $taskService.Connect()
        $rootFolder = $taskService.GetFolder('\')
        $taskPath = $task.Substring(1)

        trap { continue }
        $existingTask = $rootFolder.GetTask($taskPath)

        if ($null -ne $existingTask) {
            $existingTask.Enabled = $false
            Write-Host '...Disabling full-screen notification "Your Windows 7 PC is out of support"'
            Write-Host "   $task task found and processed"
        }
    }
}

# Windows-10
if ($os.Caption -match 'Windows 10 Pro') {
    Write-Host '...Disabling Microsoft consumer experiences'
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Force | New-ItemProperty -Name 'DisableWindowsConsumerFeatures' -Type 'DWord' -Value '1' | Out-Null
}

# Windows-7-2008R2-2012R2
if ($os.Version -like '6.*') {
    Write-Host '...Disabling IPv6'
    # The DisabledComponents registry value doesn't affect the state of the check box (https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows)
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' -Name 'DisabledComponents' -Value '0xff' | Out-Null
}

# Windows-2008R2-2012R2-2016-2019-2022
if ($os.ProductType -eq '2' -or $os.ProductType -eq '3') {
    Write-Host '...Disabling IE Enhanced Security Configuration for Administrators'
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value '0' -Force | Out-Null
    $process = Get-WmiObject -Class Win32_Process -Filter "name='explorer.exe'"
    if ($process) {
        $process.Terminate() | Out-Null
    }
}

# Windows-7-10-11-2008R2 with consideration for system bitness
# Note, in Windows-2012R2-2016-2019-2022 the 'RemoteSigned' parameter is set by default in the LocalMachine scope
if ($os.ProductType -eq '1' -or $os.Caption -match 'Windows Server 2008 R2') {
    Write-Host '...Changing the PowerShell Execution Policy'
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' -Name 'ExecutionPolicy' -Type 'String' -Value 'RemoteSigned' -Force | Out-Null

    if ([IntPtr]::Size -eq 8) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' -Name 'ExecutionPolicy' -Type 'String' -Value 'RemoteSigned' -Force | Out-Null
    }
}

# Windows-2019-2022
if ($os.Caption -match 'Windows Server 2019' -or $os.Caption -match 'Windows Server 2022') {
    Write-Host '...Disabling Windows Admin Center Pop-up in Server Manager'
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager' -Name 'DoNotPopWACConsoleAtSMLaunch' -Type 'DWord' -Value '1' -Force | Out-Null
}

# Windows-10-11-2016-2019-2022
if ($os.Version -like '10.0.*') {
    Write-Host '...Disabling IPv6'
    Disable-NetAdapterBinding -Name '*' -ComponentID ms_tcpip6 | Out-Null

    # Configuring the TLS protocol
    $protocols1 = @('TLS 1.0', 'TLS 1.1')
    $protocols2 = @('TLS 1.2')
    $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
    foreach ($protocol in $protocols1) {
        Write-Host "...Disabling $protocol"
        New-Item -Path $path -Name $protocol | Out-Null
        New-Item -Path "$path\$protocol" -Name 'Server' | Out-Null
        New-Item -Path "$path\$protocol" -Name 'Client' | Out-Null
        New-ItemProperty -Path "$path\$protocol\Client" -Name 'Enabled' -Type 'DWord' -Value '0' -Force | Out-Null
        New-ItemProperty -Path "$path\$protocol\Client" -Name 'DisabledByDefault' -Type 'DWord' -Value '1' -Force | Out-Null
        New-ItemProperty -Path "$path\$protocol\Server" -Name 'Enabled' -Type 'DWord' -Value '0' -Force | Out-Null
        New-ItemProperty -Path "$path\$protocol\Server" -Name 'DisabledByDefault' -Type 'DWord' -Value '1' -Force | Out-Null
    }
    foreach ($protocol in $protocols2) {
        Write-Host "...Enabling $protocol"
        New-Item -Path $path -Name $protocol | Out-Null
        New-Item -Path "$path\$protocol" -Name 'Server' | Out-Null
        New-Item -Path "$path\$protocol" -Name 'Client' | Out-Null
        New-ItemProperty -Path "$path\$protocol\Client" -Name 'Enabled' -Type 'DWord' -Value '1' -Force | Out-Null
        New-ItemProperty -Path "$path\$protocol\Client" -Name 'DisabledByDefault' -Type 'DWord' -Value '0' -Force | Out-Null
        New-ItemProperty -Path "$path\$protocol\Server" -Name 'Enabled' -Type 'DWord' -Value '1' -Force | Out-Null
        New-ItemProperty -Path "$path\$protocol\Server" -Name 'DisabledByDefault' -Type 'DWord' -Value '0' -Force | Out-Null
    }
}

Write-Host '...Enabling RDP connections'
& netsh advfirewall firewall set rule group="@FirewallAPI.dll,-28752" new enable=yes > $null
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value '0' | Out-Null
# https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-terminalservices-rdp-winstationextensions-userauthentication
# '0' - lower security, '1' (default) - higher security, but RDP connection will work after updates are installed in the system (CredSSP error)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value '0' | Out-Null
# https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-terminalservices-rdp-winstationextensions-securitylayer
# use TLS protocol ('1' is default value in win2008r2, '2' in newer OS)
# Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'SecurityLayer' -Value '2' | Out-Null

Write-Host '...Removing PagingFile'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value '' | Out-Null

Write-Host '...Resetting auto logon count'
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
# As soon as the value of the AutoLogonCount key reaches zero, the key is deleted
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoLogonCount' -Value '0' | Out-Null

Write-Host '...Configuration complete'