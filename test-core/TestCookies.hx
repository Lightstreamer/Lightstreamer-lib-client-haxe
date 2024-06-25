import utest.Runner;
import com.lightstreamer.client.*;
import com.lightstreamer.internal.*;
import com.lightstreamer.client.BaseListener;
import com.lightstreamer.log.ConsoleLoggerProvider;

using StringTools;
#if cs
using com.lightstreamer.CsExtender;
#end

@:timeout(3000)
@:build(utils.Macros.parameterize(["WS-STREAMING", "HTTP-STREAMING", "WS-POLLING", "HTTP-POLLING"]))
class TestCookies extends utest.Test {
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

  function _testCookies(async: utest.Async) {
    setTransport();
    exps
    .then(() -> {
      #if python
      var cookies0 = LightstreamerClient.getCookies(host).toHaxeArray();
      equals(0, cookies0.length);

      var dict = new python.Dict<String, String>();
      dict.set("X-Client", "client");
      var cookies = new com.lightstreamer.internal.SimpleCookie(dict);
      LightstreamerClient.addCookies(host, cookies);
      #elseif LS_NODE
      var cookies: Array<String> = LightstreamerClient.getCookies(host);
      equals(0, cookies.length);

      var cookie = "X-Client=client";
      LightstreamerClient.addCookies(host, [cookie]);
      #elseif java
      var uri = new java.net.URI(host);
      equals(0, LightstreamerClient.getCookies(uri).toHaxe().length);
      
      var cookie = new java.net.HttpCookie("X-Client", "client");
      cookie.setPath("/");
      LightstreamerClient.addCookies(uri, new com.lightstreamer.internal.NativeTypes.NativeList([cookie]));
      #elseif cs
      var uri = new cs.system.Uri(host);
      var cookies: cs.system.net.CookieCollection = LightstreamerClient.getCookies(uri);
      equals(0, cookies.Count);

      var cookie = new cs.system.net.Cookie("X-Client", "client");
      var cookies = new cs.system.net.CookieCollection();
      cookies.Add(cookie);
      LightstreamerClient.addCookies(uri, cookies);
      #else
      fail("to be implemented");
      #end

      listener._onStatusChange = status -> if (status == connectedString) exps.signal("connected");
      client.connect();
    })
    .await("connected")
    .then(() -> {
      #if python
      var cookies = LightstreamerClient.getCookies(host).toHaxeArray();
      equals(2, cookies.length);
      var nCookies = [for (c in cookies) c.output()];
      contains("Set-Cookie: X-Client=client", nCookies);
      contains("Set-Cookie: X-Server=server", nCookies);
      #elseif LS_NODE
      var cookies: Array<String> = LightstreamerClient.getCookies(host);
      equals(2, cookies.length);
      contains("X-Client=client; domain=localtest.me; path=/", cookies);
      contains("X-Server=server; domain=localtest.me; path=/", cookies);
      #elseif java
      var uri = new java.net.URI(host);
      var cookies = LightstreamerClient.getCookies(uri).toHaxe().map(c -> c.getName() + "=" + c.getValue());
      equals(2, cookies.length);
      contains("X-Client=client", cookies);
      contains("X-Server=server", cookies);
      #elseif cs
      var uri = new cs.system.Uri(host);
      var cookies: cs.system.net.CookieCollection = LightstreamerClient.getCookies(uri);
      equals(2, cookies.Count);
      var nCookies = [cookies[0].ToString(), cookies[1].ToString()];
      contains("X-Client=client", nCookies);
      contains("X-Server=server", nCookies);
      #else
      fail("to be implemented");
      #end
    })
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
    runner.addCase(TestCookies);
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