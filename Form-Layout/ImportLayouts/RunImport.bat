@echo off
chcp 65001 >nul
REM ============================================================
REM  Import Crystal Layouts to SAP B1 (SQL Direct)
REM  EDIT THE 4 CREDENTIAL LINES + 2 MODE LINES BELOW IF NEEDED
REM ============================================================
set SERVER=10.10.10.115
set COMPANYDB=SBO_SDA_MARK1
set DBUSER=sa
set DBPASSWORD=1q2w3e4r@

REM ============================================================
REM  AUTHOR: who to record as the layout author
REM  Use "manager" to overwrite existing layouts created by manager
REM ============================================================
set AUTHOR=manager

REM ============================================================
REM  MODE: choose one of these for MODE
REM    -DryRun        = preview only (no changes)
REM    (leave empty)  = real import
REM ============================================================
set MODE=

REM ============================================================
REM  ONDUP: how to handle duplicate layouts (DocName+TypeCode+Author match)
REM    Update  = overwrite existing (recommended, default)
REM    Skip    = leave existing alone, only insert new
REM    Insert  = always insert new row (creates duplicates - careful!)
REM ============================================================
set ONDUP=Update

REM ============================================================
REM  CONFIGDIR: folder to scan for mapping .xlsx files
REM  RPTROOT  : root folder that contains the .rpt files
REM             (RPT_Folder column in the Excel is resolved relative to this)
REM  Both can be relative (e.g. Config, ..) or absolute (C:\path\...)
REM ============================================================
set CONFIGDIR=Config
set RPTROOT=C:\SDA\SDA\Form-Layout

setlocal enabledelayedexpansion
REM Resolve CONFIGDIR / RPTROOT to absolute paths
set "CFG=!CONFIGDIR!"
if not "!CFG:~1,1!"==":" set "CFG=%~dp0!CFG!"
set "RPT=!RPTROOT!"
if not "!RPT:~1,1!"==":" set "RPT=%~dp0!RPT!"

echo ============================================
echo  Select mapping Excel file from:
echo  !CFG!
echo ============================================
set IDX=0
for %%F in ("!CFG!\*.xlsx") do (
    set /a IDX+=1
    set "FILE_!IDX!=%%~nxF"
    echo   !IDX!. %%~nxF
)
if %IDX%==0 (
    echo No .xlsx files found in !CFG!
    pause
    exit /b
)
echo.
set /p PICK=Enter number (1-%IDX%):
if "%PICK%"=="" (
    echo No selection. Exiting.
    pause
    exit /b
)
call set "MAPFILE=%%FILE_%PICK%%%"
if "%MAPFILE%"=="" (
    echo Invalid selection.
    pause
    exit /b
)
echo.
echo ============================================
echo  SAP B1 Layout Import
echo  Server   : %SERVER%
echo  Database : %COMPANYDB%
echo  MapFile  : !MAPFILE!
echo  RptRoot  : !RPT!
echo  Mode     : %MODE% (empty=real run)
echo  OnDup    : %ONDUP%
echo ============================================
echo.
pause

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\Import_SQL_Direct.ps1" ^
    -Server "%SERVER%" ^
    -CompanyDB "%COMPANYDB%" ^
    -DBUser "%DBUSER%" ^
    -DBPassword "%DBPASSWORD%" ^
    -Author "%AUTHOR%" ^
    -MapFile "!CFG!\!MAPFILE!" ^
    -RptRoot "!RPT!" ^
    -UseFileNameAsDocName ^
    -OnDuplicate %ONDUP% ^
    %MODE%
endlocal

echo.
echo ============================================
echo  Done. Check log: %~dp0Import_SQL_Log.txt
echo ============================================
pause
