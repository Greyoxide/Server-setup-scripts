#!/bin/sh

cd

#setup Rbenv

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
git clone https://github.com/rbenv/rbenv-vars.git $(rbenv root)/plugins/rbenv-vars

echo 'RBENV installed'

cd && git clone $1 app

curl 'https://raw.githubusercontent.com/Greyoxide/Server-setup-scripts/master/support/pull_changes.sh' --output pull_changes.sh
chmod +x pull_changes.sh

echo 'RAILS_ENV=production' >> ~/app/.rbenv-vars

exit
