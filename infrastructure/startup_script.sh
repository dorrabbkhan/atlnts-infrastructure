#!/bin/bash

sudo ufw allow 22
sudo apt-get install -y git-all
mkdir /etc/atlnts-backend
sudo chmod 777 /etc/atlnts-backend
sudo apt-get install -y make automake
sudo apt-get install -y gcc
sudo apt install -y nginx
sudo apt-get -y install gfortran
sudo apt install -y sqlite3 libsqlite3-dev libfcgi libfcgi-dev spawn-fcgi
cd /etc/atlnts-backend/atlnts-backend-main/3rdparty/nginx
chmod +x install_nginx.sh
./install_nginx.sh
cd ../fastcgi
chmod +x install_fcgi.sh
wget https://ftp.gnu.org/gnu/automake/automake-1.9.6.tar.gz
tar xf automake-1.9.6.tar.gz
cd automake-1.9.6/
./configure --prefix=/usr/local
make
sudo make install
cd ..
./install_fcgi.sh
