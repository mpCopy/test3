@echo off
REM Copyright  2008 - 2017 Keysight Technologies, Inc  
REM Set the library path for running modelbuilder models

if "%HPEESOF_DIR%" == "" echo Error!  HPEESOF_DIR is not set.
if "%HPEESOF_DIR%" == "" goto end
set modpath=MODELDIR\lib.win32_64;%HPEESOF_DIR%\bin\win32_64;%HPEESOF_DIR%\lib\win32_64;%HPEESOF_DIR%\adsptolemy\lib.win32_64

set PATH=%modpath%;%PATH%
:end
