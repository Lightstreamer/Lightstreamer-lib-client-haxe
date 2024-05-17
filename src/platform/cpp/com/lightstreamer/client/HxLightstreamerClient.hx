package com.lightstreamer.client;

import cpp.Star;
import cpp.Pointer;
import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.log.LoggerProvider;
import com.lightstreamer.client.LightstreamerClient;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("LightstreamerClient")
@:publicFields
@:access(com.lightstreamer.client)
class HxLightstreamerClient {

  /*
   * WARNING: Ensure that the lock is acquired before accessing the class internals.
   */
  
  private final _client: LSLightstreamerClient;
  private final _listeners = new HxListeners<NativeClientListener, ClientListenerAdapter>();

  static function getLibName(): CppString {
    return LSLightstreamerClient.LIB_NAME;
  }

  static function getLibVersion(): CppString {
    return LSLightstreamerClient.LIB_VERSION;
  }

  static function setLoggerProvider(provider: LoggerProvider) {
    LSLightstreamerClient.setLoggerProvider(provider);
  }

  @HaxeCBridge.name("LightstreamerClient_new")
  static function create(serverAddress: ConstStar<CppString>, adapterSet: ConstStar<CppString>) {
    @:nullSafety(Off)
    return new HxLightstreamerClient(serverAddress, adapterSet);
  }

  private function new(serverAddress: String, adapterSet: String) {
    _client = new LSLightstreamerClient(serverAddress, adapterSet);
  }

  function getConnectionDetails() {
    return new HxConnectionDetails(_client.connectionDetails);
  }

  function addListener(l: cpp.Star<NativeClientListener>) {
    _client.lock.synchronized(() -> 
      _listeners.add(l, _client.addListener)
    );
  }

  function removeListener(l: cpp.Star<NativeClientListener>) {
    _client.lock.synchronized(() -> 
      _listeners.remove(l, _client.removeListener)
    );
  }

  function getListeners(): ClientListenerVector {
    var res = new ClientListenerVector();
    /*
     * WARNING: Do not use the synchronized method; otherwise, the closure will operate on a copy of the vector to be returned.
     */
    _client.lock.acquire();
      for (l in _listeners) {
        var p: cpp.Pointer<NativeClientListener> = l._1;
        var pp: cpp.Star<NativeClientListener> = p.ptr;
        res.push(pp);
      }
    _client.lock.release();
    return res;
  }

  function getStatus(): CppString {
    return _client.getStatus();
  }

  function connect() {
    _client.connect();
  }

  function disconnect() {
    _client.disconnect();
  }

  function subscribe(sub: HxSubscription) {
    _client.subscribe(sub._sub);
  }

  function unsubscribe(sub: HxSubscription) {
    _client.unsubscribe(sub._sub);
  }

  function getSubscriptions(): SubscriptionVector {
    var subs = _client.machine.getSubscriptions();
    var res = new SubscriptionVector();
    for (sub in subs) {
      if (sub.wrapper != null) {
        res.push(sub.wrapper.ptr);
      }
    }
    return res;
  }

  function sendMessage(@:nullSafety(Off) message: ConstStar<CppString>, sequence: ConstStar<CppString>, delayTimeout: Int, listener: Star<NativeClientMessageListener>, enqueueWhileDisconnected: Bool) {
    _client.sendMessage(
      message, 
      @:nullSafety(Off) (sequence.isEmpty() ? null : sequence), 
      delayTimeout, 
      listener == null ? null : new ClientMessageListenerAdapter(Pointer.fromStar(listener)), 
      enqueueWhileDisconnected);
  }
}