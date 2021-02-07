@echo off
REM Copyright  2001 - 2017 Keysight Technologies, Inc  
rem Create an environment for building ptolemy models
cd tools\bin
bash ../../adsptolemy/bin/mbshellcmds > "%TEMP%\mbshell.bat"
cd ..\perl\bin
perl -pi.bak -e "s/%%PATH%%/%%HPEESOF_DIR%%\\tools\\perl\\bin\;%%HPEESOF_DIR%%\\tools\\bin\;%%PATH%%\nset ARCH=win32\nset MAKE_MODE=unix/; s/%%COMSPEC%%/%%HPEESOF_DIR%%\\tools\\bin\\bash.exe/;" "%TEMP%\mbshell.bat"
cd ..\..\bin
"%TEMP%\mbshell.bat"
