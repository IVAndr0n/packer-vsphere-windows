---
layout: post
title: Automatically create Windows virtual machine images using Packer
date: 2023-10-21
categories:
  - hashicorp
---

<!-- # Project: packer-vsphere-windows -->

The project contains a directory of files for automatically creating images of virtual machines based on Windows operating systems using Packer, including configuration files, configuration scripts, and image build scripts

## Repository structure

```sh
$ tree --dirsfirst -F
.
├── add/
│   └── win6.1/  # required updates for windows 7 and Windows Server 2008R2
│       ├── VMware-tools-11.0.6-15940789-i386.exe
│       ├── VMware-tools-11.0.6-15940789-x86_64.exe
│       ├── windows6.1-kb3138612-x64.msu
│       ├── windows6.1-kb3138612-x86.msu
│       ├── windows6.1-kb4474419-v3-x64.msu
│       ├── windows6.1-kb4474419-v3-x86.msu
│       ├── windows6.1-kb4490628-x64.msu
│       ├── windows6.1-kb4490628-x86.msu
│       ├── windows6.1-kb4555449-x64.msu
│       └── windows6.1-kb4555449-x86.msu
├── boot_config/
│   ├── Autounattend-BIOS-x64-7-2008R2.pkrtpl.hcl
│   ├── Autounattend-BIOS-x86-7.pkrtpl.hcl
│   ├── Autounattend-UEFI-x64-10-11-2012R2-2016-2019-2022.pkrtpl.hcl
│   └── Autounattend-UEFI-x86-10.pkrtpl.hcl
├── manifests/
├── scripts/
│   ├── add-win6.1.cmd
│   ├── config.ps1
│   ├── initialize.ps1
│   ├── install-vmtools.ps1
│   ├── remove-apps.ps1
│   └── specialize.ps1
├── build_all_windows_with_duration_record_parallel.ps1
├── build_all_windows_with_duration_record_sequential.ps1
├── build_all_windows_without_duration_record_parallel.cmd
├── README.md
├── template-windows_vsphere.pkr.hcl
├── variables_vsphere.pkr.hcl
├── windows-10-pro-x64_vsphere.pkrvar.hcl
├── windows-10-pro-x86_vsphere.pkrvar.hcl
├── windows-11-pro-x64_vsphere.pkrvar.hcl
├── windows-7-pro-x64_vsphere.pkrvar.hcl
├── windows-7-pro-x86_vsphere.pkrvar.hcl
├── windows-server-2008r2-std-x64_vsphere.pkrvar.hcl
├── windows-server-2012r2-std-x64_vsphere.pkrvar.hcl
├── windows-server-2016-std-x64_vsphere.pkrvar.hcl
├── windows-server-2019-std-x64_vsphere.pkrvar.hcl
└── windows-server-2022-std-x64_vsphere.pkrvar.hcl

5 directories, 36 files
```

## Tested build of the following versions of Windows with Packer

* Windows 7 x86/x64
* Windows 10 x86/x64
* Windows 11 x64
* Windows 2008 R2 x64
* Windows 2012 R2 x64
* Windows 2016 x64
* Windows 2019 x64
* Windows 2022 x64
