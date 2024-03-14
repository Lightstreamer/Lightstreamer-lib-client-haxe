package poco.net;

import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:structAccess
@:include("Poco/Net/HTTPCookie.h")
@:native("Poco::Net::HTTPCookie")
extern class HTTPCookie {
  function new(name: Reference<CppString>, value: Reference<CppString>);
  function toString(): CppString;
}