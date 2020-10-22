# Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced) 
# Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)
# Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)

#Change this variable according to your current power plan 
$GUID = "381b4222-f694-41f0-9685-ff5bb260df2e"


Function GenerateForm($status) {

    [reflection.assembly]::LoadWithPartialName("System.Windows.Forms")

    if ($status -eq 'ON') {
        $banner = [System.Drawing.Image]::Fromfile((Get-Item -Path '.\assets\ON.png'));
    }
    elseif ($status -eq 'OFF') {
        $banner = [System.Drawing.Image]::Fromfile((Get-Item -Path '.\assets\OFF.png'));
    }

    try {
        Add-Type -AssemblyName System.Windows.Forms   
        
        # Build Form
        $objForm = New-Object System.Windows.Forms.Form
        $objForm.Text = "Boost"
        $objForm.Size = New-Object System.Drawing.Size(414,180)
        $objForm.BackColor = '#FFFFFF'
        $objForm.ControlBox = $false
        $objForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

        # Add icon 
        $Icon = New-Object system.drawing.icon (".\icons\white.ico")
        $objForm.Icon= $Icon

        # Load banner
        $pictureBox = new-object Windows.Forms.PictureBox
        $pictureBox.Location = New-Object System.Drawing.Size(1,1)
        $pictureBox.Size = New-Object System.Drawing.Size($banner.Width,$banner.Height)
        $pictureBox.Image = $banner
        $objForm.controls.add($pictureBox)

        # Show the form
        $objForm.Show()| Out-Null
        Start-Sleep -Seconds 5
        $objForm.Close() | Out-Null
    }
    catch {
        Write-Host "Message: $($_.Exception.Message)"
        Write-Host "Stack: $($_.ScriptStackTrace)"
    }
}


try {    
    $powerQuery = powercfg /query $GUID SUB_PROCESSOR PROCTHROTTLEMAX
    $powerQuery[10] -match "Current AC Power Setting Index: (?<content>.*)$" 
    $currValue = $matches['content'] 

    if($currValue -eq '0x00000064') {
        powercfg -setacvalueindex SCHEME_BALANCED SUB_PROCESSOR PROCTHROTTLEMAX 99
        GenerateForm 'OFF'
    }
    else {
        powercfg -setacvalueindex SCHEME_BALANCED SUB_PROCESSOR PROCTHROTTLEMAX 100
        GenerateForm 'ON'
    } 
}
catch  {
   Write-Host "Message: $($_.Exception.Message)"
   Write-Host "Stack: $($_.ScriptStackTrace)"
}

