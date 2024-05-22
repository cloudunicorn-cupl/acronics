@echo on

rem Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script must be run as an administrator.
    pause
    exit /b
)

rem Uninstall Sophos Endpoint Agent
echo Uninstalling Sophos Endpoint Agent...
cd "C:\Program Files\Sophos\Sophos Endpoint Agent\"
SophosUninstall.exe 
echo Sophos Endpoint Agent has been uninstalled successfully.

rem Optionally, delete the Sophos Endpoint Agent directory
echo Deleting Sophos Endpoint Agent directory...
cd ..
rmdir /s /q "Sophos Endpoint Agent"
echo Sophos Endpoint Agent directory has been deleted.

rem Uninstall another application
echo Uninstalling Another Application...
rem Add commands to uninstall the other application here.
echo Another Application has been uninstalled successfully.

rem You can add more uninstallation sections for other applications as needed.

pause
