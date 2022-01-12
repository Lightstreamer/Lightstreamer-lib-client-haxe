BASE = ../..
BIN = $(BASE)/bin/cs

all: clean run
	
build:
#	haxe --cwd $(BASE) build.cs.hxml
	cp $(BIN)/bin/cs.dll .
	csc -r:cs.dll Program.cs QuoteListener.cs

run: build
	mono Program.exe

clean:
	rm -f *.exe *.dll