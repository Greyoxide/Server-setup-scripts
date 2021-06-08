#!/bin/sh

apt-get update

sudo apt install curl
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list


apt install git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn postgresql libpq-dev nginx -y

echo "Dependancies Installed"

#Phusion PASSenger setup

# Install our PGP key and add HTTPS support for APT
sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Nginx module
sudo apt-get install -y libnginx-mod-http-passenger

service nginx restart

echo 'phusion passenger installed'

#User Setup

PASS=$(openssl rand -base64 14)

useradd -m -p $PASS deploy
usermod -aG sudo deploy

echo 'deploy user created'

#allow user to restart nginx
echo 'deploy ALL=(ALL) NOPASSWD: /usr/sbin/service nginx start,/usr/sbin/service nginx stop,/usr/sbin/service nginx restart, /sbin/reboot' >> /etc/sudoers.d/deploy
chmod 0440 /etc/sudoers.d/deploy

#add user to postgresql
sudo -u postgres createuser deploy

# setup user stuff
cd /home/deploy

echo "User: $PASS" >> out.txt

curl https://raw.githubusercontent.com/Greyoxide/Server-setup-scripts/master/user_ruby_setup.sh  --output user_script.sh

chmod 777 user_script.sh
chmod +x user_script.sh

su deploy -c './user_script.sh'

# for some reason I find myself having to switch the deploy user's shell back to bash. this seems janky
chsh -s /bin/bash deploy

# copy SSH key from root
cp ~/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh

sudo -u deploy bash -c "ssh-keygen -f ~deploy/.ssh/id_rsa -N ''"

echo 'AllowUsers deploy root' >> /etc/ssh/sshd_config
