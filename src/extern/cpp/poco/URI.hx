package poco;

import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:native("Poco::URI")
@:include("Poco/URI.h")
extern class URI {
  function new(uri: Reference<CppString>);
}