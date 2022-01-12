BASE = ../..
BIN = $(BASE)/bin/web

all: clean run

build:
#	haxe --cwd $(BASE) build.web.hxml
	npx browserify main.js -o dist/bundle.js

run: build
	open test.html

clean:
	rm -f dist/*