package com.lightstreamer.client;

using StringTools;

typedef Millis = haxe.Int64

typedef ExceptionImpl = #if js
js.lib.Error
#elseif java
java.lang.Throwable
#elseif cs
cs.system.Exception
#elseif python
python.Exceptions.BaseException
#else
haxe.Exception
#end

abstract Exception(ExceptionImpl) {

  @:access(haxe.Exception.caught)
  inline public function details() {
    return haxe.Exception.caught(this).details();
  }
}

#if java
typedef IllegalArgumentException = java.lang.IllegalArgumentException
#elseif cs
typedef IllegalArgumentException = cs.system.ArgumentException
#else
class IllegalArgumentException extends haxe.Exception {}
#end

abstract ServerAddress(String) to String {
  public function new(address: String) {
    if (!address.startsWith("http://") && !address.startsWith("https://")) {
      throw new IllegalArgumentException("serverAddress scheme must be http or https");
    }
    this = address;
  }
}