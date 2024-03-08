package poco.net;

import cpp.Star;
import cpp.Reference;
import lightstreamer.cpp.CppString;

@:include("Poco/Net/Context.h")
@:native("Poco::Net::Context")
extern class Context {
  function new(
    usage: Usage, 
    privateKeyFile: Reference<CppString>, 
    certificateFile: Reference<CppString>, 
    caLocation: Reference<CppString>/*, 
    ?verificationMode: VerificationMode, 
    ?verificationDepth: Int, 
    ?loadDefaultCAs: Bool, 
    ?cipherList: Reference<CppString>*/);
}

@:include("Poco/Net/Context.h")
@:native("Poco::Net::Context::Ptr")
extern class ContextPtr {
  function new(pCtx: Star<Context>);
}

@:include("Poco/Net/Context.h")
@:native("Poco::Net::Context::Usage")
extern class Usage
{
  static final TLS_CLIENT_USE: Usage;
}
