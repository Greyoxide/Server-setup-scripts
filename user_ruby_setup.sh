#!/bin/sh

cd

#generate ssh key to pull
echo -e "\n"|ssh-keygen -t rsa -N ""
echo 'SSH key generated'

#setup Rbenv

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

echo 'RBENV installed'

cd && git clone https://github.com/kolbasa/git-repo-watcher

exit N
