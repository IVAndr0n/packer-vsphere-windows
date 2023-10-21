:: ------------------------------------------------------------------------------
:: Name:           build_all_windows_without_duration_record_parallel.cmd
:: Description:    Parallel build all Windows without duration record
:: Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
:: ------------------------------------------------------------------------------

@echo off
title Parallel build all Windows without duration record

:: example: cmd /c start packer build -force -var-file=windows-7-pro-x86_vsphere.pkrvar.hcl .
:: If you need to create a single directory for a specific system instead of using -var-file, you need to change the extension from pkrvar.hcl to auto.pkrvars.hcl
:: In this case, the command to run will be: packer build -force .

set source=e:\devopsLAB\projects\packer-vsphere-windows\

cd /d%source%

for %%f in (*.pkrvar.hcl) do (
    cmd /c start packer build -force -var-file=%%f .
)