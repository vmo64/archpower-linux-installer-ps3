#!/bin/sh
clear
echo "##### RUNNING SETUP #####"

# Check if /dev/ps3dd exists
if [ ! -b "/dev/ps3dd" ]; then
    echo -e "[\e[33mWARN\e[0m] /dev/ps3dd does not exist. Internal HDD installation mode is [\e[31mDISABLED\e[0m!"
    # exit 1
else
    echo -e "[\e[32m OK \e[0m] /dev/ps3dd detected. You can install to the Internal HDD."
fi

if ping -c 1 -W 2 google.com > /dev/null 2>&1; then
    echo -e "[\e[32m OK \e[0m] Network (eth0) is UP, continuing."
else
    echo -e "[\e[31mERROR\e[0m] No internet connection, configuring internet connection."
    
    # network configuration TODO
fi

install () {

    clear
    sleep 1;
    echo " "
    echo "###################################################"
    echo "Where do you want to install Linux?"
    echo "###################################################"
    echo " "
    echo " "
    echo "Options:"
    if [ ! -b "/dev/ps3dd" ]; then
            echo "1 - Internal PS3 Storage (/dev/ps3dd) (DISABLED, refer to DOCS to create internal storage space)"
        else
            echo "1 - Internal PS3 Storage (/dev/ps3dd)"
        fi
    echo "2 - External Drive"
    echo " "
    echo "3 - Go back to main menu"
    echo " "
    echo "Enter the option you want to run below (eg. 1), if the script quits then you have entered an invalid option."
    echo "###################################################"
    read -p "Please enter the desired option: " PART_METHOD
    echo " "
    if [[ $PART_METHOD = "1" ]]
    then
        if [ ! -b "/dev/ps3dd" ]; then
            install
        fi
        echo " "
        echo " "
        echo " "
        echo "###################################################"
        echo "Installing ArchPOWER to internal OtherOS++ Medium"
        echo "Note: OtherOS allocates a volume of 22GB max!"
        echo "###################################################"
        echo "Creating HDD Partitions"
        echo "###################################################"
        echo -e "Warning: This operation will \e[31mPERMANENTALLY DELETE\e[0m all data fom the selected volume!!"
        echo "Starting in 10 seconds, press CTRL+C to abort!"
        echo "###################################################"
        sleep 10;
        echo " "
        echo " "
        echo " "
        parted /dev/ps3dd mklabel msdos
        parted /dev/ps3dd mkpart primary ext2 1MiB 128MiB
        parted /dev/ps3dd mkpart primary ext4 128MiB 100%
        
        echo " "
        echo "Formatting partitions"
        echo " "
        mkfs.ext2 /dev/ps3dd1
        mkfs.ext4 /dev/ps3dd2
        
        echo " "
        echo "Mounting volumes"
        echo " "
        mount /dev/ps3dd2 /mnt
        mkdir /mnt/boot
        mount /dev/ps3dd1 /mnt/boot
        PART2="/dev/ps3dd2"
        PART_UUID=$(blkid -s PARTUUID -o value /dev/ps3dd2)

    fi
    if [[ $PART_METHOD = "2" ]]
    then
        echo " "
        echo " "
        echo " "
        echo "###################################################"
        echo "Installing Linux to an external medium"
        echo "###################################################"
        echo " "
        echo " "
        echo "###################################################"
        echo "Please specify which drive you want to use from the list below."
        echo "###################################################"
        echo " "
        lsblk
        echo " "
        read -p "Please enter the desired disk (/dev/xxx):" MANU_PART_DISK_SELECTION
        echo " "
        echo "###################################################"
        echo "This installer will create a boot partition 128MiB in size on the selected drive."
        echo "A swap partition will not be created, swap is managed differently."
        echo "###################################################"
        echo "Please specify the size of the main system partition (enter 100% to fill the rest of the disk)."
        echo "###################################################"
        echo " "
        read -p "Please enter the desired partition size (in GiB):" MANU_PART_MNT_SIZE
        echo " "
        echo "###################################################"
        echo -e "Warning: This operation will \e[31mPERMANENTALLY DELETE\e[0m all data fom the selected volume!!"
        echo "Starting in 10 seconds, press CTRL+C to abort!"
        echo "###################################################"
        sleep 10;
        echo " "
        echo " "
        echo " "
        parted $MANU_PART_DISK_SELECTION mklabel msdos
        parted $MANU_PART_DISK_SELECTION mkpart primary ext2 1MiB 128MiB
        parted $MANU_PART_DISK_SELECTION mkpart primary ext4 128MiB $MANU_PART_MNT_SIZE
        
        mapfile -t P < <(lsblk -lnpo NAME $MANU_PART_DISK_SELECTION | tail -n +2)
        PART1="${P[0]}"; PART2="${P[1]}"; echo "$PART1 $PART2"

        echo " "
        echo "Formatting partitions"
        echo " "
        mkfs.ext2 $PART1
        mkfs.ext4 $PART2
        
        echo " "
        echo "Mounting volumes"
        echo " "
        mount $PART2 /mnt
        mkdir /mnt/boot
        mount $PART1 /mnt/boot
        PART_UUID=$(blkid -s PARTUUID -o value $PART2)

    fi

        if [[ -z "$PART_UUID" ]]; then
            echo "###################################################"
            echo -e "[\e[31mERROR\e[0m] Install Failed!"
            echo "###################################################"
            echo " "
            echo "Something went wrong when creating the partitions"
            echo "Reason: Mountpoint partition ID does not exist (partition does not exist)"
            echo "Partition: "$PART2
            echo " "
            echo "Exiting to shell. Run 'bash .automated_script.sh' to re-run the installer."
            exit
        fi

        clear
        echo " "
        echo " "
        echo " "
        echo "###################################################"
        echo "Installing Linux"
        echo "###################################################"
        echo " "
        echo "Mountpoint partition: "$PART2
        echo "###################################################"
        echo " "
        sleep 3;
        echo " "
        read -p "Please enter the desired root user password: " -s USER_ROOT_PASS
        echo " "

        clear
        echo " "
        echo " "
        echo "###################################################"
        echo "Installing Linux"
        echo "###################################################"
        echo " "
        echo "Creating SWAP Space (512MiB)"
        echo " "

        dd if=/dev/zero of=/mnt/swapfile bs=1M count=512
        chmod 0600 /mnt/swapfile
        mkswap /mnt/swapfile
        swapon /mnt/swapfile
        sleep 1;

        clear
        echo " "
        echo " "
        echo "###################################################"
        echo "Installing Linux"
        echo "###################################################"
        echo " "
        echo "Create vconsole.conf"
        echo " "

        mkdir -p /mnt/etc && echo -e "KEYMAP=us\nFONT=lat9w-16" > /mnt/etc/vconsole.conf
        sleep 1;
        
        clear
        echo " "
        echo " "
        echo "###################################################"
        echo "Installing Linux"
        echo "###################################################"
        echo " "
        echo "Installing ArchPOWER packages"
        echo " "
        sleep 2;


        pacstrap -K /mnt base linux-ps3 wget nano vim sudo openssh iputils iproute2 dhclient net-tools htop neofetch sudo git autoconf automake libtool base-devel libnewt #networkmanager
        
        genfstab -U /mnt >> /mnt/etc/fstab

        PART_UUID=$(blkid -s PARTUUID -o value $PART2)

        clear
        echo " "
        echo " "
        echo "###################################################"
        echo "Installing Linux"
        echo "###################################################"
        echo " "
        echo "Creating KBOOT bootloader entry"
        echo " "

        printf 'timeout=100\ndefault=ArchPower\nArchPower="/vmlinuz-linux-ps3 arch=ppc64 quiet loglevel=N video=ps3fb:mode:131 root=PARTUUID=%s initrd=/initramfs-linux-ps3.img"\n' "$PART_UUID" > /mnt/boot/kboot.conf # Configure Kboot/PetitBoot Entry
        sleep 1;
        #printf '[main]\ndhcp=dhclient\n' > /mnt/etc/NetworkManager/conf.d/dhcp-client.conf # Autoconfigure network on boot
        
        echo " "
        echo "Disabling GPG check in Pacman (needed for ArchPOWER repo)"
        echo " "

        sudo sed -i 's/^SigLevel\s*=\s*Required DatabaseOptional$/SigLevel    = Never/' /etc/pacman.conf # Disable GPG Check in Pacman as root key is invalid

        echo " "
        echo "Configuring and installing system-manager service"
        echo " "

        mkdir /mnt/usr/local/bin/system-manager
        curl -o /mnt/usr/local/bin/system-manager/sys-man.sh http://ps3.christianresearchservice.com/archpower/dl/sys-man.sh # Download latest system-manager script
        curl -o /mnt/usr/local/bin/system-manager/stage2-install.sh http://ps3.christianresearchservice.com/archpower/dl/stage2-install.sh # Download latest stage2-install script
        curl -o /mnt/usr/local/bin/system-manager/updater.sh http://ps3.christianresearchservice.com/archpower/dl/updater.sh # Download latest system-manager updater script
        arch-chroot /mnt /bin/bash -c "chmod +x /usr/local/bin/system-manager/stage2-install.sh"
        arch-chroot /mnt /bin/bash -c "chmod +x /usr/local/bin/system-manager/sys-man.sh"
        arch-chroot /mnt /bin/bash -c "chmod +x /usr/local/bin/system-manager/updater.sh"
        echo -e '[Unit]\nAfter=sysinit.target\n\n[Service]\nType=oneshot\nExecStart=/usr/local/bin/system-manager/sys-man.sh\n\n[Install]\nWantedBy=multi-user.target' > /mnt/etc/systemd/system/system-manager.service #Install the system-manager service
        arch-chroot /mnt /bin/bash -c "ln -sf ../system-manager.service /etc/systemd/system/multi-user.target.wants/"
        arch-chroot /mnt /bin/bash -c "ln -sf ../systemd-timesyncd.service /etc/systemd/system/multi-user.target.wants/"

        echo " "
        echo "Setting up SSH root user login"
        echo " "

        arch-chroot /mnt /bin/bash -c "sed -i 's/^#\s*PermitRootLogin\s\+prohibit-password\s*$/PermitRootLogin yes/;s/^#\s*PermitRootLogin\s\+without-password\s*$/PermitRootLogin yes/' /etc/ssh/sshd_config" # Enable root user login via SSH
        
        echo " "
        echo "Setting up root user autologin"
        echo " "

        arch-chroot /mnt sh -c "mkdir -p /etc/systemd/system/getty@tty1.service.d && echo -e '[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin root --noclear %I $TERM' | tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null" # Enable autologin for first time
        
        echo " "
        echo "Setting up root user password"
        echo " "
        
        arch-chroot /mnt sh -c "echo 'root:'$USER_ROOT_PASS | chpasswd" # Change ROOT user password
        
        echo " "
        echo "Configuring stage2 installer"
        echo " "
        
        arch-chroot /mnt sh -c "echo -e '/usr/local/bin/system-manager/stage2-install.sh' > /root/.bash_profile" # Add the stage2 installer to autorun

        echo " "
        echo " "
        echo " "
        echo "###################################################"
        echo "Stage1 Install Completed!"
        echo "###################################################"
        echo "System is rebooting into the second installation stage."
        echo "The install will continue once you log into the system."
        echo "###################################################"
        echo " "
        echo "###################################################"
        echo -e "\e[31mPlease remove your installation media after the system restarts.\e[0m"
        echo "System is rebooting in 10 seconds."
        echo "###################################################"
        echo " "
        sleep 10; 
        reboot





}


# Script main menu
menu () {

    echo " "
    echo "###################################################"
    echo -e "\e[96mArchPOWER\e[0m PS3 Linux Installer by ajww, gypsy & vmo64"
    echo "Version 0.2 - 03.02.2026."
    echo "###################################################"
    sleep 1;
    echo " "
    echo "###################################################"
    echo " "
    echo "What do you want to do:"
    echo "1 - Install ArchPOWER Linux PS3"
    echo "2 - Exit to shell"
    echo "3 - Reboot"
    echo " "
    echo "Enter the option you want to run below (eg. 1), if the script quits then you have entered an invalid option."
    echo "###################################################"
    echo " "
    read -p "Please enter the desired option: " MAINSELECTION
    echo " "


    if [[ $MAINSELECTION = "1" ]]
    then
        install
    fi

    if [[ $MAINSELECTION = "2" ]]
    then
        exit
    fi

    if [[ $MAINSELECTION = "3" ]]
    then
        reboot
    fi
}


menu