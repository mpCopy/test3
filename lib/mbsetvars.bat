@echo off
REM Copyright  1998 - 2017 Keysight Technologies, Inc  
REM Set the library path for running modelbuilder models

if "%HPEESOF_DIR%" == "" echo Error!  HPEESOF_DIR is not set.
if "%HPEESOF_DIR%" == "" goto end
set modpath=MODELDIR\lib.win32;%HPEESOF_DIR%\bin;%HPEESOF_DIR%\lib\win32;%HPEESOF_DIR%\adsptolemy\lib.win32

set PATH=%modpath%;%PATH%
:end
