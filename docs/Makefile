BASE = ..

.PHONY: python
python:
	haxe --python dummy.py --macro 'include("com.lightstreamer")' -xml $(BASE)/dist/python/python.xml -D doc-gen --no-output -D LS_HAS_PROXY -D LS_HAS_COOKIES -D LS_HAS_TRUST_MANAGER
	haxelib run dox -i $(BASE)/dist/python/python.xml -o $(BASE)/dist/python/pages --toplevel-package com.lightstreamer --keep-field-order

.PHONY: java
java:
	haxe --jvm dummy.jar --macro 'include("com.lightstreamer")' -xml $(BASE)/dist/java/java.xml -D doc-gen --no-output --class-path $(BASE)/src/extern/java
	haxelib run dox -i $(BASE)/dist/java/java.xml -o $(BASE)/dist/java/pages --toplevel-package com.lightstreamer --keep-field-order