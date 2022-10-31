BASE=../..

run:
	cp $(BASE)/bin/python/com_lightstreamer_client.py $(BASE)/dist/python/lightstreamer-client/src/lightstreamer/client
	cp $(BASE)/tools/dependencies/python/com_lightstreamer_net.py $(BASE)/dist/python/lightstreamer-client/src/lightstreamer/client	
	haxe test.python.core.hxml
	python3 $(BASE)/bin-test/python/test-core.py