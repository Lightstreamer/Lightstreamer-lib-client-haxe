CXX = g++
CXXFLAGS = -g -std=c++17
CPPFLAGS = -I../bin/cpp/include -I${POCO_BASE}/Foundation/include -I${POCO_BASE}/Net/include -I/opt/homebrew/opt/openssl/include -I../../utpp/include
LDFLAGS = -L${POCO_BASE}/lib/Darwin/arm64
LDLIBS = -lPocoFoundationd -lPocoNetd lightstreamer_client.dylib
SRCS = main.cpp

build:
	mkdir -p bin
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) $(LDLIBS) $(SRCS) -o bin/main
	bin/main $(TEST_PATTERN)

build-all: haxe build

haxe:
	$(MAKE) -C .. build
	cp ../bin/cpp/lightstreamer_client.dylib lightstreamer_client.dylib

clean:
	rm -rf bin

clean-all: clean
	rm -f lightstreamer_client.dylib
	rm -rf ../bin/cpp