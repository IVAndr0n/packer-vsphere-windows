# ------------------------------------------------------------------------------
# Name:           windows-10-pro-x86_vsphere.pkrvar.hcl
# Description:    Required Packer Variables for VMware vSphere and Windows OS
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

# Virtual Machine Options
vm_guest_os_type            = "windows9Guest"
vm_numvCPUs                 = 2
vm_coresPerSocket           = 1
vm_mem_size                 = 3072
vm_disk_size                = 40960
vm_disk_controller          = ["pvscsi"]
vm_video_ram                = 8192
vm_vtpm                     = false
vm_firmware                 = "efi-secure"

# Images
vm_tools                    = "[] /vmimages/tools-isoimages/windows.iso"
os_iso_path                 = "ISO/Microsoft"
os_iso_file                 = "ru-ru_windows_10_consumer_editions_version_22h2_updated_jan_2023_x86_dvd_73772b8a.iso"

# Guest OS Options
os_image_name               = "Windows 10 Pro"
os_product_key              = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
os_language                 = "ru-RU"
os_keyboard                 = "en-US; ru-RU"
os_timezone                 = "E. Africa Standard Time"

# Builder Options
vm_os_family                = "windows"
vm_os_short_name            = "10-pro"
vm_os_bit                   = "x86"
boot_config                 = "Autounattend-UEFI-x86-10.pkrtpl.hcl"
floppy_files                = ["scripts/specialize.ps1", "scripts/install-vmtools.ps1", "scripts/initialize.ps1"]
cd_files                    = []
script_files                = ["scripts/config.ps1", "scripts/remove-apps.ps1"]
inline_cmds                 = ["Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }"]