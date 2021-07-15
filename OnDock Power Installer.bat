powershell.exe "Get-ExecutionPolicy -Scope 'CurrentUser' | Out-File -FilePath '%TEMP%\executionpolicy.txt' -Force; Set-ExecutionPolicy -Scope 'CurrentUser' -ExecutionPolicy 'Unrestricted'; $script = Get-Content '%~dpnx0'; $script -notmatch 'supercalifragilisticexpialidocious' | Out-File -FilePath '%TEMP%\%~n0.ps1' -Force; Start-Process powershell.exe \"Set-Location -Path '%~dp0'; ^& '%TEMP%\%~n0.ps1'\" -verb RunAs" && exit

<#
//////////////////////////////////////////////
//    OnDock Power Installer by Lulech23    //
//////////////////////////////////////////////

Perform any action when connecting and disconnecting to external power sources

What's new:
* Initial release

To-do:
* 

Notes:
* 
#>

<#
INITIALIZATION
#>

# Version... obviously
$version = "1.0"

# OnDock data path
$path = "$env:AppData\OnDock"


<#
SHOW VERSION
#>

# Ooo, shiny!
Write-Host "`n                                           " -BackgroundColor White -NoNewline
Write-Host "`n OnDock Power Installer [v$version] by Lulech23 " -NoNewline -BackgroundColor White -ForegroundColor DarkBlue
Write-Host "`n                                           " -BackgroundColor White

# About
Write-Host "`nThis script will generate separate PowerShell scripts and Windows scheduled tasks to"
Write-Host "automatically perform actions when external power is connected and disconnected."
Write-Host "Actions will be performed from folders added to the Start menu, where you can place any"
Write-Host "shortcuts to commands and applications that you wish."

Write-Host "`nIf you don't like something, running this script again will undo all changes to the"
Write-Host "system."

# Current installation
Write-Host "`nOnDock is currently: " -NoNewline
if (Test-Path "$path\OnDock.ps1") {
    Write-Host "Installed" -ForegroundColor Cyan
    Write-Host " * User actions will be performed upon connecting to an external display" -ForegroundColor Gray
    $task = "Remove OnDock"
} else {
    Write-Host "Uninstalled" -ForegroundColor Magenta
    Write-Host " * No actions will be performed upon connecting to an external display" -ForegroundColor Gray
    $task = "Install OnDock"
}

# Setup Info
Write-Host "`nSetup will: " -NoNewline
Write-Host "$task`n" -ForegroundColor Cyan
for ($s = 10; $s -ge 0; $s--) {
    $p = if ($s -eq 1) { "" } else { "s" }
    Write-Host "`rPlease wait $s second$p to continue, or close now (Ctrl + C) to exit..." -NoNewLine -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}
Write-Host


<#
INSTALL ONDOCK
#>

