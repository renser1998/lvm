#!/bin/sh
cd ~
echo "Create some data"

touch file1
touch file2
ls
echo "Create a snapshot"
sudo lvcreate -L 1G -s -n MySnapShot /dev/VolGroup00/LogVol02Home

echo "Change something"
touch newfile
rm -f file1

echo "Rolling back"
sudo umount /home
sudo lvconvert --merge /dev/VolGroup00/MySnapShot
sudo  mount -a

echo "Checking"
ls -l /home/vagrant

 
echo  "Everything is done"