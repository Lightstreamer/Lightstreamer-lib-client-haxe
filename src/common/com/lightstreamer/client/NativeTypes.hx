package com.lightstreamer.client;

typedef Long = #if (java || cs) haxe.Int64 #else Int #end

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