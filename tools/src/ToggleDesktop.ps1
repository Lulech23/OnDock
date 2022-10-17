# Get sleep time, if specified
$sleep = 3
if ($args.count -gt 0) {
    $sleep = [int] $args[0]
}

# Create shell COM object
$shell = (New-Object -ComObject shell.application)

# Minimize all windows
$shell.ToggleDesktop()

# Wait for sleep duration
Start-Sleep -Seconds $sleep

# Restore all windows
$shell.ToggleDesktop()