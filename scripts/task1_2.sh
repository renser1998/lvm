#!/bin/sh
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

echo " Remove lv from vg and create new lv 8Gb"
lvremove -y /dev/VolGroup00/LogVol00
lvcreate -y -L 8G -n LogVol00 /dev/VolGroup00

echo " Formatting new device"
mkfs.xfs /dev/VolGroup00/LogVol00

echo " Mounting new device and transfering to new dir"
mkdir /mnt/newroot
mount /dev/VolGroup00/LogVol00 /mnt/newroot
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt/newroot

echo " Preparing fs"
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/newroot/$i; done 

echo " Update grub conf file"
chroot /mnt/newroot grub2-mkconfig -o /boot/grub2/grub.cfg

echo " Update initramfs"
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
reboot