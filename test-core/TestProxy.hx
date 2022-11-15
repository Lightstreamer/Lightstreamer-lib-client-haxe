import utest.Runner;
import com.lightstreamer.client.*;
import com.lightstreamer.internal.*;
import com.lightstreamer.client.BaseListener;
import com.lightstreamer.log.ConsoleLoggerProvider;

using StringTools;

@:timeout(3000)
@:build(utils.Macros.parameterize(["WS-STREAMING", "HTTP-STREAMING", "WS-POLLING", "HTTP-POLLING"]))
class TestProxy extends utest.Test {
  #if android
  var host = "http://10.0.2.2:8080";
  #else
  var host = "http://localtest.me:8080";
  #end
  var client: LightstreamerClient;
  var listener: BaseClientListener;
  var connectedString: String;

  function setup() {
    client = new LightstreamerClient(host, "TEST");
    listener = new BaseClientListener();
    client.addListener(listener);
  }

  function teardown() {
    client.disconnect();
  }

  function _testProxy(async: utest.Async) {
    setTransport();
    exps
    .then(() -> {
      client.connectionOptions.setProxy(new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"));
      listener._onStatusChange = status -> if (status == connectedString) exps.signal("connected");
      client.connect();
    })
    .await("connected")
    .then(() -> async.completed())
    .verify();
  }

  function setTransport() {
    client.connectionOptions.setForcedTransport(_param);
    connectedString = "CONNECTED:" + _param;
    if (_param.endsWith("POLLING")) {
      client.connectionOptions.setIdleTimeout(0);
      client.connectionOptions.setPollingInterval(100);
    }
  }

  static function buildSuite(runner: Runner) {
    #if python
    Logging.basicConfig({level: Logging.DEBUG, format: "%(message)s", stream: python.lib.Sys.stdout});
    #end
    LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
    runner.addCase(TestProxy);
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