import utest.ui.common.ResultAggregator;
import utest.ui.common.PackageResult;
import utest.Runner;
import utest.ui.Report;
import com.lightstreamer.client.*;

class TestAll {
  public static function main() {
    var runner = new Runner();
    runner.addCase(new TestCase());
    Report.create(runner);
    runner.run();

    //the short way in case you don't need to handle any specifics
    //utest.UTest.run([new TestCase1(), new TestCase2()]);
  }

  #if java
  // alternative entry point to run instrumented tests under android:
  // class Report interferes with logcat
  public static function androidMain() {
    var runner = new Runner();
    runner.addCase(new TestCase());
    var aggregator = new ResultAggregator(runner, true);
    aggregator.onComplete.add(complete);
    runner.run();
  }

  static function complete(result : PackageResult) {
    var stats = result.stats;
    Sys.println("assertions: "   + stats.assertations);
    Sys.println("successes: "      + stats.successes);
    Sys.println("errors: "         + stats.errors);
    Sys.println("failures: "       + stats.failures);
    Sys.println("warnings: "       + stats.warnings);
    Sys.println("results: " + (stats.isOk ? "ALL TESTS OK (success: true)" : "SOME TESTS FAILURES (success: false)"));
    if (!stats.isOk) {
      throw "SOME TESTS FAILURES (success: false)";
    }
  }
  #end
}