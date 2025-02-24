
all: clean run

build:
	npx rollup -c

run: build
	open -a "Google Chrome" test.html

clean:
	rm -f dist/*