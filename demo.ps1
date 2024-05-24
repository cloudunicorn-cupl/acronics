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

# Function to fill in the username and password in the popup
function Fill-Credentials {
    param (
        [string]$Username,
        [string]$Password
    )

    # Wait for the Acronis popup window to appear
    Start-Sleep -Seconds 5

    # Send the username
    [System.Windows.Forms.SendKeys]::SendWait($Username)
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")  # Move to the password field
    Start-Sleep -Milliseconds 500

    # Send the password
    [System.Windows.Forms.SendKeys]::SendWait($Password)
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}") # Submit the credentials

    # Wait for any confirmation prompt
    Start-Sleep -Seconds 2
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}") # Confirm any prompt
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
    # Fill in the credentials and confirm prompts
    Fill-Credentials -Username "administrator" -Password "Cloud@123"

    # Run the installer with the specified token and provide credentials for UAC prompt
    $credential = Get-Credential -Credential "administrator"
    Start-Process -FilePath $installerPath -ArgumentList "--reg-address=https://in01-cloud.acronis.com --registration=by-token --reg-token=506D-90BD-403D" -Credential $credential -Wait
}
