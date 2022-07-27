# /bin/bash

JEKYLL_ENV=production bundle exec jekyll build --config _config_local.yml
sudo rm -rf /var/www/blog.pradosh.dev
sudo cp -r _site /var/www/blog.pradosh.dev
JEKYLL_ENV=production bundle exec jekyll build --config _config_firebase.yml
firebase deploy
