package utils;

import com.lightstreamer.internal.PlatformApi.IHttpClient;

class MockHttpClient implements IHttpClient {
  final test: utest.Test;
  final prefix: String;

  public function new(test: utest.Test, prefix: String = "http") {
    this.test = test;
    this.prefix = prefix;
  }

  public function create(url: String, body: String, headers: Null<Map<String, String>>, onText: (IHttpClient, String)->Void, onError: (IHttpClient, String)->Void, onDone: IHttpClient->Void) {
    this.onText = onText.bind(this);
    this.onError = onError.bind(this, prefix + ".error");
    this.onDone = onDone.bind(this);
    test.exps.signal(prefix + ".send " + url + "\r\n" + body);
    return this;
  }

  public function dispose() test.exps.signal(prefix + ".dispose");
  public function isDisposed() return false;

  dynamic public function onText(s: String) {}
  dynamic public function onError() {}
  dynamic public function onDone() {}
}