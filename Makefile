all: build

build:
	sudo docker run --name jekyll-build --rm -it -e JEKYLL_ENV=production --volume=".:/srv/jekyll" --volume="./vendor/bundle:/usr/local/bundle" jekyll/jekyll jekyll build --config _config.yml,_config.local.yml
push:
	rm -rf /var/www/pradosh.dev && cp -r pradosh.dev /var/www/
