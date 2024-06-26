<div id="summary" align="center">
</div>

<br/>

<img src="images/tinyllama2_pcb_top.png" title="The TinyLlama board, assembled" width=50% align="right" />
<br/>

This is an expansion of the TinyLlama v2 board created by Eivind Bohler. It combines aspects of the ITX llama as well but in a 100mm x 100mm form factor.

- A fully-fledged 486/Pentium-class PC in a small form factor
- Integrated Sound Blaster Pro-compatible audio using the crystal CS4237b sound chip
- Onboard fan controller for optional CPU or case fan support
- Hard drive clicker and system LED on-board with breakout header for installing in a custom case.
- Support for external OPL3 module from the ITX llama.
- Integrated PCM5102 module
- S/PDIF port for digital audio output
- Ethernet port for 10/100 ethernet capability
- Relocated ESP8266 module for use as dial-up modem emulator or wireless network connectivity.
- Add a Raspberry Pi Zero 2 for Roland MT&#8209;32 and General MIDI music
- Open-source hardware schematics, board layout and BIOS - build your own!


## Table of Contents
- [Summary](#summary)
- [Project Goals](#project-goals)
- [What's New In Version 2?](#whats-new-in-version-2)
- [Full system specs](#full-system-specs-revision-21)
- [Building](#building)
  * [Sourcing Parts](#sourcing-parts)
  * [Assembly](#assembly)
  * [Programming the CH559](#programming-the-ch559)
  * [Programming the BIOS](#programming-the-bios)
  * [Installing DOS](#installing-dos)
  * [Programming the CS4237B Firmware](#programming-the-cs4237b-firmware)
- [MT-32 / General MIDI](#mt-32--general-midi)
- [WiFi Connectivity](#wifi-connectivity)
- [Wiki](#wiki)
- [Help](#help)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgements](#acknowledgments)

<br/>

## Project Goals
I'm learning how to build these types of boards and decided to use a project I've built in the past and that I'm familiar with as a starting point.
The biggest goal I have for this project is to learn enough to begin designing my own circuits. In this case, I am relying on circuits that already exist
but my hope is that my next project will be a scratch-built device that doesn't require any use of pre-existing projects.

<p>
  <img src=images/tinyllama2_pcb_bottom.png title="TinyLlama" width=50%>
</p>

Both the CH559 and the ESP8266 can be easily re-flashed/programmed in-place.  
Look at [Programming the CH559](#programming-the-ch559) and [Programming the ESP8266][wiki-wifi].

## Full system specs (revision 0.1)
### Hardware
- **86Duino System-on-module**
  * Vortex86EX CPU running at 60-500 MHz
  * 16 KB L1 cache (can be disabled)
  * 128 KB L2 cache
  * 128 MB DDR3 RAM
  * 8 MB programmable flash ROM
- **Vortex86VGA module running off a x1 PCI-e lane**
  * Maximum resolution: 1024x768, 60 Hz
  * 4 MB SRAM
  * [Alternative graphics cards][wiki-alternative-gpus]
- **Crystal CS4237B all-in-one audio chip**
- **12mm PC-speaker**
- **12mm HDD clicker speaker**
- **CR1220 battery for persistent real-time clock**
- **Power and reset buttons**
- **Connectivity**
  * USB-C for power
  * 2 x USB Type-A connectors for HID-compliant keyboard and mice
  * 2 x USB Type-A connectors for storage devices (USB 2.0)
  * MicroSD slot for storage
  * DE-9 RS232 serial port (COM1)
  * 1x RJ45 10/100 Ethernet port
  * Modem or Ethernet/SLIP over WiFi (COM2)
  * Internal fan pin-header (5V only)
  * 3.5mm line-out audio jack
  * S/PDIF jack for digital line out
- **mt32-pi subsystem**
  * 40-pin connector for a Raspberry Pi Zero 2
  * Integrated PCM5102 I²S DAC module
  * Button for toggling between MT32 / General MIDI mode
  * Button for switching between audio ROMs / soundbanks
  * 4-pin I²C connector for an OLED display

### Software
- **[Custom Coreboot/SeaBIOS ROM][bios]**
- **MS-DOS / FreeDOS**

<p>
  <img src=images/tinyllama2_bios.png title="TinyLlama BIOS" width=60%>
</p>

## Building
### Sourcing Parts
I will post the BOM after I complete the initial test build to make sure everything is correct.

#### For MT-32/MIDI - optional
- Raspberry Pi Zero 2 W with a microSD card
- An [mt32-pi compatible OLED display][mt32-pi-oled], optional but nice

### Programming the CH559
1. Download the latest firmware binary from this repo, in the `hidman-binary` folder. Alternatively, get the latest source code from the [official repo][hidman] and compile it yourself.
2. Download and install `WCHISPTool_Setup.exe` from [WCH's website][wch]. Unfortunately, this tool only supports Windows. If you're on macOS or Linux, maybe try using virtualization software, or even another computer.
3. Open the `WCHISPTool_CH54x-55x` application.
4. Make sure the TinyLlama is powered off.
5. **Remove** the jumper from the "HID_POWER" pin header on the PCB (to ensure that the computer doesn't backpower the TinyLlama).
6. Connect a USB cable (type A to type A) between one of the HID USB ports on the TinyLlama and the Windows computer.
7. Press and hold the "PRG" button on the bottom side of the TinyLlama until the CH559 device pops up in the WCHISPTool.
8. Select the firmware binary file under _Download File -> Object File1_.
9. Click the "Download" button. Hopefully you'll get a success message in the log section on the right side of the program window.
10. Disconnect the USB cable.
11. **Add** the jumper to the "HID_POWER" pin header on the PCB.
12. Connect a keyboard to one of the HID USB ports. You should be good to go!

### Programming the BIOS
When purchasing the SOM-128-EX module from DMP, its ROM chip comes preinstalled with an Arduino-like bootloader which isn't what we want. Also, the  "crossbar" is configured for using the module with the 86Duino Zero/One boards - meaning its default pin layout is completely different from what we need for the TinyLlama.

Follow these steps to flash the ROM with the TinyLlama BIOS for the first time:
1. Find a USB flash drive, must be minimum 32 MB in size (shouldn't be a problem these days). Note that not all USB drives are bootable. Use a well-known bootable drive. _NB: You have to use a USB stick for this, an SD card won't work since the crossbar is configured to use different pins on the SOM for SD traffic._
2. Do a block-level transfer of the `INITBIOS.IMG` from this repo to the USB drive. Use [Balena Etcher][balena-etcher], or the command line if you know what you're doing (macOS example):
```
$ diskutil list
(Find your USB drive, eg. /dev/disk2)
$ diskutil unmountDisk /dev/disk2
$ sudo dd if=INITBIOS.IMG of=/dev/rdisk2 bs=1m
```
3. Insert the USB flash drive into the TinyLlama and turn it on. It'll hopefully boot into MS-DOS. Then, to flash the ROM:
```
C:\>anybios w initbios.rom
```
...and reboot.  

For subsequent BIOS updates, you can use the ROM's built-in virtual floppy drive available from the boot menu (press F12).  
When booted from this you'll only need a regular USB stick (formatted as FAT16/FAT32) containing the new BIOS file.

### Installing MS-DOS
_A note on selecting the DOS type:  
I've gone with MS-DOS 6.22 for maximum compatibility.  
If you prefer FreeDOS (or another DOS variant), prepare a bootable USB installer disk and use that instead of the built-in virtual floppy._
1. Pick a bootable USB drive or Micro SD card to use as the boot drive - for MS-DOS 6.22 you'll be limited to FAT16 and 2 GB per partition (though you can have several). For FreeDOS with FAT32 you can go all the way up to 2 TB.
2. Insert it, turn on the system, press F12 to bring up the boot menu, and select the virtual floppy drive.
3. Use `fdisk` from the command prompt to partition the SD/USB drive and set it to be `Active`.
4. Restart and again select to boot from the virtual floppy.  
Use `format c: /s /u` to format the drive and copy over system files. Finally use `fdisk /mbr` to make sure the Master Boot Record is correct and the drive should be bootable.
5. Copy over the `DOS` folder from A: to C:.  
You can either do this manually and create `CONFIG.SYS` and `AUTOEXEC.BAT` files to your liking, or more conveniently, just run the `SETUP.BAT` script that'll do this for you. The provided config files lets you choose from a clean boot or a QEMM-based one with XMS, EMS and 631 kB of free conventional memory.

### Programming the CS4237B Firmware
1. Copy the `CS4237B` and `UNISOUND` folders from this GitHub repo over to your SD/USB boot drive and start the system.
2. To program the firmware, run the `RESOURCE.EXE` command below and check that you get the same output:
```
C:\>cd cs4237b
C:\CS4237B>resource /f=0x120 /r=cs4237b.asm /e

Reading data from CS4237B.ASM
Length = 292    Programming EEPROM Block: 1 2    EEPROM programmed

Verifying EEPROM:
Verifying CS4237B.ASM against EEPROM . . .      Verified OKAY
```
3. Make sure the correct `BLASTER` environment variable is set and `UNISOUND.COM` command is called from `AUTOEXEC.BAT`. Note that the 8-bit DMA channel is **1** and the IRQ is **7**:
```
SET BLASTER=A220 I7 D1 P330 T4
C:\UNISOUND\UNISOUND.EXE /V60 /VW60 /VF60 /VL60 /VP60 /VC0 /VM0
```
4. Reboot the system, and you should get the following output:
```
Universal ISA PnP Sound Card Driver for DOS v0.76f. (c) JazeFox 2019-21
-----------------------------------------------------------------------
PnP card found: [CSC7537] CS4237B
BLASTER environment var found! Loading settings...
ADD:220 WSS:534 OPL:388 IRQ:7 DMA:1/1 MPU:330/I9 CTR:120 JOY:200
Initialization done.
Crystal Mixer [VOL:85 WAV:80 FM:80 LIN:0 CD:0 MIC:0]
```
5. Feel free to experiment with the different volume levels, look at the `C:\UNISOUND\UNISOUND.TXT` file for further guidance.
6. Fire up a few games to test that Adlib, SoundBlaster FM and digital sound effects are working properly.

## MT-32 / General MIDI
If you've installed [mt32-pi][mt32-pi] on a Raspberry Pi Zero 2 and connected it to the TinyLlama, it should be ready to go using IO port 330. Use the third button from the left (labeled "SYNTH_SW" on the PCB) to switch between MT-32 and General MIDI mode.  
If you want to play old games that require "MPU-401 Intelligent Mode" (Sierra games, Monkey Island 1, etc), try running [SoftMPU][softmpu]:
```
C:\SOFTMPU\>softmpu /mpu:330 /sb:220 /irq:7
```
If you want to hook up an I²C OLED display to the mt32-pi, there's a pin header on the MiniCamel labeled "I2C_OLED". The order of the pins from 1 to 4 is: GND, VCC, SCL, SDA with pin 1 being the one closest to the 3.5mm audio jack.

## WiFi Connectivity
There's a [section][wiki-wifi] in the wiki dedicated to this, take a look.

## Wiki
For an in-depth discussion of the various components, installation, configuration, etc, take a look at the [wiki][wiki].

## Help
This project is indended for people with a fair bit of hardware- and DOS knowledge. If you have questions or need help, please look at the [wiki][wiki] and [FAQ][wiki-faq] section first.

## License
[GNU General Public License v3.0](LICENSE)

## Acknowledgements

Many thanks to

- [Eivind Bohler] for creating the initial project, helping me troubleshoot my ITX llama and being a HUGE inspiration.
- [Rasteri][rasteri-videos] for creating the WeeCee and Wee86 that got me interested in going down this rabbit hole.
- [The Vogons forum][vogons] for being a great resource and always providing help when needed.
- [86Duino / DMP][86duino] for making a great and affordable system-on-module. (I concur with Eivind on this!)


[tinyllama1]: https://github.com/eivindbohler/tinyllama
[hidman]: https://github.com/rasteri/HIDman
[wiki-alternative-gpus]: https://github.com/eivindbohler/tinyllama2/wiki/alternative-gpus
[bios]: https://github.com/eivindbohler/tinyllama2-bios

[wiki]: https://github.com/eivindbohler/tinyllama2/wiki
[wiki-assembly]: https://github.com/eivindbohler/tinyllama2/wiki/assembly
[wiki-bom]: https://github.com/eivindbohler/tinyllama2/wiki/bom
[wiki-faq]: https://github.com/eivindbohler/tinyllama2/wiki/faq
[wiki-wifi]: https://github.com/eivindbohler/tinyllama2/wiki/wifi-connectivity

[balena-etcher]: https://www.balena.io/etcher
[mt32-pi-oled]: https://github.com/dwhinham/mt32-pi/wiki/LCD-and-OLED-display
[wch]: http://www.wch-ic.com/products/CH559.html

[issues]: https://github.com/eivindbohler/tinyllama2/issues

[rasteri-videos]: https://www.youtube.com/user/TheRasteri/videos
[vogons]: https://www.vogons.org
[86duino]: https://www.86duino.com
[mt32-pi]: https://github.com/dwhinham/mt32-pi
[softmpu]: http://bjt42.github.io/softmpu
