#!/bin/bash
CONTAINERNAME=$1
ADMINPASSWORD=$2
PORT=$3
CHAT=$4
# clone Odoo directory
git clone --depth=1 https://github.com/bluezebra-io/odoo-14-docker-compose $CONTAINERNAME
rm -rf $CONTAINERNAME/.git
# set permission
mkdir -p $CONTAINERNAME/postgresql
sudo chmod -R 777 $CONTAINERNAME
# enterprise
cd $CONTAINERNAME
git clone -b 14.0 https://github.com/odoo/enterprise.git
cd ..
# config
if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf); else echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf; fi
sudo sysctl -p
sed -i'.original' -e 's/<ADMIN_PASSWD>/'$ADMINPASSWORD'/g' $CONTAINERNAME/etc/odoo.conf
sed -i'.original' -e 's/10014/'$PORT'/g' $CONTAINERNAME/docker-compose.yml
sed -i'.original' -e 's/20014/'$CHAT'/g' $CONTAINERNAME/docker-compose.yml
# run Odoo
docker-compose -f $CONTAINERNAME/docker-compose.yml up -d

echo 'Started Odoo @ http://localhost:'$PORT' | Live chat port: '$CHAT
