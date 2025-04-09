<#
	.SYNOPSIS
		List dayspan, hourspan or Minutespan on Collections
	
	.DESCRIPTION
		Runas administrator on Siteserver to get list on each collection and the Recyclespan on membership
		
		- DaySpan
		- HourSpan
		-  MinuteSpan
	
	.NOTES
		===========================================================================
		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2025 v5.9.253
		Created on:   	4/9/2025 10:26 AM
		Created by:   	damberg
		Organization:	Telia Cygate AB
		Filename		Get-RefreshCycleCollectionMembership.ps1
		===========================================================================
#>


# Function to extract SCCM Site Code using CIM cmdlets
function Get-SCCMSiteCode
{
	param (
		[string]$ComputerName = 'localhost' # Default to the local computer
	)
	
	try
	{
		# Query CIM for the SMS_ProviderLocation class
		$providerLocation = Get-CimInstance -Namespace "ROOT\SMS" -ClassName "SMS_ProviderLocation" -ComputerName $ComputerName -ErrorAction Stop
		
		# Extract the Site Code
		if ($providerLocation)
		{
			$siteCode = $providerLocation.SiteCode
			#Write-Output "Detected SCCM Site Code: $siteCode"
			return $siteCode
		}
		else
		{
			Write-Output "Unable to retrieve site code."
			return $null
		}
	}
	catch
	{
		Write-Output "Error retrieving Site Code: $_"
		return $null
	}
}

# Main Script
# Get the SCCM Site Code dynamically
$siteCode = Get-SCCMSiteCode
if (-not $siteCode)
{
	Write-Output "Site Code could not be determined. Exiting script."
	exit
}

# Connect to the SCCM site using the dynamically obtained site code
$sitepath = "$siteCode"+":"
Set-Location  $sitepath

# Retrieve all device collections
$deviceCollections = Get-CMDeviceCollection

# Create an array to store results
$results = @()

# Loop through each device collection to extract RefreshSchedule details
foreach ($collection in $deviceCollections)
{
	if ($collection.RefreshSchedule)
	{
		$schedule = $collection.RefreshSchedule
		# Add to results array
		$results += [PSCustomObject]@{
			"CollectionName" = $collection.Name
			"DaySpan"	     = $schedule.DaySpan
			"HourSpan"	     = $schedule.HourSpan
			"MinuteSpan"	 = $schedule.MinuteSpan
			"StartTime"	     = $schedule.StartTime
		}
	}
	else
	{
		# If no refresh schedule, add with empty values
		$results += [PSCustomObject]@{
			"CollectionName" = $collection.Name
			"DaySpan"	     = "Not set"
			"HourSpan"	     = "Not set"
			"MinuteSpan"	 = "Not set"
			"StartTime"	     = "Not set"
		}
	}
}

# Output the results in table format
$results | Format-Table -AutoSize