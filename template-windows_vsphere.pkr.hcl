# ------------------------------------------------------------------------------
# Name:           template-windows_vsphere.pkr.hcl
# Description:    Packer Template for VMware vSphere and Windows OS
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#                                  Packer Block
# ------------------------------------------------------------------------------
packer {
    required_version = ">= 1.9.4"
    required_plugins {
        vsphere = {
            version = ">= v1.2.1"
            source  = "github.com/hashicorp/vsphere"
        }
        windows-update = {
            version = ">= 0.14.3"
            source  = "github.com/rgl/windows-update"
        }
    }
}

# ------------------------------------------------------------------------------
#                                  Local Variables Block
# ------------------------------------------------------------------------------
locals { 
    built_by                    = "HashiCorp Packer ${packer.version}"
    build_version               = formatdate("YY.MM", timestamp())
    build_date                  = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
    vm_os                       = coalesce(join("-", compact([var.vm_os_family, var.vm_os_short_name, var.vm_os_bit])), "${var.vm_guest_os_type}")
    vm_name                     = "${join("-", compact([local.vm_os, local.build_version]))}"
    vm_description              = <<-EOT
                                    Operating System: ${local.vm_os}
                                    Created: ${local.build_date}
                                    Build Version: ${local.build_version}
                                    Built By: ${local.built_by}
                                    Description: Optimized clean Windows install image for VMware vSphere. Includes all latest updates.
                                EOT
    manifest_path               = "${path.cwd}/manifests"
    manifest_file               = "manifest-${local.vm_os}.json"
}

# ------------------------------------------------------------------------------
#                                  Source Block
# ------------------------------------------------------------------------------
source "vsphere-iso" "setup" {
    # vSphere Configuration
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = var.vcenter_insecure
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    datastore                   = var.vcenter_datastore
    folder                      = var.vcenter_folder

    # vSphere Content Library and Template Configuration
    convert_to_template         = var.vcenter_convert_template
    create_snapshot             = var.vcenter_snapshot
    snapshot_name               = var.vcenter_snapshot_name
    dynamic "content_library_destination" {
        for_each = var.vcenter_content_library != null ? [1] : []
            content {
                library         = var.vcenter_content_library
                name            = "${local.vm_name}"
                description     = local.vm_description
                ovf             = var.vcenter_content_library_ovf
                destroy         = var.vcenter_content_library_destroy
                skip_import     = var.vcenter_content_library_skip
            }
    }

    # Virtual Machine Options
    vm_name                     = local.vm_name
    notes                       = local.vm_description
    vm_version                  = var.vm_hardware_version
    guest_os_type               = var.vm_guest_os_type
    CPUs                        = var.vm_numvCPUs
    cpu_cores                   = var.vm_coresPerSocket
    CPU_hot_plug                = var.vm_cpu_hotadd
    RAM                         = var.vm_mem_size
    RAM_reserve_all             = var.vm_mem_reserve_all
    RAM_hot_plug                = var.vm_mem_hotadd
    storage {
        disk_size               = var.vm_disk_size
        disk_thin_provisioned   = var.vm_disk_thin
    }
    disk_controller_type        = var.vm_disk_controller
    network_adapters {
        network_card            = var.vm_nic_type
        network                 = var.vcenter_network
    }
    cdrom_type                  = var.vm_cdrom_type
    video_ram                   = var.vm_video_ram
    vTPM                        = var.vm_vtpm
    firmware                    = var.vm_firmware
    tools_upgrade_policy        = var.vm_tools_upgrade_policy

    # vSphere Removable media configuration
    iso_paths                   = [ "[${var.os_iso_datastore}] ${var.os_iso_path}/${var.os_iso_file}", "${var.vm_tools}" ]
    floppy_files                = var.floppy_files
    floppy_content              = {
                                    "Autounattend.xml" = templatefile("${abspath(path.root)}/boot_config/${var.boot_config}", {
                                        os_image_name                = var.os_image_name
                                        os_product_key               = var.os_product_key
                                        os_language                  = var.os_language
                                        os_keyboard                  = var.os_keyboard
                                        os_timezone                  = var.os_timezone
                                        os_built-in_admin_password   = var.os_built-in_admin_password
                                        build_username               = var.build_username
                                        build_password               = var.build_password
                                    })
                                  }
    cd_files                    = var.cd_files
    cd_label                    = var.cd_label
    remove_cdrom                = var.vm_cdrom_remove

    # Builder Options
    boot_order                  = var.vm_boot_order
    boot_wait                   = var.vm_boot_wait
    boot_command                = ["<spacebar>"]
    ip_wait_timeout             = var.vm_ip_timeout
    communicator                = "winrm"
    winrm_username              = var.build_username
    winrm_password              = var.build_password
    shutdown_command            = "shutdown /s /t 60 /f /d p:4:1 /c \"Packer Shutdown\""
    shutdown_timeout            = var.vm_shutdown_timeout
}

# ------------------------------------------------------------------------------
#                                  Build Block
# ------------------------------------------------------------------------------
build {
    # Build sources
    name                        = local.vm_os
    sources                     = [ "source.vsphere-iso.setup" ]

    # Updating Windows with the "packer-provisioner-windows-update" add-on (https://github.com/rgl/packer-provisioner-windows-update)
    provisioner "windows-update" {
        pause_before            = "30s"
        search_criteria         = "IsInstalled=0"
        filters                 = [ "exclude:$_.Title -like '*VMware*'",
                                    "exclude:$_.Title -like '*Preview*'",
                                    "exclude:$_.Title -like '*Defender*'",
                                    "exclude:$_.InstallationBehavior.CanRequestUserInput",
                                    "include:$true" ]
        update_limit            = "25"
        restart_timeout         = "90m"
    }

    # Restart Provisioner
    provisioner "windows-restart" {
        pause_before            = "60s"
        restart_timeout         = "30m"
        restart_check_command   = "powershell -command \"& {Write-Host 'restarted.'}\""
    }

    # Disabling Automatic Windows Updates via Update Service
    provisioner "powershell" {
        elevated_user           = var.build_username
        elevated_password       = var.build_password
        inline                  = [ "Write-Host '...Disabling Automatic Windows Updates via Update Service'",
                                    "Stop-Service -Name wuauserv -Force -WarningAction SilentlyContinue",
                                    "Set-Service -Name wuauserv -StartupType Disabled -WarningAction SilentlyContinue" ]
    }

    # Executing a PowerShell Scripts
    provisioner "powershell" {
        elevated_user           = var.build_username
        elevated_password       = var.build_password
        scripts                 = var.script_files
        environment_vars        = [ "BUILDUSER=${var.build_username}" ]
    }

    # Executing a PowerShell Commands
    provisioner "powershell" {
        elevated_user           = var.build_username
        elevated_password       = var.build_password
        inline                  = var.inline_cmds
    }

    # Creating manifest
    post-processor "manifest" {
        output                  = "${local.manifest_path}/${local.manifest_file}"
        strip_path              = true
        strip_time              = true
        custom_data             = {
          "A. Built By"         = local.built_by
          "B. Created"          = local.build_date
          "C. vCenter Server"   = var.vcenter_server
          "D. Template Folder"  = var.vcenter_folder
          "E. Number of vCPU"   = var.vm_numvCPUs
          "F. Cores Per Socket" = var.vm_coresPerSocket
          "G. Disk"             = var.vm_disk_size
          "H. Memory"           = var.vm_mem_size
        }
    }
}