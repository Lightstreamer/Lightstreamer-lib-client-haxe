package com.lightstreamer.client;

import cpp.Star;
import com.lightstreamer.cpp.CppVector;

@:structAccess
@:native("Lightstreamer::ClientListenerVector")
@:include("Lightstreamer/Utils.h")
extern class ClientListenerVector {
  final v: CppVector<Star<NativeClientListener>>;
  function new();
}