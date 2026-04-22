@echo off
chcp 65001 >nul
REM ============================================================
REM  Test SQL connection to SAP B1 Company DB
REM  EDIT THE 4 LINES BELOW IF SERVER OR CREDENTIALS CHANGE
REM ============================================================
set SERVER=10.10.10.115
set COMPANYDB=SBO_SDA_UAT
set DBUSER=sa
set DBPASSWORD=1q2w3e4r@

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\Test-SQLConnect.ps1" ^
    -Server "%SERVER%" ^
    -CompanyDB "%COMPANYDB%" ^
    -DBUser "%DBUSER%" ^
    -DBPassword "%DBPASSWORD%"

echo.
pause
