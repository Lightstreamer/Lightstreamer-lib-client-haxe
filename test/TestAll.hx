import com.lightstreamer.client.LightstreamerClient.LSLightstreamerClient as LightstreamerClient;
import com.lightstreamer.log.ConsoleLoggerProvider.LSConsoleLoggerProvider as ConsoleLoggerProvider;
import com.lightstreamer.log.ConsoleLoggerProvider.LSConsoleLogLevel as ConsoleLogLevel;
import utest.Runner;
import com.lightstreamer.client.*;
import com.lightstreamer.internal.*;
import com.lightstreamer.internal.patch.*;
import com.lightstreamer.client.internal.*;

class TestAll {

  static function buildSuite(runner: Runner) {
    #if python
    Logging.basicConfig({level: Logging.DEBUG, format: "%(message)s", stream: python.lib.Sys.stdout});
    #end
    LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
    #if java
    utils.TestTools.enableOkHttpLogger();
    #end
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
    #if LS_JSON_PATCH
    runner.addCase(TestJsonPatch);
    #end
    #if LS_TLCP_DIFF
    runner.addCase(TestDiff);
    runner.addCase(TestDiffPatch);
    #end
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
  // alternative entry point to run tests on android devices
  public static function androidMain(ctx: android.content.Context) {
    utils.AndroidTools.appContext = ctx;
    var runner = new Runner();
    buildSuite(runner);
    runner.run();
    runner.await();
  }
  #end
}