package com.lightstreamer.client;

import com.lightstreamer.client.internal.ClientMachine;
import com.lightstreamer.internal.NativeTypes.NativeList;
import com.lightstreamer.internal.EventDispatcher;
import com.lightstreamer.internal.Factories;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class ClientEventDispatcher extends EventDispatcher<ClientListener> {}

/**
 * LightstreamerClient class
 **/
#if (js || python) @:expose @:native("LightstreamerClient") #end
#if (java || cs || python) @:nativeGen #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class LightstreamerClient {
  public static final LIB_NAME: String = "TODO";
  public static final LIB_VERSIONE: String = "TODO";

  public final connectionDetails: ConnectionDetails;
  public final connectionOptions: ConnectionOptions;
  final eventDispatcher = new ClientEventDispatcher();
  final machine: ClientMachine;

  public static function setLoggerProvider(provider: com.lightstreamer.log.LoggerProvider): Void {
    com.lightstreamer.log.LogManager.setLoggerProvider(provider);
  }

  #if java
  public static function addCookies(uri: java.net.URI, cookies: NativeList<java.net.HttpCookie>): Void {
    com.lightstreamer.internal.CookieHelper.instance.addCookies(uri, cookies);
  }

  public static function getCookies(uri: Null<java.net.URI>): NativeList<java.net.HttpCookie> {
    return com.lightstreamer.internal.CookieHelper.instance.getCookies(uri);
  }

  public static function setTrustManagerFactory(factory: java.javax.net.ssl.TrustManagerFactory) {
    com.lightstreamer.internal.Globals.instance.setTrustManagerFactory(factory);
  }
  #elseif LS_NODE
  public static function addCookies(uri: String, cookies: Array<String>): Void {
    com.lightstreamer.internal.CookieHelper.instance.addCookies(uri, cookies);
  }

  public static function getCookies(uri: Null<String>): Array<String> {
    return com.lightstreamer.internal.CookieHelper.instance.getCookies(uri);
  }
  #elseif cs
  public static function addCookies(uri: cs.system.Uri, cookies: cs.system.net.CookieCollection): Void {
    com.lightstreamer.cs.CookieHelper.instance.AddCookies(uri, cookies);
  }

  public static function getCookies(uri: cs.system.Uri): cs.system.net.CookieCollection {
    return com.lightstreamer.cs.CookieHelper.instance.GetCookies(uri);
  }

  public static function setTrustManagerFactory(factory: cs.system.net.security.RemoteCertificateValidationCallback) {
    com.lightstreamer.internal.Globals.instance.setRemoteCertificateValidationCallback(factory);
  }
  #end

  /**
   * LightstreamerClient ctor
   * @param serverAddress 
   * @param adapterSet 
   */
  public function new(serverAddress: String, adapterSet: String) {
    connectionDetails = new ConnectionDetails(@:nullSafety(Off) this);
    connectionOptions = new ConnectionOptions(@:nullSafety(Off) this);
    machine = new ClientMachine(this, serverAddress, adapterSet, createWsClient, createHttpClient, createHttpClient, createTimer, randomMillis, createReachabilityManager);
  }

  public function addListener(listener: ClientListener): Void {
    eventDispatcher.addListenerAndFireOnListenStart(listener, this);
  }

  public function removeListener(listener: ClientListener): Void {
    eventDispatcher.removeListenerAndFireOnListenEnd(listener, this);
  }

  public function getListeners(): NativeList<ClientListener> {
    return new NativeList(eventDispatcher.getListeners());
  }

  /**
   * connect
   */
  public function connect(): Void {
    machine.connect();
  }

  public function disconnect(): Void {
    machine.disconnect();
  }

  public function getStatus(): String {
    return machine.getStatus();
  }

  #if (java || cs)
  overload public function sendMessage(message: String) {
    machine.sendMessage(message, null, -1, null, false);
  }

  overload public function sendMessage(message: String, sequence: Null<String>, delayTimeout: Int, listener: Null<ClientMessageListener>, enqueueWhileDisconnected: Bool): Void {
    machine.sendMessage(message, sequence, delayTimeout, listener, enqueueWhileDisconnected);
  }
  #else
  public function sendMessage(message: String, sequence: Null<String>, delayTimeout: Null<Int>, listener: Null<ClientMessageListener>, enqueueWhileDisconnected: Null<Bool>): Void {
    machine.sendMessage(message, sequence, delayTimeout != null ? delayTimeot : -1, listener, enqueueWhileDisconnected != null ? enqueueWhileDisconnected : false);
  }
  #end

  public function subscribe(subscription: Subscription): Void {
    machine.subscribeExt(subscription);
  }

  public function unsubscribe(subscription: Subscription) {
    machine.unsubscribe(subscription);
  }

  public function getSubscriptions(): NativeList<Subscription> {
    return new NativeList(machine.getSubscriptions());
  }

  #if LS_MPN
  public function registerForMpn(mpnDevice: com.lightstreamer.client.mpn.MpnDevice) {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.registerForMpn(mpnDevice);
  }

  public function subscribeMpn(mpnSubscription: com.lightstreamer.client.mpn.MpnSubscription, coalescing: Bool) {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.subscribeMpn(mpnSubscription, coalescing);
  }

  public function unsubscribeMpn(mpnSubscription: com.lightstreamer.client.mpn.MpnSubscription) {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.unsubscribeMpn(mpnSubscription);
  }

  public function unsubscribeMpnSubscriptions(filter: Null<String>) {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.unsubscribeMpnSubscriptions(filter);
  }

  public function getMpnSubscriptions(filter: Null<String>): NativeList<com.lightstreamer.client.mpn.MpnSubscription> {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    return new NativeList(machine.getMpnSubscriptions(filter));
  }

  public function findMpnSubscription(subscriptionId: String): Null<com.lightstreamer.client.mpn.MpnSubscription> {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.findMpnSubscription(subscriptionId);
  }
  #end
}