all: build

build:
	hugo --gc --minify --config=hugo.toml,hugo_local.toml
push: build
	sudo rm -rf /var/www/pradosh.dev/*
	sudo rsync -avzP pradosh.dev/ /var/www/pradosh.dev/
