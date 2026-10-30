# SwirlOS

A single-developer operating system built entirely from scratch — no Linux kernel, no POSIX, nothing borrowed. Own bootloader, own kernel, own filesystem, own desktop environment.

**Current release: SwirlOS 0.1 "Tornado"** (x86_64, ring 0 kernel, multiboot2 / UEFI)

Screenshots are below if you don't feel like reading.

## Overview

SwirlOS is a monolithic kernel with proper ring 0 / ring 3 separation, paired with:
- **SwirlBL** — custom bootloader (BIOS and UEFI)
- **SwirlFS** — custom filesystem
- **SwirlWM** — custom desktop environment / window manager, running entirely in userspace
- **spm** — Swirl Package Manager
- **Swirl Store** — the built-in GUI app store

Everything is loaded from real files on disk — fonts, apps, system assets included. Nothing is hardcoded. This follows UNIX philosophy loosely, with its own spin.

## Specifications

**Recommended:**
- 512MB RAM (less is possible, but multitasking several apps gets tight)
- No GPU required — GPU acceleration exists but is optional and still being finished

**Tested on:**
- Real hardware (UEFI laptops, SATA SSD, Wi-Fi, audio, touchpad), including an Intel Celeron N2830 laptop with 2GB RAM, as well as VirtualBox and QEMU
- CPU support is informal, but it runs smoothly on a 2013-era dual-core 2.4GHz CPU, so most modern (and most old) hardware should handle it fine

**Memory usage:**
- ~80MB RAM idle
- ~150MB with a browser open (browsers are just heavy — not much to be done there)

## 🖥️ Bare Metal & UEFI

SwirlOS now runs on real hardware, not just in VMs.

- Full UEFI boot support.
- ACPI, AHCI (SATA SSD), and PS/2 touchpad drivers.
- Intel HDA audio and Atheros Wi-Fi drivers working on real hardware.
- Dynamic framebuffer support (auto-detects 16-bit / 32-bit pitch).

## 📦 Package Management & App Store

