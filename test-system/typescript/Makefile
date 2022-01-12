BASE = ../..
BIN = $(BASE)/bin/node

all: clean run

build:
#	haxe --cwd $(BASE) build.node.hxml
	npx tsc main.ts

run: build
	node main.js

clean:
	rm -f main.js