@echo off

set uaccheck=0

:CheckUAC
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' ( goto UACAccess ) else ( goto INSTALL )

:UACAccess
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac_get_admin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\uac_get_admin.vbs"
"%temp%\uac_get_admin.vbs"
del "%temp%\uac_get_admin.vbs"
exit /b


:INSTALL
pushd %~dp0
cls
@echo ===============================================================
@echo □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
@echo □■■■□□■□□□□■□□■■■■□□■■■■■□□□□■□□□□■□□□□□■□□□□□
@echo □□■□□□■■□□□■□■□□□□□□□□■□□□□□■□■□□□■□□□□□■□□□□□
@echo □□■□□□■■□□□■□■□□□□□□□□■□□□□□■□■□□□■□□□□□■□□□□□
@echo □□■□□□■□■□□■□■□□□□□□□□■□□□□□■□■□□□■□□□□□■□□□□□
@echo □□■□□□■□■□□■□□■■■■□□□□■□□□□■□□□■□□■□□□□□■□□□□□
@echo □□■□□□■□□■□■□□□□□□■□□□■□□□□■■■■■□□■□□□□□■□□□□□
@echo □□■□□□■□□■□■□□□□□□■□□□■□□□□■□□□■□□■□□□□□■□□□□□
@echo □□■□□□■□□□■■□□□□□□■□□□■□□□■□□□□□■□■□□□□□■□□□□□
@echo □□■□□□■□□□■■□□□□□□■□□□■□□□■□□□□□■□■□□□□□■□□□□□
@echo □■■■□□■□□□□■□■■■■■□□□□■□□□■□□□□□■□■■■■■□■■■■■□
@echo □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
@echo ===============================================================
@echo  해당 제품에 VBIOS를 설치합니다.
@echo  번호를 선택하세요.
@echo  ( 종료 = q )
@echo ===============================================================
@echo.

@dir /b *.rom
@echo.

set /p model=[ROM 파일명을 입력하세요.] : 
if "%model%" EQU "q" goto END
if "%model%" EQU "Q" goto END
if "%model%" EQU "" goto INSTALL
if not exist %model% goto INSTALL

:INSTALL2
@echo ===============================================================
@echo  아래 파일로 업데이트 하시겠습니까.
@echo  File Name : %model%
@echo  [ Y / N / 종료 Q ]
@echo ===============================================================
@echo.

set /p check=[ Y / N ] : 

if "%check%" EQU "y" goto FLASH
if "%check%" EQU "Y" goto FLASH
if "%check%" EQU "n" goto INSTALL
if "%check%" EQU "N" goto INSTALL
if "%check%" EQU "q" goto END
if "%check%" EQU "Q" goto END
goto INSTALL2

:FLASH
nvflash64.exe %model%

@echo ===============================================================
@echo  업데이트가 완료되었습니다.
@echo  File Name : %model%
@echo ===============================================================
:END
pause