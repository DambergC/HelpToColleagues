# Check if Winget is already installed
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Output "Winget is already installed."
} else {
    # Install App Installer which includes Winget
    Write-Output "Installing Winget..."
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Add-AppxPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Write-Output "Winget installation complete."
}

# Install dependencies
$dependencies = @(
    "https://aka.ms/Microsoft.UI.Xaml.2.7",
    "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
)

foreach ($dependency in $dependencies) {
    Write-Output "Installing dependency from $dependency..."
    Invoke-WebRequest -Uri $dependency -OutFile "$env:TEMP\$(Split-Path -Leaf $dependency)"
    Add-AppxPackage -Path "$env:TEMP\$(Split-Path -Leaf $dependency)"
    Write-Output "Dependency installation complete."
}
