
all: clean run

build:
	npx tsc
	npx rollup -c

run: build
	open test.html

clean:
	rm -f dist/*