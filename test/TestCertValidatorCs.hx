import com.lightstreamer.client.LightstreamerClient;
import utest.Runner;
import utest.ui.Report;
import com.lightstreamer.internal.*;
import utest.Assert.*;
import TestTools;
using TestTools;

@:timeout(1500)
class TestCertValidatorCs extends  utest.Test {
  var host = "http://localhost:8080";
  var output: Array<String>;

  public static function main() {
    var runner = new Runner();
    runner.addCase(new TestCertValidatorCs());
    Report.create(runner);
    runner.run();
  }

  function setupClass() {
    LightstreamerClient.setTrustManagerFactory((sender, cert, chain, sslPolicyErrors) -> true);
  }

  function setup() {
    output = [];
  }

  function testRemoteCertificateValidation(async: utest.Async) {
    new HttpClient(
      "https://localhost:8443/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
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

  function testInstallAnotherValidator() {
    raisesEx(
      () -> LightstreamerClient.setTrustManagerFactory((sender, cert, chain, sslPolicyErrors) -> false),
      com.lightstreamer.internal.NativeTypes.IllegalStateException,
      "RemoteCertificateValidationCallback already installed");
  }
}