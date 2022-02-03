BASE = ../..
BIN = $(BASE)/bin/node

all: clean run

build:
#	haxe --cwd $(BASE) build.node.hxml
	npx tsc
	npx rollup -c

run: build
	open test.html

clean:
	rm -f dist/*