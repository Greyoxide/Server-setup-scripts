cd ~/app

git fetch
HEADHASH=$(git rev-parse HEAD)
UPSTREAMHASH=$(git rev-parse master@{upstream})

if [ "$HEADHASH" != "$UPSTREAMHASH" ]
then
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
else
  echo -e ${FINISHED}Current branch is up to date with origin/master.${NOCOLOR}
fi
