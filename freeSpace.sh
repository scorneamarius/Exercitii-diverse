#!/bin/bash


if [ $# -eq 1 ]
then
	echo "Script is running ..."
else
	echo "Provide password e.g. ./freeSpace.sh nvidia"
	exit 1
fi

# clean journalctl logs
echo $1 | sudo -S journalctl --vacuum-size=50M 2>/dev/null

if [ $? -eq 0 ]
then
	echo "Journalctl logs has been deleted OK"
else
	echo "Journalctl logs has been deleted FAILED"
fi

# Delete cache
echo $1 | sudo -S rm -rf ~/.cache

if [ $? -eq 0 ]
then
	echo ".cache has been deleted OK"
else
	echo ".cache has been deleted FAILED"
fi

# Detele apt cache
echo $1 | sudo -S apt-get clean

if [ $? -eq 0 ]
then
	echo "apt repository cache has been deleted OK"
else
	echo "apt repository cache has been deleted FAILED"
fi

# Delete unnecesarry packages
echo $1 | sudo -S apt-get autoremove -y >/dev/null

if [ $? -eq 0 ]
then
	echo "Removing unnecessary packages... OK"
else
	echo "Removing unnecessary packages... FAILED"
fi


# Delete unnecesarry packages
echo $1 | sudo -S apt-get autoremove --purge -y > /dev/null

if [ $? -eq 0 ]
then
	echo "Unnecessary packages have been deleted OK"
else
	echo "Unnecessary packages has been deleted FAILED"
fi


