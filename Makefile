HXCPP_BUILD_DIR = bin/cpp
TEST_HXCPP_BUILD_DIR = bin-test/cpp

HXPOCO_NS = Lightstreamer/HxPoco
HXPOCO_DIR = src-hxpoco
HXPOCO_HDRS = $(patsubst $(HXPOCO_DIR)/include/%,$(HXCPP_BUILD_DIR)/include/%,$(wildcard $(HXPOCO_DIR)/include/$(HXPOCO_NS)/*.h))
HXPOCO_SRCS = $(patsubst $(HXPOCO_DIR)/src/%,$(HXCPP_BUILD_DIR)/src/$(HXPOCO_NS)/%,$(wildcard $(HXPOCO_DIR)/src/*.cpp))
TEST_HXPOCO_HDRS = $(patsubst $(HXPOCO_DIR)/include/%,$(TEST_HXCPP_BUILD_DIR)/include/%,$(wildcard $(HXPOCO_DIR)/include/$(HXPOCO_NS)/*.h))
TEST_HXPOCO_SRCS = $(patsubst $(HXPOCO_DIR)/src/%,$(TEST_HXCPP_BUILD_DIR)/src/$(HXPOCO_NS)/%,$(wildcard $(HXPOCO_DIR)/src/*.cpp))

LS_NS = Lightstreamer
LS_DIR = src/wrapper/cpp
LS_HDRS = $(patsubst $(LS_DIR)/include/%,$(HXCPP_BUILD_DIR)/include/%,$(wildcard $(LS_DIR)/include/$(LS_NS)/*.h))
LS_SRCS = $(patsubst $(LS_DIR)/src/%,$(HXCPP_BUILD_DIR)/src/$(LS_NS)/%,$(wildcard $(LS_DIR)/src/*.cpp))
TEST_LS_HDRS = $(patsubst $(LS_DIR)/include/%,$(TEST_HXCPP_BUILD_DIR)/include/%,$(wildcard $(LS_DIR)/include/$(LS_NS)/*.h))
TEST_LS_SRCS = $(patsubst $(LS_DIR)/src/%,$(TEST_HXCPP_BUILD_DIR)/src/$(LS_NS)/%,$(wildcard $(LS_DIR)/src/*.cpp))

HX_FILES = $(HXPOCO_HDRS) $(HXPOCO_SRCS) $(LS_HDRS) $(LS_SRCS)
TEST_HX_FILES = $(TEST_HXPOCO_HDRS) $(TEST_HXPOCO_SRCS) $(TEST_LS_HDRS) $(TEST_LS_SRCS)

.PHONY: build test clean

build: $(HX_FILES)
	haxe build.cpp.hxml

test: $(TEST_HX_FILES)
	haxe test.cpp.hxml com.lightstreamer.internal.BuildConfig
	bin-test/cpp/TestAll-debug

$(HXCPP_BUILD_DIR)/include/%.h: $(HXPOCO_DIR)/include/%.h
	mkdir -p $(@D)
	cp $< $@

$(HXCPP_BUILD_DIR)/src/$(HXPOCO_NS)/%.cpp: $(HXPOCO_DIR)/src/%.cpp
	mkdir -p $(@D)
	cp $< $@

$(HXCPP_BUILD_DIR)/include/%.h: $(LS_DIR)/include/%.h
	mkdir -p $(@D)
	cp $< $@

$(HXCPP_BUILD_DIR)/src/$(LS_NS)/%.cpp: $(LS_DIR)/src/%.cpp
	mkdir -p $(@D)
	cp $< $@

$(TEST_HXCPP_BUILD_DIR)/include/%.h: $(HXPOCO_DIR)/include/%.h
	mkdir -p $(@D)
	cp $< $@

$(TEST_HXCPP_BUILD_DIR)/src/$(HXPOCO_NS)/%.cpp: $(HXPOCO_DIR)/src/%.cpp
	mkdir -p $(@D)
	cp $< $@

$(TEST_HXCPP_BUILD_DIR)/include/%.h: $(LS_DIR)/include/%.h
	mkdir -p $(@D)
	cp $< $@

$(TEST_HXCPP_BUILD_DIR)/src/$(LS_NS)/%.cpp: $(LS_DIR)/src/%.cpp
	mkdir -p $(@D)
	cp $< $@

clean:
	rm -rf bin/cpp
	rm -rf bin-test/cpp