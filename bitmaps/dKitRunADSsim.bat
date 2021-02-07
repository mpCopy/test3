@echo off
REM Copyright Keysight Technologies 2001 - 2017  

REM build argument list
set commandLine=dKitRunADSsim.sh
:nextarg
if "%1"=="" goto end
set commandLine=%commandLine% %1
shift
goto nextarg
:end

REM  run command
start /i /b /wait sh -c "%commandLine%"


