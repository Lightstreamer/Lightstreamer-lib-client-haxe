/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
class TestTrustManager extends utest.Test {
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

  function _testTrustManager(async: utest.Async) {
    client = new LightstreamerClient("https://localtest.me:8443", "TEST");
    client.addListener(listener);
    setTransport();
    exps
    .then(() -> {
      #if python
      var sslcontext = com.lightstreamer.internal.SSLContext.SSL.create_default_context({cafile: "test/localtest.me.crt"});
      sslcontext.load_cert_chain({certfile: "test/localtest.me.crt", keyfile: "test/localtest.me.key"});
      LightstreamerClient.setTrustManagerFactory(sslcontext);
      #elseif java
      var ksIn = getResourceAsJavaBytes("server_certificate");
      var keyStore = java.security.KeyStore.getInstance("PKCS12");
      keyStore.load(ksIn, (cast "secret":java.NativeString).toCharArray());
      var tmf = java.javax.net.ssl.TrustManagerFactory.getInstance(java.javax.net.ssl.TrustManagerFactory.getDefaultAlgorithm());
      tmf.init(keyStore);
      LightstreamerClient.setTrustManagerFactory(tmf);
      #elseif cs
      var myCert: Dynamic = cs.system.security.cryptography.x509certificates.X509Certificate.CreateFromCertFile("test/localtest.me.crt");
      LightstreamerClient.TrustManagerFactory = (sender, cert, chain, sslPolicyErrors) -> myCert.Equals(cert);
      #else
      fail("to be implemented");
      #end
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
    runner.addCase(TestTrustManager);
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