package com.lightstreamer.client;

import com.lightstreamer.internal.NativeTypes.NativeList;
import com.lightstreamer.internal.EventDispatcher;

private class ClientEventDispatcher extends EventDispatcher<ClientListener> {}

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
  final lock = new com.lightstreamer.internal.RLock();

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
  @:nullSafety(Off)
  public function new(serverAddress: String, adapterSet: String) {
    // workaround for https://github.com/HaxeFoundation/haxe/issues/10584
    connectionDetails = null; connectionOptions = null;
    connectionDetails = new ConnectionDetails(this);
    connectionOptions = new ConnectionOptions(this);
    if (serverAddress != null) {
      connectionDetails.setServerAddress(serverAddress);
    }
    if (adapterSet != null) {
      connectionDetails.setAdapterSet(adapterSet);
    }
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
    trace("LS.connect");
  }

  public function disconnect(): Void {
    trace("LS.disconnect");
  }

  public function getStatus(): String {
    return "";
  }

  public function subscribe(subscription: Subscription): Void {
    trace("LS.subscribe");
  }

  public function unsubscribe(subscription: Subscription): Void {
    
  }

  public function getSubscriptions(): NativeList<Subscription> {
    return new NativeList([]);
  }

  public function sendMessage(message: String): Void {}

  // TODO overload
  // public function sendMessage(message: String, sequence: String, delayTimeout: Long, listener: ClientMessageListener, enqueueWhileDisconnected: Bool) {}



  // #if java
  // public overload function subscribe(subscription: Subscription) {
  //   trace("LS.subscribe");
  // }

  // public overload function subscribe(subscription: MpnSubscription, coalescing: Bool) {
  //   trace("LS.subscribeMpn");
  // }
  // #else
  // public function subscribe(subscription: Subscription) {
  //   trace("LS.subscribe");
  // }
  // #end
}