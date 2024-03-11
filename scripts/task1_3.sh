#!/bin/sh
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

echo "Remove lv and vg"
lvremove -y /dev/vg_root/lv_root
vgremove -y /dev/vg_root
echo  "========= task 1 = Done ==========="