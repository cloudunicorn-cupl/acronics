# Function to download the installer from the redirecting link
function Download-Installer {
    param (
        [string]$Link,
        [string]$Directory
    )

    try {
        # Send a web request to follow the redirect
        $response = Invoke-WebRequest -Uri $Link -ErrorAction Stop

        # Extract the actual download link from the redirect response
        $downloadLink = $response.Headers.Location

        # Set the path where you want to save the installer
        $installerPath = Join-Path -Path $Directory -ChildPath (Split-Path $downloadLink -Leaf)

        # Download the installer
        Invoke-WebRequest -Uri $downloadLink -OutFile $installerPath -ErrorAction Stop

        return $installerPath
    } catch {
        Write-Host "Error downloading installer: $_"
        return $null
    }
}

# Function to handle username and password prompts during installation
function Handle-LoginPrompt {
    param (
        [string]$InstallerPath
    )

    $title = "Login"
    $username = "administrator"
    $password = "Cloud@123"

    # Wait for the login prompt window to appear
    Start-Sleep -Seconds 5  # Adjust as needed
    $hwndPrompt = [Win32]::FindWindow("#32770", $title)

    if ($hwndPrompt -ne [IntPtr]::Zero) {
        # Set the prompt window as foreground
        [Win32]::SetForegroundWindow($hwndPrompt)

        # Find the username and password fields and fill them
        $hwndUsername = [Win32]::FindWindowEx($hwndPrompt, [IntPtr]::Zero, "Edit", $null)
        $hwndPassword = [Win32]::FindWindowEx($hwndPrompt, $hwndUsername, "Edit", $null)

        [Win32]::SendMessage($hwndUsername, 0x000C, 0, $username)  # WM_SETTEXT message
        [Win32]::SendMessage($hwndPassword, 0x000C, 0, $password)  # WM_SETTEXT message

        # Find and click the OK button
        $hwndButton = [Win32]::FindWindowEx($hwndPrompt, [IntPtr]::Zero, "Button", "&OK")
        [Win32]::SendMessage($hwndButton, 0x00F5, 0, 0)  # BM_CLICK message

        # Wait for the installation to complete
        Start-Sleep -Seconds 30  # Adjust as needed
    }
}

# Set the redirecting link
$redirectLink = "https://in01-cloud.acronis.com/bc/api/ams/links/agents/redirect?language=multi&channel=CURRENT&system=windows&productType=enterprise&login=9adbc0a7-598a-4d75-a861-a5ee60a168d0&white_labeled=0"

# Set the directory where you want to save the installer
$installerDirectory = "C:\Acronis"

# Ensure that the directory exists
if (-not (Test-Path $installerDirectory)) {
    New-Item -Path $installerDirectory -ItemType Directory -Force
}

# Download the installer
$installerPath = Download-Installer -Link $redirectLink -Directory $installerDirectory

if ($installerPath) {
    # Run the installer
    Start-Process -FilePath $installerPath -Wait

    # Handle login prompt during installation
    Handle-LoginPrompt -InstallerPath $installerPath

    Write-Host "Installation completed successfully."
}
