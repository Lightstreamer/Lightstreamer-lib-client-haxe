package com.lightstreamer.client;

import cpp.Star;
import com.lightstreamer.cpp.CppVector;

@:structAccess
@:include("Lightstreamer/ForwardDcl.h")
@:native("std::vector<Lightstreamer::Subscription*>")
extern class SubscriptionVector extends CppVector<Star<NativeSubscription>> {
  function new();
}