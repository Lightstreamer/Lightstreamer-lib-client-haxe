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
package com.lightstreamer.client;

#if LS_MPN
import com.lightstreamer.client.mpn.*;
#end

#if python
@:pythonImport("lightstreamer.client", "LightstreamerClient")
#end
#if js @:native("LightstreamerClient") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "LightstreamerClient") #end
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
   #if !cs
   public static function setTrustManagerFactory(factory: NativeTrustManager): Void;
   #else
   public static var TrustManagerFactory(never, default): NativeTrustManager;
   #end
   #end
   public function new(serverAddress: String, adapterSet: String);
   public function addListener(listener: ClientListener): Void;
   public function removeListener(listener: ClientListener): Void;
   public function connect(): Void;
   public function disconnect(): Void;
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
   #if !cs 
   public function getListeners(): NativeList<ClientListener>;
   public function getStatus(): String; 
   public function getSubscriptions(): NativeList<Subscription>; 
   #else
   public var Listeners(default, never): NativeList<ClientListener>;
   public var Status(default, never): String; 
   public var Subscriptions(default, never): NativeList<Subscription>; 
   #end
   #if LS_MPN
   public function registerForMpn(mpnDevice: MpnDevice): Void;
  
    public function subscribeMpn(mpnSubscription: MpnSubscription, coalescing: Bool): Void;
  
    public function unsubscribeMpn(mpnSubscription: MpnSubscription): Void;
  
    public function unsubscribeMpnSubscriptions(filter: Null<String>): Void;
  
    public function getMpnSubscriptions(?filter: Null<String>): NativeList<MpnSubscription>;
  
    public function findMpnSubscription(subscriptionId: String): Null<MpnSubscription>;
   #end
}