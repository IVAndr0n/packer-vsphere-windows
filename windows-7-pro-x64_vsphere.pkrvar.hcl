# ------------------------------------------------------------------------------
# Name:           windows-7-pro-x64_vsphere.pkrvar.hcl
# Description:    Required Packer Variables for VMware vSphere and Windows OS
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

# Virtual Machine Options
vm_guest_os_type            = "windows7_64Guest"
vm_numvCPUs                 = 2
vm_coresPerSocket           = 1
vm_mem_size                 = 6144
vm_disk_size                = 40960
vm_disk_controller          = ["lsilogic-sas"]
vm_video_ram                = 8192
vm_vtpm                     = false
vm_firmware                 = "bios"

# Images
vm_tools                    = "[] /vmimages/tools-isoimages/windows.iso"
os_iso_path                 = "ISO/Microsoft"
os_iso_file                 = "ru_windows_7_professional_with_sp1_vl_build_x64_dvd_u_677774.iso"

# Guest OS Options
os_image_name               = "Windows 7 PROFESSIONAL"
os_product_key              = "FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4"
os_language                 = "ru-RU"
os_keyboard                 = "en-US; ru-RU"
os_timezone                 = "E. Africa Standard Time"

# Builder Options
vm_os_family                = "windows"
vm_os_short_name            = "7-pro"
vm_os_bit                   = "x64"
boot_config                 = "Autounattend-BIOS-x64-7-2008R2.pkrtpl.hcl"
floppy_files                = ["scripts/specialize.ps1", "scripts/add-win6.1.cmd", "scripts/install-vmtools.ps1", "scripts/initialize.ps1"]
cd_files                    = ["add/win6.1/*x64.msu", "add/win6.1/*x86_64.exe"]
script_files                = ["scripts/config.ps1"]
inline_cmds                 = ["Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }"]