#!/bin/bash

apt-get update

sudo apt install curl
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list


apt install git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn postgresql libpq-dev nginx diceware redis yarn imagemagick -y

echo "Dependancies Installed"

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

# Next let's grab the NGINX config file

# setup user stuff
cd /home/deploy

echo "User: $PASS" >> out.txt
echo "DBUSER: $DBPASS" >> out.txt

#grab the user settings script and execute
curl https://raw.githubusercontent.com/Greyoxide/Server-setup-scripts/master/user_ruby_setup.sh  --output user_script.sh
chmod 777 user_script.sh
chmod +x user_script.sh
su deploy -c './user_script.sh $repo'

# for some reason I find myself having to switch the deploy user's shell back to bash. this seems janky
# chsh -s /bin/bash deploy

sudo -u deploy bash -c "ssh-keygen -f ~deploy/.ssh/id_rsa -N ''"

# copy SSH key from root to deploy
cp ~/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh

# allow ssh access to deploy user
echo 'AllowUsers deploy root' >> /etc/ssh/sshd_config
