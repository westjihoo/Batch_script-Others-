::■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
::■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
:: 필요한 windows console 기능들은 ftp 통신으로 NAS파일서버에서 다운로드함 [ wget, devcon, 기타파일 등 ]
:: WMIC과 DEVCON을 활용하여 시스템정보를 txt파일로 추출
:: 추출된 txt파일을 for문으로 한 줄씩 반복하며 진행되고, 기준이 되는 문자(&, =)로 다시 분리됨
:: (A-Type은 XML / B-type은 XML태그+가공)로 XML 또는 변수에 저장됨
::
:: 위에서 최종적으로 정리된 값을 WGET 콘솔기능으로 서버에 REQUEST를 함
:: POST / GET 방식으로 전송할 수 있으며, POST로 진행했음
:: post-data와 post-file을 동시에 지정하는건 불가능.
::  ==> A-Type을 포기한 이유. SerialNumber와 HARDWAREXML의 Value를 각각 String, File로 전송하기엔 무리였음.
::  ==> 문자열로 전송하기 위해 XML로 추출했던 정보를 String변수에 담았고, 특수문자 처리를 위해 set "변수명=값"의 형태로 선언함.
::  ==> 개발팀 요청으로 전송하는 정보 재가공했음 [ <p n="CPU" v="Intel ~~~ "/> ]
::■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
::■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■



@echo off
Setlocal EnableDelayedExpansion :: for문 안에서 !변수!를 사용하기 위해 추가함


::■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
::■■■■■■■■■■■■■■■■■■■■ A TYPE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

::set list_device=CPU MB RAM STORAGE GPU
set list_device=CPU RAM STORAGE GPU
set div=0
set /a cnt=0
set check_start=0
set vendor=UNKNOWN

