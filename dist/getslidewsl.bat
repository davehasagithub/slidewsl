@REM
@REM slidewsl
@REM
@REM The Simple Linux Interface for DEveloping on WSL
@REM
@REM built Tue Feb 20 06:56:11 EST 2024
@REM
@REM warning: this script will run wsl --shutdown
@REM
@REM ---------------------------------------------------------------

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

:SubsystemFailure
echo Install failed
echo See: https://learn.microsoft.com/en-us/windows/wsl/install-manual
echo Ensure feature is enabled: Windows Subsystem for Linux
echo Ensure feature is enabled: Virtual Machine Platform
echo Update: https://apps.microsoft.com/detail/9P9TQF7MRM4R
echo Install: https://apps.microsoft.com/detail/9NGGZVB0BKD9
exit /b 1

:Continue
set "username=%~1"
set "password=%~2"

set "WSL_UTF8=1" & @REM https://github.com/microsoft/WSL/releases/tag/0.64.0

wsl --status >nul
if %errorlevel% neq 0 (
  goto SubsystemFailure
)

set num_chunks=0
set num_chunks=5
set "shell_script_content_1=IyEvYmluL2Jhc2gKCmlmIFsgIiRVU0VSIiAhPSAicm9vdCIgXTsgdGhlbgogIGVjaG8gIkVycm9yOiB1c2VyIGlzbid0IHJvb3QiCiAgZXhpdCAxCmZpCgppZiBbIC16ICIkMSIgXTsgdGhlbgogIGVjaG8gIkVycm9yOiB1c2VybmFtZSB3YXMgbm90IHByb3ZpZGVkIgogIGVjaG8gIlVzYWdlOiAkMCA8dXNlcm5hbWU+IgogIGV4aXQgMQpmaQp1c2VybmFtZT0iJDEiCgpjZCB+IHx8IGV4aXQKCnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ2VjaG8gY2QgXH4+Pn4vLmJhc2hyYycKZG5mIGluc3RhbGwgLXkgaHR0cHM6Ly9kbC5mZWRvcmFwcm9qZWN0Lm9yZy9wdWIvZXBlbC9lcGVsLXJlbGVhc2UtbGF0ZXN0LTgubm9hcmNoLnJwbQpkbmYgaW5zdGFsbCAteSBkbmYtdXRpbHMgemlwIHVuemlwIGdpdCBiYXNoLWNvbXBsZXRpb24gZGJ1cy14MTEgdGVsbmV0IGhvc3RuYW1lCgojIHhmY2UgKyB4cmRwCmRuZiBncm91cCBpbnN0YWxsIC15IC0tc2V0b3B0PWdyb3VwX3BhY2thZ2VfdHlwZXM9Im1hbmRhdG9yeSIgeGZjZQpkbmYgaW5zdGFsbCAteSB4cmRwIHhmY2U0LXRlcm1pbmFsIHhmY2U0LWFwcGZpbmRlcgpzZWQgLXJpICJzL15wb3J0PTMzODkvcG9ydD0zMzkwLyIgL2V0Yy94cmRwL3hyZHAuaW5pCnN5c3RlbWN0bCBlbmFibGUgLS1ub3cgeHJkcAoKIyBmaXggeHJkcAojIGh0dHBzOi8vZ2l0aHViLmNvbS9uZXV0cmlub2xhYnMveHJkcC9pc3N1ZXMvMjQ5MQpjdXJsIC1zTE8gaHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hdHQzMzU2NzIvbmVzdC1zeXN0ZW1kLXVzZXIvY2E5Y2Q0MTc3OGZhZmFlOTc5MWI1MDI3ZjI2MWU0OTgyNjU2Njc5NC9zeXN0ZW1kX3VzZXJfY29udGV4dC5zaCBzeXN0ZW1kX3VzZXJfY29udGV4dC5zaApjaG1vZCAreCBzeXN0ZW1kX3VzZXJfY29udGV4dC5zaAptdiBzeXN0ZW1kX3VzZXJfY29udGV4dC5zaCAvdXNyL2xpYmV4ZWMveHJkcAp3bV9maXh1cD0iaWYgWyAteCAvdXNyL2Jpbi9zeXN0ZW1jdGwgLWEgXCJcJFhER19SVU5USU1FX0RJUlwiID0gXA=="
set "shell_script_content_2=Ii9ydW4vdXNlci9cIlxgaWQgLXVcYCBdOyB0aGVuIGV2YWwgXCJcYFwkezAlLyp9L3N5c3RlbWRfdXNlcl9jb250ZXh0LnNoIGluaXQgLXAgXCRcJFxgXCI7IGZpIgpzZWQgLWkgIi9ed21fc3RhcnQkL2kgJHdtX2ZpeHVwIiAvdXNyL2xpYmV4ZWMveHJkcC9zdGFydHdtLnNoCnNlZCAtcmkgInMjXC4gL2V0Yy9YMTEveGluaXQvWHNlc3Npb24jc3RhcnR4ZmNlNCMiIC91c3IvbGliZXhlYy94cmRwL3N0YXJ0d20uc2gKCiMgc3NoZApzZWQgLXJpICJzL14jP1BvcnQgLiovUG9ydCAyMjIzLyIgL2V0Yy9zc2gvc3NoZF9jb25maWcKCiMgZG9ja2VyCmRuZiBjb25maWctbWFuYWdlciAtLWFkZC1yZXBvPWh0dHBzOi8vZG93bmxvYWQuZG9ja2VyLmNvbS9saW51eC9jZW50b3MvZG9ja2VyLWNlLnJlcG8KZG5mIGluc3RhbGwgLXkgZG9ja2VyLWNlIGRvY2tlci1jZS1jbGkgY29udGFpbmVyZC5pbyBkb2NrZXItYnVpbGR4LXBsdWdpbiBkb2NrZXItY29tcG9zZS1wbHVnaW4KdXNlcm1vZCAtYUcgZG9ja2VyICIkdXNlcm5hbWUiCnN5c3RlbWN0bCBlbmFibGUgLS1ub3cgZG9ja2VyLnNlcnZpY2UKc3lzY3RsIC13IGZzLmlub3RpZnkubWF4X3VzZXJfd2F0Y2hlcz01MjQyODgKCiMgbm9kZSBhbmQgeWFybiAoY29udGFpbmVyaXplPykKY3VybCAtZnNTTCBodHRwczovL3JwbS5ub2Rlc291cmNlLmNvbS9zZXR1cF8xNC54IHwgZ3JlcCAtdiAnXlthLXpdKl9kZXByZWNhdGlvbl93YXJuaW5nJCcgfCBiYXNoIC0KZG5mIGluc3RhbGwgLXkgbm9kZWpzLTE0LjIwLjEKbnBtIGluc3RhbGwgLWcgeWFybkAxLjIyLjE5IC0tbm8tcHJvZ3Jlc3MKCiMgY3VzdG9tIGhvc3RzCnNoIC1jICdlY2hvIC1lICIjIS9iaW4vc2hcXG5pZiBbWyAtbiBcIlwkMVwiICYmIC1uIFwiXCQyXCIgXV07IHRoZW4gZWNobyBcIlwkMlwiIFwiXCQxXCIgfCB0ZWUgLWEgL2V0Yy9ob3N0cy53c2wgL2V0Yy9ob3N0czsgZmkiID4vdXNyL2xvY2FsL2Jpbi9hZGQtaG9zdC5zaCcKY2htb2QgK3ggL3Vzci9sb2NhbC9iaW4vYWRkLWhvc3Quc2gKdG91Yw=="
set "shell_script_content_3=aCAvZXRjL2hvc3RzLndzbAplY2hvIGNhdCAvZXRjL2hvc3RzLndzbCBcPlw+L2V0Yy9ob3N0cyA+Pi9ldGMvcmMuZC9yYy5sb2NhbC53c2wKCiMgY2FsbCByYy5sb2NhbC53c2wgZnJvbSByYy5sb2NhbAplY2hvIC9ldGMvcmMuZC9yYy5sb2NhbC53c2wgPj4vZXRjL3JjLmQvcmMubG9jYWwKY2htb2QgK3ggL2V0Yy9yYy5kL3JjLmxvY2FsIC9ldGMvcmMuZC9yYy5sb2NhbC53c2wKL2V0Yy9yYy5kL3JjLmxvY2FsLndzbAoKIyBrZWVwIGRpc3RybyBydW5uaW5nCmNhdCA8PEVPRiB8IHNlZCAicy9eICAvLyIgPi9ldGMvcHJvZmlsZS5kL3dzbC1rZWVwYWxpdmUuc2gKICAjIS9iaW4vYmFzaAoKICBwaWRfZmlsZT0iL3RtcC93c2wta2VlcGFsaXZlLnBpZCIKICBwaWQ9XCQoY2F0ICJcJHBpZF9maWxlIiAyPi9kZXYvbnVsbCkKICBpZiB0ZXN0IC16ICJcJHBpZCIgfHwgISBwcyAtcCAiXCRwaWQiID4vZGV2L251bGw7IHRoZW4KICAgIGRidXMtbGF1bmNoIHRydWUKICAgIGRidXNfcGlkPVwkKHBncmVwIC1uIGRidXMtZGFlbW9uKQogICAgZWNobyAiXCRkYnVzX3BpZCIgPiJcJHBpZF9maWxlIgogIGZpCkVPRgpjaG1vZCA2NDQgL2V0Yy9wcm9maWxlLmQvd3NsLWtlZXBhbGl2ZS5zaAovZXRjL3Byb2ZpbGUuZC93c2wta2VlcGFsaXZlLnNoCgojIGJyb3dzZXJzCmRuZiBpbnN0YWxsIC15IGZpcmVmb3ggY2hyb21pdW0KCiMgamV0YnJhaW5zIHRvb2xib3gKZG5mIGluc3RhbGwgLXkgZnVzZSBmdXNlLWxpYnMKY3VybCAtc0xPIGh0dHBzOi8vZG93bmxvYWQuamV0YnJhaW5zLmNvbS90b29sYm94L2pldGJyYWlucy10b29sYm94LTIuMi4xLjE5NzY1LnRhci5negp0YXIgLXh6ZiBqZXRicmFpbnMtdG9vbGJveC0yLjIuMS4xOTc2NS50YXIuZ3ogLUMgL29wdAojIGFkZCBkZXNrdG9wIHNob3J0Y3V0CnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ21rZGlyIERlc2t0b3AnCnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ2VjaG8gLWUgW0Rlc2t0b3AgRW50cnldID5EZXNrdG9wL2pidG9vbGJveC5kZQ=="
set "shell_script_content_4=c2t0b3AnCnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ2VjaG8gLWUgTmFtZT1KZXRCcmFpbnMgVG9vbGJveCA+PkRlc2t0b3AvamJ0b29sYm94LmRlc2t0b3AnCnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ2VjaG8gLWUgQ29tbWVudD1JbnN0YWxsIEpldEJyYWlucyBUb29sYm94ID4+RGVza3RvcC9qYnRvb2xib3guZGVza3RvcCcKc3VkbyAtdSAiJHVzZXJuYW1lIiAtaSBzaCAtYyAnZWNobyAtZSBWZXJzaW9uPTEuMCA+PkRlc2t0b3AvamJ0b29sYm94LmRlc2t0b3AnCnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ2VjaG8gLWUgSWNvbj1hcHBsaWNhdGlvbnMtZGV2ZWxvcG1lbnQgPj5EZXNrdG9wL2pidG9vbGJveC5kZXNrdG9wJwpzdWRvIC11ICIkdXNlcm5hbWUiIC1pIHNoIC1jICdlY2hvIC1lIFR5cGU9QXBwbGljYXRpb24gPj5EZXNrdG9wL2pidG9vbGJveC5kZXNrdG9wJwpzdWRvIC11ICIkdXNlcm5hbWUiIC1pIHNoIC1jICdlY2hvIC1lIFRlcm1pbmFsPWZhbHNlXFxuID4+RGVza3RvcC9qYnRvb2xib3guZGVza3RvcCcKc3VkbyAtdSAiJHVzZXJuYW1lIiAtaSBzaCAtYyAnZWNobyAtZSBFeGVjPS9vcHQvamV0YnJhaW5zLXRvb2xib3gtMi4yLjEuMTk3NjUvamV0YnJhaW5zLXRvb2xib3ggPj5EZXNrdG9wL2pidG9vbGJveC5kZXNrdG9wJwpzdWRvIC11ICIkdXNlcm5hbWUiIC1pIHNoIC1jICdjaG1vZCAreCBEZXNrdG9wL2pidG9vbGJveC5kZXNrdG9wJwoKIyB0cnVuY2F0ZSAtcyAxMEcgL21udC9kL2RhdGFiYXNlLnZoZAojIG1rZnMuZXh0NCAvbW50L2QvZGF0YWJhc2UudmhkCiMgbWtkaXIgL21udC9kYXRhYmFzZQojIG1vdW50IC1vIGxvb3AgL21udC9kL2RhdGFiYXNlLnZoZCAvbW50L2RhdGFiYXNlCiMgc2ggLWMgJ2VjaG8gL21udC9kL2RhdGFiYXNlLmltZyAvbW50L2RhdGFiYXNlIGV4dDQgbG9vcCAwIDAgPj4vZXRjL2ZzdGFiJwoKZWNobyAtbmUgIlxuRG9ja2VyIHRlc3Q6ICIKaWYgZG9ja2VyIHZlcnNpb24gMj4vZGV2L251bGwgMT4mMjsgdGhlbiBlYw=="
set "shell_script_content_5=aG8gLWUgb2tcXG47IGVsc2UgZWNobyAtZSBub3Qgb2tcIVwhXCFcIVwhXCFcIVwhXCFcIVwhXCFcXG47IGZp"
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
wsl --unregister %distro% >nul
%distroExe% install --root & REM https://github.com/microsoft/WSL/issues/3369
if %errorlevel% neq 0 (
  goto SubsystemFailure
)

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
