CXX = g++
CXXFLAGS = -g -std=c++17 -o bin/test
CPPFLAGS = -Iinclude -I${POCO_BASE}/Foundation/include -I${POCO_BASE}/Net/include -I/opt/homebrew/opt/openssl/include -I../../utpp/include
LDLIBS   = -L${POCO_BASE}/lib/Darwin/arm64 -lPocoFoundationd -lPocoNetd

SRCS = test/test_hxpoco.cpp src/CookieJar.cpp src/Utils.cpp src/LineAssembler.cpp

.PHONY: test

test:
	mkdir -p bin
	$(CXX) $(SRCS) $(CXXFLAGS) $(CPPFLAGS) $(LDLIBS)
	bin/test

clean:
	rm -rf bin