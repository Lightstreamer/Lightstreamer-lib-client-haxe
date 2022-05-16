package com.lightstreamer.internal;

import com.lightstreamer.internal.Types.Millis;
import com.lightstreamer.internal.PlatformApi;

function createWsClient(url: String, headers: Null<Map<String, String>>, 
  onOpen: IWsClient->Void,
  onText: (IWsClient, String)->Void, 
  onError: (IWsClient, String)->Void): IWsClient {
  // TODO pass all parameters
  return new WsClient(url, headers, null, null, onOpen, onText, onError);
}

function createHttpClient(url: String, body: String, headers: Null<Map<String, String>>,
  onText: (IHttpClient, String)->Void, 
  onError: (IHttpClient, String)->Void, 
  onDone: IHttpClient->Void): IHttpClient {
  // TODO pass all parameters
  return new HttpClient(url, body, headers, null, null, onText, onError, onDone);
}

function createReachabilityManager(host: String): IReachability {
  return new NetworkReachabilityManager();
}

function createTimer(id: String, delay: Millis, callback: ITimer->Void): ITimer {
  return new Timer(id, delay, callback);
}

function randomMillis(max: Millis): Millis {
  return new Millis(Std.random(max.toInt()));
}