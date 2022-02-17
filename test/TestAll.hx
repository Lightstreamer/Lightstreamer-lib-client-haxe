import utest.Runner;
import utest.ui.Report;
import com.lightstreamer.client.*;

class TestAll {

  static function buildSuite(runner: Runner) {
    // runner.addCase(new TestCase());
    runner.addCase(new TestConnectionDetails());
    runner.addCase(new TestConnectionOptions());
    runner.addCase(new TestSubscription());
    #if LS_MPN
    #if js
    runner.addCase(new com.lightstreamer.client.mpn.TestMpnDevice());
    runner.addCase(new com.lightstreamer.client.mpn.TestFirebaseMpnBuilder());
    runner.addCase(new com.lightstreamer.client.mpn.TestSafariMpnBuilder());
    #end
    runner.addCase(new com.lightstreamer.client.mpn.TestMpnSubscription());
    #if java
    runner.addCase(new com.lightstreamer.client.mpn.TestAndroidMpnBuilder());
    #end
    #end
    runner.addCase(new TestEventDispatcher());
    #if java
    runner.addCase(new com.lightstreamer.client.internal.TestCookieHelper());
    runner.addCase(new com.lightstreamer.client.internal.TestHttpClient());
    runner.addCase(new com.lightstreamer.client.internal.TestWsClient());
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