package com.lightstreamer.client;

import com.lightstreamer.client.NativeTypes.NativeList;

private class ClientEventDispatcher extends EventDispatcher<ClientListener> {}

/**
 * LightstreamerClient class
 **/
#if (js || python) @:expose @:native("LightstreamerClient") #end
#if (java || cs || python) @:nativeGen #end
@:build(com.lightstreamer.client.Macros.synchronizeClass())
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
    com.lightstreamer.client.internal.CookieHelper.instance.addCookies(uri, cookies);
  }

  public static function getCookies(uri: Null<java.net.URI>): NativeList<java.net.HttpCookie> {
    return com.lightstreamer.client.internal.CookieHelper.instance.getCookies(uri);
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