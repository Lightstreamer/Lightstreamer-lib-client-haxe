import com.lightstreamer.log.ConsoleLoggerProvider;
import utest.Runner;
import com.lightstreamer.client.*;
import com.lightstreamer.internal.*;
import com.lightstreamer.client.internal.*;

class TestAll2 {

  static function buildSuite(runner: Runner) {
    LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
    runner.addCase(TestConnectionDetails);
    runner.addCase(TestConnectionOptions);
    runner.addCase(TestSubscription);
    runner.addCase(TestEventDispatcher);
    runner.addCase(TestTimer);
    runner.addCase(TestUrl);
    runner.addCase(TestRequestBuilder);
    runner.addCase(TestAssocArray);
    runner.addCase(TestRequest);
    #if js
    runner.addCase(TestStreamReader);
    #end
    #if LS_WEB
    runner.addCase(TestHttpClientWeb);
    runner.addCase(TestWsClientWeb);
    #end
    #if LS_NODE
    runner.addCase(TestCookieHelperNode);
    runner.addCase(TestHttpClientNode);
    runner.addCase(TestWsClientNode);
    #end
    #if java
    runner.addCase(TestCookieHelperJava);
    runner.addCase(TestHttpClientJava);
    runner.addCase(TestWsClientJava);
    #end
    #if cs
    runner.addCase(TestHttpClientCs);
    runner.addCase(TestWsClientCs);
    #end
    #if python
    runner.addCase(TestHttpClientPython);
    runner.addCase(TestWsClientPython);
    #end
    #if LS_MPN
    runner.addCase(com.lightstreamer.client.mpn.TestMpnSubscription);
    #if js
    runner.addCase(com.lightstreamer.client.mpn.TestMpnDeviceWeb);
    runner.addCase(com.lightstreamer.client.mpn.TestMpnBuilderFirebase);
    runner.addCase(com.lightstreamer.client.mpn.TestMpnBuilderSafari);
    #end
    #if java
    runner.addCase(com.lightstreamer.client.mpn.TestMpnDeviceAndroid);
    runner.addCase(com.lightstreamer.client.mpn.TestMpnBuilderAndroid);
    #end
    #end
    #if (!php && !cpp)
    runner.addCase(TestClient);
    runner.addCase(TestClientExtra);
    #end
    runner.addCase(TestSubscribe_WS);
    runner.addCase(TestSubscribe_HTTP);
    runner.addCase(TestSubscribe_HTTP_Polling);
    runner.addCase(TestSubscribe_WS_Polling);
    runner.addCase(TestUpdate);
    runner.addCase(TestUpdate2Level);
    runner.addCase(TestSendMessage);
    runner.addCase(TestStreamSense);
    runner.addCase(TestRecovery);
    runner.addCase(TestControlLink);
  }

  public static function main() {
    var runner = new Runner();
    buildSuite(runner);
    runner.run();
    #if threads
    runner.await();
    Sys.exit(runner.numFailures);
    #end
  }

  #if android
  // alternative entry point to run tests on android devices:
  // if the test runner (that internally uses haxe.Timer) is not executed inside a thread
  // with an event loop (needed by haxe.Timer), the runner doesn’t wait for the completion
  // of asynchronous tests and the test execution doesn’t seem to produce any results
  public static function androidMain(ctx: android.content.Context) {
    utils.AndroidTools.appContext = ctx;
    sys.thread.Thread.createWithEventLoop(() -> {
      var runner = new Runner();
      buildSuite(runner);
      runner.run();
      Sys.exit(runner.numFailures);
    });
  }
  #end
}