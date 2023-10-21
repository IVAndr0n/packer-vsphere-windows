# ------------------------------------------------------------------------------
# Name:           windows-server-2008r2-std-x64_vsphere.pkrvar.hcl
# Description:    Required Packer Variables for VMware vSphere and Windows OS
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

# Virtual Machine Options
vm_guest_os_type            = "windows7Server64Guest"
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
os_iso_file                 = "ru_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_vl_build_x64_dvd_617421.iso"

# Guest OS Options
os_image_name               = "Windows Server 2008 R2 SERVERSTANDARD"
os_product_key              = "YC6KT-GKW9T-YTKYR-T4X34-R7VHC"
os_language                 = "ru-RU"
os_keyboard                 = "en-US; ru-RU"
os_timezone                 = "E. Africa Standard Time"

# Builder Options
vm_os_family                = "windows"
vm_os_short_name            = "server-2008r2-std"
vm_os_bit                   = "x64"
boot_config                 = "Autounattend-BIOS-x64-7-2008R2.pkrtpl.hcl"
floppy_files                = ["scripts/specialize.ps1", "scripts/add-win6.1.cmd", "scripts/install-vmtools.ps1", "scripts/initialize.ps1"]
cd_files                    = ["add/win6.1/*x64.msu", "add/win6.1/*x86_64.exe"]
script_files                = ["scripts/config.ps1"]
inline_cmds                 = ["Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }"]