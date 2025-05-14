<#
.SYNOPSIS
    Retrieves members of a specified local group on a computer.

.DESCRIPTION
    This script gets the members of a specified local group (default is "Administrators") on a specified computer.

.PARAMETER GroupName
    The name of the local group to query.

.PARAMETER ComputerName
    The name of the computer to query. Defaults to the local computer.

.EXAMPLE
    Get-LocalGroupMembers -GroupName "Administrators" -ComputerName "Server01"

.NOTES
    Created by: Christian Damberg
    Date: 2025-04-13
#>

# Function to get local group members
function Get-LocalGroupMembers {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$GroupName = "Administrators",

        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = $env:COMPUTERNAME
    )

    try {
        # Get the local group
        $group = Get-CimInstance -ClassName Win32_Group -Filter "Name='$GroupName'" -ComputerName $ComputerName
    } catch {
        Write-Error "Failed to retrieve group: $GroupName on $ComputerName. Error: $_"
        return
    }

    try {
        # Get the members of the local group
        $members = $group.GetRelated("Win32_UserAccount") + $group.GetRelated("Win32_Group")
    } catch {
        Write-Error "Failed to retrieve members of group: $GroupName on $ComputerName. Error: $_"
        return
    }

    # Create a custom object for each member
    $members | ForEach-Object {
        [PSCustomObject]@{
            Name         = $_.Name
            Domain       = $_.Domain
            LocalAccount = $_.LocalAccount
            SID          = $_.SID
        }
    }
}

# Get the members of the Administrators group
$adminMembers = Get-LocalGroupMembers -GroupName "Administrators"

# Check if any members were retrieved
if (-not $adminMembers) {
    Write-Host "No members found in the group 'Administrators' on $env:COMPUTERNAME." -ForegroundColor Yellow
    return
}

# Output the results
Write-Host "Administrators group members on $env:COMPUTERNAME:" -ForegroundColor Green
$adminMembers | Format-Table -AutoSize

# Export results to a CSV file
$csvFilePath = "$env:USERPROFILE\Documents\AdminMembers.csv"
try {
    $adminMembers | Export-Csv -Path $csvFilePath -NoTypeInformation -Force
    Write-Host "Results exported to $csvFilePath" -ForegroundColor Cyan
} catch {
    Write-Error "Failed to export results to CSV. Error: $_"
}

# Log results to a text file
$logFilePath = "$env:USERPROFILE\Documents\AdminMembers.log"
try {
    $adminMembers | Out-File -FilePath $logFilePath -Force
    Write-Host "Results logged to $logFilePath" -ForegroundColor Cyan
} catch {
    Write-Error "Failed to log results to file. Error: $_"
}