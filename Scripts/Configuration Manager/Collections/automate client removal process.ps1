<# 
AUTHOR  : Eswar Koneti 
DATE    : 18-Nov-2016
COMMENT : This script will remove clients that you input in text file from SCCM database
VERSION : 1.0
#>

# Determine script location
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$log      = "C:\Users\eswar\Desktop\Scripts\PS\clientremoval.log"
$date     = Get-Date -Format "dd-MM-yyyy hh:mm:ss"
# Get list of clients from notepad
"---------------------------------------------------------------------------" + "`r`n" | Out-File $log -append
$CollectionID="CB10032C"
Try
{
  Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
$SiteCode = Get-PSDrive -PSProvider CMSITE
$SMSProvider=$sitecode.SiteServer
Set-Location "$($SiteCode.Name):\"
}
Catch
{
 Write-Host "[ERROR]`t SCCM Module couldn't be loaded. Script will stop!"
 Exit 1
 }
$GetCOLL=Get-WmiObject -Namespace root\SMS\Site_$SiteCode -Class SMS_collection -Filter "CollectionID = '$CollectionID'"
if ($GetCOLL)
{
#get count of resources from the given collection
$collectioncount = (Get-WmiObject -Class SMS_FullCollectionMembership -Namespace root\SMS\Site_$SiteCode -Filter "CollectionID = '$CollectionID'"| Measure-Object).Count

#check if the collection is blank or any resources exist
if ($collectioncount -gt 0)
    {
	 #Get list of computers
     $compobject=Get-WmiObject -Class SMS_FullCollectionMembership -Namespace root\SMS\Site_$SiteCode -Filter "CollectionID = '$CollectionID'"
    write-host $compobject.name
    ForEach-Object { $compobject.Delete() }
      }
   #Update the collection
   Invoke-WmiMethod -Path "ROOT\SMS\Site_$($SiteCode):SMS_Collection.CollectionId='$CollectionID'" -Name RequestRefresh -ComputerName $SMSProvider
  }
   #If the Supplied collection not found--Deleted for some Reason
   else
   {
    "collectionID "+$CollectionID+" Not found" | out-file -FilePath Out-File $log -append
	}