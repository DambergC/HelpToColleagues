# Function to check for pending Windows updates
function Check-WindowsUpdates {
    Write-Output "Checking for pending Windows updates..."
    $updatesSession = New-Object -ComObject Microsoft.Update.Session
    $updatesSearcher = $updatesSession.CreateUpdateSearcher()
    $searchResult = $updatesSearcher.Search("IsInstalled=0")
    
    if ($searchResult.Updates.Count -eq 0) {
        Write-Output "No pending updates found."
    } else {
        Write-Output "$($searchResult.Updates.Count) pending updates found."
        foreach ($update in $searchResult.Updates) {
            Write-Output "Update: $($update.Title)"
        }
    }
}

# Function to check for pending reboot
function Check-PendingReboot {
    Write-Output "Checking for pending reboot..."
    $rebootRequired = $false

    # Check registry keys for pending reboot
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations"
    )

    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            $rebootRequired = $true
            Write-Output "Pending reboot detected at: $path"
        }
    }

    if (-not $rebootRequired) {
        Write-Output "No pending reboot detected."
    }
}

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

# Install dependencies (example: Visual Studio Code)
$apps = @(
    "Microsoft.VisualStudioCode"
)

foreach ($app in $apps) {
    Write-Output "Installing $app..."
    winget install --id $app --silent
    Write-Output "$app installation complete."
}

# Check for pending Windows updates
Check-WindowsUpdates

# Check for pending reboot
Check-PendingReboot