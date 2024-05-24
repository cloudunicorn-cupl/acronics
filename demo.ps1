# Function to handle the username and password prompts during installation
function Handle-LoginPrompt {
    param (
        [string]$InstallerPath
    )

    # Wait for the login prompt window to appear
    Start-Sleep -Seconds 5

    # Define username and password
    $username = "administrator"
    $password = "Cloud@123"

    # Send the username and password to the prompt
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.Interaction]::AppActivate("Acronis Cyber installer")
    [System.Windows.Forms.SendKeys]::SendWait($username)
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    [System.Windows.Forms.SendKeys]::SendWait($password)
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

# Set the redirecting link
$redirectLink = "https://in01-cloud.acronis.com/bc/api/ams/links/agents/redirect?language=multi&channel=CURRENT&system=windows&productType=enterprise&login=9adbc0a7-598a-4d75-a861-a5ee60a168d0&white_labeled=0"

# Function to download the installer from the redirecting link
function Download-Installer {
    param (
        [string]$Link,
        [string]$Directory
    )

    # Send a web request to follow the redirect
    $response = Invoke-WebRequest -Uri $Link -MaximumRedirection 0 -ErrorAction SilentlyContinue

    # Check if the response contains a redirect
    if ($response.StatusCode -eq 302 -and $response.Headers.Location) {
        # Extract the actual download link from the redirect response
        $downloadLink = $response.Headers.Location

        # Set the path where you want to save the installer
        $installerPath = Join-Path -Path $Directory -ChildPath (Split-Path $downloadLink -Leaf)

        # Download the installer
        Invoke-WebRequest -Uri $downloadLink -OutFile $installerPath

        return $installerPath
    } else {
        Write-Host "Error: The redirect link did not lead to a download link."
        return $null
    }
}

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
