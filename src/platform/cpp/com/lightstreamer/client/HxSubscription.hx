package com.lightstreamer.client;

import cpp.Star;
import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.cpp.CppStringVector;
import com.lightstreamer.internal.NativeTypes.NativeArray;
import com.lightstreamer.client.Subscription.LSSubscription;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("Subscription")
@:publicFields
@:access(com.lightstreamer.client)
@:nullSafety(Off)
class HxSubscription {

  /*
   * WARNING: Ensure that the lock is acquired before accessing the class internals.
   */
  
  private final _sub: LSSubscription;
  private final _listeners = new HxListeners<NativeSubscriptionListener, SubscriptionListenerAdapter>();

  @HaxeCBridge.name("Subscription_new")
  static function create(mode: ConstStar<CppString>, items: ConstStar<CppStringVector>, fields: ConstStar<CppStringVector>, wrapper: Star<NativeSubscription> = null) {
    var _items = items.toHaxe();
    var _fields = fields.toHaxe();
    var _wrapper = wrapper == null ? null : cpp.Pointer.fromStar(wrapper);
    return new HxSubscription(mode, _items, _fields, _wrapper);
  }

  private function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>, wrapper: Null<cpp.Pointer<NativeSubscription>> = null) {
    _sub = new LSSubscription(mode, items, fields, wrapper);
  }

  function addListener(l: cpp.Star<NativeSubscriptionListener>) {
    _sub.lock.synchronized(() -> 
      _listeners.add(l, _sub.addListener)
    );
  }

  function removeListener(l: cpp.Star<NativeSubscriptionListener>) {
    _sub.lock.synchronized(() -> 
      _listeners.remove(l, _sub.removeListener)
    );
  }

  function getListeners(): SubscriptionListenerVector {
    var res = new SubscriptionListenerVector();
    /*
     * WARNING: Do not use the synchronized method; otherwise, the closure will operate on a copy of the vector to be returned.
     */
    _sub.lock.acquire();
      for (l in _listeners) {
        var p: cpp.Pointer<NativeSubscriptionListener> = l._1;
        var pp: cpp.Star<NativeSubscriptionListener> = p.ptr;
        res.push(pp);
      }
    _sub.lock.release();
    return res;
  }

  function isActive() {
    return _sub.isActive();
  }

  function isSubscribed() {
    return _sub.isSubscribed();
  }

  function setDataAdapter(val: ConstStar<CppString>) {
    _sub.setDataAdapter(val);
  }

  function getCommandPosition() {
    return _sub.getCommandPosition();
  }

  function getKeyPosition() {
    return _sub.getKeyPosition();
  }

  function setCommandSecondLevelDataAdapter(val: ConstStar<CppString>) {
    _sub.setCommandSecondLevelDataAdapter(val);
  }

  function setCommandSecondLevelFields(fields: ConstStar<CppStringVector>) {
    var _fields = fields == null ? null : fields.toHaxe();
    _sub.setCommandSecondLevelFields(_fields);
  }
}