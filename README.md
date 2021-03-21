```
  ____ ____  _   _ ____ ____    _____ _   _ _____ __  __ _____ ____
 / ___|  _ \| | | | __ )___ \  |_   _| | | | ____|  \/  | ____/ ___|
| |  _| |_) | | | |  _ \ __) |   | | | |_| |  _| | |\/| |  _| \___ \
| |_| |  _ <| |_| | |_) / __/    | | |  _  | |___| |  | | |___ ___) |
 \____|_| \_\\___/|____/_____|   |_| |_| |_|_____|_|  |_|_____|____/

```

## Flat Design themes for Grub

## Installation:

Usage:  `sudo ./install.sh [OPTIONS...]`

|  Options:              | Description: |
|:-----------------------|:-------------|
| -u, --user             | Install grub theme into `/usr/share/grub/themes` |
| -t, --theme            | theme name (default is material)"
| -i, --icon             | icon variant(s) [white/color/whitesur] (default is white)"
| -s, --size             | icon size [32x/48x/64x] (default is 32x)"
| -r, --remove [THEME]   | Uninstall selected theme |
| -h, --help             | Show this help |


### Examples:
 - Install Tela theme on 2k display device:
   - `sudo ./install.sh -t tela -s 48x`

 - Uninstall Tela theme:
   - `sudo ./install.sh -r -t tela`

## Issues / tweaks:

### Setting a custom background:

 - Make sure you have `imagemagick` installed, or at least something that provides `convert`
 - Find the resolution of your display, and make sure your background matches the resolution
   - (1920x1080 -> --1080p, 2560x1080 -> --ultrawide, 2560x1440 -> --2k, 3440x1440 -> --ultrawide2k, 3840x2160 -> --4k)
 - Place your custom background inside the root of the project, and name it `background.jpg`
 - Run the installer like normal, but with -s `[YOUR_RESOLUTION]` and -t `[THEME]` and -i `[ICON]`
   - Make sure to replace `[YOUR_RESOLUTION]` with your resolution and `[THEME]` with the theme

## Screenshots:

### Material grub theme:

![material](screenshots/grub-theme-material.jpg?raw=true)

