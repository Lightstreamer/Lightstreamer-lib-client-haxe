package com.lightstreamer.client;

import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:structAccess
@:native("Lightstreamer::ClientListener")
@:include("Lightstreamer/ClientListener.h")
extern class NativeClientListener {
  function onListenEnd(): Void;
  function onListenStart(): Void;
  function onServerError(errorCode: Int, errorMessage: Reference<CppString>): Void;
  function onStatusChange(status: Reference<CppString>): Void;
  function onPropertyChange(property: Reference<CppString>): Void;
}