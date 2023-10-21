# ------------------------------------------------------------------------------
# Name:           windows-server-2022-std-x64_vsphere.pkrvar.hcl
# Description:    Required Packer Variables for VMware vSphere and Windows OS
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

# Virtual Machine Options
vm_guest_os_type            = "windows2019srvNext_64Guest"
vm_numvCPUs                 = 2
vm_coresPerSocket           = 1
vm_mem_size                 = 6144
vm_disk_size                = 40960
vm_disk_controller          = ["pvscsi"]
vm_video_ram                = 8192
vm_vtpm                     = false
vm_firmware                 = "efi-secure"

# Images
vm_tools                    = "[] /vmimages/tools-isoimages/windows.iso"
os_iso_path                 = "ISO/Microsoft"
os_iso_file                 = "SW_DVD9_Win_Server_STD_CORE_2022_2108.15_64Bit_Russian_DC_STD_MLF_X23-31810.ISO"

# Guest OS Options
os_image_name               = "Windows Server 2022 SERVERSTANDARD"
os_product_key              = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
os_language                 = "ru-RU"
os_keyboard                 = "en-US; ru-RU"
os_timezone                 = "E. Africa Standard Time"

# Builder Options
vm_os_family                = "windows"
vm_os_short_name            = "server-2022-std"
vm_os_bit                   = "x64"
boot_config                 = "Autounattend-UEFI-x64-10-11-2012R2-2016-2019-2022.pkrtpl.hcl"
floppy_files                = ["scripts/specialize.ps1", "scripts/install-vmtools.ps1", "scripts/initialize.ps1"]
cd_files                    = []
script_files                = ["scripts/config.ps1"]
inline_cmds                 = ["Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }"]