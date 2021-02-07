@echo off
REM Copyright Keysight Technologies 2014 - 2014  

REM wrapper around eesofsubed for windows

REM SET HPEESOF_DIR=C:/ADS2015.01

if not defined HPEESOF_DIR ( echo The HPEESOF_DIR environment variable must be set & exit /b 1 )
set PATH=%HPEESOF_DIR%\bin;%HPEESOF_DIR%\tools;%PATH%

eesofsubed.exe %*
