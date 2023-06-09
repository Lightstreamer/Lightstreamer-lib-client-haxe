import utest.Runner;
import com.lightstreamer.client.*;
import com.lightstreamer.log.ConsoleLoggerProvider;

class TestCore {

  static function buildSuite(runner: Runner) {
    LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
    runner.addCase(TestClient);
  }

  public static function main() {
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