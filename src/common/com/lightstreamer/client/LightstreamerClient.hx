package com.lightstreamer.client;

/**
 * LightstreamerClient class
 **/
@:expose("LightstreamerClient")
class LightstreamerClient {
  public final details = new ConnectionDetails();

  public static final LIB_NAME: String = "TODO";
  public static final LIB_VERSIONE: String = "TODO";

  // TODO setLoggerProvider
  // public static function setLoggerProvider(provider: LoggerProvider): Void {}

  /**
   * LightstreamerClient ctor
   * @param serverAddress 
   * @param adapterSet 
   */
  public function new(serverAddress: String, adapterSet: String) {
    if (serverAddress != null) {
      details.setServerAddress(serverAddress);
    }
    if (adapterSet != null) {
      details.setAdapterSet(adapterSet);
    }
  }
  public function addListener(): Void {
    trace("LS:addListener");
  }
  public function removeListener(listener: ClientListener): Void {}
  public function getListeners(): Array<ClientListener> {
    return null;
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
    return null;
  }

  public function subscribe(subscription: Subscription): Void {
    trace("LS.subscribe");
  }

  public function unsubscribe(subscription: Subscription): Void {
    
  }

  public function getSubscriptions(): Array<Subscription> {
    return null;
  }

  public function sendMessage(message: String): Void {}

  // TODO overload
  // public function sendMessage(message: String, sequence: String, delayTimeout: Types.Millis, listener: ClientMessageListener, enqueueWhileDisconnected: Bool) {}



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