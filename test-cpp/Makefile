CXX = g++
CXXFLAGS = -g -std=c++17 -o bin/main
CPPFLAGS = -I../bin/cpp/include -I${POCO_BASE}/Foundation/include -I${POCO_BASE}/Net/include -I/opt/homebrew/opt/openssl/include -I../../utpp/include
LDLIBS = -L${POCO_BASE}/lib/Darwin/arm64 -lPocoFoundationd -lPocoNetd lightstreamer_client.dylib

SRCS = main.cpp

HAXE_INCLUDE_DIR = ../bin/cpp/include
NATIVE_HEADERS = $(HAXE_INCLUDE_DIR)/Lightstreamer/LightstreamerClient.h $(HAXE_INCLUDE_DIR)/Lightstreamer/ClientListener.h $(HAXE_INCLUDE_DIR)/Lightstreamer/Utils.h

LS_NS = Lightstreamer
LS_DIR = src/wrapper/cpp
LS_HDRS = $(patsubst $(LS_DIR)/include/%,$(HXCPP_BUILD_DIR)/include/%,$(wildcard $(LS_DIR)/include/$(LS_NS)/*.h))
LS_SRCS = $(patsubst $(LS_DIR)/src/%,$(HXCPP_BUILD_DIR)/src/$(LS_NS)/%,$(wildcard $(LS_DIR)/src/*.cpp))

HX_FILES = $(HXPOCO_HDRS) $(HXPOCO_SRCS) $(LS_HDRS) $(LS_SRCS)

build:
	mkdir -p bin
	$(CXX) $(SRCS) $(CXXFLAGS) $(CPPFLAGS) $(LDLIBS)
	bin/main

build-all: haxe build

../bin/cpp/include/%.h: ../src/wrapper/cpp/include/%.h
	mkdir -p $(@D)
	cp $< $@

haxe: $(NATIVE_HEADERS)
	cd .. && haxe build.cpp.hxml
	cp ../bin/cpp/lightstreamer_client.dylib lightstreamer_client.dylib

clean:
	rm -rf bin

clean-all: clean
	rm -f lightstreamer_client.dylib
	rm -rf ../bin/cpp