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

# Function to fill in the username and password using AutoIt
function Fill-UsernamePassword {
    param (
        [string]$Username,
        [string]$Password
    )

    # Wait for the Acronis installer window to appear
    Start-Sleep -Seconds 10

    # Use AutoIt to fill in the username and password
    $acronisInstallerWindow = "[CLASS:#32770; TITLE:Acronis Installer]"  # Adjust the window title as per the installer window
    AutoItSetOption("WinTitleMatchMode", 2)  # Match the window title as a substring

    ; Find the username field and fill it
    ControlFocus($acronisInstallerWindow, "", "[CLASS:Edit; INSTANCE:1]")
    ControlSetText($acronisInstallerWindow, "", "[CLASS:Edit; INSTANCE:1]", $Username)

    ; Find the password field and fill it
    ControlFocus($acronisInstallerWindow, "", "[CLASS:Edit; INSTANCE:2]")
    ControlSetText($acronisInstallerWindow, "", "[CLASS:Edit; INSTANCE:2]", $Password)

    ; Find and click the OK button
    ControlClick($acronisInstallerWindow, "", "[CLASS:Button; INSTANCE:1]")
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
    # Fill in the username and password
    Fill-UsernamePassword -Username "your_username" -Password "your_password"

    # Run the installer with the specified token and provide credentials for UAC prompt
    $credential = Get-Credential -Credential "administrator"
    Start-Process -FilePath $installerPath -ArgumentList "--reg-address=https://in01-cloud.acronis.com --registration=by-token --reg-token=506D-90BD-403D" -Credential $credential -Wait
}
