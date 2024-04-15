#!/bin/sh

g++ -g src/test-bug-ws2.cpp -Iinclude -I${POCO_BASE}/Foundation/include -I${POCO_BASE}/Net/include -I/opt/homebrew/opt/openssl/include -L${POCO_BASE}/lib/Darwin/arm64 -lPocoFoundationd -lPocoNetd -lPocoNetSSLd -std=c++17 -o bin/a.out

bin/a.out

