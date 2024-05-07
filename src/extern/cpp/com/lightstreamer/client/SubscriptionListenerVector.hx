package com.lightstreamer.client;

import cpp.Star;
import com.lightstreamer.cpp.CppVector;
import com.lightstreamer.client.NativeSubscriptionListener;

@:structAccess
@:include("vector")
@:native("std::vector<Lightstreamer::SubscriptionListener*>")
extern class SubscriptionListenerVector extends CppVector<Star<NativeSubscriptionListener>> {
  function new();
}