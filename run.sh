#!/bin/bash

# change root password
echo 'change root password'
passwd root

# create new user
echo 'enter new username'
read USERNAME
USERHOME="/home/$USERNAME"
USERDOWNLOADDIR="$USERHOME/Downloads"
REPODIR="$USERHOME/repos"
adduser $USERNAME

# switch to user and create Downloads folder
su $USERNAME
cd
mkdir Downloads
exit

# update and download packages
echo 'updating and installing required packages'
apt-get update -y
apt-get install -y git nano htop transmission-cli transmission-common transmission-daemon vsftpd

# stop services
echo 'stopping services in order to configure'
stop transmission-daemon
stop vsftpd

# configure
usermod -a -G debian-transmission $USERNAME
chgrp debian-transmission "$USERDOWNLOADDIR"
chmod 770 "$USERDOWNLOADDIR"

# update transmission config file
echo 'using $USERNAME as the transmission user name (for the webui)'
perl -pi -e 's/REPLACEWITHUSER/$USERNAME' setting.json
echo 'enter password for the webui'
read TRPASS
perl -pi -e 's/REPLACEWITHPASS/$TRPASS' settings.json
cp settings.json /etc/transmission-daemon/
# update and copy the auto-clear finished torrents script
perl -pi -e 's/REPLACEWITHUSER/$USERNAME' clear-finished.sh
perl -pi -e 's/REPLACEWITHPASS/$TRPASS' clear-finished.sh
mkdir "$USERHOME/bin"
cp clear-finished.sh "$USERHOME/bin/"
# copy vsftpd config
cp vsftpd.conf /etc/

# start services
echo 'starting services'
start transmission-daemon
start vsftpd

# install pirate-get
cd $REPODIR
git clone git@github.com:eyalzek/pirate-get.git && cd pirate-get
./install
cd

# test connection?

# get external ip and print relevant address?
# echo 'transmission webui availble on: '
