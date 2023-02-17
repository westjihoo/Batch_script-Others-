@echo off
@setlocal EnableDelayedExpansion
@color 3f
@title USB UPDATE

:VERSION_CHECK
@set UPDATE_SERVER_IP=10.10.10.10 :: 파일서버 IP
@set S_PATH=LINE\PATCHES :: 파일서버 경로
@set USB_C_VERSION=
@set USB_S_VERSION=

pushd %~p0
cd ..
@set /p USB_C_VERSION=<"HANSUNG_WINDOWS_USB_Version.txt" :: USB로컬 버전정보 로드

@net use v: "\\%UPDATE_SERVER_IP%\%S_PATH%" /user:admin admin :: 네트워크 자격 증명 정보
@set /p USB_S_VERSION=<"\\%UPDATE_SERVER_IP%\%S_PATH%\HANSUNG_WINDOWS_USB_Version.txt" :: 서버 버전정보 로드
@net use v: /delete /y

@echo.
@echo 서버 USB 버전 : %USB_S_VERSION%
@echo 현재 USB 버전 : %USB_C_VERSION%
@echo.

if %USB_C_VERSION%==%USB_S_VERSION% (
	goto END
)

:UPDATE
@title USB UPDATE @ 진행중
@color 6f

@for %%i in (C D E F G H I J K L M N O P Q R S T U W X Y Z) do (
	@if exist %%i:\WINDOWS_NB_BIOS_TEST_USB.data (

		@timeout /t 2

		@net use v: "\\%UPDATE_SERVER_IP%\%S_PATH%" /user:factory todtks01
		xcopy "\\%UPDATE_SERVER_IP%\%S_PATH%\생산USB_UPDATE.bat" %%i:\생산USB_UPDATE.bat /y
		xcopy "\\%UPDATE_SERVER_IP%\%S_PATH%\WINDOWS_USB_Version.txt" %%i:\HANSUNG_WINDOWS_USB_Version.txt /y
		xcopy "\\%UPDATE_SERVER_IP%\%S_PATH%\_version.nsh" %%i:\_version.nsh /y
		xcopy "\\%UPDATE_SERVER_IP%\%S_PATH%\_production.nsh" %%i:\_production.nsh /y

		@mkdir %%i:\TEST > NUL
		@mkdir %%i:\BIOS > NUL
		@mkdir %%i:\EFI > NUL
		@robocopy "\\%UPDATE_SERVER_IP%\%S_PATH%\EFI" %%i:\EFI /COPY:DAT /MIR /DCOPY:DAT /R:1 /W:1
		@robocopy "\\%UPDATE_SERVER_IP%\%S_PATH%\BIOS" %%i:\BIOS /COPY:DAT /MIR /DCOPY:DAT /R:1 /W:1
		@robocopy "\\%UPDATE_SERVER_IP%\%S_PATH%\TEST" %%i:\TEST /COPY:DAT /MIR /DCOPY:DAT /R:1 /W:1
		@timeout /t 2
		@net use v: /delete /y
		@timeout /t 1
		goto END
	)
)


:END
@title USB UPDATE @ 업데이트 완료
@echo.
@echo ### USB UPDATE 완료 ###

 :--------------------------------------------------------------
if not (%FROM_TEST_TOOL%==1) (
@set FROM_TEST_TOOL=0
)
 :--------------------------------------------------------------
if %FROM_TEST_TOOL%==1 (
@echo TEST TOOL을 다시 실행하세요.
@echo.
)

@pause
exit