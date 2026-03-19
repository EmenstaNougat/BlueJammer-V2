<h1 align="center">BlueJammer-V2 - by @emensta</h1>
<h3 align="center">5GHz AP Remote Control via webserver, up to 4x nRF24, maximal power</h3>
<div align="center">
  
![bluejammerv2banner](https://github.com/user-attachments/assets/de74713c-8b11-4200-8282-a86c3eb6faa6)

  <h3 align="center">Jamming is ILLEGAL! Educational purposes only!</h3>
</div>

<div align="center">

<a href="https://github.com/EmenstaNougat/BlueJammer-V2" title="Go to GitHub repo">
  <img src="https://img.shields.io/static/v1?label=EmenstaNougat&message=BlueJammer-V2&color=purple&logo=github" alt="EmenstaNougat - BlueJammer-V2">
</a>
<a href="https://github.com/EmenstaNougat/BlueJammer-V2">
  <img src="https://img.shields.io/github/stars/EmenstaNougat/BlueJammer-V2?style=social" alt="stars - BlueJammer-V2">
</a>
<a href="https://github.com/EmenstaNougat/BlueJammer-V2">
  <img src="https://img.shields.io/github/forks/EmenstaNougat/BlueJammer-V2?style=social" alt="forks - BlueJammer-V2">
</a>

![Platform](https://img.shields.io/badge/platform-ESP32%20%2B%20BW16-blue)
![Closed Source](https://img.shields.io/badge/source-closed-red)
![License](https://img.shields.io/badge/license-All%20Rights%20Reserved-red)

</div>

---

## What is BlueJammer-V2?

BlueJammer-V2 is a two-board RF research platform built around the **ESP32-WROOM-32U** and the **Ai-Thinker BW16** (RTL8720DN). It is the direct successor to the original [ESP32-BlueJammer](https://github.com/EmenstaNougat/ESP32-BlueJammer), bringing a completely reworked architecture, a live 5GHz web interface, a 128x64 OLED display, a quad NRF24L01 jamming engine, and a robust UART communication layer between both boards.

> This project is **closed source** and provided as pre-compiled firmware only. The source code is not publicly available. If you purchased this device from anyone other than official sources at [emensta.pages.dev](https://emensta.pages.dev) - **you have been scammed.**

---

## Architecture

BlueJammer-V2 runs across two boards, each with a dedicated role:

| Board | Role |
|---|---|
| **ESP32-WROOM-32U** | Jamming engine, OLED display, button, LED |
| **Ai-Thinker BW16** | 5GHz WiFi AP, web interface, UART master |

They communicate over a **UART link at 115200 baud** using a lightweight protocol with handshaking, command acknowledgement, and live error detection.

---

## Features

### Jamming Engine (ESP32)
- **Up to 4x NRF24L01+ modules** running simultaneously in a dynamic round-robin hop pattern
- Modules are hot-pluggable - the probe task detects connect/disconnect every 500ms and redistributes hops automatically so 1, 2, 3, or 4 radios always run at full capacity
- **4 jamming modes:**
  - `Mode 1` - Bluetooth (2.4GHz, CH 0-78)
  - `Mode 2` - BLE (2.4GHz, CH 0-38)
  - `Mode 3` - WiFi (2.4GHz, CH 0-13)
  - `Mode 4` - RC/Drone (2.4GHz, CH 0-124)
- Dual SPI buses (HSPI + VSPI) with NRF3 sharing HSPI via separate CE/CSN
- Built to squeeze every bit of processing power out of the ESP32 - the jamming engine runs completely separately from the UI, UART, and display tasks with zero interference between them

### Web Interface (BW16)
- Hosted on a **5GHz WiFi AP** (default channel 149, configurable)
- Full real-time mode control with live status polling every 300ms
- NRF module status (R1 / R2 / R3 / R4 - OK or FAIL)
- Serial monitor built into the web UI
- Command log
- **AP Settings panel** - change SSID, password, channel, hidden mode
- **Preferences panel** - OLED I2C address, UART baud rate, boot behaviour
- **UART error overlay** - animated red notification slides in from the top if the ESP32 link drops mid-session
- 5-minute AP auto-shutdown with a 10-second countdown if no browser connects (configurable)
- Safety notice - if the AP is configured on a 2.4GHz channel, a warning banner is shown in the web UI. Jamming will still work but you will lose the web connection the moment a mode is activated since the control link operates in the same frequency space being jammed. Switch back to Idle using the physical button on the ESP32, then reconnect to regain web access. Using a 5GHz channel (default: 149) avoids this entirely.

### OLED Display (128x64)
- Boot splash screen
- Live status bar - NRF module indicators, web connection cloud icon, activity icons
- Mode screens with icon and label for each jamming mode
- Settings screen when web settings panel is open
- AP timeout countdown shown in the status bar (last 10 seconds)

### BW16 LED Feedback
The onboard RGB LED on the BW16 communicates device state visually:

| Pattern | Meaning |
|---|---|
| Slow blue breathe | Waiting for web connection |
| Mode colour solid | Active jamming mode (Blue=BT, Green=BLE, Orange=WiFi, Purple=RC) |
| Red breathe | Idle |
| Cyan breathe | Settings panel open |
| Cyan strobe | Browser just connected |
| Green/Orange/Red blink | AP 10s countdown (colour changes by urgency) |
| Rapid R+B flash | AP shutting down |
| B-B-R-R rapid flash | No ESP32 detected on UART, Distinct warning pattern |
| 3x green flash | ESP32 connected after initial link-down |

### UART Handshake Protocol
Both boards announce their presence on boot with a `SYN` message. If no response is received within 10 seconds the BW16 activates the link-down LED pattern and keeps probing. Every mode command sent includes an acknowledgement system - if no `ACK` is received within 2 seconds the web UI shows a live error notification.

---

## Hardware Requirements

### Core Components

| Component | Quantity | Notes |
|---|---|---|
| ESP32-WROOM-32 | 1 | Any module that covers the required pinout |
| Ai-Thinker BW16 | 1 | RTL8720DN, 5GHz capable |
| NRF24L01+ modules | 1-4 | With 10µF capacitor on each VCC/GND |
| SSD1306 OLED 128x64 | 1 | I2C, address 0x3C (or 0x3D, configurable) |
| Push button | 1 | Mode cycle / long press = idle |
| LED | 1 | External, connected to GPIO27 |
| Decoupling capacitors | 4 | 10µF electrolytic, one per NRF module |

### Power
- Both boards share **3.3V and GND**
- The BW16 can be powered directly from the ESP32's 3V3 rail
- NRF24L01 modules are **very sensitive to power noise** - the 10µF capacitor on each module is not optional

---

## Wiring

### ESP32 Pin Assignments

#### NRF1 - HSPI
| NRF24 Pin | ESP32 GPIO |
|---|---|
| CE | 16 |
| CSN | 15 |
| SCK | 14 |
| MOSI | 13 |
| MISO | 12 |
| VCC | 3.3V |
| GND | GND |

#### NRF2 - VSPI
| NRF24 Pin | ESP32 GPIO |
|---|---|
| CE | 22 |
| CSN | 21 |
| SCK | 18 |
| MOSI | 23 |
| MISO | 19 |
| VCC | 3.3V |
| GND | GND |

#### NRF3 - HSPI shared (same SCK/MOSI/MISO as NRF1, unique CE/CSN)
| NRF24 Pin | ESP32 GPIO |
|---|---|
| CE | 32 |
| CSN | 17 |
| SCK | 14 |
| MOSI | 13 |
| MISO | 12 |
| VCC | 3.3V |
| GND | GND |

#### NRF4 - VSPI shared (same SCK/MOSI/MISO as NRF2, unique CE/CSN)
| NRF24 Pin | ESP32 GPIO |
|---|---|
| CE | 25 |
| CSN | 2 |
| SCK | 18 |
| MOSI | 23 |
| MISO | 19 |
| VCC | 3.3V |
| GND | GND |

#### OLED (I2C)
| OLED Pin | ESP32 GPIO |
|---|---|
| SDA | 4 |
| SCL | 5 |
| VCC | 3.3V |
| GND | GND |

#### UI
| Component | ESP32 GPIO |
|---|---|
| Button | GPIO0 → GND |
| LED | GPIO27 |

#### UART to BW16
| Signal | ESP32 GPIO | BW16 Pin |
|---|---|---|
| RX | GPIO26 | PB1 (TX) |
| TX | GPIO33 | PB2 (RX) |
| GND | GND | GND |
| 3V3 | 3V3 | 3V3 |

> **Note:** Cross the TX/RX lines. ESP32 TX → BW16 RX and ESP32 RX → BW16 TX.

---

## Flashing

Pre-compiled firmware is included in the `Firmware-Flasher_USE_THIS` folder. A ready-to-run batch flasher is included for Windows.

### What you need
All files must be in the **same folder**:

**ESP32:**
- `BlueJammer-V2.ino.bin`
- `BlueJammer-V2.ino.bootloader.bin`
- `BlueJammer-V2.ino.partitions.bin`
- `esptool.exe`

**BW16:**
- `km0_boot_all.bin`
- `km4_boot_all.bin`
- `km0_km4_image2.bin`
- `amebatool.exe`
- `imgtool_flashloader_amebad.bin`

### Flashing ESP32
1. Connect ESP32 via USB
2. Run `BlueJammer-V2-Flasher_RUN_THIS.bat`
3. Select your COM port
4. Choose `1` for ESP32
5. The flasher handles everything automatically

### Flashing BW16
1. Put BW16 into **download mode:**
   - Hold the **BURN** button
   - Press and release **RST**
   - Release **BURN**
2. Run `BlueJammer-V2-Flasher_RUN_THIS.bat`
3. Select your COM port
4. Choose `2` for BW16
5. Press any key when ready

---

## First Boot

1. Flash both boards
2. Power on the ESP32 first, then the BW16 (or both simultaneously)
3. The BW16 creates a **5GHz WiFi AP:**
   - **SSID:** `BlueJ-V2_by_@emensta`
   - **Password:** `NoConn1337`
4. Connect to the AP and open `http://192.168.1.1`
5. The OLED on the ESP32 shows the current mode and radio status
6. The BW16 RGB LED confirms connection state

> The AP auto-shuts down after **5 minutes** if no browser connects. A 10-second countdown is shown on the OLED before shutdown. This can be adjusted in the firmware.

---

## Web Interface Usage

Once connected to the AP:

- **Mode buttons** - select Bluetooth, BLE, WiFi, RC, or Idle
- **NRF status** - shows which of the 4 modules are detected and operational
- **Serial monitor** - live output from the ESP32 over UART
- **Command log** - history of mode changes sent from the browser
- **Settings (gear icon)** - AP SSID, password, channel, and preferences
- **UART error overlay** - appears if the ESP32 link drops, with a dismiss button

---

## Troubleshooting

**OLED not turning on**
- Check SDA/SCL wiring (GPIO4/5)
- Verify I2C address - default is 0x3C, some displays use 0x3D (adjustable in web preferences)
- `uiTask` stack was increased to 8192 bytes - if you modify the display code ensure it stays sufficient

**NRF modules showing FAIL**
- Check wiring and the 10µF decoupling capacitor
- Modules are detected live every 500ms - they will appear as soon as connected
- All 4 modules are managed independently - NRF1 and NRF3 share HSPI, NRF2 and NRF4 share VSPI, each with unique CE and CSN pins

**BW16 not connecting to UART**
- Verify TX/RX are crossed correctly
- ESP32 UART: GPIO26 (RX) ← BW16 PB1, GPIO33 (TX) → BW16 PB2
- Both boards share GND - this is required
- The BW16 will show a distinct warning LED pattern if no ESP32 is detected within 10 seconds of boot

**Web interface not loading**
- Confirm you are connected to the BW16's AP (5GHz capable device required)
- Default AP: `BlueJ-V2_by_@emensta` / `NoConn1337`
- Navigate to `http://192.168.1.1`
- The AP shuts down after 5 minutes if no browser connects - reset the BW16 to restart the window

**BW16 serial disconnects after AP starts**
- This is a known AmebaD SDK behaviour - the WiFi driver briefly resets the UART peripheral during `apbegin()`. The firmware calls `Serial.begin()` again immediately after to restore the connection. Close and reopen the serial monitor if needed.

---

## Discord
You can join my Discord server [here](https://discord.gg/emensta)!

## Portfolio and all my links
Here you can visit my Portfolio, you'll find everything that you're looking for [here](https://emensta.pages.dev)!

## Support me
Via [this link](https://ko-fi.com/emensta), you can leave a tip to keep me motivated developing future projects! Thank you for your support :)

---

<h1 align="center">DISCLAIMER</h1>

<h4 align="center">
The use of this tool is entirely at your own risk. It is intended strictly for educational and research purposes and must not be used for any illegal or unethical activities. Jamming radio frequencies is illegal in most jurisdictions and can result in significant legal consequences including fines and imprisonment.
</h4>

<h4 align="center">
Interfering with radio communications is a federal offense in many countries. Do not use this device in public, near critical infrastructure, or in any situation where it could cause harm or disrupt legitimate communications.
</h4>

<h4 align="center">
I am not responsible for your actions. By using this project you acknowledge that you understand the legal implications and take full responsibility for any consequences.
</h4>
