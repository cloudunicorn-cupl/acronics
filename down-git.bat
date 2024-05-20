@echo off

:: Define the GitHub URL of the PowerShell script
set "GitHubURL=https://raw.githubusercontent.com/cloudunicorn-cupl/acronics/main/OnlyInstallation.ps1"

:: Set the destination directory to store the downloaded script
set "DestinationDirectory=C:\Path\To\Save\Script"

:: Ensure the destination directory exists
if not exist "%DestinationDirectory%" (
    mkdir "%DestinationDirectory%"
)

:: Set the path for the downloaded PowerShell script
set "ScriptPath=%DestinationDirectory%\OnlyInstallation.ps1"

:: Provide feedback that the download process has started
echo Downloading PowerShell script from GitHub...

:: Download the PowerShell script from GitHub
PowerShell -Command "(New-Object System.Net.WebClient).DownloadFile('%GitHubURL%', '%ScriptPath%')"

:: Check if the download was successful
if exist "%ScriptPath%" (
    echo Script downloaded successfully to: %ScriptPath%
    echo.
    echo Running the downloaded PowerShell script...
    echo.
    
    :: Run the downloaded PowerShell script
    PowerShell -ExecutionPolicy Bypass -File "%ScriptPath%"
) else (
    echo Failed to download the script.
)
