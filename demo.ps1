# Set the redirecting link
$redirectLink = "https://in01-cloud.acronis.com/bc/api/ams/links/agents/redirect?language=multi&channel=CURRENT&system=windows&productType=enterprise&login=9adbc0a7-598a-4d75-a861-a5ee60a168d0&white_labeled=0"

# Function to download the installer from the redirecting link
function Download-Installer {
    param (
        [string]$Link,
        [string]$Directory
    )

    try {
        # Create a WebClient object
        $webClient = New-Object System.Net.WebClient

        # Download the installer
        $installerPath = Join-Path -Path $Directory -ChildPath "AcronisInstaller.exe"
        $webClient.DownloadFile($Link, $installerPath)

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
        # Run the installer without prompting for credentials
        Start-Process -FilePath $installerPath -ArgumentList "--reg-address=https://in01-cloud.acronis.com --registration=by-token --reg-token=506D-90BD-403D" -Wait -NoNewWindow -ErrorAction Stop
    } catch {
        Write-Host "Error running installer: $_"
    }
}
