@REM
@REM SlideWSL
@REM
@REM The Simple Linux Interface for DEveloping on WSL (Slide Whistle!)
@REM
@REM placeholder1 for build timestamp
@REM
@REM https://github.com/davehasagithub/slidewsl
@REM
@REM -----------------------------------------------------------------

@echo off
setlocal enabledelayedexpansion

set startTime=%time%
set tempProvisionPath=.slidewsl
set encodedTgzFile=assets.tgz.enc
set tempProvisionScript=_slidewsl.sh
set distro=Ubuntu-22.04
set distroExe=ubuntu2204

if "%~1" == "" goto ShowUsage
if "%~2" == "" goto ShowUsage
goto Continue

:ShowUsage
echo Usage: %~nx0 ^<username^> ^<password^>
exit /b 1

:SubsystemFailure
echo Install failed
echo See: https://learn.microsoft.com/en-us/windows/wsl/install-manual
echo Ensure feature is enabled: Windows Subsystem for Linux
echo Ensure feature is enabled: Virtual Machine Platform
echo Update: https://apps.microsoft.com/detail/9P9TQF7MRM4R
echo Install: https://apps.microsoft.com/detail/9pn20msr04dw
exit /b 1

:Continue
set "username=%~1"
set "password=%~2"

echo user: %username%

set "WSL_UTF8=1" & @REM https://github.com/microsoft/WSL/releases/tag/0.64.0

wsl --status >nul
if errorlevel 1 (
  goto SubsystemFailure
)

set num_chunks=0
@REM placeholder2 for base64 encoded tarball
if %num_chunks% equ 0 (
  echo Missing companion assets.
  echo Do you need to do a build?
  exit /b 1
)

wsl -d %distro% true >nul
if not errorlevel 1 (
  echo %distro% already exists. do you wish to delete it?
  choice /C YN /M "Enter Y or N:"
  if errorlevel 2 (
    echo Aborting.
    exit /b 1
  )

  wsl -l --running | findstr /C:"%distro%" >nul
  if not errorlevel 1 (
    echo Unmount disk image
    wsl -d %distro% -u root -e bash -c "systemctl stop disk-image || true"
  )
)

@REM clear any pre-existing known-hosts entry on 2223
ssh-keygen -R [localhost]:2223 2> nul

wsl --update
wsl --set-default-version 2
wsl --unregister %distro% >nul
%distroExe% install --root
if errorlevel 1 (
  goto SubsystemFailure
)

wsl --set-default %distro%
wsl -u root -e bash -c "echo -e [user]\\ndefault=%username% >/etc/wsl.conf"
wsl -u root -e bash -c "echo -e [boot]\\nsystemd=true >>/etc/wsl.conf"
wsl -u root -e bash -c "echo -e [interop]\\nenabled=true\\nappendWindowsPath=false >>/etc/wsl.conf"
wsl -u root -e bash -c "echo -e [experimental]\\nsparseVhd=true >>/etc/wsl.conf"
wsl -u root -e bash -c "echo -e [network]\\ngenerateResolvConf=false >>/etc/wsl.conf"
wsl -u root -e bash -c "apt update && apt install -y dos2unix"
echo wsl shutting down
wsl --shutdown

echo gathering assets
rmdir /s /q "%tempProvisionPath%" 2>nul
mkdir "%tempProvisionPath%" 2>nul
copy NUL "%tempProvisionPath%/%encodedTgzFile%" >nul
for /l %%i in (1,1,%num_chunks%) do (
  echo|set /p="!asset_encoded_tar_%%i!" | wsl -u root -e bash -c "base64 -d >>%tempProvisionPath%/%encodedTgzFile%"
)
echo extracting
wsl -u root -e bash -c "xxd -r -p <%tempProvisionPath%/%encodedTgzFile% | tar xzvf - -C %tempProvisionPath%"
wsl -u root -e bash -c "find %tempProvisionPath% -type f \( -not -name *.enc \) -exec dos2unix -ic0 {} + | xargs -0 dos2unix"

if not exist "%tempProvisionPath%/wsl/%tempProvisionScript%" (
  echo %tempProvisionScript% script is missing.
  echo Aborting.
  exit /b 1
)

echo provisioning
@REM -----------------------------------------------------------------------------------------------------------------
wsl -u root -e bash -c "cd \"%tempProvisionPath%/wsl\"; bash \"%tempProvisionScript%\" \"%username%\" \"%password%\" \"%userprofile%\""
@REM -----------------------------------------------------------------------------------------------------------------

if errorlevel 1 (
  echo Aborting.
  exit /b 1
)

@REM needed for \\wsl$ to pick up the new default user
echo restarting wsl
wsl -u root -e bash -c "systemctl stop disk-image || true"
wsl --shutdown

wsl sudo /usr/local/bin/wsl-keepalive.sh

rmdir /s /q "%tempProvisionPath%"

(
  echo. HIGHLIGHT1="\x1b[33;44m"
  echo. HIGHLIGHT2="\x1b[32m"
  echo. NC='\033[0m'
  echo. echo -e "\n----------------------------------------------------------\n"
  echo. echo -e " Done!\n"
  echo. echo -e " Start: %startTime%, End: %time%\n"
  echo. echo -e " For a terminal: wsl or %distroExe%"
  echo. echo -e " For ssh: ssh %username%@localhost -p 2223\n"
  echo. echo -e "----------------------------------------------------------\n"
  echo. echo -e " ${HIGHLIGHT1}Edit %userprofile%\\.wslconfig to keep vm alive:${NC}"
  echo. echo -e " (Requires a wsl --shutdown)\n"
  echo. echo -e " [wsl2]"
  echo. echo -e " vmIdleTimeout=-1\n"
  echo. echo -e "----------------------------------------------------------"

) | wsl -e bash -c "tr -d '\r'" | wsl -e bash

endlocal
