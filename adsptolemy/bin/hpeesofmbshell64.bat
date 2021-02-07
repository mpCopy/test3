@echo off
REM Copyright  2007 - 2017 Keysight Technologies, Inc  
rem Create an environment for building ptolemy models
.\tools\bin\mount -f  "%CD%" /adstmp
set PATH=%PATH%;%CD%\tools\bin
cd adsptolemy\bin
..\..\tools\bin\bash ../../adsptolemy/bin/mbshellcmds64 > "%TEMP%\mbshell.bat"
"%TEMP%\mbshell.bat"
