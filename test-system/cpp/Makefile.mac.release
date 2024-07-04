BIN = bin/release
LS_BASE = $(abspath ../../bin/cpp/mac/release)

CXX = g++
CXXFLAGS = -g -Og -std=c++17 -Wall -Wextra -pedantic -Wno-unused-parameter
CPPFLAGS = -I$(LS_BASE)/include
LDFLAGS  = -L$(LS_BASE)
LDLIBS   = -llightstreamer_client
LD_LIB_PATH = $(LS_BASE)

test: test_ssl test_main

test_main:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $@.cpp $(LDFLAGS) $(LDLIBS) 
	DYLD_LIBRARY_PATH=$(LD_LIB_PATH) $(BIN)/$@

test_ssl:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $@.cpp $(LDFLAGS) $(LDLIBS) 
	DYLD_LIBRARY_PATH=$(LD_LIB_PATH) $(BIN)/$@

test_retry:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $@.cpp $(LDFLAGS) $(LDLIBS) 
	DYLD_LIBRARY_PATH=$(LD_LIB_PATH) $(BIN)/$@

test_demo:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $@.cpp $(LDFLAGS) $(LDLIBS) 
	DYLD_LIBRARY_PATH=$(LD_LIB_PATH) $(BIN)/$@

clean:
	rm -rf $(BIN)
	mkdir -p $(BIN)