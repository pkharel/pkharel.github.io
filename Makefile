all: build

build:
	JEKYLL_ENV=production bundle exec jekyll build --config _config.local.yml
docker_build:
	sudo docker run --name jekyll-build --rm -it -e JEKYLL_ENV=production --volume=".:/srv/jekyll" --volume="./vendor/bundle:/usr/local/bundle" jekyll/jekyll jekyll build --config _config.local.yml
push:
	sudo rsync -avzP pradosh.dev /var/www/
