# script variables


<#
	.SYNOPSIS
		A brief description of the Send-LocAdmReport.ps1 file.
	
	.DESCRIPTION
		Script to extract data from database and send it by mail
	
	.EXAMPLE
		PS C:\> .\Send-LocAdmReport.ps1
	
	.NOTES
		Additional information about the file.
#>


$scriptversion = '1.0'
$scriptname = $MyInvocation.MyCommand.Name
$ResultColl = @()
$dbserver = 'cm01'
$exclude = @("Administrator","Domain Admins")

# modules

if (-not (Get-PackageProvider -name NuGet))
{
	Install-PackageProvider nuget -ErrorAction SilentlyContinue
}


$checkfordbtools = Get-Module dbatools -ListAvailable

if (-not $checkfordbtools.name -eq 'dbatools')
{
    #Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	#Install-Module dbatools -ErrorAction SilentlyContinue -Force
	write-host 'Dbtools not installed'
}

if (-not (Get-Module -name send-mailkitmessage))
{
	Install-Module send-mailkitmessage -ErrorAction SilentlyContinue
	Import-Module send-mailkitmessage -Force
}


if (-not (Get-Module -name PSWriteHTML))
{
	Install-Module PSWriteHTML -ErrorAction SilentlyContinue
	Import-Module PSWriteHTML -Force
}


        $query = "SELECT TOP (1000) [ResourceID]
              ,[GroupID]
              ,[RevisionID]
              ,[AgentID]
              ,[TimeStamp]
              ,[Domain0]
              ,[LocalSecurityGroup0]
              ,[PrimaryKey0]
              ,[SID0]
              ,[User0]
          FROM [CM_PS1].[dbo].[v_GS_LOCALSECURITYGROUPINVENTORY]"
                           
            	$data = Invoke-Sqlcmd -ServerInstance $dbserver -Database CM_PS1 -Query $query


                ForEach ($device in $data)

                {

                    $resourceid = $device.ResourceID

                    $querydevice = "SELECT SMS_R_System.Name0 AS ClientName FROM v_R_System AS SMS_R_System WHERE SMS_R_System.ResourceID = $resourceid";

                    $clientname = Invoke-Sqlcmd -ServerInstance $dbserver -Database CM_PS1 -Query $querydevice
                    $clientnameToString = $clientname.ClientName
                   
                    	$object = New-Object -TypeName PSObject
				        $object | Add-Member -MemberType NoteProperty -Name 'Clientname' -Value $clientnameToString
				        $object | Add-Member -MemberType NoteProperty -Name 'AccountType' -Value $device.Domain0
                        $object | Add-Member -MemberType NoteProperty -Name 'GroupName' -Value $device.LocalSecurityGroup0
                        $object | Add-Member -MemberType NoteProperty -Name 'SID' -Value $device.SID0
                        $object | Add-Member -MemberType NoteProperty -Name 'User' -Value $device.User0


				        $resultColl += $object


                }
                            


$filteredArray = $ResultColl | Where-Object { $exclude -notcontains $_.user}

$filteredArray | Out-GridView
