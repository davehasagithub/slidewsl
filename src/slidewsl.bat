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
set distro=OracleLinux_8_7
set distroExe=oraclelinux87

if "%~1" == "" goto ShowUsage
if "%~2" == "" goto ShowUsage
if not "%3"=="" if "%4"=="" goto ShowUsage
goto Continue

:ShowUsage
echo Usage: %~nx0 ^<username^> ^<password^> [^<uid^> ^<gid^> [^<path to sync.sh^>]]
echo uid is optional. gid is required with uid.
echo uid and gid default to 1000 and must be 1000 or greater.
exit /b 1

:SubsystemFailure
echo Install failed
echo See: https://learn.microsoft.com/en-us/windows/wsl/install-manual
echo Ensure feature is enabled: Windows Subsystem for Linux
echo Ensure feature is enabled: Virtual Machine Platform
echo Update: https://apps.microsoft.com/detail/9P9TQF7MRM4R
echo Install: https://apps.microsoft.com/detail/9NGGZVB0BKD9
exit /b 1

:checkInteger
set "varToCheck=%~1"
echo !varToCheck!| findstr /R "[^0-9]" >nul
if errorlevel 1 (
  set /a num=!varToCheck!
  if !num! GEQ 1000 (
    exit /b 0
  )
  exit /b 1
)
exit /b 1

:Continue
set "username=%~1"
set "password=%~2"

set "uid=1000"
set "gid=1000"
if not "%~3" == "" (
  set "uid=%~3"
  set "gid=%~4"
  set "syncPath=%~5"

  call :checkInteger !uid!
  if !errorlevel! equ 1 (
    echo bad uid
    goto ShowUsage
  )
  call :checkInteger !gid!
  if !errorlevel! equ 1 (
    echo bad gid
    goto ShowUsage
  )

  if not "!syncPath!" == "" (
    if not exist "!syncPath!" (
      echo sync script not found at !syncPath!
      goto ShowUsage
    )
  )
)

echo user: %username%
echo uid : %uid%
echo gid : %gid%
if not "%syncPath%" == "" echo path: %syncPath%

set "WSL_UTF8=1" & @REM https://github.com/microsoft/WSL/releases/tag/0.64.0

wsl --status >nul
if %errorlevel% neq 0 (
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
wsl --unregister %distro% >nul
%distroExe% install --root
if %errorlevel% neq 0 (
  goto SubsystemFailure
)

wsl --set-default %distro%
wsl -u root sh -c "groupadd --gid "%gid%" "%username%""
wsl -u root sh -c "useradd "%username%" --create-home --uid "%uid%" --gid "%gid%""
wsl -u root sh -c "echo "%username%:%password%" | chpasswd"
wsl -u root -e sh -c "echo -e [user]\\ndefault=%username% >/etc/wsl.conf"
wsl -u root -e sh -c "echo -e [boot]\\nsystemd=true >>/etc/wsl.conf"
wsl -u root -e sh -c "echo -e [interop]\\nenabled=false\\nappendWindowsPath=false >>/etc/wsl.conf"
wsl -u root -e sh -c "dnf install -y dos2unix"

echo wsl shutting down
wsl --shutdown

echo gathering assets
rmdir /s /q "%tempProvisionPath%" 2>nul
mkdir "%tempProvisionPath%" 2>nul
copy NUL "%tempProvisionPath%/%encodedTgzFile%" >nul
for /l %%i in (1,1,%num_chunks%) do (
  echo|set /p="!asset_encoded_tar_%%i!" | wsl -e sh -c "base64 -d >>%tempProvisionPath%/%encodedTgzFile%"
)
echo extracting
wsl -e sh -c "xxd -r -p <%tempProvisionPath%/%encodedTgzFile% | tar xzvf - -C %tempProvisionPath%"
wsl -e sh -c "find %tempProvisionPath% -type f \( -not -name *.enc \) -exec dos2unix -ic0 {} + | xargs -0 dos2unix"

if not exist "%tempProvisionPath%/%tempProvisionScript%" (
  echo %tempProvisionScript% script is missing.
  echo Aborting.
  exit /b 1
)

if not "%syncPath%" == "" (
  echo adding %syncPath%
  copy "%syncPath%" "%tempProvisionPath%/docker/sync.sh"
)

echo provisioning
@REM -------------------------------------------------------------------------------------------
wsl -u root -e sh -c "cd \"%tempProvisionPath%\"; bash \"%tempProvisionScript%\" \"%username%\""
@REM -------------------------------------------------------------------------------------------

if %errorlevel% neq 0 (
  echo Aborting.
  exit /b 1
)

rmdir /s /q "%tempProvisionPath%"

(
  echo. HIGHLIGHT1="\x1b[33;44m"
  echo. HIGHLIGHT2="\x1b[32m"
  echo. NC='\033[0m'
  echo. echo -e "\n----------------------------------------------------------\n"
  echo. echo -e " Done!\n"
  echo. echo -e " Start: %startTime%"
  echo. echo -e " End  : %time%\n"
  echo. echo -e " Now run ${HIGHLIGHT1} Windows Remote Desktop ${NC} (mstsc.exe)"
  echo. echo -e " Use the computer location: ${HIGHLIGHT2}localhost:3390${NC}"
  echo. echo -e " Username: %username% (and the password you provided)\n"
  echo. echo -e " Or, for a terminal: wsl or %distroExe%"
  echo. echo -e " Or, for ssh: ssh %username%@localhost -p 2223\n"
  echo. echo -e " To launch the devcontainer: dc help\n"
  echo. echo -e "----------------------------------------------------------"

) | wsl -e sh -c "tr -d '\r'" | wsl

endlocal
