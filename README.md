# SwirlOS

A single-developer operating system built entirely from scratch — no Linux kernel, no POSIX, nothing borrowed. Own bootloader, own kernel, own filesystem, own desktop environment.

Screenshots are below if you don't feel like reading.

## Overview

SwirlOS is a monolithic kernel with proper ring 0 / ring 3 separation, paired with:
- **SwirlBL** — custom bootloader
- **SwirlFS** — custom filesystem
- **SwirlWM** — custom desktop environment / window manager, running entirely in userspace

Everything is loaded from real files on disk — fonts, apps, system assets included. Nothing is hardcoded. This follows UNIX philosophy loosely, with its own spin.

## Specifications

**Recommended:**
- 512MB RAM (less is possible, but multitasking several apps gets tight)
- No GPU required — GPU acceleration exists but is optional and still being finished

**Tested on:**
- CPU support is informal, but it runs smoothly on a 2013-era dual-core 2.4GHz CPU, so most modern (and most old) hardware should handle it fine

**Memory usage:**
- ~80MB RAM idle
- ~150MB with a browser open (browsers are just heavy — not much to be done there)

## Not UNIX-like

There's no POSIX compliance, but some UNIX-style conventions carry over — directory structure like `/home/user`, `/root`, etc. SwirlOS runs `.elf` natively, and Windows `.exe` files run through SwirlRun.

## Desktop Environment (SwirlWM)

Clean, flat and modern — people have mistaken it for a Linux GNOME/KDE Plasma distro on sight. The whole UI went through a modernisation pass: new look for every app (except the ported NetSurf browser and the 3D demo), a new wallpaper, new default settings, and a theme engine driven by a single editable `theme.json` (colours, fonts, corner radius, window borders, shadows, title-bar layout, window transparency).

It's still fully customisable: taskbar position, colour, transparency, system tray, icons, clock, width, height, and corner radius — all editable live via `settings.json` or the Settings app.

The window manager lives in userspace, not the kernel. The kernel's job is syscalls and hardware; the desktop is just another program.

## SwirlRun

A `.exe` compatibility layer — translation, not emulation, similar in spirit to WINE but built entirely around SwirlOS's own syscalls. Not a single line of code borrowed from WINE. It lives entirely in userspace; the kernel has no `.exe` logic.

Real Win32 programs run unmodified: DOOM, Minesweeper, Cave Story (Doukutsu.exe), and DirectX 7 3D games.

**What's new in the latest SwirlRun:**
- **New C runtime** — msvcrt/crtdll/msvcr7x written from scratch: stdio, file I/O, printf/scanf, time, x87 math, argv/envp, atexit, threads.
- **Real dialogs and controls** — buttons, checkboxes, radio buttons, edit boxes, list boxes, combo boxes, progress/scroll/track bars, up-down controls and status bars, with proper Tab / Enter / Esc / arrow-key / Alt-mnemonic handling. Programs' own dialogs now show up and work instead of being skipped.
- **Real MessageBox** and **Open/Save file dialogs** (comdlg32) with a built-in folder browser.
- **Threads, sync objects, a persistent registry** and a much broader kernel32.
- **Installers work** — a Windows game installer (an LHA self-extractor) ran from a USB stick, installed the game, and the game launched.

**Update 1:** Cave Story (Doukutsu.exe), a freeware game, runs. Proof below.

**Update 2:** A 2004 DirectX 7 3D game (Warning Forever) installs and runs — installer dialog, the game's own **DirectX Setting menu** (window/full screen mode, graphics, control and sound device, "don't show next time"), and gameplay.

In an unreleased in-progress build, SwirlRun has been tested against ~50 Windows games, with ~20 running successfully — this number is expected to grow as the translation layer matures.

**Not done yet:** colour picker / font chooser / print dialogs, owner-draw controls, JavaScript-heavy and exotic Windows APIs, structured exception handling, and fog/stencil/mipmaps in the Direct3D layer.

## DirectX

DirectDraw, Direct3D 7, DirectInput and DirectSound layers inside SwirlRun, enough to run real games from the DirectX 7 era including their own device-selection menus.

## 2D GPU Acceleration

Rebuilt 2D acceleration for windows, cursor rendering and window effects — reduces CPU load and makes the whole desktop noticeably smoother.

## Optimisation

A general performance pass across the compositor, desktop and SwirlRun, so the desktop and Windows games run smoother on the same hardware.

## Driver Manager

A Windows-10-style Driver Manager: see every device and its driver, run self-tests, and adjust settings. Includes drivers for the six VirtualBox virtual Ethernet adapters (real PCI enumeration and register-level drivers) and xHCI USB 3.0.

## Networking and Browser

Ethernet networking with TCP/IP, TLS, and a real port of the NetSurf browser running in a SwirlWM window. JavaScript is on the to-do list, along with Wi-Fi.

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

## Ring 0 / Ring 3 Separation

Proper privilege separation between kernel and userspace — this isn't a flat, single-ring kernel. Combined with everything loading from real files on disk, this is core to SwirlOS's design philosophy.

## Gaming Support

DOOM ships with the OS as the only "bloat" (and it's fully uninstallable). Real gaming support comes from SDL 2.0, DirectX through SwirlRun, and the 2D acceleration work above — the long-term goal includes a package manager for SDL 2.0 games/apps, and eventually running platforms like Steam.

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
