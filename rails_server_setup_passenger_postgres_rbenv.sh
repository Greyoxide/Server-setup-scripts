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
touch /etc/sudoers.d/deploy
echo 'deploy ALL=(ALL) NOPASSWD: /usr/sbin/service nginx start,/usr/sbin/service nginx stop,/usr/sbin/service nginx restart' >> /etc/sudoers.d/deploy
chmod 0440 /etc/sudoers.d/deploy

# setup user stuff
cd /home/deploy

#add user to postgresql
sudo -u postgres createuser deploy

su deploy

echo "User: $PASS" >> out.txt

#generate ssh key to pull
ssh-keygen -t rsa -N "" -f '~/.ssh/id_rsa'

echo 'SSH key generated'

#setup Rbenv

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

echo 'RBENV installed'

cd && git clone https://github.com/kolbasa/git-repo-watcher

exit 0
