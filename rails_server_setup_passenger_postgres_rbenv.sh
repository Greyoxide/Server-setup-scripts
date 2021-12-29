#!/bin/bash

set +o noclobber

apt-get update
apt-get upgrade -y

sudo apt install curl
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list


apt install git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn postgresql libpq-dev nginx diceware redis yarn imagemagick ufw -y

echo "Dependancies Installed"

#Phusion passenger setup

# Install our PGP key and add HTTPS support for APT
sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Nginx module
sudo apt-get install -y libnginx-mod-http-passenger

# next we have to point passenger at the rbenv ruby version. Im going to do this by replacing the entire conf script rather than relying on a complicated sed command.
rm /etc/nginx/conf.d/mod-http-passenger.conf
curl 'https://raw.githubusercontent.com/Greyoxide/Server-setup-scripts/master/support/mod-http-passenger.conf' --output /etc/nginx/conf.d/mod-http-passenger.conf

# Now let's grab the NGINX site config file

curl 'https://raw.githubusercontent.com/Greyoxide/Server-setup-scripts/master/support/nginx_passenger_default_setup' > /etc/nginx/sites-enabled/default

service nginx restart

echo 'phusion passenger installed'

#User Setup

PASS=$(diceware)
DBPASS=$(diceware)

adduser --quiet --disabled-password --gecos '' deploy
echo 'deploy:$PASS' | chpasswd
adduser deploy sudo

echo 'deploy user created'

#allow user to restart nginx
echo 'deploy ALL=(ALL) NOPASSWD: /usr/sbin/service nginx start,/usr/sbin/service nginx stop,/usr/sbin/service nginx restart, /sbin/reboot' >> /etc/sudoers.d/deploy
chmod 0440 /etc/sudoers.d/deploy

#add user to postgresql
sudo -u postgres createuser app_user
sudo -u postgres psql -c "ALTER USER app_user WITH PASSWORD '$DBPASS';"
sudo -u postgres psql -c "ALTER USER app_user CREATEDB"

echo 'database user created'

# setup user stuff
cd /home/deploy

echo "User: $PASS" >> out.txt
echo "DBUSER: $DBPASS" >> out.txt

#grab the user settings script and execute
curl https://raw.githubusercontent.com/Greyoxide/Server-setup-scripts/master/user_ruby_setup.sh  --output user_script.sh
chmod 777 user_script.sh
chmod +x user_script.sh
su deploy -c './user_script.sh $repo'

# Theres prolly a better way to append a space... but I don't know it.
echo '===========SSH===========' >> out.txt

# Generate an SSH key so we can pull from Github.
sudo -u deploy bash -c "ssh-keygen -f ~deploy/.ssh/id_rsa -N ''"
echo cat /home/deploy/.ssh/id_rsa.pub >> out.txt

# copy SSH key from root to deploy
cp ~/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh

# allow ssh access to deploy user
echo 'AllowUsers deploy root' >> /etc/ssh/sshd_config

# Configure ufw

ufw default deny incoming
ufw default deny outgoing
ufw limit ssh
ufw allow git
# Should I allow http traffic?
ufw allow out http
ufw allow in http

ufw allow out https
ufw allow in https
ufw allow out 53
ufw logging on
ufw enable
