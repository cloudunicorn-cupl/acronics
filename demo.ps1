# Add-Type to load Windows API functions
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class Win32 {
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    }
"@

# Function to find and fill in username and password fields
function Handle-LoginPrompt {
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
    }
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
$installerDirectory = "C:\Desktop\Acronis"

# Ensure that the directory exists
if (-not (Test-Path $installerDirectory)) {
    New-Item -Path $installerDirectory -ItemType Directory -Force
}

# Download the installer
$installerPath = Download-Installer -Link $redirectLink -Directory $installerDirectory

if ($installerPath) {
    # Run the installer
    Start-Process -FilePath $installerPath -ArgumentList "--reg-address=https://in01-cloud.acronis.com --registration=by-token --reg-token=506D-90BD-403D" -Wait

    # Handle login prompt
    Handle-LoginPrompt
}
