@echo off
REM Copyright Keysight Technologies 2012 - 2014  

REM wrapper around Mom/FemEngine for windows

set MomOrFemEngine=%1
shift

if not defined HPEESOF_DIR ( echo The HPEESOF_DIR environment variable must be set & exit /b 1 )
set PATH=%HPEESOF_DIR%\bin;%PATH%

REM Note that FemEngine also is in the Momentum component
for /f "tokens=*" %%a in ('menv getRefvalue --name Momentum --product_root "%HPEESOF_DIR%"') do set Momcmpt=%%a

if /i "%PROCESSOR_ARCHITECTURE%" == "amd64" (set Momexe=%Momcmpt%\win32_64\bin\%MomOrFemEngine%.exe) else (set Momexe=%Momcmpt%\win32_32\bin\%MomOrFemEngine%.exe)

if not exist "%Momexe%" ( echo The Momentum executable cannot be found & echo "%Momexe%" & exit /b 2 )

"%Momexe%" %*
