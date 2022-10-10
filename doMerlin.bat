@echo off
if %errorlevel% neq 0 exit /b %errorlevel%
echo --------------- Variables ---------------
Set PRG=a230th
Set ProjectFolder=.

Set MyAppleFolder=F:\Bruno\Dev\AppleWin
Set APPLEWIN=%MyAppleFolder%\AppleWin\Applewin.exe
Set MERLIN32ROOT=%MyAppleFolder%\Merlin32_v1.0
Set MERLIN32LIBS=%MERLIN32ROOT%\Library
Set MERLIN32WIN=%MERLIN32ROOT%\Windows
Set MERLIN32EXE=%MERLIN32WIN%\merlin32.exe
Set APPLECOMMANDER=%MyAppleFolder%\Utilitaires\AppleCommander-win64-1.6.0.jar
Set ACJAR=java.exe -jar %APPLECOMMANDER%

echo --------------- debut Merlin ---------------
%MERLIN32EXE% -V %MERLIN32LIBS% %ProjectFolder%\%PRG%.s
if exist %ProjectFolder%\error_output.txt exit
echo --------------- fin Merlin ---------------

copy /Y %ProjectFolder%\A.po %ProjectFolder%\%PRG%.po

echo --------------- Debut Applecommander ---------------
rem add binary program to image disk
%ACJAR% -p %PRG%.po a bin 32768 < %PRG%

echo ----------- fin Applecommander ---------------
echo --------------- Debut Applewin ---------------
%APPLEWIN% -d1 %PRG%.po
echo --------------- Fin Applewin ---------------
