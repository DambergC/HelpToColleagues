<#
	.SYNOPSIS
		Get DNS-settings and verify specfic dns-server ipaddress.
	
	.DESCRIPTION
		The script reads a csv-file with servernames and connect remotely to get DNS-setting. If you har searching for a specific dns-server you can use FilteIPs.
	
	.PARAMETER FilterIPs
		Search for specific ipaddress for a DNS-server.
	
		Get-DNSsettings.ps1 -FilterIPs '192.168.1.200' -CSVFile 'd:\test\servers.csv'
	
	.PARAMETER CSVFile
		CSV-file with servers to get dns-settings. Must have the format.

		Name,
		server01,
		server02,

		Get-DNSsettings.ps1 -CSVFile 'd:\test\servers.csv'
	
	.NOTES
		===========================================================================
		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2023 v5.8.229
		Created on:   	2023-10-10 08:37
		Created by:   	Christian Damberg
		Organization: 	Telia Cygate AB
		Filename:     	Get-DNSSettings.ps1
		===========================================================================
#>
param
(
	[Parameter(Mandatory = $false)]
	[String]$FilterIPs,
	[Parameter(Mandatory = $false)]
	[String]$CSVFile
)

$data = @()

$servers = import-csv -Path $CSVFile


foreach ($server in $servers)
{
	
	$ComputerName = $server.name
	
	If (Test-Connection $ComputerName -Count 1 -ErrorAction SilentlyContinue)
	{
		
		
		Try
		{
			$NICs = Get-WmiObject -Class win32_networkadapterconfiguration -Credential $Credential -ComputerName $ComputerName -Filter "IPEnabled=TRUE" -ErrorAction Stop
		}
		Catch
		{
			If ($_.Exception.Message)
			{
				$object = New-Object -TypeName PSObject
				$object | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ComputerName
				$object | Add-Member -MemberType NoteProperty -Name 'IPaddress' -Value $NIC.ipaddress
				$object | Add-Member -MemberType NoteProperty -Name 'DefaultIPGateway' -Value $NIC.DefaultIPGateway
				$object | Add-Member -MemberType NoteProperty -Name 'DNSServerSearchOrder' -Value ($NIC.DNSServerSearchOrder | Where-Object { $_ -ne $null })
				$object | Add-Member -MemberType NoteProperty -Name 'MatchFilter' -Value $Script:MatchFilter
				$object | Add-Member -MemberType NoteProperty -Name 'Result' -Value $_.Exception.Message
				
				$data += $object
			}
		}
		
		
		ForEach ($NIC in $NICs)
		{
			$Script:MatchFilter = $null
			If ($FilterIPs)
			{
				$NIC.DNSServerSearchOrder | ForEach-Object {
					If ($FilterIPs -contains $_)
					{
						#$FilterIPs
						$Script:MatchFilter = $true
					}
				}
			}
			
			
			$object = New-Object -TypeName PSObject
			$object | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ComputerName
			$object | Add-Member -MemberType NoteProperty -Name 'IPaddress' -Value $NIC.ipaddress
			$object | Add-Member -MemberType NoteProperty -Name 'DefaultIPGateway' -Value $NIC.DefaultIPGateway
			$object | Add-Member -MemberType NoteProperty -Name 'DNSServerSearchOrder' -Value ($NIC.DNSServerSearchOrder | Where-Object { $_ -ne $null })
			$object | Add-Member -MemberType NoteProperty -Name 'MatchFilter' -Value $Script:MatchFilter
			$object | Add-Member -MemberType NoteProperty -Name 'Result' -Value 'OK'
			
			$data += $object
			
		}
		
	}
	
	else
	{
		
		$object = New-Object -TypeName PSObject
		$object | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ComputerName
		$object | Add-Member -MemberType NoteProperty -Name 'IPaddress' -Value $null
		$object | Add-Member -MemberType NoteProperty -Name 'DefaultIPGateway' -Value $null
		$object | Add-Member -MemberType NoteProperty -Name 'DNSServerSearchOrder' -Value $null
		$object | Add-Member -MemberType NoteProperty -Name 'MatchFilter' -Value $null
		$object | Add-Member -MemberType NoteProperty -Name 'Result' -Value 'Failed'
		
		$data += $object
	}

}

Write-host 'Done!' -ForeGroundColor Green
$data | FT

$data | out-gridview

	