# Function to get local group members
function Get-LocalGroupMembers {
    param (
        [string]$GroupName = "Administrators",
        [string]$ComputerName = $env:COMPUTERNAME
    )

    try {
        # Get the local group using Get-CimInstance
        $group = Get-CimInstance -ClassName Win32_Group -Filter "Name='$GroupName'" -ComputerName $ComputerName -ErrorAction Stop

        # Get the members of the local group
        $members = $group.GetRelated("Win32_UserAccount") + $group.GetRelated("Win32_Group")

        # Create a custom object for each member
        $members | ForEach-Object {
            [PSCustomObject]@{
                Name         = $_.Name
                Domain       = $_.Domain
                LocalAccount = $_.LocalAccount
                AccountType  = if ($_.LocalAccount) { "Local" } else { "Domain" }
                SID          = $_.SID
            }
        }
    } catch {
        Write-Error "Failed to retrieve group members: $_"
    }
}

# Get the members of the Administrators group
$adminMembers = Get-LocalGroupMembers -GroupName "Administrators"

# Output the results
if ($adminMembers) {
    # Display in table format
    $adminMembers | Format-Table -AutoSize

    # Optionally export to CSV
    $outputPath = "$env:USERPROFILE\Desktop\AdminGroupMembers.csv"
    $adminMembers | Export-Csv -Path $outputPath -NoTypeInformation -Force
    Write-Host "Results exported to $outputPath" -ForegroundColor Green
} else {
    Write-Host "No members found in the group." -ForegroundColor Yellow
}# Function to get local group members
function Get-LocalGroupMembers {
    param (
        [string]$GroupName = "Administrators",
        [string]$ComputerName = $env:COMPUTERNAME
    )

    # Get the local group
    $group = Get-wmiobject -ClassName Win32_Group -Filter "Name='$GroupName'" -ComputerName $ComputerName

    #$group = Get-CimInstance -ClassName Win32_Group -Filter "Name='$GroupName'" -ComputerName $ComputerName


    # Get the members of the local group
    $members = $group.GetRelated("Win32_UserAccount") + $group.GetRelated("Win32_Group")

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

# Output the results
$adminMembers | Format-Table -AutoSize
