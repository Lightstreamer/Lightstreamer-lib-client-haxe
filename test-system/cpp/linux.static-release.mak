BIN = bin/static-release
LS_BASE = ../../bin/cpp/linux/static-release

CXX = g++
CXXFLAGS = -g -Og -std=c++17 -Wall -Wextra -pedantic -Wno-unused-parameter
CPPFLAGS = -I$(LS_BASE)/include
LDFLAGS = 
LDLIBS = $(LS_BASE)/liblightstreamer_client.a

test: test_ssl test_main

test_main:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $@.cpp $(LDFLAGS) $(LDLIBS)
	$(BIN)/$@

test_ssl:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $@.cpp $(LDFLAGS) $(LDLIBS)
	$(BIN)/$@

test_retry: $(LS_LIB)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $@.cpp $(LDFLAGS) $(LDLIBS)
	$(BIN)/$@

test_demo:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $(BIN)/$@ $@.cpp $(LDFLAGS) $(LDLIBS)
	$(BIN)/$@

clean:
	rm -rf $(BIN)
	mkdir -p $(BIN)