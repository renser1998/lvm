#!/bin/sh
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

echo "Creating pv"
pvcreate /dev/sdc /dev/sdd

echo "Creating vg"
vgcreate VolGroup01 /dev/sdc /dev/sdd

echo "Create mirror volume" 
lvcreate -L 950M -m 1 -n LogVol03Var /dev/VolGroup01

echo "Formatting /dev/VolGroup01/LogVol03Var"
mkfs.xfs /dev/VolGroup01/LogVol03Var

echo "Mounting to temp and transferring fs to temp"
mkdir /mnt/temp_var
mount /dev/VolGroup01/LogVol03Var/ /mnt/temp_var
cp --preserve=all -rfp /var/* /mnt/temp_var/


echo "Removing old var and mounting to new dir"
rm -rf /var/*
umount /mnt/temp_var
mount /dev/VolGroup01/LogVol03Var /var/
echo 'UUID='`blkid /dev/VolGroup01/LogVol03Var -s UUID -o value`' /var           xfs    defaults        0 0' >> /etc/fstab
echo  "========= task 3.Done ==========="
reboot