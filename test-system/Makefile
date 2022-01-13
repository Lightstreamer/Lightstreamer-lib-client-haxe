.PHONY: all web ts node java cs py sys

all: web ts node java cs py

sys: ts node java cs py

web:
	cd browserify-full && make
	cd esm-full && make
	cd globals-full && make
	cd requirejs-full && make
	cd rollup-full && make
	cd webpack-full && make
	cd widgets && make

ts:
	cd typescript && make

node:
	cd node && make

java:
	cd java && make

cs:
	cd cs && make

py:
	cd python && make