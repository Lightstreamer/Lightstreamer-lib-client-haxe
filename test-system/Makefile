.PHONY: all web web_all ts node java cs py sys php rollup-full rollup-core

all: web_all ts node java cs py php

sys: ts node java cs py php

web: rollup-full

rollup-full:
	cd rollup-full && make

rollup-core:
	cd rollup-core && make

web_all:
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

php:
	cd php && make