cd ~/app

git pull origin master

mkdir -p shared/pids shared/sockets shared/log

bundle install

rake db:create
rake db:migrate

rm -r public/packs
rm -r public/assets
rake assets:precompile
bin/webpack

if grep 'whenever' Gemfile;
  then whenever --update-crontab
fi

sudo service nginx restart
