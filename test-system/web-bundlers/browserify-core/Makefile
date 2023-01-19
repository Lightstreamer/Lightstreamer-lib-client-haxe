
all: clean run

build:
	npx browserify main.js -o dist/bundle.js

run: build
	open test.html

clean:
	rm -f dist/*