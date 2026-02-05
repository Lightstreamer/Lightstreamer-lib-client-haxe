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
import com.lightstreamer.client.LightstreamerClient.LSLightstreamerClient as LightstreamerClient;
import com.lightstreamer.log.ConsoleLoggerProvider.LSConsoleLoggerProvider as ConsoleLoggerProvider;
import com.lightstreamer.log.ConsoleLoggerProvider.LSConsoleLogLevel as ConsoleLogLevel;
import utest.Runner;
import com.lightstreamer.client.*;
import com.lightstreamer.internal.*;
import com.lightstreamer.internal.patch.*;
import com.lightstreamer.client.internal.*;

class TestAll {

  static function buildSuite(runner: Runner) {
    #if python
    Logging.basicConfig({level: Logging.DEBUG, format: "%(message)s", stream: python.lib.Sys.stdout});
    #end
    LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
    #if java
    utils.TestTools.enableOkHttpLogger();
    #end
    runner.addCase(TestConnectionDetails);
    runner.addCase(TestConnectionOptions);
    runner.addCase(TestSubscription);
    runner.addCase(TestEventDispatcher);
    runner.addCase(TestTimer);
    runner.addCase(TestExecutor);
    runner.addCase(TestUrl);
    runner.addCase(TestRequestBuilder);
    runner.addCase(TestMyArray);
    runner.addCase(TestOrderedIntMap);
    runner.addCase(TestRequest);
    #if js
    runner.addCase(TestStreamReader);
    #end
    #if LS_WEB
    runner.addCase(TestHttpClientWeb);
    runner.addCase(TestWsClientWeb);
    runner.addCase(TestFreeze);
    #end
    #if LS_NODE
    runner.addCase(TestCookieHelperNode);
    runner.addCase(TestHttpClientNode);
    runner.addCase(TestWsClientNode);
    #end
    #if java
    // runner.addCase(TestOkHttp);
    runner.addCase(TestCookieHelperJava);
    runner.addCase(TestHttpClientJava);
    runner.addCase(TestWsClientJava);
    #end
    #if cs
    runner.addCase(TestHttpClientCs);
    runner.addCase(TestWsClientCs);
    #end
    #if python
    runner.addCase(TestHttpClientPython);
    runner.addCase(TestWsClientPython);
    #end
    #if cpp
    runner.addCase(TestCookie);
    runner.addCase(TestCookieJar);
    runner.addCase(TestHttpClientCpp);
    runner.addCase(TestWsClientCpp);
    #end
    #if LS_MPN
    runner.addCase(com.lightstreamer.client.mpn.TestMpnSubscription);
    runner.addCase(com.lightstreamer.client.mpn.TestMpnSubscribe);
    #if js
    runner.addCase(com.lightstreamer.client.mpn.TestMpnDeviceWeb);
    runner.addCase(com.lightstreamer.client.mpn.TestMpnBuilderFirebase);
    runner.addCase(com.lightstreamer.client.mpn.TestMpnBuilderSafari);
    #end
    #if java
    runner.addCase(com.lightstreamer.client.mpn.TestMpnDeviceAndroid);
    runner.addCase(com.lightstreamer.client.mpn.TestMpnBuilderAndroid);
    #end
    #end
    runner.addCase(TestSubscribe_WS);
    runner.addCase(TestSubscribe_HTTP);
    runner.addCase(TestSubscribe_HTTP_Polling);
    runner.addCase(TestSubscribe_WS_Polling);
    runner.addCase(TestUpdate);
    runner.addCase(TestUpdate2Level);
    runner.addCase(TestSendMessage);
    runner.addCase(TestStreamSense);
    runner.addCase(TestRecovery);
    runner.addCase(TestControlLink);
    #if LS_JSON_PATCH
    runner.addCase(TestJsonPatch);
    #end
    #if LS_TLCP_DIFF
    runner.addCase(TestDiff);
    runner.addCase(TestDiffPatch);
    #end
    runner.addCase(TestClient);
    runner.addCase(TestClientExtra);
    runner.addCase(TestCertificatePinning);
  }

  public static function main() {
    var runner = new Runner();
    buildSuite(runner);
    runner.run();
    #if threads
    runner.await();
    Sys.exit(runner.numFailures);
    #end
  }

  #if android
  // alternative entry point to run tests on android devices
  public static function androidMain(ctx: android.content.Context) {
    utils.AndroidTools.appContext = ctx;
    var runner = new Runner();
    buildSuite(runner);
    runner.run();
    runner.await();
  }
  #end
}