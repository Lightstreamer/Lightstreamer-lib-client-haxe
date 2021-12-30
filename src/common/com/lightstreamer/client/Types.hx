package com.lightstreamer.client;

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