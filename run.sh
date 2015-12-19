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

# update and download packages
echo 'updating and installing required packages'
apt-get update -y
apt-get install -y curl git nano htop transmission-cli transmission-common transmission-daemon vsftpd

# switch to user and create folders
su $USERNAME
cd $USERHOME
mkdir Downloads repos bin
cd $REPODIR && git clone git@github.com:eyalzek/trserver-startup.git
exit
cd "$REPODIR/trserver-startup"

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

# test connection?

# get external ip and print relevant address
EXTIP=$(curl ident.me)
echo 'transmission webui availble on: '
echo '$EXTIP:9091/transmission/web'
