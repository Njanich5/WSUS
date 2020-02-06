# WSUS Scripts 

## **Better-WSUS-Search.ps1**


Prior to using making sure you install the Update Services module with the following commands:

`Import-Module -Name UpdateServices` 

This script is inteded to be run on your WSUS server.
It adds the following Products to the update scope: 
   - Microsoft Security Essentials
   - Office 2016
   - Internet Security and Acceleration Server
   - Windows 10

Then checks for updates in these Classifications:
   - Security Updates
   - Definition Updates
   - Critical Updates

*A full list of Update Classifications can be found here: https://docs.microsoft.com/en-us/configmgr/sum/get-started/configure-classifications-and-products*

First, the script has you select a group from an existing computer group.
Then prompts you to enter a date to begin searching updates from. *Optionally, you can choose to search the update scope for a specific keyword.*

This script pulls all updates with **Any** Approval status as well as **All** Installation States

The **Any** and **All** settings are the most inclusive and will provide the most accurate data points

Once all the prompts are done, the script will output 3 tables.
The first table lists the Arrival Date, Update Title, Approved Status, Declined Status, Superseded Status, and Update Classification.

The second table lists each computer from the selected group, 
it then outputs a table showing which updates are Needed, Downloaded, Not Applicable, NotInstalled, Installed, and Failed.

The third table lists a table for each individual update showing a number of computers 
with the update status Needed, NotApplicable, NotInstalled, Installed, Failed, or Unknown

Lastly, a small table lists the total number of updates found.
If total updates found = 0 the first and third tables don't appear as there are no updates to list. 
![Image of BetterWSUSSearch.ps1](https://github.com/Njanich5/WSUS/blob/master/images/better.PNG?raw=true)

## DeclineUpdates.ps1
DeclineUpdates.ps1 uses the Update Services module. You can install it with the following commands:

`Import-Module -Name UpdateServices`

This script will prompt you for a keyword and return all update results that contain the keyword
in a table. This table will tell you if the update is needed, if it's declined already, if it's superseded
by another update, when the update arrived into WSUS, the title, and the classification it's in.

It will then ask if you want to remove any Updatethat has this keyword in it's title. 
This works great for declining any Windows 7 updates or any other version you don't want updates for anymore.

![Image of DeclineUpdates.ps1](https://github.com/Njanich5/WSUS/blob/master/images/decline.PNG?raw=true)

