@echo off
REM Copyright Keysight Technologies 2012 - 2019  

echo Windows Firewall configuration script for ADS 2012.08 (version 1)
echo Author: Michiel De Wilde, Keysight Technologies

rem Get admisitrative privileges (http://sites.google.com/site/eneerge/scripts/batchgotadmin)

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo.
    echo This script needs administrative privileges in order to adjust the firewall settings, and will request them now.
    echo If you are running this script from a network drive, it will likely not continue after getting administrative privileges.
    echo In this case, please copy the script to a local location such as the desktop and run it from there.
    set /p PROMPT=Press the ENTER key to continue...
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

rem Determine HPEESOF_DIR, FEM_VERSION, EESOF_LICENSE_TOOLS_DIR and RULE_PROFILE

:enter_hpeesof_dir
set HPEESOF_DIR=%SYSTEMDRIVE%\Keysight\ADS2012_08
echo.
echo Please enter the ADS 2012.08 installation directory and then press the ENTER key.
echo Just press ENTER to use the default directory %HPEESOF_DIR%.
set /p HPEESOF_DIR=ADS 2012.08 installation directory: 
if exist "%HPEESOF_DIR%\bin\ads.exe" ( goto hpeesof_dir_ok )
echo No valid ADS installation found at %HPEESOF_DIR%. Trying again...
goto enter_hpeesof_dir
:hpeesof_dir_ok

for /f %%A in ('dir /b "%HPEESOF_DIR%\Momentum"') do (set MOMENTUM_VERSION=%%A)
if exist "%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\version.txt" ( goto momentum_version_ok )
:enter_momentum_version
echo.
echo The Momentum version could not be automatically determined.
echo This is the name of a directory inside %HPEESOF_DIR%\Momentum.
set /p MOMENTUM_VERSION=Please enter this number manually: 
if exist "%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\version.txt" ( goto momentum_version_ok )
echo No valid Momentum installation found at %HPEESOF_DIR%\momentum\%MOMENTUM_VERSION%. Trying again...
goto enter_momentum_version
:momentum_version_ok 

for /f %%A in ('dir /b "%HPEESOF_DIR%\fem"') do (set FEM_VERSION=%%A)
if exist "%HPEESOF_DIR%\fem\%FEM_VERSION%\version.txt" ( goto fem_version_ok )
:enter_fem_version
echo.
echo The FEM version could not be automatically determined.
echo This is the name of a directory inside %HPEESOF_DIR%\fem.
set /p FEM_VERSION=Please enter this number manually: 
if exist "%HPEESOF_DIR%\fem\%FEM_VERSION%\version.txt" ( goto fem_version_ok )
echo No valid FEM installation found at %HPEESOF_DIR%\fem\%FEM_VERSION%. Trying again...
goto enter_fem_version
:fem_version_ok 

set EESOF_LICENSE_TOOLS_DIR=%SYSTEMDRIVE%\Program Files\Keysight\EEsof_License_Tools
if exist "%EESOF_LICENSE_TOOLS_DIR%\bin\lmgrd.exe" ( goto eesof_license_tools_dir_ok )
:enter_eesof_license_tools_dir
echo.
set EESOF_LICENSE_TOOLS_DIR=%SYSTEMDRIVE%\Program Files\Keysight\EEsof_License_Tools
set /p EESOF_LICENSE_TOOLS_DIR=Please enter the EEsof license tools installation directory and then press ENTER key (e.g. %EESOF_LICENSE_TOOLS_DIR%): 
if exist "%EESOF_LICENSE_TOOLS_DIR%\bin\lmgrd.exe" ( goto eesof_license_tools_dir_ok )
echo No valid EEsof license tools installation found at %EESOF_LICENSE_TOOLS_DIR%. Trying again...
goto enter_eesof_license_tools_dir
:eesof_license_tools_dir_ok

echo.
echo The firewall will be opened for ADS for private and domain networks.
echo Do you also want to open it for ADS for untrusted public networks?
echo This is less secure, but required if you need to run ADS when connected to an untrusted public network (e.g. airport terminal, hotel, conference).
:enter_trust_yes_no
set ALLOW_UNTRUSTED=n
set /p ALLOW_UNTRUSTED=Please answer Y or N and press the ENTER key [N]: 
if /i {%ALLOW_UNTRUSTED%}=={n} ( goto allow_trusted_only )
if /i {%ALLOW_UNTRUSTED%}=={no} ( goto allow_trusted_only )
if /i {%ALLOW_UNTRUSTED%}=={y} ( goto allow_all )
if /i {%ALLOW_UNTRUSTED%}=={yes} ( goto allow_all )
goto enter_trust_yes_no
:allow_all
set RULE_PROFILE=any
goto after_set_trust
:allow_trusted_only
set RULE_PROFILE=private,domain
:after_set_trust

echo.
echo Configuring Windows Firewall...
echo.

netsh advfirewall firewall delete rule name=ads_lmgr                                   program="%EESOF_LICENSE_TOOLS_DIR%\bin\lmgrd.exe"                                     >nul
netsh advfirewall firewall add    rule name=ads_lmgr               dir=in action=allow program="%EESOF_LICENSE_TOOLS_DIR%\bin\lmgrd.exe"                                     enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_lmgr_64                                program="%EESOF_LICENSE_TOOLS_DIR%\bin\win32_64\lmgrd.exe"                            >nul
netsh advfirewall firewall add    rule name=ads_lmgr_64            dir=in action=allow program="%EESOF_LICENSE_TOOLS_DIR%\bin\win32_64\lmgrd.exe"                            enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=agileesofd                                 program="%EESOF_LICENSE_TOOLS_DIR%\bin\agileesofd.exe"                                >nul
netsh advfirewall firewall add    rule name=agileesofd             dir=in action=allow program="%EESOF_LICENSE_TOOLS_DIR%\bin\agileesofd.exe"                                enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=agileesofd_64                              program="%EESOF_LICENSE_TOOLS_DIR%\bin\win32_64\agileesofd.exe"                       >nul
netsh advfirewall firewall add    rule name=agileesofd_64          dir=in action=allow program="%EESOF_LICENSE_TOOLS_DIR%\bin\win32_64\agileesofd.exe"                       enable=yes profile=%RULE_PROFILE%
                                                                                                                                                                    
netsh advfirewall firewall delete rule name=hpeesofemx                                 program="%HPEESOF_DIR%\bin\hpeesofemx.exe"                                            >nul
netsh advfirewall firewall add    rule name=hpeesofemx             dir=in action=allow program="%HPEESOF_DIR%\bin\hpeesofemx.exe"                                            enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=oaFSLockD                                  program="%HPEESOF_DIR%\bin\oaFSLockD.exe"                                             >nul
netsh advfirewall firewall add    rule name=oaFSLockD              dir=in action=allow program="%HPEESOF_DIR%\bin\oaFSLockD.exe"                                             enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=oaFSLockD_64                               program="%HPEESOF_DIR%\bin\win32_64\oaFSLockD.exe"                                    >nul
netsh advfirewall firewall add    rule name=oaFSLockD_64           dir=in action=allow program="%HPEESOF_DIR%\bin\win32_64\oaFSLockD.exe"                                    enable=yes profile=%RULE_PROFILE%
                                                                                                                                                                    
netsh advfirewall firewall delete rule name=MomEngine                                  program="%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\win32_32\bin\MomEngine.exe"        >nul
netsh advfirewall firewall add    rule name=MomEngine              dir=in action=allow program="%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\win32_32\bin\MomEngine.exe"        enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=MomEngine_64                               program="%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\win32_64\bin\MomEngine.exe"        >nul
netsh advfirewall firewall add    rule name=MomEngine_64           dir=in action=allow program="%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\win32_64\bin\MomEngine.exe"        enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=FemEngine                                  program="%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\win32_32\bin\FemEngine.exe"        >nul
netsh advfirewall firewall add    rule name=FemEngine              dir=in action=allow program="%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\win32_32\bin\FemEngine.exe"        enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=FemEngine_64                               program="%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\win32_64\bin\FemEngine.exe"        >nul
netsh advfirewall firewall add    rule name=FemEngine_64           dir=in action=allow program="%HPEESOF_DIR%\Momentum\%MOMENTUM_VERSION%\win32_64\bin\FemEngine.exe"        enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_python                                 program="%HPEESOF_DIR%\tools\win32\python\bin\python.exe"                             >nul
netsh advfirewall firewall add    rule name=ads_python             dir=in action=allow program="%HPEESOF_DIR%\tools\win32\python\bin\python.exe"                             enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_python_64                              program="%HPEESOF_DIR%\tools\win32_64\python\bin\python.exe"                          >nul
netsh advfirewall firewall add    rule name=ads_python_64          dir=in action=allow program="%HPEESOF_DIR%\tools\win32_64\python\bin\python.exe"                          enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_pythonw                                program="%HPEESOF_DIR%\tools\win32\python\bin\pythonw.exe"                            >nul
netsh advfirewall firewall add    rule name=ads_pythonw            dir=in action=allow program="%HPEESOF_DIR%\tools\win32\python\bin\pythonw.exe"                            enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_pythonw_64                             program="%HPEESOF_DIR%\tools\win32_64\python\bin\pythonw.exe"                         >nul
netsh advfirewall firewall add    rule name=ads_pythonw_64         dir=in action=allow program="%HPEESOF_DIR%\tools\win32_64\python\bin\pythonw.exe"                         enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_fem_python                             program="%HPEESOF_DIR%\fem\%FEM_VERSION%\win32_32\bin\tools\win32\python\python.exe"  >nul
netsh advfirewall firewall add    rule name=ads_fem_python         dir=in action=allow program="%HPEESOF_DIR%\fem\%FEM_VERSION%\win32_32\bin\tools\win32\python\python.exe"  enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_fem_python_64                          program="%HPEESOF_DIR%\fem\%FEM_VERSION%\win32_64\bin\tools\win32\python\python.exe"  >nul
netsh advfirewall firewall add    rule name=ads_fem_python_64      dir=in action=allow program="%HPEESOF_DIR%\fem\%FEM_VERSION%\win32_64\bin\tools\win32\python\python.exe"  enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_fem_pythonw                            program="%HPEESOF_DIR%\fem\%FEM_VERSION%\win32_32\bin\tools\win32\python\pythonw.exe" >nul
netsh advfirewall firewall add    rule name=ads_fem_pythonw        dir=in action=allow program="%HPEESOF_DIR%\fem\%FEM_VERSION%\win32_32\bin\tools\win32\python\pythonw.exe" enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_fem_pythonw_64                         program="%HPEESOF_DIR%\fem\%FEM_VERSION%\win32_64\bin\tools\win32\python\pythonw.exe" >nul
netsh advfirewall firewall add    rule name=ads_fem_pythonw_64     dir=in action=allow program="%HPEESOF_DIR%\fem\%FEM_VERSION%\win32_64\bin\tools\win32\python\pythonw.exe" enable=yes profile=%RULE_PROFILE%

netsh advfirewall firewall delete rule name=eesofg2p                                   program="%HPEESOF_DIR%\bin\eesofg2p.exe"                                              >nul
netsh advfirewall firewall add    rule name=eesofg2p               dir=in action=allow program="%HPEESOF_DIR%\bin\eesofg2p.exe"                                              enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofg2p_64                                program="%HPEESOF_DIR%\bin\win32_64\eesofg2p.exe"                                     >nul
netsh advfirewall firewall add    rule name=eesofg2p_64            dir=in action=allow program="%HPEESOF_DIR%\bin\win32_64\eesofg2p.exe"                                     enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofp2g                                   program="%HPEESOF_DIR%\bin\eesofp2g.exe"                                              >nul
netsh advfirewall firewall add    rule name=eesofp2g               dir=in action=allow program="%HPEESOF_DIR%\bin\eesofp2g.exe"                                              enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofp2g_64                                program="%HPEESOF_DIR%\bin\win32_64\eesofp2g.exe"                                     >nul
netsh advfirewall firewall add    rule name=eesofp2g_64            dir=in action=allow program="%HPEESOF_DIR%\bin\win32_64\eesofp2g.exe"                                     enable=yes profile=%RULE_PROFILE%

netsh advfirewall firewall delete rule name=eesofcksimsetup                            program="%HPEESOF_DIR%\pvm3\bin\win32\eesofcksimsetup.exe"                            >nul
netsh advfirewall firewall add    rule name=eesofcksimsetup        dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofcksimsetup.exe"                            enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofcksimsetup_64                         program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofcksimsetup.exe"                         >nul
netsh advfirewall firewall add    rule name=eesofcksimsetup_64     dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofcksimsetup.exe"                         enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofClmClient                             program="%HPEESOF_DIR%\pvm3\bin\win32\eesofClmClient.exe"                             >nul
netsh advfirewall firewall add    rule name=eesofClmClient         dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofClmClient.exe"                             enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofClmClient_64                          program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofClmClient.exe"                          >nul
netsh advfirewall firewall add    rule name=eesofClmClient_64      dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofClmClient.exe"                          enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpsh                                   program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpsh.exe"                                   >nul
netsh advfirewall firewall add    rule name=eesofpsh               dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpsh.exe"                                   enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpsh_64                                program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpsh.exe"                                >nul
netsh advfirewall firewall add    rule name=eesofpsh_64            dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpsh.exe"                                enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpshd                                  program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpshd.exe"                                  >nul
netsh advfirewall firewall add    rule name=eesofpshd              dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpshd.exe"                                  enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpshd_64                               program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpshd.exe"                               >nul
netsh advfirewall firewall add    rule name=eesofpshd_64           dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpshd.exe"                               enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvm                                   program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvm.exe"                                   >nul
netsh advfirewall firewall add    rule name=eesofpvm               dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvm.exe"                                   enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvm_64                                program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvm.exe"                                >nul
netsh advfirewall firewall add    rule name=eesofpvm_64            dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvm.exe"                                enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvm_halter                            program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvm_halter.exe"                            >nul
netsh advfirewall firewall add    rule name=eesofpvm_halter        dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvm_halter.exe"                            enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvm_halter_64                         program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvm_halter.exe"                         >nul
netsh advfirewall firewall add    rule name=eesofpvm_halter_64     dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvm_halter.exe"                         enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvm_imply_kill                        program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvm_imply_kill.exe"                        >nul
netsh advfirewall firewall add    rule name=eesofpvm_imply_kill    dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvm_imply_kill.exe"                        enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvm_imply_kill_64                     program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvm_imply_kill.exe"                     >nul
netsh advfirewall firewall add    rule name=eesofpvm_imply_kill_64 dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvm_imply_kill.exe"                     enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvm_multitool                         program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvm_multitool.exe"                         >nul
netsh advfirewall firewall add    rule name=eesofpvm_multitool     dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvm_multitool.exe"                         enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvm_multitool_64                      program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvm_multitool.exe"                      >nul
netsh advfirewall firewall add    rule name=eesofpvm_multitool_64  dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvm_multitool.exe"                      enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvmd3                                 program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvmd3.exe"                                 >nul
netsh advfirewall firewall add    rule name=eesofpvmd3             dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvmd3.exe"                                 enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvmd3_64                              program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvmd3.exe"                              >nul
netsh advfirewall firewall add    rule name=eesofpvmd3_64          dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvmd3.exe"                              enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvmgs                                 program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvmgs.exe"                                 >nul
netsh advfirewall firewall add    rule name=eesofpvmgs             dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvmgs.exe"                                 enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvmgs_64                              program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvmgs.exe"                              >nul
netsh advfirewall firewall add    rule name=eesofpvmgs_64          dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvmgs.exe"                              enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvmhoster                             program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvmhoster.exe"                             >nul
netsh advfirewall firewall add    rule name=eesofpvmhoster         dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvmhoster.exe"                             enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvmhoster_64                          program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvmhoster.exe"                          >nul
netsh advfirewall firewall add    rule name=eesofpvmhoster_64      dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvmhoster.exe"                          enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvmtracer                             program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvmtracer.exe"                             >nul
netsh advfirewall firewall add    rule name=eesofpvmtracer         dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofpvmtracer.exe"                             enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofpvmtracer_64                          program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvmtracer.exe"                          >nul
netsh advfirewall firewall add    rule name=eesofpvmtracer_64      dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofpvmtracer.exe"                          enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofsc                                    program="%HPEESOF_DIR%\pvm3\bin\win32\eesofsc.exe"                                    >nul
netsh advfirewall firewall add    rule name=eesofsc                dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32\eesofsc.exe"                                    enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=eesofsc_64                                 program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofsc.exe"                                 >nul
netsh advfirewall firewall add    rule name=eesofsc_64             dir=in action=allow program="%HPEESOF_DIR%\pvm3\bin\win32_64\eesofsc.exe"                                 enable=yes profile=%RULE_PROFILE%

netsh advfirewall firewall delete rule name=ads_sshd                                   program="%SYSTEMDRIVE%\Program Files\ICW\Bin\sshd.exe"                                >nul
netsh advfirewall firewall add    rule name=ads_sshd               dir=in action=allow program="%SYSTEMDRIVE%\Program Files\ICW\Bin\sshd.exe"                                enable=yes profile=%RULE_PROFILE%
netsh advfirewall firewall delete rule name=ads_sshd_64                                program="%SYSTEMDRIVE%\Program Files (x86)\ICW\Bin\sshd.exe"                          >nul
netsh advfirewall firewall add    rule name=ads_sshd_64            dir=in action=allow program="%SYSTEMDRIVE%\Program Files (x86)\ICW\Bin\sshd.exe"                          enable=yes profile=%RULE_PROFILE%

echo Windows Firewall has been configured for ADS 2012.08. Check above for potential reported errors.
echo Please reboot before starting ADS.
set /p PROMPT=Press the ENTER key to close this window.
