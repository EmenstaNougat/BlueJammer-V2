@echo off
setlocal
title BlueJammer-V2 Flasher

echo  ============================================
echo   BlueJammer-V2 Flasher  -  by @emensta
echo  ============================================
echo.

echo [CHECK] Verifying requirements...
set missing=0
if not exist esptool.exe (echo [MISSING] esptool.exe & set missing=1)
if not exist BlueJammer-V2.ino.bootloader.bin (echo [MISSING] BlueJammer-V2.ino.bootloader.bin & set missing=1)
if not exist BlueJammer-V2.ino.partitions.bin (echo [MISSING] BlueJammer-V2.ino.partitions.bin & set missing=1)
if not exist BlueJammer-V2.ino.bin (echo [MISSING] BlueJammer-V2.ino.bin & set missing=1)
if %missing%==1 (echo Fix missing files and retry. & pause & exit /b 1)
echo [OK] All ESP32 files present.
if not exist amebatool.exe echo [NOTE] amebatool.exe missing - BW16 flash will fail.
echo.

echo Available COM ports:
for /f "tokens=3 delims= " %%a in ('reg query "HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM" 2^>nul') do echo %%a
set /p com_port=Enter COM port (e.g. COM4 or 4): 
if "%com_port%"=="" goto no_com
:: Normalize: allow 13, COM13, com13 -> COM13
echo %com_port% | findstr /I /R "^COM[0-9][0-9]*$" >nul
if %errorlevel%==0 goto com_ok
echo %com_port% | findstr /R "^[0-9][0-9]*$" >nul
if %errorlevel%==0 set com_port=COM%com_port% & goto com_ok
:: assume already COMx with wrong case, upper it via powershell
for /f "delims=" %%c in ('powershell -Command "$p='%com_port%'; $p=$p.ToUpper(); if($p -match '^[0-9]+$'){ $p='COM'+$p }; Write-Output $p"') do set com_port=%%c
:com_ok

echo Select target device:
echo 1. ESP32   (BlueJammer-V2 main board)
echo 2. BW16    (5GHz WiFi controller)
set /p choice=1 or 2: 
if "%choice%"=="1" goto esp32
if "%choice%"=="2" goto bw16
echo Invalid selection.
pause
exit /b 1

:no_com
echo No COM port given.
pause
exit /b 1

:esp32
echo Flashing ESP32 on %com_port% (official)...
esptool.exe --chip esp32 --port %com_port% --baud 921600 write_flash --force 0x1000 BlueJammer-V2.ino.bootloader.bin 0x8000 BlueJammer-V2.ino.partitions.bin 0x10000 BlueJammer-V2.ino.bin
if errorlevel 1 (echo [ERROR] esptool failed. Check COM port and wiring. & pause & exit /b 1)
echo.
echo Done.
goto end

:bw16
echo Put BW16 in download mode: hold BURN, press+release RST, release BURN
pause
if not exist amebatool.exe (echo [ERROR] amebatool.exe missing. & pause & exit /b 1)
amebatool.exe . %com_port% --verbose=5
goto end

:end
pause
