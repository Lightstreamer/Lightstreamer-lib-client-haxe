package com.lightstreamer.internal;

interface IHttpClient {
  function dispose(): Void;
  function isDisposed(): Bool;
}

// TODO add proxy and trust manager
typedef IHttpClientFactory = (url: String, body: String, headers: Null<Map<String, String>>,
  onText: (IHttpClient, String)->Void, 
  onError: (IHttpClient, String)->Void, 
  onDone: IHttpClient->Void) -> IHttpClient;

interface IWsClient {
  function dispose(): Void;
  function isDisposed(): Bool;
  function send(txt: String): Void;
}

// TODO add proxy and trust manager
typedef IWsClientFactory = (url: String, headers: Null<Map<String, String>>, 
  onOpen: IWsClient->Void,
  onText: (IWsClient, String)->Void, 
  onError: (IWsClient, String)->Void) -> IWsClient;

interface ITimer {
  function cancel(): Void;
  function isCanceled(): Bool;
}

typedef ITimerFactory = (id: String, delay: Types.Millis, callback: ITimer->Void) -> ITimer;