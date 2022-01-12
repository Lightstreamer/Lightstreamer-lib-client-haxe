BASE = ../..
BIN = $(BASE)/bin/web

all: clean run

build:
#	haxe --cwd $(BASE) build.web.hxml
	npx rollup -c

run: build
	open test.html

clean:
	rm -f dist/*