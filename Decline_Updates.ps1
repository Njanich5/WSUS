<#
DeclineUpdates.ps1 uses the Update Services module. You can install it with the following commands:
Import-Module -Name UpdateServices 

This script will prompt you for a keyword and return all update results that contain the keyword
in a table. This table will tell you if the update is needed, if it's declined already, if it's superseded
by another update, when the update arrived into WSUS, the title, and the classification it's in.

It will then ask if you want to remove any Updatethat has this keyword in it's title. 
This works great for declining any Windows 7 updates or any other version you don't want updates for anymore.
#>

$wsus = Get-WsusServer
$count = 0
Write-Host -f Gray '---------------------------------------------------------------------------------------
Please type an identifier you want to search Windows Update for
Popular Search Queries include KB Numbers, Windows 10 version #, x64 or x86 architectures. etc
For examples, searching "Windows 7" will grab all updates that have Windows 7 in their title

Enter your query here: ' -NoNewline

$decline_word = Read-Host
$updates_declined = $wsus.GetUpdates()| Where { $_.Title -like "*$decline_word*" } | Select @{n="Needed";e={$_.State}},IsDeclined,IsSuperseded,ArrivalDate,Title,UpdateClassificationTitle |
Sort Needed
$updates_declined | FT -auto
Write-Host -f Gray " Decline ALL of these updates? (yes/no)
    "-NoNewline
$DeclineAnswer = Read-Host
$su = $wsus.SearchUpdates("$decline_word")
If($DeclineAnswer -in ("yes","YES"))
{
    foreach($s in $su) {
        $su.Decline()
        $count += 1
    }
Write-host -f yellow "
$count updates were declined"
}

else{
Write-Host " 
Updates were not declined. Press any key to exit"
}
