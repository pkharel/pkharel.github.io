all: build serve

build:
	sudo docker run --rm -it --volume=".:/srv/jekyll" --volume="./vendor/bundle:/usr/local/bundle" jekyll/jekyll jekyll build --config _config.local.yml
serve:
	docker run --name myblog --volume=".:/srv/jekyll" -p 4000:4000 -it jekyll/jekyll jekyll serve --watch --
