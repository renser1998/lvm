#!/bin/sh

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi


echo  "Installing xfsdump"
yum install xfsdump -y

echo   "Create logival volume on sdb for the entire disk size"
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -l +80%FREE -n lv_root /dev/vg_root

echo "Formatting /dev/vg_root/lv_root"
mkfs.xfs /dev/vg_root/lv_root
mkdir /mnt/tmproot

echo "Mounting new device and transfering fs"
mount /dev/vg_root/lv_root /mnt/tmproot
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt/tmproot

echo "Preparing fs for chroot"
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/tmproot/$i; done 

echo "Updating grup conf file"
chroot /mnt/tmproot grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Update initramfs"
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)

echo "Change boot sector"
sed -i 's/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=vg_root\/lv_root/' /boot/grub2/grub.cfg
reboot
