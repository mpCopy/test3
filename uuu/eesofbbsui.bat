@echo off
REM Copyright Keysight Technologies 2019 - 2019

REM wrapper around the broadband spice model generator for windows

if not defined HPEESOF_DIR ( echo The HPEESOF_DIR environment variable must be set & exit /b 1 )
set PATH=%HPEESOF_DIR%\bin;%PATH%

for /f "tokens=*" %%a in ('menv getRefvalue --name Momentum --product_root "%HPEESOF_DIR%"') do set Momcmpt=%%a

set BBSUIexe=%Momcmpt%\win32_64\bin\eesofbbsui.exe
if not exist "%BBSUIexe%" ( echo The eesofbbsui executable cannot be found & echo "%BBSUIexe%" & exit /b 2 )

"%BBSUIexe%" %*
