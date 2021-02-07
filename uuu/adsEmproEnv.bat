@echo off
REM Copyright Keysight Technologies 2014 - 2014  

REM wrapper around around the fem engines for windows
REM   starts engines from commandline initializing the empro environment first

if not defined HPEESOF_DIR ( echo The HPEESOF_DIR environment variable must be set & exit /b 1 )
set PATH=%HPEESOF_DIR%\bin;%PATH%

for /f "tokens=*" %%a in ('menv getRefvalue --name fem --product_root "%HPEESOF_DIR%"') do set FEMcmpt=%%a

if /i "%PROCESSOR_ARCHITECTURE%" == "amd64" (set EmproEnv=%FEMcmpt%\win32_64\bin\emproenv.bat) else (set EmproEnvBat=%FEMcmpt%\win32_32\bin\emproenv.bat)

if not exist "%EmproEnv%" ( echo The FEM environment cannot be set & echo "%EmproEnv%" & exit /b 2 )

"%EmproEnv%" %*
