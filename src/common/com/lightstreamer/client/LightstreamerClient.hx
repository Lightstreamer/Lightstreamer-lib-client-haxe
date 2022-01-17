package com.lightstreamer.client;

import com.lightstreamer.log.LogManager;

/**
 * LightstreamerClient class
 **/
#if (js || python) @:expose @:native("LightstreamerClient") #end
#if (java || cs || python) @:nativeGen #end
class LightstreamerClient {
  public final connectionDetails = new ConnectionDetails();
  public final connectionOptions = new ConnectionOptions();

  public static final LIB_NAME: String = "TODO";
  public static final LIB_VERSIONE: String = "TODO";

  public static function setLoggerProvider(provider: com.lightstreamer.log.LoggerProvider): Void {
    com.lightstreamer.log.LogManager.setLoggerProvider(provider);
  }

  /**
   * LightstreamerClient ctor
   * @param serverAddress 
   * @param adapterSet 
   */
  public function new(serverAddress: String, adapterSet: String) {
    if (serverAddress != null) {
      connectionDetails.setServerAddress(serverAddress);
    }
    if (adapterSet != null) {
      connectionDetails.setAdapterSet(adapterSet);
    }
  }
  public function addListener(): Void {
    trace("LS:addListener");
  }
  public function removeListener(listener: ClientListener): Void {}
  public function getListeners(): Array<ClientListener> {
    return [];
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

  public function getSubscriptions(): Array<Subscription> {
    return [];
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