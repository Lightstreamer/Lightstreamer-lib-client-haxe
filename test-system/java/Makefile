BASE = ../..
BIN = $(BASE)/bin/java

all: clean run

build:
#	haxe --cwd $(BASE) build.java.hxml
	javac -cp $(BIN)/ls-javase-client.jar myapp/Main.java

run: build
	java -cp .:$(BIN)/ls-javase-client.jar myapp.Main

clean:
	rm -f myapp/*.class