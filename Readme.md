# Help to colleagues!
## _I Collection of scripts created to help colleagues in the work..._
![ProjectIcon](https://user-images.githubusercontent.com/16079354/209583161-b65c52fb-45a6-4d9d-b431-ef3c9610471f.png) 
### Get-DNSSettings.ps1
Save script on the server, start a powershell console as administrator in the folder where you have the script. The scripts read  a csv-file for devices to check and you have the choise to filter on specific ipaddress to check.

You need to create a csv-file with the devices you want to check dns-settings.

### FilterIP
If you use "FilterIPs" and the script finds match it will write TRUE in the output.

### Output
- out-gridview
- csv-file
- console
#### Out-gridview
![ProjectIcon](https://raw.githubusercontent.com/DambergC/HelpToColleagues/main/Images/Out-Gridview_Get-DnsSettings.png)
#### CSV-file
![ProjectIcon](https://raw.githubusercontent.com/DambergC/HelpToColleagues/main/Images/CSV-File_Get-DnsSettings.png)
#### Console
![ProjectIcon](https://raw.githubusercontent.com/DambergC/HelpToColleagues/main/Images/Console_Get-DnsSettings.png)

#### One-Liner
One-Liner to get all servers in AD to a csv-file

Get-ADComputer -Filter 'operatingsystem -like "*server*" -and enabled -eq "true"' -Properties * | Select-Object name | export-csv c:\temp\server.csv -NoClobber -Encoding UTF8
