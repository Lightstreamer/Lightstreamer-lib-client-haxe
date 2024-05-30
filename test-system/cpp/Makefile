CXX = g++
CXXFLAGS = -g -Og -std=c++17 -Wall -Wextra -pedantic -Wno-unused-parameter
CPPFLAGS = -I../../bin/cpp/include -I$(POCO_BASE)/Foundation/include -I$(POCO_BASE)/Net/include -I/opt/homebrew/opt/openssl/include
LDFLAGS = -L$(POCO_BASE)/lib/Darwin/arm64
LDLIBS = -lPocoFoundationd -lPocoNetd -lPocoNetSSLd bin/lightstreamer_client.dylib

test_demo:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) $(LDLIBS) $@.cpp -o bin/$@
	cd bin && ./$@
