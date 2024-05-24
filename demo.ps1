# Set the redirecting link
$redirectLink = "https://in01-cloud.acronis.com/bc/api/ams/links/agents/redirect?language=multi&channel=CURRENT&system=windows&productType=enterprise&login=9adbc0a7-598a-4d75-a861-a5ee60a168d0&white_labeled=0"

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

# Set the directory where you want to save the installer
$installerDirectory = "C:\Acronis"

# Ensure that the directory exists
if (-not (Test-Path $installerDirectory)) {
    New-Item -Path $installerDirectory -ItemType Directory -Force
}

# Download the installer
$installerPath = Download-Installer -Link $redirectLink -Directory $installerDirectory

if ($installerPath) {
    try {
        # Run the installer
        Start-Process -FilePath $installerPath -Wait -ErrorAction Stop
        Write-Host "Installation completed successfully."

        # Cleanup: Delete the downloaded script
        Remove-Item -Path $MyInvocation.MyCommand.Path -Force
        Write-Host "Downloaded script deleted."
    } catch {
        Write-Host "Error running installer: $_"
    }
}
