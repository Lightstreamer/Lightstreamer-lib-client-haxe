import utest.Runner;
import utest.ui.Report;
import com.lightstreamer.client.Proxy;
import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.internal.*;
import utest.Assert.*;
import TestTools;
using TestTools;

@:timeout(1500)
class TestProxyCs extends  utest.Test {
  var proxy = new Proxy("HTTP", "localhost", 8079, "myuser", "mypassword");
  // use an alias of localhost to fool the network layer and force it to pass through the proxy
  // see https://stackoverflow.com/a/7103016
  var host = "test.lightstreamer.com:8080";
  var output: Array<String>;

  public static function main() {
    var runner = new Runner();
    runner.addCase(new TestProxyCs());
    Report.create(runner);
    runner.run();
  }

  function setupClass() {
    // NB needs a validator even if the proxy is not secured
    LightstreamerClient.setTrustManagerFactory((sender, cert, chain, sslPolicyErrors) -> true);
    new LightstreamerClient(null, null).connectionOptions.setProxy(proxy);
  }

  function setup() {
    output = [];
  }

  function testProxyHttp(async: utest.Async) {
    new HttpClient(
      "http://" + host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
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

  function testProxyWs(async: utest.Async) {
    new WsClient(
      "ws://" + host + "/lightstreamer", 
      null,
      proxy,
      null,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        c.dispose();
        async.completed();
      }, 
      function onError(c, error) {
        if (c.isDisposed()) return;
        fail(error); 
        async.completed(); 
      });
  }

  @:timeout(3000)
  function testProxyWss(async: utest.Async) {
    new WsClient(
      "wss://push.lightstreamer.com/lightstreamer", 
      null,
      proxy,
      // NB needs a validator even if the proxy is not secured
      (sender, cert, chain, sslPolicyErrors) -> true,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        c.dispose();
        async.completed();
      }, 
      function onError(c, error) {
        if (c.isDisposed()) return;
        fail(error); 
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