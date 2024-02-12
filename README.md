---
layout: post
title: Автоматизация создания образов Windows с использованием Packer
date: 2023-10-21
categories:
  - hashicorp
---

<!-- # Автоматизация создания образов **Windows** с использованием **Packer** -->

## Введение

**Packer** - инструмент от компании HashiCorp, автоматизирующий создание однородных образов виртуальных машин. Это руководство описывает процесс создания таких образов для операционных систем Windows с использованием Packer на платформе виртуализации vSphere.

### Предварительные требования

Перед началом работы убедитесь, что у вас установлен [Packer](https://www.packer.io) и есть доступ к репозиторию на [GitHub](https://github.com/IVAndr0n/packer-vsphere-windows). Проверьте наличие различных ISO-образов Windows, а также наличие административного доступа к vCenter.

### Структура репозитория на GitHub

<img allign="left" alt="img" src="https://raw.githubusercontent.com/IVAndr0n/packer-vsphere-windows/main/images/01.png" width="545">

<!-- ```sh
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
``` -->

- add/: Содержит необходимые обновления для Windows 7 и Windows Server 2008R2;

- boot_config/: Включает файлы конфигурации для каждой версии Windows;

- scripts/: Содержит скрипты для настройки операционных систем и установки дополнительного ПО;

- build_all_windows_with_duration_record_parallel.ps1: Обеспечивает параллельное создание образов с фиксацией длительности процесса на хосте Windows;

- build_all_windows_with_duration_record_sequential.ps1: Обеспечивает последовательное создание образов с фиксацией длительности процесса на хосте Windows;

- build_all_windows_without_duration_record_parallel.cmd: Обеспечивает параллельное создание образов без фиксации длительности процесса на хосте Windows;

- README.md: Документация с подробным описанием процесса;

- variables_vsphere.pkr.hcl: Определяются необходимые переменные, такие как адрес сервера vCenter и параметры виртуальной машины;

- template-windows_vsphere.pkr.hcl: Это шаблон, который содержит конфигурацию Packer, локальные переменные и другие настройки;

- windows-`<version>`_vsphere.pkrvar.hcl: Для каждой версии Windows созданы файлы переменных, которые содержат уникальные параметры, такие как путь к ISO-образу и размер диска.

### Создание образа с использованием Packer

1. ISO-образы операционных систем требуется предварительно разместить в хранилище данных vCenter.

2. Вы можете изменить переменные в файле **'variables_vsphere.pkr.hcl'**, однако это необязательно, так как файл уже оптимизирован.

3. Вы можете настроить переменные в файлах **'windows-`<version>`_vsphere.pkrvar.hcl'**, такие как путь к ISO-образу. В остальном это необязательно, поскольку настройки в целом являются оптимальными.

4. Рекомендую воздерживаться от внесения изменений в файл **'template-windows_vsphere.pkr.hcl'** без тщательного изучения, поскольку он является шаблоном для настройки Packer.

#### Создание отдельного образа

1. Откройте терминал и перейдите в директорию с файлами Packer.

2. Выполните команду **'packer build -force -var-file=windows-`<version>`_vsphere.pkrvar.hcl'** для запуска процесса создания образа. Учтите, что вместо  **'windows-`<version>`_vsphere.pkrvar.hcl'** следует указать соответствующее имя файла для нужной операционной системы.   

3. Packer создаст виртуальную машину в vSphere, установит операционную систему из ISO-образа, выполнит необходимые скрипты и обновления, а затем создаст образ этой виртуальной машины.

#### Создание ряда образов

1. Откройте терминал и перейдите в директорию с файлами Packer.

2. Примите решение о том, для каких версий систем Windows вы будете создавать образы, и оставьте в директории только файлы, соответствующие этим версиям, с названиями вида **'windows-`<version>`_vsphere.pkrvar.hcl'**. 

3. Запустите необходимый скрипт на ваш выбор: это может быть скрипт для параллельного создания образов с фиксацией времени выполнения на хосте Windows, скрипт для последовательного создания образов с фиксацией времени выполнения или скрипт для параллельного создания образов без фиксации времени выполнения на хосте Windows. Скрипт автоматически обнаружит все файлы конфигурации Packer в текущей директории и запустит процесс создания образов для каждого из них.

4. Каждый образ будет сопровождаться записью лога и созданием файла, указывающего продолжительность процесса, за исключением случаев, когда используется скрипт без фиксации времени выполнения.

5. По завершении работы скрипта можно анализировать логи и файлы длительности для оценки производительности и успешности создания образов.

### Поддерживаемые версии Windows

- Windows 7 x86/x64
- Windows 10 x86/x64
- Windows 11 x64
- Windows 2008 R2 x64
- Windows 2012 R2 x64
- Windows 2016 x64
- Windows 2019 x64
- Windows 2022 x64

### Заключение

Использование Packer в DevOps практиках улучшает процессы развертывания, обеспечивая быстрое создание надежных окружений и повышая скорость, безопасность и консистентность среды.
