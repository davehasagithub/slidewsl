@echo off
setlocal enabledelayedexpansion

set startTime=%time%
set tempProvisionScriptPath=_slidewsl.tmp
set distro=OracleLinux_8_7
set distroExe=oraclelinux87

if "%~1" == "" goto MissingParams
if "%~2" == "" goto MissingParams
goto Continue

:MissingParams
echo Usage: %~nx0 ^<username^> ^<password^>
exit /b 1

:Continue
set "username=%~1"
set "password=%~2"

set "WSL_UTF8=1" & @REM https://github.com/microsoft/WSL/releases/tag/0.64.0
for /f "delims=" %%i in ('wsl -v^|findstr /b /c:"WSL version"') do set WSL_VERSION=%%i
echo %WSL_VERSION% | findstr /C:"WSL version" > nul
if %errorlevel% neq 0 (
  echo Error: 'wsl -v' did not return 'WSL version'.
  echo This might indicate an old version of wsl.
  echo Please update: https://apps.microsoft.com/detail/9P9TQF7MRM4R
  exit /b 1
)

set num_chunks=0
@REM placeholder1 for base64 encoded shell script. used by build. do not remove
if %num_chunks% equ 0 (
  echo Missing companion shell script content.
  echo Perhaps you need to do a build?
  exit /b 1
)

wsl -d %distro% true >nul
if %errorlevel% equ 0 (
  echo %distro% already exists. do you wish to delete it?
  choice /C YN /M "Enter Y or N:"
  if errorlevel 2 (
    echo Aborting.
    exit /b 1
  )
)

@REM clear any pre-existing known-hosts entry on 2223
ssh-keygen -R [localhost]:2223 2> nul

wsl --update
wsl --set-default-version 2
wsl --unregister %distro%
%distroExe% install --root & REM https://github.com/microsoft/WSL/issues/3369
wsl --set-default %distro%
wsl -u root useradd -m "%username%"
wsl -u root sh -c "echo "%username%:%password%" | chpasswd"
wsl -u root usermod -aG adm,wheel,cdrom "%username%"
wsl -u root -e sh -c "echo -e [user]\\ndefault=%username% >/etc/wsl.conf"
wsl -u root -e sh -c "echo -e [boot]\\nsystemd=true >>/etc/wsl.conf"
wsl -u root -e sh -c "echo -e [interop]\\nenabled=false\\nappendWindowsPath=false >>/etc/wsl.conf"
wsl --shutdown

copy NUL "%tempProvisionScriptPath%" >nul
for /l %%i in (1,1,%num_chunks%) do (
  echo|set /p="!shell_script_content_%%i!" | wsl -e sh -c "base64 -d >>%tempProvisionScriptPath%"
)

if not exist "%tempProvisionScriptPath%" (
  echo %tempProvisionScriptPath% script is missing.
  echo Aborting.
  exit /b 1
)

@REM ------------------------------------------------------------------------------------
wsl -u root -e sh -c "tr -d '\r' <\"%tempProvisionScriptPath%\" | sh -s -- \"%username%\""
@REM ------------------------------------------------------------------------------------

del "%tempProvisionScriptPath%"

echo Start Time: %startTime%
echo Finish Time: %time%

(
  echo. HIGHLIGHT1="\x1b[33;44m"
  echo. HIGHLIGHT2="\x1b[32m"
  echo. NC='\033[0m'
  echo. echo -e "\n------------------------------------------------\n"
  echo. echo -e " Done!\n"
  echo. echo -e " Now run ${HIGHLIGHT1} Windows Remote Desktop ${NC} (mstsc.exe)"
  echo. echo -e " Use the computer location: ${HIGHLIGHT2}localhost:3390${NC}"
  echo. echo -e " Username: %username% (and the password you provided)\n"
  echo. echo -e " Or, for a terminal: wsl or %distroExe%"
  echo. echo -e " Or, for ssh: ssh %username%@localhost -p 2223\n"
  echo. echo -e "------------------------------------------------"

) | wsl -e sh -c "tr -d '\r'" | wsl

endlocal
