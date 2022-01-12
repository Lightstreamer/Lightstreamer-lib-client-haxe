BASE = ../..
BIN = $(BASE)/bin/node

all: clean run
	
build:
#	haxe --cwd $(BASE) build.node.hxml

run: build
	node test.js
	node test-min.js

clean: