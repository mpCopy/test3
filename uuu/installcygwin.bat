@echo off
REM Copyright  2001 - 2017 Keysight Technologies, Inc  
@echo -------------------------------------------------------------------------
@echo WARNING: CYGWIN IS NOT SUPPORTED - USE AT YOUR OWN RISK!
@echo          Now installing Cygwin into ADS Tools menu
@echo -------------------------------------------------------------------------
cd ..\tools\bin
bash ../../adsptolemy/bin/mbshellcmds > %TEMP%\mbshell.bat
cd ..\perl\bin
perl -pi.bak -e "s/%%PATH%%/%%HPEESOF_DIR%%\\tools\\perl\\bin\;%%HPEESOF_DIR%%\\tools\\bin\;%%PATH%%\nset ARCH=win32\nset MAKE_MODE=unix/; s/%%COMSPEC%%/%%HPEESOF_DIR%%\\bin\\instscut -s "%%HPEESOF_DIR%%" hpeesofcygwin.bat "Cygwin"/;" %TEMP%\mbshell.bat
cd ..\..\bin
%TEMP%\mbshell.bat
