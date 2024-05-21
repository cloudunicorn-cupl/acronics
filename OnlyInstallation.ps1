# Set the redirecting link
$A = "https://in01-cloud.acronis.com/bc/api/ams/links/agents/redirect?language=multi&channel=CURRENT&system=windows&productType=enterprise&login=9adbc0a7-598a-4d75-a861-a5ee60a168d0&white_labeled=0"

# Set the token for registration
$B = "506D-90BD-403D"

# Function to download the installer from the redirecting link
function C {
    param (
        [string]$D,
        [string]$E
    )

    # Send a web request to follow the redirect
    $F = Invoke-WebRequest -Uri $D -MaximumRedirection 0 -ErrorAction SilentlyContinue -UseBasicParsing

    # Check if the response contains a redirect
    if ($F.StatusCode -eq 302 -and $F.Headers.Location) {
        # Extract the actual download link from the redirect response
        $G = $F.Headers.Location

        # Set the path where you want to save the installer
        $H = Join-Path -Path $E -ChildPath (Split-Path $G -Leaf)

        # Download the installer
        Invoke-WebRequest -Uri $G -OutFile $H

        return $H
    } else {
        Write-Host "Error: The redirect link did not lead to a download link."
        return $null
    }
}

# Set the directory where you want to save the installer
$I = "C:\Path\To\Save\Installer"

# Ensure that the directory exists
if (-not (Test-Path $I)) {
    New-Item -Path $I -ItemType Directory -Force
}

# Download the installer
$J = C -D $A -E $I

if ($J) {
    # Run the installer with the specified token
    $K = "--registration by-token --reg-token $B --reg-address $J"
    Start-Process -FilePath $J -ArgumentList $K -Wait
}
