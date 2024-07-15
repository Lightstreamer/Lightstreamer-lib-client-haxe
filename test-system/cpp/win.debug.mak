BIN = bin\debug
LS_BASE = $(abspath ..\..\bin\cpp\win\debug)

CXX = cl
CXXFLAGS = /W3 /EHsc /std:c++17 /Fo: $(BIN)\ /MDd
CPPFLAGS = -I$(LS_BASE)\include
LDFLAGS  = /link
LDLIBS   = $(LS_BASE)\obj\lib\lightstreamer_clientd.lib
LD_LIB_PATH = $(LS_BASE)

test: test_ssl test_main

test_main:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $@.cpp $(LDFLAGS) /out:$(BIN)\$@.exe $(LDLIBS) 
	set PATH=$(LD_LIB_PATH);%PATH% && $(BIN)\$@.exe

test_ssl:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $@.cpp $(LDFLAGS) /out:$(BIN)\$@.exe $(LDLIBS) 
	set PATH=$(LD_LIB_PATH);%PATH% && $(BIN)\$@.exe

test_retry:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $@.cpp $(LDFLAGS) /out:$(BIN)\$@.exe $(LDLIBS) 
	set PATH=$(LD_LIB_PATH);%PATH% && $(BIN)\$@.exe

test_demo:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $@.cpp $(LDFLAGS) /out:$(BIN)\$@.exe $(LDLIBS) 
	set PATH=$(LD_LIB_PATH);%PATH% && $(BIN)\$@.exe

clean:
	rmdir /s/q $(BIN)
	mkdir $(BIN)