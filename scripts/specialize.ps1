# ------------------------------------------------------------------------------
# Name:           specialize.ps1
# Description:    Specialized stage of Windows installation. Advanced settings.
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

$host.ui.RawUI.WindowTitle = 'Specialized stage of Windows installation. Advanced settings.'

$ErrorActionPreference = 'Stop'

# During Windows installation's 'specialization' stage, 'Get-WmiObject' class may not be present, requiring an alternative method to identify the system version
$osVersion = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentVersion
$osType = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').InstallationType

# Switching power scheme to high performance in WinPE for quicker imaging
& powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disabling automatic Screen Off
& powercfg -x -monitor-timeout-ac 0
& powercfg -x -monitor-timeout-dc 0

# Disabling automatic HDD Off
& powercfg -x -disk-timeout-ac 0
& powercfg -x -disk-timeout-dc 0

# Disabling Standby mode
& powercfg -x -standby-timeout-ac 0
& powercfg -x -standby-timeout-dc 0

# Disabling Hibernation mode
& powercfg -x -hibernate-timeout-ac 0
& powercfg -x -hibernate-timeout-dc 0

# Turn off Network Location wizard
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff' -Force

# Disabling UAC (autounattend.xml\pass="offlineServicing"\"Microsoft-Windows-LUA-Settings"\EnableLUA=false)
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Type 'DWord' -Value '0' -Force

# Windows-2008R2-2012R2-2016-2019-2022
if ($osType -eq 'Server') {
    # Disabling auto-start of the 'Server Manager' application (autounattend.xml\pass="specialize"\"Microsoft-Windows-ServerManager-SvrMgrNc"\DoNotOpenServerManagerAtLogon=true)
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -Type 'DWord' -Value '1' -Force
}

# Windows-2008R2
if ($osType -eq 'Server' -and $osVersion -eq '6.1') {
    # Disabling auto-start of the 'Initial Configuration Tasks' application (autounattend.xml\pass="specialize"\"Microsoft-Windows-OutOfBoxExperience"\DoNotOpenInitialConfigurationTasksAtLogon=true)
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager\oobe' -Name 'DoNotOpenInitialConfigurationTasksAtLogon' -Type 'DWord' -Value '1' -Force
}

# Changing keyboard shortcut for input languages to 'CTRL+SHIFT' for All users
New-Item -Path 'Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle' -Force
New-ItemProperty -Path 'Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle' -Name 'Hotkey' -Type 'String' -Value '2' -Force
New-ItemProperty -Path 'Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle' -Name 'Language Hotkey' -Type 'String' -Value '2' -Force
New-ItemProperty -Path 'Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle' -Name 'Layout Hotkey' -Type 'String' -Value '3' -Force

#---Starting to make settings for all users in the Default profile---#
$defaultProfilePath = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList' -Name Default).Default
$regSection = 'DefaultUserHive'
& reg load "HKU\$regSection" "$defaultProfilePath\NTUSER.DAT"
New-PSDrive -Name 'HKU' -PSProvider 'Registry' -Root 'HKEY_USERS'

# Enabling Show all icons in the taskbar notification area (don't work in Windows 11)
New-ItemProperty -Path "HKU:\$regSection\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name 'EnableAutoTray' -Type 'DWord' -Value '0' -Force 

# Disabling Screensaver
New-Item -Path "HKU:\$regSection\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -Force | New-ItemProperty -Name 'ScreenSaveActive' -Type 'String' -Value '0' -Force 

# Setting Explorer view options
New-ItemProperty -Path "HKU:\$regSection\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'Hidden' -Type 'DWord' -Value '1' -Force
New-ItemProperty -Path "HKU:\$regSection\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'HideFileExt' -Type 'DWord' -Value '0' -Force   

# Windows-7
if ($osType -eq 'Client' -and $osVersion -eq '6.1') {
    # Enabling Showing Run Command in Start Menu
    New-ItemProperty -Path "HKU:\$regSection\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'Start_ShowRun' -Type 'DWord' -Value '1' -Force 

    # Enabling Showing Administrative Tools in Start Menu
    New-ItemProperty -Path "HKU:\$regSection\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'StartMenuAdminTools' -Type 'DWord' -Value '1' -Force
}   

# Windows-7-2008R2-2012R2
if ($osVersion -eq '6.1' -or $osVersion -eq '6.3') {
    # Enabling QuickEdit mode
    New-ItemProperty -Path "HKU:\$regSection\Console" -Name 'QuickEdit' -Value '1' -Force
}

[gc]::Collect()                 # helps to close the registry paths (otherwise it will not let you unload the hive), see: https://stackoverflow.com/questions/25438409/reg-unload-and-new-key
Start-Sleep -Seconds 5          # pause, for garbage collector
& reg unload "HKU\$regSection"
Remove-PSDrive HKU -Force
#---Finishing to make settings for all users in the Default profile---#