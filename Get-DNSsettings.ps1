<#
	.SYNOPSIS
		Get DNS-settings and verify specfic dns-server ipaddress.
	
	.DESCRIPTION
		The script reads a csv-file with servernames and connect remotely to get DNS-setting. If you har searching for a specific dns-server you can use FilteIPs.
	
	.PARAMETER CSVFile
		CSV-file with servers to get dns-settings. Must have the format.
		
		Name,
		server01,
		server02,
		
		Get-DNSsettings.ps1 -CSVFile 'd:\test\servers.csv'
	
	.PARAMETER FilterIPs
		Search for specific ipaddress for a DNS-server.
		
		Get-DNSsettings.ps1 -FilterIPs '192.168.1.200' -CSVFile 'd:\test\servers.csv'
		
		If you need to check multiple ipaddresses you can create a variable containing all your ipaddresses.
		
		PS C:\>$dns = '192.168.148.11','192.168.150.201'
		
		Get-DNSsettings.ps1 -FilterIPs $dns -CSVFile 'd:\test\servers.csv'
	
	.PARAMETER OutPut
		How the result will be displayed
		
		- Out-GridView
		- Console
		- CSV-file
		
		If CSV-file is selected the file will be created in the same location as the script.
	
	.PARAMETER Credential
		If Credential is requried to run the script you need to do the following steps to create a variable with your login credentials.
		
		PS C:\>$UserID = 'DOMAIN\UserID'
		PS C:\>$PlainPassword = 'mypassword'
		PS C:\>$SecPwd = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
		PS C:\>$Cred = New-Object System.Management.Automation.PSCredential ($UserID,$SecPwd)
		
		Get-DNSsettings.ps1 -FilterIPs '192.168.1.200' -CSVFile 'd:\test\servers.csv' -credential $cred
	
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
	[String]$CSVFile,
	[Parameter(Mandatory = $false)]
	[String]$FilterIPs,
	[ValidateSet('Out-Gridview', 'Console', 'CsvFile')]
	[String]$OutPut,
	[pscredential]$Credential
)

$data = @()

$servers = import-csv -Path $CSVFile
$index = 1
foreach ($server in $servers)
{
	Write-Progress -CurrentOperation "Processing server $index $($server.count)" -Activity 'Checking dns-settings' -PercentComplete (($index) / ($servers.count)* 100)
	Start-Sleep -Milliseconds 150
 	$ComputerName = $server.name
	
	If (Test-Connection $ComputerName -Count 1 -ErrorAction SilentlyContinue)
	{
		if ($Credential)
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
			Try
			{
				$NICs = Get-WmiObject -Class win32_networkadapterconfiguration -ComputerName $ComputerName -Filter "IPEnabled=TRUE" -ErrorAction Stop
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
 
$index++
}




Write-host 'Done!' -ForeGroundColor Green

if ($OutPut -eq 'Out-gridview')
{
	
	$data | out-gridview
	
}

if ($OutPut -eq 'Console')
{
	
	$data | FT
	
}

if ($OutPut -eq 'CsvFile')
{
	
	
	$data | Export-Csv -Path "$PSScriptRoot\DNS_result.csv" -NoClobber -Encoding UTF8 -Force -Verbose
	
}




	
