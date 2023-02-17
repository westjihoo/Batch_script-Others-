

:: DETERMINE Location C OR M
@set DONOTMDA=0
@set NOCONNECT=0
@set LOCATION=N
@set LOCATION_DETAIL=N
@set HOME_DIR=%temp%\loccheck

@rmdir /s /q "%HOME_DIR%">nul
@mkdir "%HOME_DIR%">nul
@cd /d "%HOME_DIR%"

set ERROR_IP1=N
set ERROR_IP2=N
set ERROR_IP3=N

:: LAN check    ===============================================
:: %ERRORLEVEL% : 0 => LAN connected
:: %ERRORLEVEL% : 1 => No LAN
@ping 8.8.8.8 -n 1 -w 2000> nul
@if %ERRORLEVEL% == 0 set NOCONNECT=0
@if %ERRORLEVEL% == 1 set NOCONNECT=1
@if %ERRORLEVEL% == 1 set ERROR_IP1=8.8.8.8

@if "%ERROR_IP1%" EQU "8.8.8.8" do (
	@ping 1.1.1.1 -n 1 -w 2000> nul
	@if %ERRORLEVEL% == 0 set NOCONNECT=0
	@if %ERRORLEVEL% == 1 set NOCONNECT=1
	@if %ERRORLEVEL% == 1 set ERROR_IP1=1.1.1.1
)

:: ============================================================

:: Location check-1  ==========================================
:: %ERRORLEVEL% : 0 => Magok
:: %ERRORLEVEL% : 1 => Cheongna
@ping 10.10.10.11 -n 1 -w 2000> nul
@if %ERRORLEVEL% == 0 set LOCATION=M
@if %ERRORLEVEL% == 1 set LOCATION=C
@if %ERRORLEVEL% == 1 set ERROR_IP2=10.10.10.11

:: ============================================================

:: Location check-2   =========================================
:: %ERRORLEVEL% : 0 => Assembly line
:: %ERRORLEVEL% : 1 => Office
@ping 192.168.20.1 -n 1 -w 2000> nul
@if %ERRORLEVEL% == 0 set LOCATION_DETAIL=LINE
@if %ERRORLEVEL% == 1 set LOCATION_DETAIL=OFFICE
@if %ERRORLEVEL% == 1 set ERROR_IP3=192.168.20.1

:: ============================================================



:: 랜 연결 N
@if "%NOCONNECT%"=="1" goto END2

:: 랜 연결 Y
@if %NOCONNECT%==0 (
	:: LOCATION [ M ]
	if "%LOCATION%"=="M" (
		:: 사무
		if "%LOCATION_DETAIL%"=="OFFICE" (
			set DONOTMDA=1
			set UPDATE_SERVER_IP=10.10.10.11
			goto CHECK_UPDATE
		)
		:: 생산
		if "%LOCATION_DETAIL%"=="LINE" (
			set UPDATE_SERVER_IP=192.168.20.233
			goto CHECK_UPDATE
		)
	)

	:: LOCATION [ C ]
	if "%LOCATION%"=="C" (
		if "%LOCATION_DETAIL%"=="LINE" (
			set UPDATE_SERVER_IP=192.168.20.233
			goto CHECK_UPDATE
		)
	)
)
