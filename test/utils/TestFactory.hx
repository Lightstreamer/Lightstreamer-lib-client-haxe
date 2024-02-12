package utils;

import com.lightstreamer.internal.Types.Millis;
import com.lightstreamer.internal.PlatformApi;

class TestFactory implements IFactory {
  final ws: MockWsClient;
  final http: MockHttpClient;
  final ctrl: MockHttpClient;
  final scheduler: MockScheduler;
  final lifecycle: MockPageLifecycle;

  public function new(test: utest.Test, ?ws: MockWsClient, ?http: MockHttpClient, ?ctrl: MockHttpClient, ?scheduler: MockScheduler, ?lifecycle: MockPageLifecycle) {
    this.ws = ws ?? new MockWsClient(test);
    this.http = http ?? new MockHttpClient(test);
    this.ctrl = ctrl ?? new MockHttpClient(test, "ctrl");
    this.scheduler = scheduler ?? new MockScheduler(test);
    this.lifecycle = lifecycle ?? new MockPageLifecycle();
  }

  public function createWsClient(url: String, headers: Null<Map<String, String>>, 
    onOpen: IWsClient->Void,
    onText: (IWsClient, String)->Void, 
    onError: (IWsClient, String)->Void): IWsClient {
    return ws.create(url, headers, onOpen, onText, onError);
  }
  
  public function createHttpClient(url: String, body: String, headers: Null<Map<String, String>>,
    onText: (IHttpClient, String)->Void, 
    onError: (IHttpClient, String)->Void, 
    onDone: IHttpClient->Void): IHttpClient {
    return http.create(url, body, headers, onText, onError, onDone);
  }

  public function createCtrlClient(url: String, body: String, headers: Null<Map<String, String>>,
    onText: (IHttpClient, String)->Void, 
    onError: (IHttpClient, String)->Void, 
    onDone: IHttpClient->Void): IHttpClient {
    return ctrl.create(url, body, headers, onText, onError, onDone);
  }
  
  public function createReachabilityManager(host: String): IReachability {
    return new com.lightstreamer.internal.ReachabilityManager();
  }
  
  public function createTimer(id: String, delay: Millis, callback: ITimer->Void): ITimer {
    return scheduler.create(id, delay, callback);
  }
  
  public function randomMillis(max: Millis): Millis {
    return new Millis(Std.random(max.toInt()));
  }

  public function createPageLifecycleFactory(onEvent: PageState -> Void): IPageLifecycle {
    return lifecycle.create(onEvent);
  }
}