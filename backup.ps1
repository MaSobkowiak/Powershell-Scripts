# User paths
$log = "X:\Backup TelWin24H script\log"
$backupPath = "Z:\TelApp_backup"
$rootPath = "Y:\TelApp"

# List of files to be excluded from backup, regex avalable
$exclude = @("*.bak", "*.lck", "*.lic", "*.TMP", "*.tmp", ".run", "MKcert.pem")
$maxLen = 80

# Get list of files in each directory
$root = @(Get-ChildItem -Recurse -Path $rootPath -Exclude $exclude)
$backup = @(Get-ChildItem -Recurse -Path $backupPath)

# Generate filename for log file
$logPath = $log + "\" + (Get-Date -Format "yyyy_MM_dd_HH_mm_ss") + '.txt'

function Generate-Log($type, $rootFile, $backupFile){
    $time = Get-Date
    $type = $type.PadRight(6)
    $rootFile = $rootFile.PadRight($maxLen)
    $backupFile = $backupFile.PadRight($maxLen)

    #Add header to log
    if(!(Test-Path -Path $logPath)){
        New-Item -ItemType File -Path $logPath -Force | Out-Null
        "| $('Date:'.PadRight(19)) | $('Type:'.PadRight(6)) | $('Base file:'.PadRight($maxLen)) | $('Backup file:'.PadRight($maxLen)) |" | Out-File $logPath -Append
    }

    "| $time | $type | $rootFile | $backupFile |" | Out-File $logPath -Append
}

# Copy files missing in backup folder
$mising = Compare-Object -ReferenceObject $root -DifferenceObject $backup -IncludeEqual -Property Name, Attributes -PassThru |Where-Object {$_.SideIndicator -eq "<="}
for ($i = 0; $i -lt $mising.Count; $i++) {
    if($mising[$i].Attributes -ne 'Directory'){
        New-Item -ItemType File -Path $($mising[$i].FullName).Replace($rootPath, $backupPath) -Force | Out-Null
        Copy-Item -Path $mising[$i].FullName -Destination $($mising[$i].FullName).Replace($rootPath, $backupPath) -Recurse -Force
        Generate-Log 'COPY' $mising[$i].FullName $($mising[$i].FullName).Replace($rootPath, $backupPath)
    }
    Write-Progress -Activity "Progress" -Status "$([Math]::Floor(($i / $mising.Count) * 100))% Complete, Current file: $($mising[$i].Name)" -PercentComplete $([Math]::Floor(($i / $mising.Count) * 100)) -CurrentOperation 'COPY'
}


# Delete files from backup
$extra =Compare-Object -ReferenceObject $root -DifferenceObject $backup -IncludeEqual -Property Name, Attributes -PassThru |Where-Object {$_.SideIndicator -eq "=>"}
for ($i = 0; $i -lt $extra.Count; $i++){
    if(Test-Path $extra[$i].FullName){
        Remove-Item -Path $extra[$i].FullName -Recurse -Force
        Generate-Log 'DELETE' '' $extra[$i].FullName  
    }
    Write-Progress -Activity "Progress" -Status "$([Math]::Floor(($i / $extra.Count) * 100))% Complete, Current file: $($extra[$i].Name)" -PercentComplete $([Math]::Floor(($i / $extra.Count) * 100)) -CurrentOperation 'DELETE'
}

# Update files in backup 
$update =Compare-Object -ReferenceObject $root -DifferenceObject $backup -IncludeEqual -Property Name, Attributes -PassThru |Where-Object {$_.SideIndicator -eq "=="}
for ($i = 0; $i -lt $update.Count; $i++) {
    if($update[$i].Attributes -ne 'Directory'){
        if((Test-Path $update[$i].FullName) -and (Test-Path $($update[$i].FullName).Replace($rootPath, $backupPath))){
            if((Get-ItemProperty -Path $update[$i].FullName -Name LastWriteTime).LastWriteTime -ne (Get-ItemProperty -Path $($update[$i].FullName).Replace($rootPath, $backupPath) -Name LastWriteTime).LastWriteTime){
                Copy-Item -Path $update[$i].FullName -Destination $($update[$i].FullName).Replace($rootPath, $backupPath) -Recurse -Force
                Generate-Log 'UPDATE' $update[$i].FullName $($update[$i].FullName).Replace($rootPath, $backupPath)
            }
        }
    }
    Write-Progress -Activity "Progress" -Status "$([Math]::Floor(($i / $update.Count) * 100))% Complete, Current file: $($update[$i].Name)" -PercentComplete $([Math]::Floor(($i / $update.Count) * 100)) -CurrentOperation 'UPDATE'
}
