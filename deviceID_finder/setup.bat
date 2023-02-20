@echo off
cd /d "%~dp0"
Devcon.exe find *>"%temp%\hansung_dev_temp_drv_install.txt"

find "PCI\VEN_10EC&DEV_522A" "%temp%\hansung_dev_temp_drv_install.txt">nul
if %ERRORLEVEL% EQU 0 (
	echo Realtek Card Reader
	cd Realtek
	setup.exe
	goto END
)

find "PCI\VEN_1217&DEV_8621" "%temp%\hansung_dev_temp_drv_install.txt">nul
if %ERRORLEVEL% EQU 0 (
	echo Bayhub Card Reader
	cd Bayhub
	setup.exe
	goto END
)

find "PCI\VEN_10EC^&DEV_522A" "%temp%\hansung_dev_temp_drv_install.txt">nul
if %ERRORLEVEL% EQU 0 (
	echo Realtek Card Reader
	cd Realtek
	setup.exe
	goto END
)

find "PCI\VEN_1217^&DEV_8621" "%temp%\hansung_dev_temp_drv_install.txt">nul
if %ERRORLEVEL% EQU 0 (
	echo Bayhub Card Reader
	cd Bayhub
	setup.exe
	goto END
) else (
	echo 지원되는 장치가 없습니다
)

:END
del "%temp%\hansung_dev_temp_drv_install.txt"
::pause