:::::::: GET /d get_systeminfo FROM NAS-STORAGE VIA FTP ::::::::
if not exist header.txt (
	echo [account]>script.txt
	echo [password]>>script.txt
	echo bin>>script.txt
	echo mget get_systeminfo/*>>script.txt xml tag files 
	echo get shutdown.exe>>script.txt
	echo quit>>script.txt
	ftp -i /s:script.txt %IP% > nul
)

:GET_SYSINFO_A-type
WMIC CPU GET Name, Status /FORMAT:LIST>systeminfo_CPU.txt
WMIC BASEBOARD GET Manufacturer, Product, SerialNumber, Version /FORMAT:LIST>systeminfo_MB.txt
WMIC MEMORYCHIP GET Devicelocator, Capacity, Speed /FORMAT:LIST>systeminfo_RAM.txt
WMIC DISKDRIVE GET Model, Size, Status /FORMAT:LIST>systeminfo_STORAGE.txt
x:\driver\devcon.exe findall * | find "VGA">systeminfo_GPU.txt
x:\driver\devcon.exe findall * | find ": 3D">>systeminfo_GPU.txt

:MAKE_REPORT_XML_A-type
if exist "report.txt" del "report.txt"
if exist "report.xml" del "report.xml"

@type "header.txt" > "report.txt"

for %%d in (%list_device%) do (

:::::::::::::::::: Reset ::::::::::::::::::

	set div=0
	set /a cnt=0
	set check_start=0

	if "%%d"=="GPU" (
		for /f "tokens=1,2,3,4 delims=:&" %%i in ('type systeminfo_GPU.txt') do (
			
			if "%%i"=="PCI\VEN_8086" (
				set vendor=INTEL
			)
			if "%%i"=="PCI\VEN_10DE" (
				set vendor=NVIDIA
			)
			if "%%i"=="PCI\VEN_1002" (
				set vendor=AMD
			)
			
			@type "header2.txt" >> "report.txt"
			@echo %%d!cnt! >> "report.txt"
			@echo HWID="%%i&amp;%%j&amp;%%k(!vendor!)">> "report.txt"
			@type "header2_close.txt" >> "report.txt"
			set /a cnt=!cnt!+1
		)
	) else (
		@type "header2.txt" >> "report.txt"
		@echo %%d!cnt! >> "report.txt"
		for /f "tokens=1,2 delims==" %%i in ('type systeminfo_%%d.txt') do (
			if "!check_start!"=="0" (
				set check_start=1
				set div=%%i
			) else if "!div!"=="%%i" (
				set /a cnt=!cnt!+1
				@type "header2_close.txt" >> "report.txt"
				@type "header2.txt" >> "report.txt"
				@echo %%d!cnt! >> "report.txt"
			)
			@echo %%i="%%j">> "report.txt"
		)
		@type "header2_close.txt" >> "report.txt"
	)
)
@type "header_close.txt" >> "report.txt"
notepad.exe report.txt
pause


::■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
::■■■■■■■■■■■■■■■■■■■■ B TYPE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

:GET_SYSINFO_B-type
WMIC CPU GET Name /FORMAT:LIST>systeminfo_CPU.txt
WMIC MEMORYCHIP GET Capacity /FORMAT:LIST>systeminfo_RAM.txt
WMIC DISKDRIVE GET Model /FORMAT:LIST>systeminfo_STORAGE.txt
x:\driver\devcon.exe findall * | find "VGA">systeminfo_GPU.txt
x:\driver\devcon.exe findall * | find ": 3D">>systeminfo_GPU.txt


:MAKE_REPORT_STRING_B-type
set "sys_info=<?xml version="1.0"?><Specification>"

for %%d in (%list_device%) do (
	
	set div=0
	set /a cnt=0
	set check_start=0
	
	if "%%d"=="GPU" (
		for /f "tokens=1,2,3,4 delims=:&" %%i in ('type systeminfo_GPU.txt') do (
			
			if "%%i"=="PCI\VEN_8086" (
				set vendor=INTEL
			)
			if "%%i"=="PCI\VEN_10DE" (
				set vendor=NVIDIA
			)
			if "%%i"=="PCI\VEN_1002" (
				set vendor=AMD
			)
			
			set "sys_info=!sys_info! <"
			set "sys_info=!sys_info!%%d!cnt! "
			set "sys_info=!sys_info!%%i&%%j&%%k(!vendor!)"
			set "sys_info=!sys_info!/>"
			set /a cnt=!cnt!+1
		)
	) else (
		set "sys_info=!sys_info!<"
		
		for /f "tokens=1,2 delims==" %%i in ('type systeminfo_%%d.txt') do (
			if "!check_start!"=="0" (
				set check_start=1
				set div=%%i
			) else if "!div!"=="%%i" (
				set /a cnt=!cnt!+1
				set "sys_info=!sys_info!/>"
				set "sys_info=!sys_info! <"
				set "sys_info=!sys_info!%%d!cnt! "
			)
			set "sys_info=!sys_info!%%i="%%j" "
		)
		set "sys_info=!sys_info!/>"
	)
)
set "sys_info=!sys_info!</Specification>"
set sys_info=!sys_info: =^^!
echo !sys_info!
pause




::■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
::■■■■■■■■■■■■■■■■■■■■ 공통구간(REQUEST) ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

:: HTTP POST With content-type: application/x-www-form-urlencoded
wget --method=POST --no-check-certificate --output-document=return.txt "https://url.php" --header="content-type: application/x-www-form-urlencoded" --body-data="SerialNumber=%serial_num%&HARDWAREXML=!sys_info!"

if "%wms_return%" EQU "1" (
	color 60
	cls
	title [ SN# %serial_num% ] Delete
	@echo.
	@echo [Serial]: %serial_num%
	@echo.
	@echo [SYS] Serial 정보 확인 완료   # %serial_num%
	@echo.
	@echo [SYS] 시스템 정보 전송 완료
	@echo.
	@echo [SYS] 디스크 정보 확인 중 ...
	@echo.
	goto DELETE
)

if "%wms_return%" EQU "NO" (
	color C0
	cls
	@echo.
	@echo [Serial]: %serial_num%
	@echo.
	@echo [SYS] ERR : 확인되지 않은 Serial
	@echo [SYS] ERR : 확인되지 않은 Serial
	@echo [SYS] ERR : 확인되지 않은 Serial
	@echo.
	@echo 아무 키나 눌러 돌아가십시오.
	pause > nul
	cls
	goto FIRMWARE
)

if "%wms_return%" EQU "ERR" (
	color C0
	cls
	title [TOOL] ### ERROR : PLEASE REBOOT
	@echo.
	@echo [Serial]: %serial_num%
	@echo.
	@echo [SYS] ERR : 시스템 정보 관련 오류
	@echo [SYS] ERR : 시스템 정보 관련 오류
	@echo [SYS] ERR : 시스템 정보 관련 오류
	@echo.
	@echo [SYS] 시스템 재부팅 및 재시도 하십시오.
	@echo.
	pause > nul
	cls
	goto FIRMWARE
)

if "%wms_return%" EQU "default" (
	color C0
	cls
	title [TOOL] ### ERROR : PLEASE REBOOT
	@echo.
	@echo [Serial]: %serial_num%
	@echo.
	@echo [SYS] ERR : 서버 통신 오류
	@echo [SYS] ERR : 서버 통신 오류
	@echo [SYS] ERR : 서버 통신 오류
	@echo.
	@echo [SYS] 시스템 재부팅 및 재시도 하십시오.
	@echo.
	pause > nul
	cls
	goto FIRMWARE
)