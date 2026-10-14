# SwirlOS

A single-developer operating system built entirely from scratch — no Linux kernel, no POSIX, nothing borrowed. Own bootloader, own kernel, own filesystem, own desktop environment.

Screenshots are below if you don't feel like reading.

## Overview

SwirlOS is a monolithic kernel with proper ring 0 / ring 3 separation, paired with:
- **SwirlBL** — custom bootloader
- **SwirlFS** — custom filesystem
- **SwirlWM** — custom desktop environment / window manager

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

There's no POSIX compliance, but some UNIX-style conventions carry over — directory structure like `/home/user`, `/root`, etc. SwirlOS runs `.elf` natively, and `.exe` support is in progress via SwirlRun.

## Desktop Environment (SwirlWM)

Aims to be modern and clean — people have mistaken it for a Linux GNOME/KDE Plasma distro on sight. It's fully customisable: taskbar position, colour, transparency, system tray, icons, clock, width, height, and corner radius — all editable live via `settings.json` or the Settings app.

## SwirlRun

A `.exe` compatibility layer — translation, not emulation, similar in spirit to WINE but built entirely around SwirlOS's own syscalls. Not a single line of code borrowed from WINE.

Currently runs real Win32 executables including DOOM, Minesweeper, and Cave Story (Doukutsu.exe), unmodified, with working dialogs, menus, and window behavior. In an unreleased in-progress build, SwirlRun has been tested against ~50 Windows games, with ~20 running successfully — this number is expected to grow quickly as the translation layer matures.

**Update 1:** Cave Story (Doukutsu.exe), a freeware game, now runs. Proof below.

## 2D GPU Acceleration

Hardware-accelerated 2D for windows, cursor rendering, and window effects — reduces CPU load and makes the whole desktop noticeably smoother.

## SDL 2.0

Ported and working — powers DOOM with a solid performance boost, and opens the door to a much wider library of games and apps going forward.

## xHCI (USB 3.0) Support

Real USB 3.0 driver support — transfer files onto SwirlOS via USB.

## .wad Installer

A dedicated installer for `.wad` files — creates a desktop shortcut and mounts the file to the right location automatically.

## Image Format Support

Improved PNG and JPEG decoding — broader compatibility with real-world image files.

## Ring 0 / Ring 3 Separation

Proper privilege separation between kernel and userspace — this isn't a flat, single-ring kernel. Combined with everything loading from real files on disk, this is core to SwirlOS's design philosophy.

## Gaming Support

DOOM ships with the OS as the only "bloat" (and it's fully uninstallable). Real gaming support is landing through SDL 2.0 and the 2D acceleration work above — the long-term goal includes a package manager for SDL 2.0 games/apps, and eventually running platforms like Steam.

## Philosophy

**Simplicity of Windows, power of Linux.**

The DE/WM stays simple — sliders and toggles, nothing you need a manual for. But like Linux, nothing is hidden: every setting, every file, every system asset is exposed and editable by the user.

## Screenshots

<p align="center">
  <img width="1024" height="768" alt="Cave Story running via SwirlRun" src="https://github.com/user-attachments/assets/c0bf5502-a813-4bde-971c-8a7c98cc1cb7" />
  <img width="1024" height="765" alt="SwirlOS desktop" src="https://github.com/user-attachments/assets/6ee8cfc6-44dd-4d03-baf8-ed69ee9db54f" />
  <img width="1024" height="768" alt="DOOM and TinyGL running simultaneously" src="https://github.com/user-attachments/assets/f83070ae-e6cc-4b3b-8fb7-4827f26d869a" />
  <img width="1024" height="768" alt="SwirlOS desktop environment" src="https://github.com/user-attachments/assets/67c9bbed-98ea-49bd-9d2a-6a79706f2df2" />
  <img width="1024" height="768" alt="SwirlOS desktop environment" src="https://github.com/user-attachments/assets/70873ecd-ed17-411a-951b-d2882e509cc8" />
</p>
