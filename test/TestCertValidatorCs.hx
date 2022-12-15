import com.lightstreamer.client.LightstreamerClient.LSLightstreamerClient as LightstreamerClient;
import utest.Runner;
import com.lightstreamer.internal.*;

@:timeout(1500)
class TestCertValidatorCs extends  utest.Test {
  var host = "http://localtest.me:8080";
  var secHost = "https://localtest.me:8443";
  var output: Array<String>;

  public static function main() {
    setupClass();
    var runner = new Runner();
    runner.addCase(TestCertValidatorCs);
    runner.run();
    runner.await();
  }

  static function setupClass() {
    LightstreamerClient.setTrustManagerFactory((sender, cert, chain, sslPolicyErrors) -> true);
  }

  function setup() {
    output = [];
  }

  function testRemoteCertificateValidationHttp(async: utest.Async) {
    new HttpClient(
      secHost + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.4.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", null,
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

  function testRemoteCertificateValidationWs(async: utest.Async) {
    new WsClient(
      secHost + "/lightstreamer", null, null, 
      (sender, cert, chain, sslPolicyErrors) -> true,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
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

  function testInstallAnotherValidator() {
    raisesEx(
      () -> LightstreamerClient.setTrustManagerFactory((sender, cert, chain, sslPolicyErrors) -> false),
      com.lightstreamer.internal.NativeTypes.IllegalStateException,
      "RemoteCertificateValidationCallback already installed");
  }
}