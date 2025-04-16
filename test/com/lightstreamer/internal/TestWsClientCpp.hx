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
package com.lightstreamer.internal;

import cpp.Star;

private class _WsClient extends WsClient {
  public function new(url, ?headers, _onOpen, _onText, _onError) {
    super(url, headers, _onOpen, _onText, _onError);
  }
}

@:timeout(2000)
class TestWsClientCpp extends utest.Test {
  var host = "http://localtest.me:8080";
  var secHost = "https://localtest.me:8443";
  var output: Array<String>;
  var ws: WsClient;

  function setup() {
    output = [];
  }

  function teardown() {
    ws.dispose();
    #if LS_HAS_COOKIES
    CookieHelper.instance.clearCookies();
    #end
    #if LS_HAS_TRUST_MANAGER
    Globals.instance.clearTrustManager();
    #end
  }

  function testPolling(async: utest.Async) {
    ws = new _WsClient(
      host + "/lightstreamer",
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (~/LOOP/.match(line)) {
          pass();
          async.completed(); 
        }
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }

  function testStreaming(async: utest.Async) {
    ws = new _WsClient(
      host + "/lightstreamer", 
      function onOpen(c) {
        c.send("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      });
  }

  @:timeout(3000)
  function testHttps(async: utest.Async) {
    ws = new _WsClient(
      "https://push.lightstreamer.com/lightstreamer", 
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      });
  }

  function testConnectionError(async: utest.Async) {
    ws = new _WsClient(
      secHost + "/lightstreamer", 
      function onOpen(c) {
        fail("Unexpected call"); 
        async.completed(); 
      }, 
      function onText(c, l) { 
        fail("Unexpected call"); 
        async.completed(); 
      },
      function onError(c, error) { 
        isTrue(error.length > 0);
        async.completed(); 
      });
  }

  #if LS_HAS_COOKIES
  function testCookies(async: utest.Async) {
    var uri = host;
    equals(0, LightstreamerClient.getCookies(uri).length);
    
    var cookies = [ "X-Client=client" ];
    LightstreamerClient.addCookies(uri, cookies);

    ws = new _WsClient(
      host + "/lightstreamer",
      function onOpen(c) {
        var cookies = LightstreamerClient.getCookies(uri);
        equals(2, cookies.length);
        var c1: String = cookies[0].toString();
        var c2: String = cookies[1].toString();
        equals("X-Client=client; domain=localtest.me; path=/", c1);
        equals("X-Server=server; domain=localtest.me; path=/", c2);
        async.completed();
      },
      function onText(c, line) {
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }
  #end

  function testHeaders(async: utest.Async) {
    ws = new _WsClient(
      host + "/lightstreamer", 
      ["X-Header" => "header"],
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }

  #if LS_HAS_PROXY
  function testProxy(async: utest.Async) {
    ws = new _WsClient(
      host + "/lightstreamer", 
      new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"),
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }

  @:timeout(3000)
  function testProxyHttps(async: utest.Async) {
    ws = new _WsClient(
      "https://push.lightstreamer.com/lightstreamer", 
      new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"),
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }
  #end

  #if LS_HAS_TRUST_MANAGER
  function testTrustManager(async: utest.Async) {
    var privateKeyFile = "test/localtest.me.key";
    var certificateFile = "test/localtest.me.crt";
    var caLocation = "test/localtest.me.crt";

    LightstreamerClient.setTrustManagerFactory(caLocation, certificateFile, privateKeyFile, "", true);
    ws = new _WsClient(
      secHost + "/lightstreamer",
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }
  #end
}