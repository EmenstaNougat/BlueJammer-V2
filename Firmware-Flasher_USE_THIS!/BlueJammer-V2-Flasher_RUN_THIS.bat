@echo off
title BlueJammer-V2 Flasher

echo  ============================================
echo   BlueJammer-V2 Flasher  -  by @emensta
echo  ============================================
echo.

echo Available COM ports:
for /f "tokens=3 delims= " %%a in ('reg query "HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM"') do (
    echo %%a
)

set /p com_port=Enter COM port (e.g. COM4): 

echo Select target device:
echo 1. ESP32   (BlueJammer-V2 main board)
echo 2. BW16    (5GHz WiFi controller)
set /p choice=1 or 2: 

if "%choice%"=="1" (
    echo Flashing ESP32 on %com_port%...
    esptool.exe --chip esp32 --port %com_port% --baud 921600 write_flash 0x1000 BlueJammer-V2.ino.bootloader.bin 0x8000 BlueJammer-V2.ino.partitions.bin 0x10000 BlueJammer-V2.ino.bin
) else if "%choice%"=="2" (
    echo Put BW16 in download mode: hold BURN, press+release RST, release BURN
    pause
    echo Flashing BW16 on %com_port%...
    amebatool.exe . %com_port% --verbose=5
) else (
    echo Invalid selection.
)

pause