Param(
    [parameter(position=0)]
    [String]
        $WebApplicationURL,
    [parameter(position=1)]
    [Boolean]
        $AnalysisOnly = $true,
    [parameter(position=2)]
    [String[]]
        $ExclusionURLs
)
 
#Display Exclusion URL information
if($ExclusionURLs -and $ExclusionURLs.Count -gt 0) {
    Write-Host "Excluded URLs:" -foregroundcolor green
    $ExclusionURLs | ForEach-Object {
        Write-Host "     $_" -foregroundcolor green
    }
} else {
    Write-Host "No URL Exclusions" -foreground cyan
}
 
#Display Feature Information
$feature = Get-SPFeature "DocumentRouting"
Write-Host "Feature ID for Content Organizer is called $($feature.DisplayName)" -foregroundcolor cyan
 
if($AnalysisOnly) {
    Write-Host "ANALYSIS ONLY" -foregroundcolor red
}
 
#Go Through Every Site
Get-SPWebApplication $WebApplicationURL | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL | ForEach-Object {
 
    #Check for Exclusion
    if(!($ExclusionURLs -contains $_.URL)) {
        Write-Host "$_ | $($_.URL)" -foregroundcolor DarkCyan
 
        #Disable Feature if found
        if ($_.Features[$feature.ID]) {
            Write-Host "  Feature $($feature.DisplayName) Found" -foreground green
            if(!$AnalysisOnly){
                Disable-SPFeature $feature -Url $_.Url -Force -Confirm:$false
                Write-Host "  Feature $($feature.DisplayName) Disabled" -foreground magenta
            }
        } else {
            Write-Host "  Feature $($feature.DisplayName) NOT Found" -foreground yellow
        }
 
        #Delete Drop Off Library if found
        $list = $_.Lists["DROP OFF LIBRARY"]
        if ($list) {
            Write-Host "  List $list Found" -foregroundcolor green
            if(!$AnalysisOnly){
                $list.AllowDeletion = $true;
                $list.Update()
                $list.Delete()
                Write-Host "  List $list Deleted" -foreground magenta
            }
        } else {
            Write-Host "  Drop Off Library NOT found" -foregroundcolor yellow
        }
    }
 
}
Write-Host " "
Write-Host "All Done!" -foregroundcolor yellow
