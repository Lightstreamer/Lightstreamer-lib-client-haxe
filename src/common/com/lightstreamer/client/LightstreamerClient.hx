package com.lightstreamer.client;

import com.lightstreamer.client.internal.ClientMachine;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.EventDispatcher;
import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
import com.lightstreamer.internal.Constants;

using com.lightstreamer.log.LoggerTools;

class ClientEventDispatcher extends EventDispatcher<ClientListener> {}

#if (js || python) @:expose @:native("LSLightstreamerClient") #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class LSLightstreamerClient {
  public static final LIB_NAME: String = LS_LIB_NAME;
  public static final LIB_VERSION: String = LS_LIB_VERSION;

  public final connectionDetails: ConnectionDetails;
  public final connectionOptions: ConnectionOptions;
  final eventDispatcher = new ClientEventDispatcher();
  final machine: ClientMachine;

  public static function setLoggerProvider(provider: com.lightstreamer.log.LoggerProvider): Void {
    com.lightstreamer.log.LogManager.setLoggerProvider(provider);
  }

  #if LS_HAS_COOKIES
  public static function addCookies(uri: NativeURI, cookies: NativeCookieCollection): Void {
    com.lightstreamer.internal.CookieHelper.instance.addCookies(uri, cookies);
  }

  public static function getCookies(uri: Null<NativeURI>): NativeCookieCollection {
    #if cs @:nullSafety(Off) #end
    return com.lightstreamer.internal.CookieHelper.instance.getCookies(uri);
  }
  #end

  #if LS_HAS_TRUST_MANAGER
  public static function setTrustManagerFactory(factory: NativeTrustManager) {
    com.lightstreamer.internal.Globals.instance.setTrustManagerFactory(factory);
  }
  #end

  public function new(serverAddress: String, adapterSet: String #if LS_TEST ,?factory: IFactory #end) {
    connectionDetails = new ConnectionDetails(@:nullSafety(Off) this);
    connectionOptions = new ConnectionOptions(@:nullSafety(Off) this);
    #if LS_TEST
    machine = new #if LS_MPN com.lightstreamer.client.internal.MpnClientMachine #else ClientMachine #end(this, factory ?? new Factory(this));
    #else
    machine = new #if LS_MPN com.lightstreamer.client.internal.MpnClientMachine #else ClientMachine #end(this, new Factory(this));
    #end
    if (serverAddress != null) {
      connectionDetails.setServerAddress(serverAddress);
    }
    if (adapterSet != null) {
      connectionDetails.setAdapterSet(adapterSet);
    }
  }

  public function addListener(listener: ClientListener): Void {
    eventDispatcher.addListenerAndFireOnListenStart(listener #if js , this #end);
  }

  public function removeListener(listener: ClientListener): Void {
    eventDispatcher.removeListenerAndFireOnListenEnd(listener #if js , this #end);
  }

  public function getListeners(): NativeList<ClientListener> {
    return new NativeList(eventDispatcher.getListeners());
  }

  public function connect(): Void {
    machine.connect();
  }

  public function disconnect(): Void {
    machine.disconnect();
  }

  #if ((java && !android) || cs)
  public function disconnectFuture(): NativeFuture {
    return machine.disconnectFuture();
  }
  #end

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
  public function sendMessage(message: String, sequence: Null<String> = null, delayTimeout: Null<Int> = -1, listener: Null<ClientMessageListener> = null, enqueueWhileDisconnected: Null<Bool> = false): Void {
    machine.sendMessage(message, sequence, delayTimeout != null ? delayTimeout : -1, listener, enqueueWhileDisconnected != null ? enqueueWhileDisconnected : false);
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

  public function getSubscriptionWrappers(): NativeList<Any> {
    return new NativeList([for (sub in machine.getSubscriptions()) if (sub.wrapper != null) (sub.wrapper : Any)]);
  }

  #if LS_MPN
  public function registerForMpn(mpnDevice: MpnDevice) {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.registerForMpn(mpnDevice);
  }

  public function subscribeMpn(mpnSubscription: MpnSubscription, coalescing: Bool) {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.subscribeMpn(mpnSubscription, coalescing);
  }

  public function unsubscribeMpn(mpnSubscription: MpnSubscription) {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.unsubscribeMpn(mpnSubscription);
  }

  public function unsubscribeMpnSubscriptions(filter: Null<String>) {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    machine.unsubscribeMpnSubscriptions(filter);
  }

  public function getMpnSubscriptions(filter: Null<String>): NativeList<MpnSubscription> {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    return new NativeList(machine.getMpnSubscriptions(filter));
  }

  public function getMpnSubscriptionWrappers(filter: Null<String>): NativeList<Any> {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    return new NativeList([for (sub in machine.getMpnSubscriptions(filter)) if (sub.wrapper != null) (sub.wrapper : Any)]);
  }

  public function findMpnSubscription(subscriptionId: String): Null<MpnSubscription> {
    var machine = cast(machine, com.lightstreamer.client.internal.MpnClientMachine);
    return machine.findMpnSubscription(subscriptionId);
  }

  public function findMpnSubscriptionWrapper(subscriptionId: String): Null<Any> {
    var sub = findMpnSubscription(subscriptionId);
    return sub?.wrapper;
  }
  #end
}