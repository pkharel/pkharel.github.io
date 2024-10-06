all: build

build:
	sudo docker run --rm -it -e JEKYLL_ENV=production --volume=".:/srv/jekyll" --volume="./vendor/bundle:/usr/local/bundle" jekyll/jekyll jekyll build --config _config.yml,_config.local.yml
push:
	rm -rf /var/www/blog.pradosh.dev && cp -r blog.pradosh.dev /var/www/
