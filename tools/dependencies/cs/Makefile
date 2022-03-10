LIB=../../../lib

build:
	cd Lightstreamer && msbuild Lightstreamer.sln -target:Lightstreamer_Net:Rebuild
	cp -f Lightstreamer/Lightstreamer.Net/bin/Debug/netstandard2.1/Lightstreamer.Net.dll $(LIB)/cs/

clean:
	rm -rf $(LIB)/cs