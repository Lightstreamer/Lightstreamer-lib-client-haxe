BIN = bin\release
LS_BASE = $(abspath ..\..\bin\cpp\win\release)

CXX = cl
CXXFLAGS = /W3 /EHsc /std:c++17 /Fo: $(BIN)\ /MD
CPPFLAGS = -I$(LS_BASE)\include
LDFLAGS  = /link
LDLIBS   = $(LS_BASE)\obj\lib\lightstreamer_client.lib
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