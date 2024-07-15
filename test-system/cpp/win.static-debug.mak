BIN = bin\static-debug
LS_BASE = $(abspath ..\..\bin\cpp\win\static-debug)

CXX = cl
CXXFLAGS = /W3 /EHsc /std:c++17 /Fo: $(BIN)\ /MTd
CPPFLAGS = -I$(LS_BASE)\include
LDFLAGS  = /link
LDLIBS   = $(LS_BASE)\lightstreamer_clientd.lib

test: test_ssl test_main

test_main:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $@.cpp $(LDFLAGS) /out:$(BIN)\$@.exe $(LDLIBS) 
	$(BIN)\$@.exe

test_ssl:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $@.cpp $(LDFLAGS) /out:$(BIN)\$@.exe $(LDLIBS) 
	$(BIN)\$@.exe

test_retry:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $@.cpp $(LDFLAGS) /out:$(BIN)\$@.exe $(LDLIBS) 
	$(BIN)\$@.exe

test_demo:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $@.cpp $(LDFLAGS) /out:$(BIN)\$@.exe $(LDLIBS) 
	$(BIN)\$@.exe

clean:
	rmdir /s/q $(BIN)
	mkdir $(BIN)