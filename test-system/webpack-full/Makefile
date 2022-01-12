BASE = ../..
BIN = $(BASE)/bin/web

all: clean run

build:
#	haxe --cwd $(BASE) build.web.hxml
	npx webpack

run: build
	open test.html

clean:
	rm -f dist/*