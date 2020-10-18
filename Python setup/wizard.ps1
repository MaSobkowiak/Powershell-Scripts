
$dependencies = 'dependencies/packages'
$python32 = 'dependencies/python/python-3.7.9-x32.exe'
$python64 = 'dependencies/python/python-3.7.9-x64.exe'
$requirements = 'requirements.txt'

do {   
    cls
    if ($dev -eq $False) {
        Write-Output "
            0. Exit
            1. Install python 
            2. Setup venv
            3. Verify venv
            4. Update dependencies
        "
    }

    function scriptExit {
        cls
        timeout /T 1 /nobreak
        exit
    }

    function installPython {
        # Start python installer 
        if ($([Environment]::Is64BitOperatingSystem) -eq $True) {
            Write-Host '64bit system'
            & $python64 PrependPath=1 Include_test=0
        }
        else {
            Write-Host '32bit system'
            & $python32 PrependPath=1 Include_test=0
        }
    }
    function checkCommand($cmdname) {
        # Check if command is recognized as an internal or external command
        return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
    }

    function setupEnviroments {
        # Create venv and install dependencies

        # Check if commands are recognized.
        if (-not((checkCommand 'python') -And (checkCommand 'pip'))) {
            Write-Warning 'Python or pip are not recognized as command.'
            pause
            break
        }

        # Create venv if not exists
        if (-not (Test-Path 'venv\Scripts')) {
            python -m venv venv 
            Write-Host 'Created venv.'
        }

        # Activate venv
        if (Test-Path 'venv\Scripts\activate') {
            .\venv\Scripts\activate
        }
        else {
            Write-Warning 'Cant activate venv.'
            pause 
            break       
        }
        # Check if requirements.txt exists
        if (-not (Test-Path $requirements)) {    
            Write-Warning 'No requirements file found.'   
            pause
            break
        }

        # If no dependencies folder, try to download them from pypi.org
        if (-not (Test-Path $dependencies)) {
            Write-Host 'No dependencies folder found'
            New-Item $dependencies -ItemType directory
                
            # Check if PC can access pypi.org
            if (-not(Test-NetConnection -ComputerName "www.pypi.org" -InformationLevel "Quiet")) {
                Write-Warning 'No internet connection.'   
                pause
                break 
            }
            pip --disable-pip-version-check download -r $requirements -d $dependencies 
            Write-Host "Downloaded dependencies to: $dependencies"
                
        }
        # Install dependencies into venv 
        pip --disable-pip-version-check install --no-index --find-links $dependencies -r $requirements
        Write-Host 'Dependencies installed.'
        pause
        
    }

    function updateDependencies {
        # Do pip freeze action and download dependencies from pypi.org into dependencies folder.

        # Check if commands are recognized.
        if (-not((checkCommand 'python') -And (checkCommand 'pip'))) {
            Write-Warning 'Python or pip are not recognized as command.'
            pause
            break
        }

        # Create venv if not exists
        if (-not (Test-Path 'venv\Scripts')) {
            python -m venv venv 
            Write-Host 'Created venv.'
        }

        # Activate venv
        if (Test-Path 'venv\Scripts\activate') {
            .\venv\Scripts\activate
        }
        else {
            Write-Warning 'Cant activate venv.'
            pause 
            break       
        }

        # Check if requirements.txt exists
        if (-not (Test-Path $requirements)) {    
            New-Item -ItemType File -Path $requirements -Force | Out-Null
        }

        pip freeze > $requirements

        # Check if PC can access pypi.org
        if (Test-NetConnection -ComputerName "www.pypi.org" -InformationLevel "Quiet") {
            pip download -r $requirements -d $dependencies 
        }
        else {
            Write-Error 'No internet connection.'      
        }
    }

    function checkEnviroment {

        # Check if commands are recognized.
        if (-not((checkCommand 'python') -And (checkCommand 'pip'))) {
            Write-Warning 'Python or pip are not recognized as command.'
            pause
            break
        }

        # Check of venv have been created.
        if (-not(Test-Path 'venv\Scripts\activate')) {
            Write-Warning 'No venv can be found.'
            pause
            break
        }
        else {
            .\venv\Scripts\activate
        }

        #Check of all dependencies have been installed
        $req = Get-Content -Path $requirements
        $reqObj = @()

        foreach ($elem in $req) {
        
            $reqArray = $elem.Split("==")
            
            if ($reqArray[0] -ne "") {
                $newObjR = New-Object -TypeName psobject
                $newObjR | Add-Member -MemberType NoteProperty -Name Package -Value $reqArray[0].ToString()
                $newObjR | Add-Member -MemberType NoteProperty -Name Version -Value $reqArray[2].ToString()
                $reqObj += $newObjR
            }
        }

        $pip = (pip --disable-pip-version-check list) | Out-String 
        $pipArray = $pip.Split() | Where-Object { $_ }
        $pipObj = @()

        for ($i = 4; $i -lt $pipArray.Length; $i = $i + 2) {

            $newObjP = New-Object -TypeName psobject
            $newObjP | Add-Member -MemberType NoteProperty -Name Package -Value $pipArray[$i].ToString()
            $newObjP | Add-Member -MemberType NoteProperty -Name Version -Value $pipArray[$i + 1].ToString()
            $pipObj += $newObjP
        }

        Write-Host 'List of dependencies'
        Write-Host '--------------------------'
        foreach ($req in $reqObj) {
            if (-not ($pipObj.Package -contains $req.Package)) {
                Write-Warning " Not installed: $($req.Package)=$($req.Version) "
            }
            else {
                Write-Host "OK: $($req.Package)=$($req.Version)"
            }
        }
        pause
    }

    function menuDefaultAction {
        cls
        Write-Host `n ' Option is not recognized...' `n -ForegroundColor Red
        pause
    }

    $option = Read-Host '   Select option: '

    switch ($option) {
        0 { scriptExit; break }
        1 { installPython; break }
        2 { setupEnviroments; break }
        3 { checkEnviroment; break }
        4 { updateDependencies; break }
        default { menuDefaultAction }
    }

} while ($option -ne 9)
