@echo off
REM Copyright Keysight Technologies 1999 - 2017  
REM DOS wrapper for hpeesofmake

set CYGWIN=nodosfilewarning
if "%HPEESOF_DIR%" == "" echo Error!  HPEESOF_DIR is not set.
if "%HPEESOF_DIR%" == "" goto end
set ARCH=win32_64
set MAKE_MODE=unix
set CEDA_SITE=gent
"%HPEESOF_DIR%\tools\bin\mkdir" -p /bin
set _PTPATH=%PATH%
set PATH=%HPEESOF_DIR%\tools\perl\bin;%HPEESOF_DIR%\tools\bin;%PATH%
"%HPEESOF_DIR%\tools\bin\mount" | "%HPEESOF_DIR%\tools\bin\grep"  'on /bin' > adsmountjunk
if "%ERRORLEVEL%" == "1" goto run

:: echo ************************************************
:: echo *  REMINDER: This program will unmount /bin
:: echo ************************************************
:: "%HPEESOF_DIR%\tools\bin\umount" /bin > adsmountjunk

:run
"%HPEESOF_DIR%\tools\bin\mount" "%HPEESOF_DIR%\tools\bin" /bin

if not "%~1" == "--setup" goto nosetup
shift

bash "%HPEESOF_DIR%\bin\hpeesofFindVcPath" > "%TEMP%\VCPATH_ADS.bat"
call "%TEMP%\VCPATH_ADS.bat"

:nosetup

:: get short DOS path for HPEESOF_DIR
set HPEESOF_DIR_LONG=%HPEESOF_DIR%
set HPEESOF_DIR_SHORT=%HPEESOF_DIR%
for %%H in ("%HPEESOF_DIR%") do set HPEESOF_DIR_SHORT=%%~sH
set HPEESOF_DIR=%HPEESOF_DIR_SHORT%

make %1 %2 %3 %4 %5 %6 %7 %8 %9

set HPEESOF_DIR=%HPEESOF_DIR_LONG%
:: "%HPEESOF_DIR%\tools\bin\umount" /bin > adsmountjunk
:: "%HPEESOF_DIR%\tools\bin\rm" adsmountjunk
set PATH=%_PTPATH%
set ARCH=
set MAKE_MODE=
set CEDA_SITE=
set _PTPATH=
:end
