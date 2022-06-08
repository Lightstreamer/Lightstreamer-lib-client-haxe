package utils;

import com.lightstreamer.internal.PlatformApi.IWsClient;

class MockWsClient implements IWsClient {
  final test: utest.Test;

  public function new(test: utest.Test) this.test = test;
  
  public function create(url: String, headers: Null<Map<String, String>>, onOpen: IWsClient->Void, onText: (IWsClient, String)->Void, onError: (IWsClient, String)->Void) {
    this.onOpen = onOpen.bind(this);
    this.onText = onText.bind(this);
    this.onError = onError.bind(this, "ws.error");
    test.exps.signal("ws.init " + url);
    return this;
  }

  public function send(txt: String) test.exps.signal(txt);
  public function dispose() test.exps.signal("ws.dispose");
  public function isDisposed() return false;

  dynamic public function onOpen() {}
  dynamic public function onText(s: String) {}
  dynamic public function onError() {}
}