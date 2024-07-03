package com.lightstreamer.internal;

import com.lightstreamer.client.ConnectionOptions;
import com.lightstreamer.client.LightstreamerClient.LSLightstreamerClient;
import com.lightstreamer.internal.Types.Millis;

interface IHttpClient {
  function dispose(): Void;
  function isDisposed(): Bool;
}

typedef IHttpClientFactory = (url: String, body: String, headers: Null<Map<String, String>>,
  onText: (IHttpClient, String)->Void, 
  onError: (IHttpClient, String)->Void, 
  onDone: IHttpClient->Void) -> IHttpClient;

interface IWsClient {
  function dispose(): Void;
  function isDisposed(): Bool;
  function send(txt: String): Void;
}

typedef IWsClientFactory = (url: String, headers: Null<Map<String, String>>, 
  onOpen: IWsClient->Void,
  onText: (IWsClient, String)->Void, 
  onError: (IWsClient, String)->Void) -> IWsClient;

interface ITimer {
  function cancel(): Void;
  function isCanceled(): Bool;
}

typedef ITimerFactory = (id: String, delay: Types.Millis, callback: ITimer->Void) -> ITimer;

enum ReachabilityStatus {
  RSReachable;
  RSNotReachable;
}

interface IReachability {
  function startListening(onUpdate: ReachabilityStatus -> Void): Void;
  function stopListening(): Void;
}

typedef IReachabilityFactory = (host: String) -> IReachability;

interface IPageLifecycle {
  var frozen(default, null): Bool;
  function startListening(): Void;
  function stopListening(): Void;
}

enum PageState {
  Frozen; Resumed;
}

typedef IPageLifecycleFactory = (PageState -> Void) -> IPageLifecycle;

interface IFactory {
  public function createWsClient(url: String, headers: Null<Map<String, String>>, 
    onOpen: IWsClient->Void,
    onText: (IWsClient, String)->Void, 
    onError: (IWsClient, String)->Void): IWsClient;
  public function createHttpClient(url: String, body: String, headers: Null<Map<String, String>>,
    onText: (IHttpClient, String)->Void, 
    onError: (IHttpClient, String)->Void, 
    onDone: IHttpClient->Void): IHttpClient;
  public function createCtrlClient(url: String, body: String, headers: Null<Map<String, String>>,
    onText: (IHttpClient, String)->Void, 
    onError: (IHttpClient, String)->Void, 
    onDone: IHttpClient->Void): IHttpClient;
  public function createReachabilityManager(host: String): IReachability;  
  public function createTimer(id: String, delay: Millis, callback: ITimer->Void): ITimer;
  public function randomMillis(max: Millis): Millis;
  public function createPageLifecycleFactory(onEvent: PageState -> Void): IPageLifecycle;
}

class Factory implements IFactory {
	final connectionOptions: LSConnectionOptions;

  public function new(client: LSLightstreamerClient) {
    this.connectionOptions = client.connectionOptions;
  }

  public function createWsClient(url: String, headers: Null<Map<String, String>>, 
    onOpen: IWsClient->Void,
    onText: (IWsClient, String)->Void, 
    onError: (IWsClient, String)->Void): IWsClient {
    #if java
    var proxy = connectionOptions.getProxy();
    var trustManager = com.lightstreamer.internal.Globals.instance.getTrustManagerFactory();
    return new com.lightstreamer.internal.WsClient(url, headers, proxy, trustManager, onOpen, onText, onError);
    #elseif cs
    var proxy = connectionOptions.getProxy();
    var trustManager = com.lightstreamer.internal.Globals.instance.getTrustManagerFactory();
    return new com.lightstreamer.internal.WsClient(url, headers, proxy, trustManager, onOpen, onText, onError);
    #elseif (js && LS_WEB)
    return new com.lightstreamer.internal.WsClient(url, onOpen, onText, onError);
    #elseif js
    return new com.lightstreamer.internal.WsClient(url, headers, onOpen, onText, onError);
    #elseif python
    var proxy = connectionOptions.getProxy();
    var trustManager = com.lightstreamer.internal.Globals.instance.getTrustManagerFactory();
    return new com.lightstreamer.internal.WsClient(url, headers, proxy, trustManager, onOpen, onText, onError);
    #elseif cpp
    var proxy = connectionOptions.getProxy();
    return new com.lightstreamer.internal.WsClientAlt(url, headers, proxy, onOpen, onText, onError);
    #else
    @:nullSafety(Off)
    return null;
    #end
  }
  
  public function createHttpClient(url: String, body: String, headers: Null<Map<String, String>>,
    onText: (IHttpClient, String)->Void, 
    onError: (IHttpClient, String)->Void, 
    onDone: IHttpClient->Void): IHttpClient {
    #if java
    var proxy = connectionOptions.getProxy();
    var trustManager = com.lightstreamer.internal.Globals.instance.getTrustManagerFactory();
    return new com.lightstreamer.internal.HttpClient(url, body, headers, proxy, trustManager, onText, onError, onDone);
    #elseif cs
    return new com.lightstreamer.internal.HttpClient(url, body, headers, onText, onError, onDone);
    #elseif js
    return new com.lightstreamer.internal.HttpClient(url, body, headers, connectionOptions.isCookieHandlingRequired(), onText, onError, onDone);
    #elseif python
    var proxy = connectionOptions.getProxy();
    var trustManager = com.lightstreamer.internal.Globals.instance.getTrustManagerFactory();
    return new com.lightstreamer.internal.HttpClient(url, body, headers, proxy, trustManager, onText, onError, onDone);
    #elseif cpp
    var proxy = connectionOptions.getProxy();
    return new com.lightstreamer.internal.HttpClientAlt(url, body, headers, proxy, onText, onError, onDone);
    #else
    @:nullSafety(Off)
    return null;
    #end
  }

  public function createCtrlClient(url: String, body: String, headers: Null<Map<String, String>>,
    onText: (IHttpClient, String)->Void, 
    onError: (IHttpClient, String)->Void, 
    onDone: IHttpClient->Void): IHttpClient {
    return createHttpClient(url, body, headers, onText, onError, onDone);
  }
  
  public function createReachabilityManager(host: String): IReachability {
    return new com.lightstreamer.internal.ReachabilityManager();
  }
  
  public function createTimer(id: String, delay: Millis, callback: ITimer->Void): ITimer {
    return new com.lightstreamer.internal.Timer(id, delay, callback);
  }
  
  public function randomMillis(max: Millis): Millis {
    return new Millis(Std.random(max.toInt()));
  }

  public function createPageLifecycleFactory(onEvent: PageState -> Void): IPageLifecycle {
    return new com.lightstreamer.internal.PageLifecycle(onEvent);
  }
}