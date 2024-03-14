package poco.net;

import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:include("Poco/Net/HTTPCookie.h")
@:native("Poco::Net::HTTPCookie")
extern class HTTPCookie {
  function new(name: Reference<CppString>, value: Reference<CppString>);
}