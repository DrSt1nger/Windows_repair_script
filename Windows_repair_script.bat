@echo off
:: ==============================================================================
:: Created by DrSt1nger - https://github.com/DrSt1nger/Windows_repair_script
:: ==============================================================================
:: COMPREHENSIVE WINDOWS MAINTENANCE, REPAIR AND CLEANUP SCRIPT
:: Requires Administrator Privileges
:: ==============================================================================

title Windows System Repair and Deep Cleanup

:: 1. Check for Administrator Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ==============================================================================
    echo [ERROR] This script MUST be executed as Administrator.
    echo.
    echo Right-click on the .bat file and select "Run as administrator".
    echo ==============================================================================
    echo.
    pause
    exit /b
)

color 0A
cls
echo ==============================================================================
echo                STARTING SYSTEM MAINTENANCE AND REPAIR
echo ==============================================================================
echo.
echo Created by DrSt1nger - https://github.com/DrSt1nger/Windows_repair_script
echo.
echo This process will perform the following tasks:
echo   1. System image verification and repair (DISM)
echo   2. Protected system file scan and repair (SFC)
echo   3. Component store cleanup and optimization (WinSxS)
echo   4. Disk file system integrity check (CHKDSK)
echo   5. Cleanup of temporary files and Windows Update cache
echo   6. Network stack reset and DNS cache flush
echo.
echo NOTE: The process may take between 10 to 25 minutes depending on your system.
echo.
pause

:: ------------------------------------------------------------------------------
:: PHASE 1: DISM (Deployment Image Servicing and Management)
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PHASE 1/6] Analyzing and repairing Windows image (DISM)...
echo ==============================================================================
echo.

echo -- [1/3] Checking image health...
dism /Online /Cleanup-Image /CheckHealth

echo.
echo -- [2/3] Scanning image state...
dism /Online /Cleanup-Image /ScanHealth

echo.
echo -- [3/3] Restoring system image via Windows Update...
dism /Online /Cleanup-Image /RestoreHealth

:: ------------------------------------------------------------------------------
:: PHASE 2: SFC (System File Checker)
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PHASE 2/6] Scanning and repairing protected system files (SFC)...
echo ==============================================================================
echo.
sfc /scannow

:: ------------------------------------------------------------------------------
:: PHASE 3: WinSxS Component Store Cleanup
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PHASE 3/6] Optimizing and cleaning up component store (WinSxS)...
echo ==============================================================================
echo.
dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase

:: ------------------------------------------------------------------------------
:: PHASE 4: Disk Integrity Check
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PHASE 4/6] Checking drive C: integrity...
echo ==============================================================================
echo.
chkdsk C: /scan

:: ------------------------------------------------------------------------------
:: PHASE 5: Temp Files & Windows Update Cache Cleanup
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PHASE 5/6] Cleaning temporary files and Windows Update cache...
echo ==============================================================================
echo.

echo -- Stopping Windows Update services...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

echo -- Removing old or corrupted update downloads...
if exist "C:\Windows\SoftwareDistribution\Download" (
    del /f /q /s "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
)

echo -- Restarting Windows Update services...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo -- Cleaning System and User Temp folders...
del /f /q /s "%TEMP%\*.*" >nul 2>&1
del /f /q /s "C:\Windows\Temp\*.*" >nul 2>&1

echo -- Cleaning Prefetch files...
del /f /q /s "C:\Windows\Prefetch\*.*" >nul 2>&1

:: ------------------------------------------------------------------------------
:: PHASE 6: Network & DNS Reset
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PHASE 6/6] Flushing DNS cache and resetting network sockets...
echo ==============================================================================
echo.
ipconfig /flushdns
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1

echo.
echo ==============================================================================
echo                       MAINTENANCE COMPLETED!
echo ==============================================================================
echo.
echo All repair and cleanup tasks have been executed successfully.
echo A system reboot is recommended to apply all changes.
echo.
pause
