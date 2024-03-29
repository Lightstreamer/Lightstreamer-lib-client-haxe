import utest.Runner;
import com.lightstreamer.client.*;
import com.lightstreamer.client.mpn.*;
import com.lightstreamer.internal.*;
import com.lightstreamer.log.ConsoleLoggerProvider;

class TestCore {

  static function buildSuite(runner: Runner) {
    #if python
    Logging.basicConfig({level: Logging.DEBUG, format: "%(message)s", stream: python.lib.Sys.stdout});
    #end
    LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
    runner.addCase(TestClient);
    #if LS_MPN
    runner.addCase(com.lightstreamer.client.mpn.TestMpnClient);
    #end
  }

  public static function main() {
    trace('***** Running lib ${LightstreamerClient.LIB_NAME} ${LightstreamerClient.LIB_VERSION} *****');
    var runner = new Runner();
    buildSuite(runner);
    runner.run();
    #if threads
    runner.await();
    #end
    #if sys
    Sys.exit(runner.numFailures);
    #end
  }
}