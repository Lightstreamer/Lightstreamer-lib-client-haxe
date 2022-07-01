BASE = ../..

run:
	python3 test.py

build:
	cd $(BASE) && haxe release.python.hxml
	cd $(BASE)/dist/python/lightstreamer-client && python3 -m pip install -e .