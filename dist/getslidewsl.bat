@REM
@REM slidewsl
@REM
@REM The Simple Linux Interface for DEveloping on WSL
@REM
@REM built Mon Feb 19 09:13:11 EST 2024
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

:Continue
set "username=%~1"
set "password=%~2"

@REM https://github.com/microsoft/WSL/issues/7865
for /f "delims=" %%i in ('powershell -Command "(wsl -v) -replace '\0', ''"^|findstr /b /c:"WSL version"') do set WSL_VERSION=%%i
echo %WSL_VERSION% | findstr /C:"WSL version" > nul
if %errorlevel% neq 0 (
  echo Error: 'wsl -v' did not return 'WSL version'.
  echo This might indicate an old version of wsl.
  echo Please update: https://apps.microsoft.com/detail/9P9TQF7MRM4R
  exit /b 1
)

set num_chunks=0
set num_chunks=5
set "shell_script_content_1=IyEvYmluL2Jhc2gKCmlmIFsgIiRVU0VSIiAhPSAicm9vdCIgXTsgdGhlbgogIGVjaG8gIkVycm9yOiB1c2VyIGlzbid0IHJvb3QiCiAgZXhpdCAxCmZpCgppZiBbIC16ICIkMSIgXTsgdGhlbgogIGVjaG8gIkVycm9yOiB1c2VybmFtZSB3YXMgbm90IHByb3ZpZGVkIgogIGVjaG8gIlVzYWdlOiAkMCA8dXNlcm5hbWU+IgogIGV4aXQgMQpmaQp1c2VybmFtZT0iJDEiCgpjZCB+IHx8IGV4aXQKCnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ2VjaG8gY2QgXH4+Pn4vLmJhc2hyYycKZG5mIGluc3RhbGwgLXkgaHR0cHM6Ly9kbC5mZWRvcmFwcm9qZWN0Lm9yZy9wdWIvZXBlbC9lcGVsLXJlbGVhc2UtbGF0ZXN0LTgubm9hcmNoLnJwbQpkbmYgaW5zdGFsbCAteSBkbmYtdXRpbHMgemlwIHVuemlwIGdpdCBiYXNoLWNvbXBsZXRpb24gZGJ1cy14MTEgdGVsbmV0IGhvc3RuYW1lCgojIHhmY2UgKyB4cmRwCmRuZiBncm91cCBpbnN0YWxsIC15IC0tc2V0b3B0PWdyb3VwX3BhY2thZ2VfdHlwZXM9Im1hbmRhdG9yeSIgeGZjZQpkbmYgaW5zdGFsbCAteSB4cmRwIHhmY2U0LXRlcm1pbmFsIHhmY2U0LWFwcGZpbmRlcgpzZWQgLXJpICJzL15wb3J0PTMzODkvcG9ydD0zMzkwLyIgL2V0Yy94cmRwL3hyZHAuaW5pCnN5c3RlbWN0bCBlbmFibGUgLS1ub3cgeHJkcAoKIyBmaXggeHJkcAojIGh0dHBzOi8vZ2l0aHViLmNvbS9uZXV0cmlub2xhYnMveHJkcC9pc3N1ZXMvMjQ5MQpjdXJsIC1zTE8gaHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hdHQzMzU2NzIvbmVzdC1zeXN0ZW1kLXVzZXIvY2E5Y2Q0MTc3OGZhZmFlOTc5MWI1MDI3ZjI2MWU0OTgyNjU2Njc5NC9zeXN0ZW1kX3VzZXJfY29udGV4dC5zaCBzeXN0ZW1kX3VzZXJfY29udGV4dC5zaApjaG1vZCAreCBzeXN0ZW1kX3VzZXJfY29udGV4dC5zaAptdiBzeXN0ZW1kX3VzZXJfY29udGV4dC5zaCAvdXNyL2xpYmV4ZWMveHJkcAp3bV9maXh1cD0iaWYgWyAteCAvdXNyL2Jpbi9zeXN0ZW1jdGwgLWEgXCJcJFhER19SVU5USU1FX0RJUlwiID0gXA=="
set "shell_script_content_2=Ii9ydW4vdXNlci9cIlxgaWQgLXVcYCBdOyB0aGVuIGV2YWwgXCJcYFwkezAlLyp9L3N5c3RlbWRfdXNlcl9jb250ZXh0LnNoIGluaXQgLXAgXCRcJFxgXCI7IGZpIgpzZWQgLWkgIi9ed21fc3RhcnQkL2kgJHdtX2ZpeHVwIiAvdXNyL2xpYmV4ZWMveHJkcC9zdGFydHdtLnNoCnNlZCAtcmkgInMjXC4gL2V0Yy9YMTEveGluaXQvWHNlc3Npb24jc3RhcnR4ZmNlNCMiIC91c3IvbGliZXhlYy94cmRwL3N0YXJ0d20uc2gKCiMgc3NoZApzZWQgLXJpICJzL14jP1BvcnQgLiovUG9ydCAyMjIzLyIgL2V0Yy9zc2gvc3NoZF9jb25maWcKCiMgZG9ja2VyCmRuZiBjb25maWctbWFuYWdlciAtLWFkZC1yZXBvPWh0dHBzOi8vZG93bmxvYWQuZG9ja2VyLmNvbS9saW51eC9jZW50b3MvZG9ja2VyLWNlLnJlcG8KZG5mIGluc3RhbGwgLXkgZG9ja2VyLWNlIGRvY2tlci1jZS1jbGkgY29udGFpbmVyZC5pbyBkb2NrZXItYnVpbGR4LXBsdWdpbiBkb2NrZXItY29tcG9zZS1wbHVnaW4KdXNlcm1vZCAtYUcgZG9ja2VyICIkdXNlcm5hbWUiCnN5c3RlbWN0bCBlbmFibGUgLS1ub3cgZG9ja2VyLnNlcnZpY2UKc3lzY3RsIC13IGZzLmlub3RpZnkubWF4X3VzZXJfd2F0Y2hlcz01MjQyODgKCiMgbm9kZSBhbmQgeWFybiAoY29udGFpbmVyaXplPykKY3VybCAtZnNTTCBodHRwczovL3JwbS5ub2Rlc291cmNlLmNvbS9zZXR1cF8xNC54IHwgZ3JlcCAtdiAnXlthLXpdKl9kZXByZWNhdGlvbl93YXJuaW5nJCcgfCBiYXNoIC0KZG5mIGluc3RhbGwgLXkgbm9kZWpzLTE0LjIwLjEKbnBtIGluc3RhbGwgLWcgeWFybkAxLjIyLjE5IC0tbm8tcHJvZ3Jlc3MKCiMgY3VzdG9tIGhvc3RzIHdpdGggd3NsIHN1YmRvbWFpbgpzaCAtYyAnZWNobyAtZSAiIyEvYmluL3NoXFxuaWYgW1sgLW4gXCJcJDFcIiAmJiAtbiBcIlwkMlwiIF1dOyB0aGVuIGVjaG8gXCJcJDJcIiB3c2wuXCJcJDFcIiB8IHRlZSAtYSAvZXRjL2hvc3RzLndzbCAvZXRjL2hvc3RzOyBmaSIgPi91c3IvbG9jYWwvYmluL3VwZGF0ZS1ob3N0cy5zaCcKY2htb2QgK3ggL3Vzcg=="
set "shell_script_content_3=L2xvY2FsL2Jpbi91cGRhdGUtaG9zdHMuc2gKdG91Y2ggL2V0Yy9ob3N0cy53c2wKZWNobyBjYXQgL2V0Yy9ob3N0cy53c2wgXD5cPi9ldGMvaG9zdHMgPj4vZXRjL3JjLmQvcmMubG9jYWwud3NsCgojIGNhbGwgcmMubG9jYWwud3NsIGZyb20gcmMubG9jYWwKZWNobyAvZXRjL3JjLmQvcmMubG9jYWwud3NsID4+L2V0Yy9yYy5kL3JjLmxvY2FsCmNobW9kICt4IC9ldGMvcmMuZC9yYy5sb2NhbCAvZXRjL3JjLmQvcmMubG9jYWwud3NsCi9ldGMvcmMuZC9yYy5sb2NhbC53c2wKCiMga2VlcCBkaXN0cm8gcnVubmluZwpjYXQgPDxFT0YgfCBzZWQgInMvXiAgLy8iID4vZXRjL3Byb2ZpbGUuZC93c2wta2VlcGFsaXZlLnNoCiAgIyEvYmluL2Jhc2gKCiAgcGlkX2ZpbGU9Ii90bXAvd3NsLWtlZXBhbGl2ZS5waWQiCiAgcGlkPVwkKGNhdCAiXCRwaWRfZmlsZSIgMj4vZGV2L251bGwpCiAgaWYgdGVzdCAteiAiXCRwaWQiIHx8ICEgcHMgLXAgIlwkcGlkIiA+L2Rldi9udWxsOyB0aGVuCiAgICBkYnVzLWxhdW5jaCB0cnVlCiAgICBkYnVzX3BpZD1cJChwZ3JlcCAtbiBkYnVzLWRhZW1vbikKICAgIGVjaG8gIlwkZGJ1c19waWQiID4iXCRwaWRfZmlsZSIKICBmaQpFT0YKY2htb2QgNjQ0IC9ldGMvcHJvZmlsZS5kL3dzbC1rZWVwYWxpdmUuc2gKL2V0Yy9wcm9maWxlLmQvd3NsLWtlZXBhbGl2ZS5zaAoKIyBicm93c2VycwpkbmYgaW5zdGFsbCAteSBmaXJlZm94IGNocm9taXVtCgojIGpldGJyYWlucyB0b29sYm94CmRuZiBpbnN0YWxsIC15IGZ1c2UgZnVzZS1saWJzCmN1cmwgLXNMTyBodHRwczovL2Rvd25sb2FkLmpldGJyYWlucy5jb20vdG9vbGJveC9qZXRicmFpbnMtdG9vbGJveC0yLjIuMS4xOTc2NS50YXIuZ3oKdGFyIC14emYgamV0YnJhaW5zLXRvb2xib3gtMi4yLjEuMTk3NjUudGFyLmd6IC1DIC9vcHQKIyBhZGQgZGVza3RvcCBzaG9ydGN1dApzdWRvIC11ICIkdXNlcm5hbWUiIC1pIHNoIC1jICdta2RpciBEZXNrdG9wJwpzdWRvIC11ICIkdXNlcm5hbWUiIC1pIHNoIC1jICdlY2hvIC1lIFtEZXNrdA=="
set "shell_script_content_4=b3AgRW50cnldID5EZXNrdG9wL2pidG9vbGJveC5kZXNrdG9wJwpzdWRvIC11ICIkdXNlcm5hbWUiIC1pIHNoIC1jICdlY2hvIC1lIE5hbWU9SmV0QnJhaW5zIFRvb2xib3ggPj5EZXNrdG9wL2pidG9vbGJveC5kZXNrdG9wJwpzdWRvIC11ICIkdXNlcm5hbWUiIC1pIHNoIC1jICdlY2hvIC1lIENvbW1lbnQ9SW5zdGFsbCBKZXRCcmFpbnMgVG9vbGJveCA+PkRlc2t0b3AvamJ0b29sYm94LmRlc2t0b3AnCnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ2VjaG8gLWUgVmVyc2lvbj0xLjAgPj5EZXNrdG9wL2pidG9vbGJveC5kZXNrdG9wJwpzdWRvIC11ICIkdXNlcm5hbWUiIC1pIHNoIC1jICdlY2hvIC1lIEljb249YXBwbGljYXRpb25zLWRldmVsb3BtZW50ID4+RGVza3RvcC9qYnRvb2xib3guZGVza3RvcCcKc3VkbyAtdSAiJHVzZXJuYW1lIiAtaSBzaCAtYyAnZWNobyAtZSBUeXBlPUFwcGxpY2F0aW9uID4+RGVza3RvcC9qYnRvb2xib3guZGVza3RvcCcKc3VkbyAtdSAiJHVzZXJuYW1lIiAtaSBzaCAtYyAnZWNobyAtZSBUZXJtaW5hbD1mYWxzZVxcbiA+PkRlc2t0b3AvamJ0b29sYm94LmRlc2t0b3AnCnN1ZG8gLXUgIiR1c2VybmFtZSIgLWkgc2ggLWMgJ2VjaG8gLWUgRXhlYz0vb3B0L2pldGJyYWlucy10b29sYm94LTIuMi4xLjE5NzY1L2pldGJyYWlucy10b29sYm94ID4+RGVza3RvcC9qYnRvb2xib3guZGVza3RvcCcKc3VkbyAtdSAiJHVzZXJuYW1lIiAtaSBzaCAtYyAnY2htb2QgK3ggRGVza3RvcC9qYnRvb2xib3guZGVza3RvcCcKCiMgdHJ1bmNhdGUgLXMgMTBHIC9tbnQvZC9kYXRhYmFzZS52aGQKIyBta2ZzLmV4dDQgL21udC9kL2RhdGFiYXNlLnZoZAojIG1rZGlyIC9tbnQvZGF0YWJhc2UKIyBtb3VudCAtbyBsb29wIC9tbnQvZC9kYXRhYmFzZS52aGQgL21udC9kYXRhYmFzZQojIHNoIC1jICdlY2hvIC9tbnQvZC9kYXRhYmFzZS5pbWcgL21udC9kYXRhYmFzZSBleHQ0IGxvb3AgMCAwID4+L2V0Yy9mc3RhYicKCmVjaG8gLW5lICJcbkRvY2tlciB0ZXN0OiAiCmlmIGRvY2tlciB2ZQ=="
set "shell_script_content_5=cnNpb24gMj4vZGV2L251bGwgMT4mMjsgdGhlbiBlY2hvIC1lIG9rXFxuOyBlbHNlIGVjaG8gLWUgbm90IG9rXCFcIVwhXCFcIVwhXCFcIVwhXCFcIVwhXFxuOyBmaQ=="
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
