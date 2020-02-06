<#
BetterWSUSSearch.ps1

Prior to using making sure you install the Update Services module with the following commands:
Import-Module -Name UpdateServices 

A full list of availible cmdlets from this module can be found with the following command:
Get-Command -Module  UpdateServices 

This script is inteded to be run on your WSUS server.
Only adds the following Products to the update scope: 
    Microsoft Security Essentials
    Office 2016
    Internet Security and Acceleration Server
    Windows 10

Only checks for updates in these Classifications:
    Security Updates
    Definition Updates
    Critical Updates
A full list of Update Classifications can be found here: https://docs.microsoft.com/en-us/configmgr/sum/get-started/configure-classifications-and-products

First, the script has you select a group from an existing computer group.
Then prompts you to enter a date to begin searching updates from.
Optionally, you can choose to search the update scope for a specific keyword. 
This script pulls all updates with "Any" Approval status as well as "All" States

The Any and All settings are the most inclusive and will provide the most accurate data points

Once all the prompts are done, the script will output 3 tables.
The first table lists the Arrival Date, Update Title, Approved Status, Declined Status, Superseded Status, and Update Classification.

The second table lists each computer from the selected group, 
it then outputs a table showing which updates are Needed, Downloaded, Not Applicable, NotInstalled, Installed, and Failed.

The third table lists a table for each individual update showing a number of computers 
with the update status Needed, NotApplicable, NotInstalled, Installed, Failed, or Unknown

Lastly, a small table lists the total number of updates found.
If total updates found = 0 the first and third tables don't appear as there are no updates to list. 

#>

#Initialize variables
$wsus = Get-WsusServer
$newscope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
$computerscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$wsusProducts = 'Microsoft Security Essentials','Office 2016','Internet Security and Acceleration Server','Windows 10'
$keyword = ""

#Set Update Products
$updatecategories = $wsus.GetUpdateCategories() | where { $_.Title -in $wsusProducts }
$newscope.Categories.AddRange($updatecategories)

#Classifications
$classifications = $wsus.GetUpdateClassifications() | Where {$_.Title -in ('Security Updates','Definition Updates','Critical Updates')}
$newscope.Classifications.AddRange($classifications)

#Find updates with ANY approval status
$newscope.ApprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::Any

#Find updates with ALL installation status - Note - Setting this to Installed will help find updates that are downloaded but not installed
$newscope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::All

#Set Groups
$groups = @()
foreach( $group in $wsus.GetComputerTargetGroups() ) 
{ 
    #Uncomment the line below to list all group members
    #Write-Host $group.Name " - " $group.GetComputerTargets().Count " member(s)" 
    $groups += $group.Name
}
#For loop to go through the length of the groups array. Print out the index{0}, the groupname{1}
for($i=0;$i-le $groups.length-1;$i++){“{0} = {1}" -f $i,$groups[$i]}

#Select Computer Group
Write-Host -f Gray "
 - Select a group - "
$select = Read-Host
$SelectGroup= $groups[$select]
$new_group = $wsus.GetComputerTargetGroups() | Where{$_.Name -eq $SelectGroup}
$addgroup = $newscope.ApprovedComputerTargetGroups.Add($new_group) 
[void]$computerscope.ComputerTargetGroups.Add($new_group)

#Set Arrival Date
Write-Host -f Gray '
 - Arrival Date - 
Enter a start date to search updates from in the format MM/DD/YYYY
For example, if you want to find all new updates after January 1st 2020 you would enter 01/01/2020
: ' -NoNewline
$TextDate = Read-Host
$Date = [datetime]::Parse($TextDate)
$newscope.FromArrivalDate = $TextDate


#If statement, asks if you want to find updates that match a keyword in each updates title/description
Write-Host -f Gray "
 - Keyword Search -
Note: This will only find updates that have the keyword in the title/description

Do you want to use a keyword to find specific updates? (y/n): " -Nonewline
$keyword = Read-host

if($keyword -in ("yes","y","YES")) 
{
Write-Host -f Gray '
Please type an identifier you want to search Windows Update for
Popular Search Queries include KB Numbers, Windows 10 version #, x64 or x86 architectures. etc
For examples, searching "Windows 7" will return all updates that have Windows 7 in their title

Enter your query here: ' -NoNewline

$approve_word = Read-Host
$newscope.TextIncludes = $approve_word
}

#Print a table showing all update's status
$wsus.GetUpdates($newscope) | Select ArrivalDate,Title,IsApproved,IsDeclined,IsSuperseded,UpdateClassificationTitle | FT

#Print a Table showing a summary of each computer and their updates
$wsus.GetSummariesPerComputerTarget($newscope,$computerscope) |
Select @{L=’ComputerTarget’;E={($wsus.GetComputerTarget([guid]$_.ComputerTargetId)).FullDomainName}},
@{L=’NeededCount’;E={($_.DownloadedCount + $_.NotInstalledCount)}},DownloadedCount,NotApplicableCount,NotInstalledCount,InstalledCount,FailedCount | Sort NeededCount -Descending | FT


#Print a table showing the status of each update
#If there are no updates pulled, this table is empty and does not show
$wsus.GetSummariesPerUpdate($newscope,$computerscope) |
Select @{L=’UpdateTitle’;E={($wsus.GetUpdate([guid]$_.UpdateId)).Title}},
@{L=’Needed’;E={($_.DownloadedCount + $_.NotInstalledCount)}},@{l="NotApplicable";e={$_.NotApplicableCount}}, @{l="NotInstalled";e={$_.NotInstalled}},
@{l="Installed";e={$_.InstalledCount}},@{l="Failed";e={$_.FailedCount}},@{l="Unknown";e={$_.UnknownCount}} | Sort-Object Needed -Descending | FT

#Each Update Status
$wsus.GetUpdateStatus($newscope,$False) | Select @{l="Total Updates Found";e={$_.UpdateCount}}
