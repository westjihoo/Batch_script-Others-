@echo off

set uaccheck=0

:CheckUAC
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' ( goto UACAccess ) else ( goto START )

:UACAccess
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac_get_admin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\uac_get_admin.vbs"
"%temp%\uac_get_admin.vbs"
del "%temp%\uac_get_admin.vbs"
exit /b


:START
@echo off
:: HOTFIX_WindowsDefender_Set_Exclude_folder
@for %%i in (C D E F G H I J K L M N O P Q R S T U W X Y Z) do (
	@if exist %%i:\HANSUNG_WINDOWS_INJECT_USB.data (
		if not exist "%%i:\Delete_WD_Exclude.cmd" (
			echo noDelWD>%%i:\HANSUNG_WINDOWS_client_version.txt
		)
		@echo Start %%i!
		@powershell -inputformat none -outputformat none -NonInteractive -Command Add-MpPreference -ExclusionPath "%%i"
		@powershell -inputformat none -outputformat none -NonInteractive -Command Add-MpPreference -ExclusionPath "C:\OATools"
		@powershell -inputformat none -outputformat none -NonInteractive -Command Add-MpPreference -ExclusionPath "%temp%\hansung"
		timeout /t 1
		xcopy /Y "%%i:\Delete_WD_Exclude.cmd" "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup\Delete_WD_Exclude.c*"
	)
)
