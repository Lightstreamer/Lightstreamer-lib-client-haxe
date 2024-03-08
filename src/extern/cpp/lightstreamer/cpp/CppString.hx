package lightstreamer.cpp;

import cpp.StdString;
import cpp.NativeString;
import cpp.ConstCharStar;

@:include("string")
@:native("std::string")
extern class CppString {
  function new();
  static inline function of(s: String): CppString {
    return untyped __cpp__("std::string({0}.c_str())", s);
  }
}