if ($task.contains("Install")) {
    # Ensure OnDock directories exists
    if (!(Test-Path -Path "$path")) {
        New-Item -ItemType Directory -Path "$path" -Force | Out-Null
    }
    if (!(Test-Path -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock\Connect")) {
        New-Item -ItemType Directory -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock\Connect" -Force | Out-Null
    }
    if (!(Test-Path -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock\Disconnect")) {
        New-Item -ItemType Directory -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock\Disconnect" -Force | Out-Null
    }

    # Create shortcut to OnDock directory
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock\Open OnDock Directory.lnk")
    $shortcut.TargetPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock\"
    $shortcut.Save()
    

    <#
    CREATE SCRIPT
    #>

    Write-Host "`nGenerating OnDock script..."
    Start-Sleep -Seconds 1

    # Get initial battery status
    $battery = (Get-WmiObject -Class Win32_Battery | Select-Object -First 1)
    $batteryStatus = ($battery -ne $null -and $battery.BatteryStatus -eq 1)
    Set-Content -Path "$path\wmi.txt" -Value "$([int] $batteryStatus)"

    # Write scheduled task to folder
    Set-Content -Path "$path\OnDock.ps1" -Value @"
<#
//////////////////////////////
//    OnDock by Lulech23    //
//////////////////////////////
#>

Register-WmiEvent -Class Win32_DeviceChangeEvent -SourceIdentifier DockStateChanged
do {
    `$path = "`$env:AppData\OnDock"

    `$event = Wait-Event -SourceIdentifier DockStateChanged
    `$eventType = `$event.SourceEventArgs.NewEvent.EventType

    `$battery = (Get-WmiObject -Class Win32_Battery | Select-Object -First 1)
    `$batteryStatus = (`$battery -ne `$null -and `$battery.BatteryStatus -eq 1)

    if ([int] `$batteryStatus -ne (Get-Content "`$path\wmi.txt")) {
        
        # OnDock Connect
        if (!(`$batteryStatus)) {
            # Run user actions
            Get-ChildItem "`$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock\Connect" |
            ForEach-Object {
                Start-Process -FilePath "`$(`$_.FullName)"
            }
    
        # OnDock Disconnect
        } else {
            # Run user actions
            Get-ChildItem "`$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock\Disconnect" |
            ForEach-Object {
                Start-Process -FilePath "`$(`$_.FullName)"
            }
        }

        # Update battery status
        Set-Content -Path "`$path\wmi.txt" -Value "`$([int] `$batteryStatus)"
    }
    Remove-Event -SourceIdentifier DockStateChanged
} while (1 -eq 1) # Loop until next event
Unregister-Event -SourceIdentifier DockStateChanged
"@
    
    
    <#
    CREATE SCHEDULED TASK
    #>

    Write-Host "`nGenerating scheduled task..."

    # Write scheduled task to folder
    Set-Content -Path "$path\OnDock.xml" -Value @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
    <RegistrationInfo>
        <Date>2021-07-13T12:18:54.2929428</Date>
        <Author>BUILTIN\Administrators</Author>
        <Description>Perform any action when connecting and disconnecting to external power sources</Description>
        <URI>\OnDock Service</URI>
    </RegistrationInfo>
    <Triggers>
        <LogonTrigger>
            <Enabled>true</Enabled>
        </LogonTrigger>
    </Triggers>
    <Principals>
        <Principal id="Author">
            <GroupId>S-1-5-32-544</GroupId>
            <RunLevel>HighestAvailable</RunLevel>
        </Principal>
    </Principals>
    <Settings>
        <MultipleInstancesPolicy>StopExisting</MultipleInstancesPolicy>
        <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
        <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
        <AllowHardTerminate>false</AllowHardTerminate>
        <StartWhenAvailable>true</StartWhenAvailable>
        <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
        <IdleSettings>
            <StopOnIdleEnd>false</StopOnIdleEnd>
            <RestartOnIdle>false</RestartOnIdle>
        </IdleSettings>
        <AllowStartOnDemand>true</AllowStartOnDemand>
        <Enabled>true</Enabled>
        <Hidden>false</Hidden>
        <RunOnlyIfIdle>false</RunOnlyIfIdle>
        <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
        <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
        <WakeToRun>false</WakeToRun>
        <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
        <Priority>7</Priority>
    </Settings>
    <Actions Context="Author">
        <Exec>
            <Command>powershell</Command>
            <Arguments>-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "$path\OnDock.ps1"</Arguments>
        </Exec>
    </Actions>
</Task>
"@

    # Import task to Windows scheduler
    $schtask = (Get-ScheduledTask "OnDock Service" -ErrorAction "SilentlyContinue" | Out-String)
    if ($schtask.length -gt 0) {
        # Delete old task, if any
        Unregister-ScheduledTask -TaskName "OnDock Service" -Confirm:$False -ErrorAction "SilentlyContinue"
    }
    Register-ScheduledTask -TaskName "OnDock Service" -Xml (Get-Content "$env:AppData\OnDock\OnDock.xml" | Out-String)

    # Run imported task
    Enable-ScheduledTask -TaskName "OnDock Service" | Out-Null
    Start-ScheduledTask -TaskName "OnDock Service"

    # Ensure task creation succeeded
    $schtask = (Get-ScheduledTask "OnDock Service" -ErrorAction "SilentlyContinue" | Out-String)

    # End process, we're done!
    if ($schtask.length -gt 0) {
        Write-Host "`nProcess complete! " -NoNewline -ForegroundColor Green
        Write-Host "OnDock installed successfully. You may now add actions to the " -NoNewLine 
        Write-Host "OnDock > Connect " -ForegroundColor Yellow
        Write-Host "and " -NoNewline
        Write-Host "OnDock > Disconnect " -NoNewline -ForegroundColor Yellow
        Write-Host "folders of your Windows Start menu. Enjoy!"
        Write-Host "`nIf you liked this, stop by my website at " -NoNewline
        Write-Host "https://lucasc.me" -NoNewline -ForegroundColor Yellow
        Write-Host "!"
    } else {
        # Show error if service creation failed
        Write-Host "`nCreating OnDock service failed!" -ForegroundColor Magenta
        Write-Host "`nPlease import `"$env:AppData\OnDock\OnDock.xml`" to Task Scheduler" 
        Write-Host "manually, if it exists."
    }
}


<#
REMOVE ONDOCK
#>

if ($task.contains("Remove")) {
    # Get user action removal preference
    Write-Host
    $purge = (Read-Host "Also remove user actions? (Y/N)").ToUpper()

    Write-Host "`nRemoving OnDock..."
    Start-Sleep -Seconds 1

    # Remove user actions, if enabled
    if ($purge -eq "Y") {
        Remove-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\OnDock" -Force -Recurse -ErrorAction SilentlyContinue
    }

    # Unregister OnDock service
    Stop-ScheduledTask -TaskName "OnDock Service" | Out-Null
    Unregister-ScheduledTask -TaskName "OnDock Service" -Confirm:$False -ErrorAction "SilentlyContinue"
    Remove-Item "$env:AppData\OnDock\*"
    
    # End process, we're done!
    Write-Host "`nProcess complete! " -NoNewline -ForegroundColor Green
    if ($purge -eq "Y") {
        Write-Host "OnDock and all user actions have been removed. Enjoy, I guess..."
    } else {
        Write-Host "OnDock has been removed (user actions were unaffected). Enjoy, I guess..."
    }
}


<# 
FINALIZATION
#>

# Exit, we're done!
Write-Host
for ($s = 5; $s -ge 0; $s--) {
    $p = if ($s -eq 1) { "" } else { "s" }
    Write-Host "`rSetup will cleanup and exit in $s second$p, please wait..." -NoNewLine -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}
Write-Host
Write-Host "`nCleaning up..."
Start-Sleep -Seconds 1

# Reset execution policy and delete temporary script file
$policy = "Default"
if (Test-Path -Path "$env:Temp\executionpolicy.txt") {
    $policy = [string] (Get-Content -Path "$env:Temp\executionpolicy.txt")
}
Start-Process powershell.exe "Set-ExecutionPolicy -Scope 'CurrentUser' -ExecutionPolicy '$policy'; Remove-Item -Path '$env:Temp\executionpolicy.txt' -Force; Remove-Item -Path '$PSCommandPath' -Force"
