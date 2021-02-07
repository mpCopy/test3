@echo off
REM Copyright  2000 - 2017 Keysight Technologies, Inc  
rem Create an environment for building ptolemy models
.\tools\bin\mount -f  "%CD%" /adstmp
set PATH=%PATH%;%CD%\tools\bin
cd adsptolemy\bin
..\..\tools\bin\bash ../../adsptolemy/bin/mbshellcmds > "%TEMP%\mbshell.bat"
"%TEMP%\mbshell.bat"
