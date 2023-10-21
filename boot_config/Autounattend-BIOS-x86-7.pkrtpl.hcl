<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SetupUILanguage>
                <UILanguage>${os_language}</UILanguage>
            </SetupUILanguage>
            <InputLocale>${os_keyboard}</InputLocale>
            <SystemLocale>${os_language}</SystemLocale>
            <UILanguage>${os_language}</UILanguage>
            <UILanguageFallback>en-US</UILanguageFallback>
            <UserLocale>${os_language}</UserLocale>
        </component>
        <component name="Microsoft-Windows-Setup" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                    <CreatePartitions>
                        <!-- System partition -->
                        <CreatePartition wcm:action="add">
                            <Order>1</Order>
                            <Type>Primary</Type>
                            <Size>300</Size>
                        </CreatePartition>
                        <!-- Windows partition -->
                        <CreatePartition wcm:action="add">
                            <Order>2</Order>
                            <Type>Primary</Type>
                            <Extend>true</Extend>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <!-- System partition -->
                        <ModifyPartition wcm:action="add">
                            <Order>1</Order>
                            <PartitionID>1</PartitionID>
                            <Label>System</Label>
                            <Format>NTFS</Format>
                            <Active>true</Active>
                        </ModifyPartition>
                        <!-- Windows partition -->
                        <ModifyPartition wcm:action="add">
                            <Order>2</Order>
                            <PartitionID>2</PartitionID>
                            <Label>Windows</Label>
                            <Format>NTFS</Format>
                            <Letter>C</Letter>
                        </ModifyPartition>
                    </ModifyPartitions>
                </Disk>
                <WillShowUI>OnError</WillShowUI>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallFrom>
                        <MetaData wcm:action="add">
                            <Key>/IMAGE/NAME</Key>
                            <Value>${os_image_name}</Value>
                        </MetaData>
                    </InstallFrom>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>2</PartitionID>
                    </InstallTo>
                    <WillShowUI>OnError</WillShowUI>
                </OSImage>
            </ImageInstall>
            <UserData>
                <ProductKey>
                    <WillShowUI>OnError</WillShowUI>
                    <Key>${os_product_key}</Key>
                </ProductKey>
                <AcceptEula>true</AcceptEula>
                <FullName>${build_username}</FullName>
                <Organization>Assembling the Packer</Organization>
            </UserData>
            <ComplianceCheck>
                <DisplayReport>OnError</DisplayReport>
            </ComplianceCheck>
        </component>
    </settings>
    <settings pass="generalize">
        <component name="Microsoft-Windows-Security-SPP" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SkipRearm>1</SkipRearm>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <TimeZone>${os_timezone}</TimeZone>
            <ComputerName>*</ComputerName>
        </component>
        <component name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SkipAutoActivation>true</SkipAutoActivation>
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>Specialization Step Settings</Description>
                    <Path>cmd /c powershell -ExecutionPolicy Bypass -File a:\specialize.ps1</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <AutoLogon>
                <Password>
                    <Value>${build_password}</Value>
                    <PlainText>true</PlainText>
                </Password>
                <LogonCount>777</LogonCount>
                <Username>${build_username}</Username>
                <Enabled>true</Enabled>
            </AutoLogon>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>Installing required updates for VMware Tools and Windows Update client</Description>
                    <CommandLine>a:\add-win6.1.cmd</CommandLine>
                    <RequiresUserInput>true</RequiresUserInput>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Description>Install VMware Tools</Description>
                    <CommandLine>cmd /c powershell -ExecutionPolicy Bypass -File a:\install-vmtools.ps1</CommandLine>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Order>3</Order>
                    <Description>Basic Windows settings to run a Packer build</Description>
                    <CommandLine>cmd /c powershell -ExecutionPolicy Bypass -File a:\initialize.ps1</CommandLine>
                </SynchronousCommand>
            </FirstLogonCommands>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <ProtectYourPC>3</ProtectYourPC>
                <NetworkLocation>Work</NetworkLocation>
            </OOBE>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>${os_built-in_admin_password}</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>${build_password}</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Group>Administrators</Group>
                        <DisplayName>${build_username}</DisplayName>
                        <Name>${build_username}</Name>
                        <Description>Assembling the Packer</Description>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>${os_keyboard}</InputLocale>
            <SystemLocale>${os_language}</SystemLocale>
            <UILanguage>${os_language}</UILanguage>
            <UILanguageFallback>en-US</UILanguageFallback>
            <UserLocale>${os_language}</UserLocale>
        </component>
    </settings>
</unattend>
