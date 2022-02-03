BASE=../../bin/cpp
INCLUDE=$(BASE)/include

run: build
	dist/a.out

build:
	g++ $(BASE)/liboutput.a -I$(INCLUDE) main.cpp -o dist/a.out