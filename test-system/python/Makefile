BASE = ../..
BIN = $(BASE)/bin/python

all: clean run
	
build:
#	haxe --cwd $(BASE) build.python.hxml
	cp $(BIN)/lightstreamer.py .
	cp $(BIN)/com_lightstreamer_net.py .

run: build
	python3 test.py

clean:
	rm -f lightstreamer.py
	rm -f com_lightstreamer_net.py