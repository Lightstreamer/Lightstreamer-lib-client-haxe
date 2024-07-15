LS_BASE = ../../src/wrapper/cpp
BIN = bin/hxpoco

CXX = g++
CXXFLAGS = -g -Og -std=c++17 -Wall -Wextra -pedantic -Wno-unused-parameter
CPPFLAGS = -I$(LS_BASE)/HxPoco/include
LDFLAGS = 
LDLIBS = -lPocoFoundation -lPocoNet
SRCS = $(LS_BASE)/HxPoco/src/CookieJar.cpp $(LS_BASE)/HxPoco/src/Utils.cpp $(LS_BASE)/HxPoco/src/LineAssembler.cpp

test: test_hxpoco

test_hxpoco:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $(SRCS) $@.cpp $(LDFLAGS) $(LDLIBS)
	$(BIN)/$@

clean:
	rm -rf $(BIN)
	mkdir -p $(BIN)