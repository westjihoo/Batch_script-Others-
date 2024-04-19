@echo off

set uaccheck=0

:CheckUAC
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' ( goto UACAccess ) else ( goto expert )

:UACAccess
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac_get_admin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\uac_get_admin.vbs"
"%temp%\uac_get_admin.vbs"
del "%temp%\uac_get_admin.vbs"
exit /b


:expert
pushd %~dp0
:: 날짜 문자열을 년월일로 분해
set YEAR=%date:~0,4%
set MONTH=%date:~5,2%
set DAY=%date:~8,2%
cls
@echo.
@echo □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
@echo □□■■■■■□□■□□□■□□■■■■□□□■■■■■□□■■■■□□□■■■■■□□
@echo □□■□□□□□□■□□□■□□■□□□■□□■□□□□□□■□□□■□□□□■□□□□
@echo □□■□□□□□□□■□■□□□■□□□■□□■□□□□□□■□□□■□□□□■□□□□
@echo □□■■■□□□□□□■□□□□■■■■□□□■■■□□□□■■■■□□□□□■□□□□
@echo □□■□□□□□□□■□■□□□■□□□□□□■□□□□□□■□□□■□□□□■□□□□
@echo □□■□□□□□□■□□□■□□■□□□□□□■□□□□□□■□□□■□□□□■□□□□
@echo □□■■■■■□□■□□□■□□■□□□□□□■■■■■□□■□□□■□□□□■□□□□
@echo □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
@echo.
@echo  현재 위치의 ROM 리스트입니다.
@echo  파일명 중복에 유의하세요.
@echo.
@dir /b *.rom
@echo.
@echo ===============================================================
@echo  실행 제품의 VBIOS 를 저장합니다.
@echo ===============================================================
@echo.


@if exist version.txt del version.txt
@if exist temp.txt del temp.txt

set /p model=[모델명을 입력하세요.] : 

nvflash64.exe --save %model%_VBIOS.rom

ren %model%_VBIOS.rom %model%_VBIOS_%YEAR%%MONTH%%DAY%.rom

@echo ===============================================================
@echo  저장이 완료되었습니다.
@echo  File Name : %model%_VBIOS_%YEAR%%MONTH%%DAY%.rom
@echo ===============================================================
pause