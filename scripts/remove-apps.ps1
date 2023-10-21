# ------------------------------------------------------------------------------
# Name:           remove-apps.ps1
# Description:    Removing unnecessary applications in Windows 10 for Packer build
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------

$host.ui.RawUI.WindowTitle = 'Removing unnecessary applications in Windows 10 for Packer build'

$ErrorActionPreference = 'Stop'

$os = Get-WmiObject Win32_OperatingSystem

# Windows-10
if ($os.Caption -match 'Windows 10 Pro') {
    Write-Host '...Start uninstalling applications in Windows 10'
    $ProgressPreference = 'SilentlyContinue'

    $appList = @(
        'Microsoft.549981C3F5F10',
        'Microsoft.BingWeather',
        'Microsoft.GetHelp',
        'Microsoft.Getstarted',
        'Microsoft.Microsoft3DViewer',
        'Microsoft.MicrosoftOfficeHub',
        'Microsoft.MicrosoftSolitaireCollection',
        'Microsoft.MicrosoftStickyNotes',
        'Microsoft.MixedReality.Portal',
        'Microsoft.Office.OneNote',
        'Microsoft.People',
        'Microsoft.ScreenSketch',
        'Microsoft.SkypeApp',
        'Microsoft.StorePurchaseApp',
        'Microsoft.Wallet',
        'Microsoft.Windows.Photos',
        'Microsoft.WindowsAlarms',
        'Microsoft.WindowsCamera',
        'microsoft.windowscommunicationsapps',
        'Microsoft.WindowsFeedbackHub',
        'Microsoft.WindowsMaps',
        'Microsoft.WindowsSoundRecorder',
        'Microsoft.WindowsStore',
        'Microsoft.Xbox.TCUI',
        'Microsoft.XboxApp',
        'Microsoft.XboxGameOverlay',
        'Microsoft.XboxGamingOverlay',
        'Microsoft.XboxIdentityProvider',
        'Microsoft.XboxSpeechToTextOverlay',
        'Microsoft.YourPhone',
        'Microsoft.ZuneMusic',
        'Microsoft.ZuneVideo'
    )   

    function Remove-App {
        param ([string]$appName)    

        try {
            Get-AppxPackage $appName -AllUsers -ErrorAction Stop | Remove-AppxPackage -Confirm:$false -ErrorAction Stop
            Get-AppXProvisionedPackage -Online | Where-Object DisplayName -match $appName -ErrorAction Stop | Remove-AppxProvisionedPackage -Online -ErrorAction Stop
            # Write-Host "...Removed $appName"
            return $true
        }
        catch {
            Write-Host "...Failed to remove $($appName): $_"
            return $false
        }
    }   

    foreach ($app in $appList) {
        $package = Get-AppxPackage $app -AllUsers -ErrorAction SilentlyContinue
        if ($package) {
            $result = Remove-App $app
            if ($result) {
                Write-Host "   $app was successfully removed"
            } else {
                Write-Host "   $app removal failed"
            }
        } else {
            Write-Host "   $app is not installed"
        }
    }
    Write-Host '...Finish uninstalling applications in Windows 10'
}