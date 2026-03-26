# ArchPOWER Linux PS3 AutoInstaller
Automatic installer script for the ArchPOWER Linux Distro on the PS3.

## How to use?
1. You can boot straight off of the [ISO](http://ps3.christianresearchservice.com/archpower/dl/ARCH_202509.iso) modified to include this script (and it updates itself!).
2. You can use this script directly by running: <br>
``curl -o https://raw.githubusercontent.com/vmo64/archpower-linux-installer-ps3/main/setup-archpower.sh && bash setup-archpower.sh`` (GitHub Direct) <br>
or <br>
``curl -o http://ps3.christianresearchservice.com/archpower/dl/setup-archpower.sh && bash setup-archpower.sh`` (Mirror) <br>

## What can it do?
I made this tool to make installing this modern distro as painless as possible for the average user.

Other than making the installation process much easier, here are the features this script offers:
- Auto partitioning on the PS3 (Internal HDD and External HDD)
- Setting up a desktop environment (currently only LXQt and LXDE are supported due to their low ram usage)
- Sets up the PS3's RSX VRAM as hi-speed swap for extra memory alongside ZRAM for better performance
- Sets up ps3linux utilities (and soon, ps3hvc utilities) to give you direct access to the console hardware

# Requirements
- To use this script, you currently must have a LAN interface connected to the console, WiFi support will be added in future updates.
- A PS3 (obviously).
Thats pretty much it.

More updates coming soon.
