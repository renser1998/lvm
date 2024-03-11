#!/bin/sh
echo "Creating lv for home directory"
lvcreate -L 1G -n LogVol02Home /dev/VolGroup00
echo "Formatting  new home"
mkfs.xfs /dev/VolGroup00/LogVol02Home
echo "Mounting home to temp directory"
mkdir /mnt/tmphome
mount /dev/VolGroup00/LogVol02Home /mnt/tmphome
cp --preserve=all -rfp /home/* /mnt/tmphome/
echo "Create old dir and mount to new dir"
rm -rf /home/*
umount /mnt/tmphome
mount /dev/VolGroup00/LogVol02Home /home/
echo 'UUID='`blkid /dev/VolGroup00/LogVol02Home -s UUID -o value`' /home           xfs    defaults        0 0' >> /etc/fstab
echo  "========= task 2.Done ==========="
reboot
