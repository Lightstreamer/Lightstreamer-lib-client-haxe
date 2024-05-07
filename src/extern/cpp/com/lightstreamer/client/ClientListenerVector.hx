package com.lightstreamer.client;

import cpp.Star;
import com.lightstreamer.cpp.CppVector;

@:structAccess
@:include("vector")
@:native("std::vector<Lightstreamer::ClientListener*>")
extern class ClientListenerVector extends CppVector<Star<NativeClientListener>> {
  function new();
}