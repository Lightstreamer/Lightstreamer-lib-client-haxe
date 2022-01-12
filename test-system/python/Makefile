BASE = ../..
BIN = $(BASE)/bin/python

all: clean run
	
build:
#	haxe --cwd $(BASE) build.python.hxml
	cp $(BIN)/lightstreamer.py .

run: build
	python3 test.py

clean:
	rm -f lightstreamer.py
	rm -f $(BIN)/*