- **spm (Swirl Package Manager)** — Git-based `.json` commands and package resolution. Packages live in a GitHub repo ([swirl-packages](https://github.com/qwerwasi6-lab/swirl-packages)). Try it in the terminal: `spm update`, `spm search`, `spm install`, `spm help`. Packages can even add new terminal commands.
- **Swirl Store** — a GUI app store powered by spm, with Discover, Games, Apps, Installed and Updates tabs, a featured banner, search, and install / play buttons. Ships with small games like Snake, 2048, Blocks and Breakout.
- **Self-updating OS** with A/B rollback, plus `spm os repair` for self-healing.

## 💿 Installer

A guided GUI setup that installs SwirlOS to disk, or lets you **try it live from RAM** without installing ("Try without installing"). Five steps:

1. **Components** — SwirlOS itself is required (desktop, terminal, files, settings, Swirl Store and spm). Everything else is optional: DOOM, the Windows games bundle (Minesweeper, Pinball, Solitaire, DX-Ball via SwirlRun) and Doukutsu (Cave Story). Shows how much space it will use.
2. **Region & time** — pick your time zone, with a daylight saving toggle.
3. **Personalise** — computer name, theme (Swirl / Black / White), accent colour and 12/24-hour clock.
4. **Hardware check** — detects graphics, audio, Ethernet, Wi-Fi, keyboard/mouse, memory and storage, and tells you whether SwirlOS supports the machine.
5. **Install** — a summary of what's about to happen, then one click to install.

## Not UNIX-like

There's no POSIX compliance, but some UNIX-style conventions carry over — directory structure like `/home/user`, `/root`, etc. SwirlOS runs `.elf` natively, and Windows `.exe` files run through SwirlRun.

## 🎨 Graphics & UI (SwirlWM)

Clean, flat and modern — people have mistaken it for a Linux GNOME/KDE Plasma distro on sight. The whole UI went through a modernisation pass: new look for every app (except the 3D demo), a new wallpaper, new default settings, and a theme engine driven by a single editable `theme.json` (colours, fonts, corner radius, window borders, shadows, title-bar layout, window transparency).

- Taskbar position, colour, transparency, system tray, icons, clock, width, height, and corner radius — all editable live via `settings.json` or the Settings app.
- Modernised **NetSurf** browser with a Chromium-style menu and JavaScript support.
- A built-in 3D demo (spinning gears) hitting 300+ FPS on a Celeron laptop.

The window manager lives in userspace, not the kernel. The kernel's job is syscalls and hardware; the desktop is just another program.

### Settings

A brand-new Settings app with a searchable sidebar and collapsible categories:

- **System** — Display (resolution, brightness), Sound, About, and **Storage** (a breakdown of System / Games / Your files / Other, live memory usage, and drive info).
- **Input & Output** — Mouse, **Time & Date**.
- **Network & Internet** — including **Wi-Fi**.
- **Personalisation** — theme picker, accent colours and more.
- **My Tabs** — your own pinned settings.

### GPU Acceleration

- **Intel HD Graphics** — partial 2D/3D acceleration (728 FPS on bare metal!).
- Rebuilt 2D acceleration for windows, cursor rendering and window effects — reduces CPU load and makes the whole desktop noticeably smoother.

## 🎮 SwirlRun (Win32 Translation)

A `.exe` compatibility layer — translation, not emulation, similar in spirit to WINE but built entirely around SwirlOS's own syscalls. Not a single line of code borrowed from WINE. It lives entirely in userspace; the kernel has no `.exe` logic.

Real Win32 programs run unmodified: DOOM, Minesweeper, Cave Story (Doukutsu.exe), Warning Forever, DX-Ball, and DirectX 7 3D games.

**Highlights:**
- **DirectDraw support.**
- **Native multi-window support** — dialogs, installers and file pickers get their own real windows.
- **New C runtime** — msvcrt/crtdll/msvcr7x written from scratch: stdio, file I/O, printf/scanf, time, x87 math, argv/envp, atexit, threads.
- **Real dialogs and controls** — buttons, checkboxes, radio buttons, edit boxes, list boxes, combo boxes, progress/scroll/track bars, up-down controls and status bars, with proper Tab / Enter / Esc / arrow-key / Alt-mnemonic handling. Programs' own dialogs now show up and work instead of being skipped.
- **Real MessageBox** and **Open/Save file dialogs** (comdlg32) with a built-in folder browser.
- **Threads, sync objects, a persistent registry** and a much broader kernel32.
- **Installers work** — Windows game installers (including an LHA self-extractor and the DX-Ball installer) run from a USB stick, install the game, and the game launches. Uninstallers like UNWISE.EXE work too.
- **Bundled Windows games** — Minesweeper, Pinball, Solitaire and DX-Ball are offered right in the installer.

**Update 1:** Cave Story (Doukutsu.exe), a freeware game, runs. Proof below.

**Update 2:** A 2004 DirectX 7 3D game (Warning Forever) installs and runs — installer dialog, the game's own **DirectX Setting menu** (window/full screen mode, graphics, control and sound device, "don't show next time"), and gameplay.

In an unreleased in-progress build, SwirlRun has been tested against ~50 Windows games, with ~20 running successfully — this number is expected to grow as the translation layer matures.

**Not done yet:** colour picker / font chooser / print dialogs, owner-draw controls, exotic Windows APIs, structured exception handling, and fog/stencil/mipmaps in the Direct3D layer.

## DirectX

DirectDraw, Direct3D 7, DirectInput and DirectSound layers inside SwirlRun, enough to run real games from the DirectX 7 era including their own device-selection menus.

## Optimisation

A general performance pass across the compositor, desktop and SwirlRun, so the desktop and Windows games run smoother on the same hardware.

## Driver Manager

A Windows-10-style Driver Manager: see every device and its driver, run self-tests, and adjust settings. Includes drivers for the six VirtualBox virtual Ethernet adapters (real PCI enumeration and register-level drivers) and xHCI USB 3.0.

## Networking and Browser

Ethernet and Wi-Fi (Atheros) networking with TCP/IP, TLS, and a real port of the NetSurf browser running in a SwirlWM window. The browser now has JavaScript support and a modern, Chromium-style menu.

## SwirlyMP

Swirly Media Player — own lightweight player for video, pictures and audio.

## SDL 2.0

Ported and working — powers DOOM with a solid performance boost, and opens the door to a much wider library of games and apps going forward.

## xHCI (USB 3.0) Support

Real USB 3.0 driver support — transfer files onto SwirlOS via USB, and run installers straight from a USB stick.

## .wad Installer

A dedicated installer for `.wad` files — creates a desktop shortcut and mounts the file to the right location automatically.

## Image Format Support

Improved PNG and JPEG decoding — broader compatibility with real-world image files.

## 🛠️ Developer Tools

- `/proc/drivers` and `/proc/audio` virtual files for hardware debugging.
- **GUI Installer** — install to disk, or run live from RAM.

## Ring 0 / Ring 3 Separation

Proper privilege separation between kernel and userspace — this isn't a flat, single-ring kernel. Combined with everything loading from real files on disk, this is core to SwirlOS's design philosophy.

## Gaming Support

DOOM ships with the OS as the only "bloat" (and it's fully uninstallable). Real gaming support comes from SDL 2.0, DirectX through SwirlRun, and the 2D acceleration work above. With spm and the Swirl Store now in place, the long-term goal is a growing library of SDL 2.0 games/apps, and eventually running platforms like Steam.

## Philosophy

**Simplicity of Windows, power of Linux.**

The DE/WM stays simple — sliders and toggles, nothing you need a manual for. But like Linux, nothing is hidden: every setting, every file, every system asset is exposed and editable by the user.

## Screenshots

<p align="center">
  <img width="1024" height="768" alt="Cave Story running via SwirlRun" src="https://github.com/user-attachments/assets/c0bf5502-a813-4bde-971c-8a7c98cc1cb7" />
<img width="1024" height="768" alt="Screenshot_20261023_164209" src="https://github.com/user-attachments/assets/93af64a3-7b89-4227-99d7-ba2b3a0714d5" />
<img width="1024" height="768" alt="Screenshot_20261023_164235" src="https://github.com/user-attachments/assets/6d06cd15-d7fa-41c7-9960-830fb9dc3b38" />
<img width="1024" height="754" alt="Screenshot_20261023_164511" src="https://github.com/user-attachments/assets/ea076883-93cf-4991-9cf9-e6ad9816b2e6" />
<img width="1024" height="768" alt="Screenshot_20261023_165415" src="https://github.com/user-attachments/assets/147fe929-b9b9-4025-9fc6-cd8bbfa4b34f" />
