import com.lightstreamer.log.ConsoleLoggerProvider;
import utest.Runner;
import utest.ui.Report;
import com.lightstreamer.client.*;

class TestAll {

  static function buildSuite(runner: Runner) {
    //LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.DEBUG));
    //runner.addCase(new TestCase());
    runner.addCase(new TestConnectionDetails());
    runner.addCase(new TestConnectionOptions());
    runner.addCase(new TestSubscription());
    runner.addCase(new com.lightstreamer.internal.TestEventDispatcher());
    #if js
    runner.addCase(new com.lightstreamer.internal.TestStreamReader());
    #end
    #if LS_WEB
    runner.addCase(new com.lightstreamer.internal.TestHttpClientWeb());
    runner.addCase(new com.lightstreamer.internal.TestWsClientWeb());
    #end
    #if LS_NODE
    runner.addCase(new com.lightstreamer.internal.TestCookieHelperNode());
    runner.addCase(new com.lightstreamer.internal.TestHttpClientNode());
    runner.addCase(new com.lightstreamer.internal.TestWsClientNode());
    #end
    #if java
    runner.addCase(new com.lightstreamer.internal.TestCookieHelperJava());
    runner.addCase(new com.lightstreamer.internal.TestHttpClientJava());
    runner.addCase(new com.lightstreamer.internal.TestWsClientJava());
    #end
    #if LS_MPN
    runner.addCase(new com.lightstreamer.client.mpn.TestMpnSubscription());
    #if js
    runner.addCase(new com.lightstreamer.client.mpn.TestMpnDevice());
    runner.addCase(new com.lightstreamer.client.mpn.TestFirebaseMpnBuilder());
    runner.addCase(new com.lightstreamer.client.mpn.TestSafariMpnBuilder());
    #end
    #if java
    runner.addCase(new com.lightstreamer.client.mpn.TestAndroidMpnBuilder());
    #end
    #end
  }

  public static function main() {
    var runner = new Runner();
    buildSuite(runner);
    Report.create(runner);
    runner.run();
  }

  #if android
  // alternative entry point to run tests on android devices:
  // if the test runner (that internally uses haxe.Timer) is not executed inside a thread
  // with an event loop (needed by haxe.Timer), the runner doesn’t wait for the completion
  // of asynchronous tests and the test execution doesn’t seem to produce any results
  public static function androidMain(ctx: android.content.Context) {
    appContext = ctx;
    sys.thread.Thread.createWithEventLoop(() -> {
      var runner = new Runner();
      buildSuite(runner);
      Report.create(runner);
      runner.run();
    });
  }

  public static var appContext: android.content.Context;

  public static function openRawResource(res: String): java.io.InputStream {
    return appContext.getResources().openRawResource(
      appContext.getResources().getIdentifier(res, "raw", appContext.getPackageName()));
  }
  #end
}