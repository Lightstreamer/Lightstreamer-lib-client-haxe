/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.client.hxcbridge;

import cpp.Star;
import cpp.Pointer;
import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.cpp.CppStringVector;
import com.lightstreamer.log.NativeLoggerProvider;
import com.lightstreamer.log.LoggerProviderAdapter;
import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.internal.NativeTypes;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("LightstreamerClient")
@:publicFields
@:access(com.lightstreamer.client)
class HxCBridgeLightstreamerClient {

  /*
   * WARNING: Ensure that the lock is acquired before accessing the class internals.
   */
  
  private final _client: LSLightstreamerClient;
  private final _listeners = new ListenerArray<NativeClientListener, ClientListenerAdapter>();

  static function GC() {
    cpp.vm.Gc.run(true);
  }

  static function getLibName(): CppString {
    return LSLightstreamerClient.LIB_NAME;
  }

  static function getLibVersion(): CppString {
    return LSLightstreamerClient.LIB_VERSION;
  }

  static function setLoggerProvider(provider: Star<NativeLoggerProvider>) {
    var _provider = provider == null ? null : new LoggerProviderAdapter(Pointer.fromStar(provider));
    LSLightstreamerClient.setLoggerProvider(_provider);
  }

  #if LS_HAS_COOKIES
  static function addCookies(@:nullSafety(Off) uri: ConstStar<CppString>, @:nullSafety(Off) cookies: ConstStar<CppStringVector>) {
    var cookies: NativeArray<String> = cookies;
    LSLightstreamerClient.addCookies(uri, cookies);
  }

  static function getCookies(@:nullSafety(Off) uri: ConstStar<CppString>): CppStringVector {
    var cookies: NativeArray<String> = LSLightstreamerClient.getCookies(uri);
    return cookies;
  }

  static function clearAllCookies() {
    com.lightstreamer.internal.CookieHelper.instance.clearCookies();
  }
  #end

  #if LS_HAS_TRUST_MANAGER
  static function setTrustManagerFactory(caFile: ConstStar<CppString>, certificateFile: ConstStar<CppString>, privateKeyFile: ConstStar<CppString>, password: ConstStar<CppString>, verifyCert: Bool) {
    @:nullSafety(Off)
    LSLightstreamerClient.setTrustManagerFactory(
      caFile.isEmpty() ? null : caFile,
      certificateFile.isEmpty() ? null : certificateFile,
      privateKeyFile.isEmpty() ? null : privateKeyFile, 
      password.isEmpty() ? null : password, 
      verifyCert
    );
  }
  #end

  @HaxeCBridge.name("LightstreamerClient_new")
  static function create(serverAddress: ConstStar<CppString>, adapterSet: ConstStar<CppString>) {
    @:nullSafety(Off)
    return new HxCBridgeLightstreamerClient(
      serverAddress.isEmpty() ? null : serverAddress, 
      adapterSet.isEmpty() ? null : adapterSet
    );
  }

  private function new(serverAddress: String, adapterSet: String) {
    _client = new LSLightstreamerClient(serverAddress, adapterSet);
  }

  function getConnectionOptions(): HxCBridgeConnectionOptions {
    return new HxCBridgeConnectionOptions(_client.connectionOptions);
  }

  function getConnectionDetails(): HxCBridgeConnectionDetails {
    return new HxCBridgeConnectionDetails(_client.connectionDetails);
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

  function subscribe(sub: HxCBridgeSubscription) {
    _client.subscribe(sub._sub);
  }

  function unsubscribe(sub: HxCBridgeSubscription) {
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