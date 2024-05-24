# Function to handle the username and password prompts during installation
function Handle-LoginPrompt {
    param (
        [string]$WindowTitle
    )

    # Wait for the login prompt window to appear
    Start-Sleep -Seconds 5

    # Define username and password
    $username = "administrator"
    $password = "Cloud@123"

    # Send the username and password to the prompt
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.Interaction]::AppActivate($WindowTitle)
    [System.Windows.Forms.SendKeys]::SendWait($username)
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    [System.Windows.Forms.SendKeys]::SendWait($password)
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

# Set the path to the Acronis installer
$installerPath = "C:\Path\To\AcronisInstaller.exe"

# Run the installer
Start-Process -FilePath $installerPath -Wait

# Detect and handle login prompt during installation
$loginPrompt = $null
$timeout = 60  # Timeout in seconds
$startTime = Get-Date
while (-not $loginPrompt) {
    $loginPrompt = Get-Process | Where-Object { $_.MainWindowTitle -match "Acronis" }
    if ((Get-Date) -ge ($startTime).AddSeconds($timeout)) {
        Write-Host "Login prompt not detected within the timeout period."
        break
    }
    Start-Sleep -Seconds 1
}

if ($loginPrompt) {
    Handle-LoginPrompt -WindowTitle $loginPrompt.MainWindowTitle
    Write-Host "Username and password provided."
} else {
    Write-Host "No login prompt detected."
}
