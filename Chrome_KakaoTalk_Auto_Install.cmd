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

echo.
echo ################ INSTALL APPs ################
echo.

:install_chrome
echo.
echo # Google Chrome
echo.
powershell -command (new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', $env:TEMP+'\chrome.exe'); & start %temp%\chrome.exe

timeout /t 3

:install_kakaotalk
echo.
echo # Step1. Download Kakao Talk installer
echo.
start /wait powershell -Command "Invoke-WebRequest https://app-pc.kakaocdn.net/talk/win32/KakaoTalk_Setup.exe -OutFile %temp%\KakaoTalk_Setup.exe"

echo.
echo # Step2. Kakao Talk Install
echo.
start %temp%\KakaoTalk_Setup.exe /s /q

timeout /t 3

echo.
echo.
echo ################ FINISH ################
