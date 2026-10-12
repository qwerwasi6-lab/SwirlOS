# SwirlOS - Single developer OS project
A OS made from scratch. no linux whatsoever.
some screenshots below cus im lazy to explain
# Kernel
A monolithic kernel+own bootloader (SwirlBL) own filesystem (SwirlFS) own DE/WM (SwirlWM)
Aiming to be lightweight, as of now it runs 80mb ram idle, but with a browser open it goes up to 150mb ram usage. not something i can change, browsers are heavy on ram.
# Specifications recomended
512mb ram (could go less but then you couldnt get much apps multitasking)
CPU is untested, but it smoothly runs on a 2013 dual core 2.4ghz CPU, so it would work on even shittier CPU's
No GPU required,GPU acceleration is still optional because its not finished
# Not unix like
theres no POSIX but theres some similarities to unix, such as dirs (/home/user, /root and stuff)
it runs .elf and .exe (.exe is still work in progress)
# Desktop einviroment (DE) 
SwirlWM aims to be modern and sleek, and we have already acomplished that. people mistake my OS as a Linux Gnome/KDE plasma distro.
its simple but efective. its highly customisable, you can customise the taskbar position,colour transparency, system tray, icons, clock, width, height, corner smoothnes radius. all from a single settings.json or using settings.
SwirlWM is simple but detailed.
# SwirlRun
A .exe runner, its a translation layer, not emulation. similiar to WINE except this syscalls for SwirlOS syscalls. not a single line of code borrowed from WINE. 
# 2D GPU acceleration
I added some GPU acceleration for 2D stuff like the windows,cursor and all window effects, this helps the OS work smoother and CPU not use as much as it did.
# SDL 2.0 ported!
SDL 2.0 wnow helps run DOOM, performance boost aquired and allows you to play alot games.
# xHCI (USB 3.0) support added
now you can get files with usb onto SwirlOS.
# Installer for .wad
now theres a installer for wad, creates a desktop shortcut+mounts files to a place where the shortcut falls for.
# better png+jpg support!
now decodes more jpg and pngs
# Ring 3 and 0
yes this OS does include proper ring 3 and ring 0 seperation, everything is loaded from files, even font and apps.
following UNIX phisolophy with a little bit of mine
# Gaming support
no gaming support except DOOM which comes in the OS (thats the only bloat) but you can uninstall it. im working on 2D acceleration and SDL 2.0 support, which will include steam platform and a package manager (package manager for SDL 2.0 games/apps. SDL 2.0 will let us play thousands of games, run browsers we couldnt before, run platforms like steam.
# Phisolophy
Simplicity of Windows, Power of Linux
means the DE and WM are simple to use, customisation is slider+toggles only, but power of linux is nothing is hidden from the user, so the user can edit anything.
# Gaming compatibility
DOOM runs as a .exe or a native port. 
In newer not released version, SwirlRun manages to run more windows games, such as classic 2D windows xp games, and some freeware games that i was able to test on legaly.
Around 50 games have been tested on SwirlRun, 20 of them ran in the unreleased version. its getting improved so this message will probably change soon
<img width="1024" height="765" alt="Screenshot_20261009_160211" src="https://github.com/user-attachments/assets/6ee8cfc6-44dd-4d03-baf8-ed69ee9db54f" />

<img width="1024" height="768" alt="DOOMandTinygl" src="https://github.com/user-attachments/assets/f83070ae-e6cc-4b3b-8fb7-4827f26d869a" />

<img width="1024" height="768" alt="Screenshot_20260927_155923" src="https://github.com/user-attachments/assets/67c9bbed-98ea-49bd-9d2a-6a79706f2df2" />

<img width="1024" height="768" alt="OSSwirl" src="https://github.com/user-attachments/assets/70873ecd-ed17-411a-951b-d2882e509cc8" />

