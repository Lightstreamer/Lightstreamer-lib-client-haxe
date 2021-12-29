package com.lightstreamer.client;

typedef Millis = haxe.Int64

typedef Exception = #if js
js.lib.Error
#elseif java
java.lang.Throwable
#elseif cs
cs.system.Exception
#end