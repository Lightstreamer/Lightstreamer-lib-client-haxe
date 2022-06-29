.PHONY: java
java:
	haxe --jvm dummy.jar --macro 'include("com.lightstreamer")' -xml java.xml -D doc-gen --no-output
	haxelib run dox -i java.xml -o java/pages --toplevel-package com.lightstreamer --keep-field-order
# open java/pages/index.html

.PHONY: python
python:
	haxe --python dummy.py --macro 'include("com.lightstreamer")' -xml python.xml -D doc-gen --no-output -D LS_HAS_PROXY -D LS_HAS_COOKIES -D LS_HAS_TRUST_MANAGER
	haxelib run dox -i python.xml -o python/pages --toplevel-package com.lightstreamer --keep-field-order
#	open python/pages/index.html