package com.lightstreamer.internal;

import com.lightstreamer.internal.Types.Millis;
import com.lightstreamer.internal.PlatformApi;

function createWsClient(url: String, headers: Null<Map<String, String>>, 
  onOpen: IWsClient->Void,
  onText: (IWsClient, String)->Void, 
  onError: (IWsClient, String)->Void): IWsClient {
  #if java
  // TODO pass all parameters
  return new WsClient(url, headers, null, null, onOpen, onText, onError);
  #elseif (js && LS_WEB)
  return new WsClient(url, onOpen, onText, onError);
  #elseif js
  return new WsClient(url, headers, onOpen, onText, onError);
  #end
}

function createHttpClient(url: String, body: String, headers: Null<Map<String, String>>,
  onText: (IHttpClient, String)->Void, 
  onError: (IHttpClient, String)->Void, 
  onDone: IHttpClient->Void): IHttpClient {
  #if java
  // TODO pass all parameters
  return new HttpClient(url, body, headers, null, null, onText, onError, onDone);
  #elseif js
  return new HttpClient(url, body, headers, onText, onError, onDone);
  #end
}

function createReachabilityManager(host: String): IReachability {
  return new DummyReachabilityManager();
}

function createTimer(id: String, delay: Millis, callback: ITimer->Void): ITimer {
  return new Timer(id, delay, callback);
}

function randomMillis(max: Millis): Millis {
  return new Millis(Std.random(max.toInt()));
}