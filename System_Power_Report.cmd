@echo off

set uaccheck=0

:CheckUAC
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' ( goto UACAccess ) else ( goto DEPLOY )

:UACAccess
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac_get_admin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\uac_get_admin.vbs"
"%temp%\uac_get_admin.vbs"
del "%temp%\uac_get_admin.vbs"
exit /b


:DEPLOY

:: 날짜 문자열을 년월일로 분해
set YEAR=%date:~0,4%
set MONTH=%date:~5,2%
set DAY=%date:~8,2%

:: 시간 문자열을 시분초로 분리
set H=%time:~0,2%
set MIN=%time:~3,2%
set SEC=%time:~6,2%

pushd %~dp0

powercfg /sleepstudy /output SleepStudy_%YEAR%%MONTH%%DAY%-%H%.%MIN%.%SEC%.html

pause