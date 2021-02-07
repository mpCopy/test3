@echo off
REM Copyright  1998 - 2017 Keysight Technologies, Inc  
REM Set up ADS Ptolemy modelbuilder under DOS

set CYGWIN=nodosfilewarning

if "%HPEESOF_DIR%" == "" echo Error!  HPEESOF_DIR is not set.
if "%HPEESOF_DIR%" == "" goto end
set ARCH=win32_64
set MAKE_MODE=unix
set CEDA_SITE=gent
"%HPEESOF_DIR%\tools\bin\mkdir" -p /bin
set _PTPATH=%PATH%
set PATH=%HPEESOF_DIR%\tools\bin;%PATH%
"%HPEESOF_DIR%\tools\bin\mount" | "%HPEESOF_DIR%\tools\bin\grep"  'on /bin' > adsmount
if "%ERRORLEVEL%" == "1" goto run

:: echo ************************************************
:: echo *  REMINDER: This program will unmount /bin
:: echo ************************************************
:: "%HPEESOF_DIR%\tools\bin\umount" /bin > adsmount

:run
"%HPEESOF_DIR%\tools\bin\mount" "%HPEESOF_DIR%\tools\bin" /bin
bash "%HPEESOF_DIR%\adsptolemy\bin\hpeesofmb" %1 %2 %3 %4 %5 %6 %7 %8 %9
:: "%HPEESOF_DIR%\tools\bin\umount" /bin > adsmount
:: "%HPEESOF_DIR%\tools\bin\rm" adsmount
set PATH=%_PTPATH%
set ARCH=
set MAKE_MODE=
set CEDA_SITE=
set _PTPATH=
:end
