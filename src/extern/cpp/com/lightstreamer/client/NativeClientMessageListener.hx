package com.lightstreamer.client;

import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:structAccess
@:native("Lightstreamer::ClientMessageListener")
@:include("Lightstreamer/ClientMessageListener.h")
extern class NativeClientMessageListener {
  function onAbort(originalMessage: Reference<CppString>, sentOnNetwork: Bool): Void;
  function onDeny(originalMessage: Reference<CppString>, code: Int, error: Reference<CppString>): Void;
  function onDiscarded(originalMessage: Reference<CppString>): Void;
  function onError(originalMessage: Reference<CppString>): Void;
  function onProcessed(originalMessage: Reference<CppString>, response: Reference<CppString>): Void;
}