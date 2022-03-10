import utest.Runner;
import utest.ui.Report;
import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.internal.*;
import utest.Assert.*;
import TestTools;
using TestTools;

@:timeout(1500)
class TestProxyCs extends  utest.Test {
  var host = "http://localhost:8080";
  var output: Array<String>;

  public static function main() {
    var runner = new Runner();
    runner.addCase(new TestProxyCs());
    Report.create(runner);
    runner.run();
  }

  function setupClass() {
    var proxy = new com.lightstreamer.client.Proxy("HTTP", "localhost", 8079, "myuser", "mypassword");
    new LightstreamerClient(null, null).connectionOptions.setProxy(proxy);
  }

  function setup() {
    output = [];
  }

  function testProxy(async: utest.Async) {
    // see https://stackoverflow.com/a/7103016
    new HttpClient(
      "http://test.lightstreamer.com:8080/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null,
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) { 
        isTrue(output.length > 0);
        match(~/CONOK/, output[0]);
        async.completed(); 
      });
  }

  @:timeout(3000)
  function testProxyHttps(async: utest.Async) {
    new HttpClient(
      "https://push.lightstreamer.com/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null,
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) { 
        isTrue(output.length > 0);
        match(~/CONOK/, output[0]);
        async.completed(); 
      });
  }

  function testInstallSameProxy() {
    var proxy = new com.lightstreamer.client.Proxy("HTTP", "localhost", 8079, "myuser", "mypassword");
    new LightstreamerClient(null, null).connectionOptions.setProxy(proxy);
    pass();
  }

  function testInstallDifferentProxy() {
    var proxy = new com.lightstreamer.client.Proxy("HTTP", "localhost", 8079);
    raisesEx(
      () -> new LightstreamerClient(null, null).connectionOptions.setProxy(proxy),
      com.lightstreamer.internal.NativeTypes.IllegalStateException,
      "Proxy already installed");
  }
}