# /bin/bash

# Build local iste
if [[ $1 == "local" || $1 == "all" ]]; then
  JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config.local.yml
  # Delete old file and copy over new ones (local build)
  sudo rm -rf /var/www/blog.pradosh.dev
  sudo cp -r _site /var/www/blog.pradosh.dev
fi
if [[ $1 == "firebase" || $1 == "all" ]]; then
  # Build and deploy to firebase
  JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config.firebase.yml
  firebase deploy
fi
