#!/bin/bash

# System manager script for Arch Power PS3 Linux
# Built by ajww, gypsy & vmo64 (NGX)
# Disabling this script will cause system instability!



# Configure network IP
dhclient 
# Crude way to fix out-of-sync time on boot
systemctl restart systemd-timesyncd

# Enable RSX VRAM to be used as high-speed SWAP
mkswap /dev/ps3vram
swapon /dev/ps3vram 

# Create symlinks to reroute ps3-util names to traditional names
ln -sf /dev/ps3vflashf /dev/ps3flash
ln -sf /dev/ps3strgmngr /dev/ps3stormgr
ln -sf /dev/ps3lv1 /dev/ps3hvcall

# Make agresssive swap scheme
sysctl vm.swappiness=100
sysctl vm.vfs_cache_pressure=110 
sysctl vm.min_free_kbytes=8192 # Do not fill the last 8MiB of RAM
sysctl vm.watermark_scale_factor=10

# Run the updater script after initializing system (check for updates)
nohup /usr/local/bin/system-manager/updater.sh &



