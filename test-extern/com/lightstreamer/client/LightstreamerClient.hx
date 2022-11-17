package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer.client", "LightstreamerClient")
#end
#if js @:native("LightstreamerClient") #end
extern class LightstreamerClient {
   public static final LIB_NAME: String;
   public static final LIB_VERSION: String;
   public var connectionDetails(default, null): ConnectionDetails;
   public var connectionOptions(default, null): ConnectionOptions;
   public static function setLoggerProvider(provider: com.lightstreamer.log.LoggerProvider): Void;
   #if LS_HAS_COOKIES
   public static function addCookies(uri: NativeURI, cookies: NativeCookieCollection): Void;
   public static function getCookies(uri: Null<NativeURI>): NativeCookieCollection;
   #end
   #if LS_HAS_TRUST_MANAGER
   public static function setTrustManagerFactory(factory: NativeTrustManager): Void;
   #end
   public function new(serverAddress: String, adapterSet: String);
   public function addListener(listener: ClientListener): Void;
   public function removeListener(listener: ClientListener): Void;
   public function getListeners(): NativeList<ClientListener>;
   public function connect(): Void;
   public function disconnect(): Void;
   public function getStatus(): String;
   #if (java || cs)
   overload public function sendMessage(message: String, sequence: Null<String>, delayTimeout: Int, listener: Null<ClientMessageListener>, enqueueWhileDisconnected: Bool): Void;
   #else
   public function sendMessage(message: String, sequence: Null<String> = null, delayTimeout: Null<Int> = -1, listener: Null<ClientMessageListener> = null, enqueueWhileDisconnected: Null<Bool> = false): Void;
   #end
   #if (java || cs)
   overload public function sendMessage(message: String): Void;
   #end
   public function subscribe(subscription: Subscription): Void;
   public function unsubscribe(subscription: Subscription): Void;
   public function getSubscriptions(): NativeList<Subscription>;
}