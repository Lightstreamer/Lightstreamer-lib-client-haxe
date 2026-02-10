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
package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener;

@:timeout(3000)
class TestCertificatePinning extends utest.Test {
  var client: LightstreamerClient;
  var listener: BaseClientListener;
  var connectedString: String;
  /*
  The certificate pins below are derived using the SSL Server Test tool:

  https://www.ssllabs.com/ssltest/analyze.html?d=push.lightstreamer.com
  */
  // Leaf certificate pin of push.lightstreamer.com
  var leafCertificate = "sha256/j12gjVRVSgVtL8OCXyx2fpULjxJNIRIKpCrjWUxVdvw=";
  // Intermediate certificate pin of push.lightstreamer.com
  var intermediateCertificate = "sha256/iFvwVyJSxnQdyaUvUERIf+8qk7gRze3612JMwoO3zdU=";
  // Other pins
  var bogusCertificate = "sha256/mExQV1m8P3X5mz2EsY3ascQlMz1NAdjrKvfvR6FUMI0=";
  var bogusCertificate2 = "sha256/vh78KSg1Ry4NaqGDV10w/cTb9VH3BQUZoCWNa93W/EY=";

  function setup() {
  }

  function teardown() {
    client.disconnect();
  }

  #if java
  function testMalformedCertificate() {
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    try {
      client.connectionDetails.setCertificatePins([
        "malformed-pin"
      ]);
      fail("Expected exception");
    } catch(e) {
      equals('Pins must start with "sha256/" or "sha1/": malformed-pin', e.message);
    }
    try {
      client.connectionDetails.setCertificatePins([
        "sha256/malformed-pin!"
      ]);
      fail("Expected exception");
    } catch(e) {
      equals('Invalid pin hash: sha256/malformed-pin!', e.message);
    }
  }

  function testOnPropertyChange(async: utest.Async) {
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onPropertyChange = function(prop) {
      if (prop == "certificatePins") {
        pass();
        async.completed();
      }
    }
    client.connectionDetails.setCertificatePins([
      leafCertificate
    ]);
  }

  function testNoCertificate(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        equals("CONNECTED:" + transport, client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  function testNoCertificate_NoTLS(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("http://push.lightstreamer.com", "DEMO");
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        equals("CONNECTED:" + transport, client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  /**
   * Validates the certificates when creating a WebSocket connection.
   */
  function testBadCertificate_WS(async: utest.Async) {
    var transport = "WS";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      bogusCertificate
    ]);
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onServerError = (code, msg) -> {
      equals("62 Unrecognized server's identity", '$code $msg');
      async.completed();
    };
    client.connect();
  }

  /**
   * Validates the certificates when creating an HTTP connection.
   */
  function testBadCertificate_HTTP(async: utest.Async) {
    var transport = "HTTP";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      bogusCertificate
    ]);
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onServerError = (code, msg) -> {
      equals("62 Unrecognized server's identity", '$code $msg');
      async.completed();
    };
    client.connect();
  }

  /**
   * Validates the certificates when sending an HTTP force_rebind request.
   */
  function testBadCertificate_ForceRebind(async: utest.Async) {
    var transport = "HTTP-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        exps.signal("CONNECTED");
      }
    };
    listener._onServerError = (code, msg) -> {
      exps.signal('$code $msg');
    };
    exps
    .then(() -> {
      client.connect();
    })
    .await("CONNECTED")
    .then(() -> {
      client.connectionDetails.setCertificatePins([
        bogusCertificate
      ]);
      setTransport("WS");
    })
    .await("62 Unrecognized server's identity")
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Validates the certificates when sending a WS-STREAMING rebind request.
   */
  function testBadCertificate_SwitchToWSStreaming(async: utest.Async) {
    var transport = "WS-POLLING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        exps.signal("CONNECTED");
      }
    };
    listener._onServerError = (code, msg) -> {
      exps.signal('$code $msg');
    };
    exps
    .then(() -> {
      client.connect();
    })
    .await("CONNECTED")
    .then(() -> {
      client.connectionDetails.setCertificatePins([
        bogusCertificate
      ]);
      setTransport("WS-STREAMING");
    })
    .await("62 Unrecognized server's identity")
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Validates the certificates when sending a WS-POLLING rebind request.
   */
  function testBadCertificate_SwitchToWSPolling(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        exps.signal("CONNECTED");
      }
    };
    listener._onServerError = (code, msg) -> {
      exps.signal('$code $msg');
    };
    exps
    .then(() -> {
      client.connect();
    })
    .await("CONNECTED")
    .then(() -> {
      client.connectionDetails.setCertificatePins([
        bogusCertificate
      ]);
      setTransport("WS-POLLING");
    })
    .await("62 Unrecognized server's identity")
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Validates the certificates when sending an HTTP-STREAMING rebind request.
   */
  function testBadCertificate_SwitchToHttpStreaming(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        exps.signal("CONNECTED");
      }
    };
    listener._onServerError = (code, msg) -> {
      exps.signal('$code $msg');
    };
    exps
    .then(() -> {
      client.connect();
    })
    .await("CONNECTED")
    .then(() -> {
      client.connectionDetails.setCertificatePins([
        bogusCertificate
      ]);
      setTransport("HTTP-STREAMING");
    })
    .await("62 Unrecognized server's identity")
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Validates the certificates when sending an HTTP-POLLING rebind request.
   */
  function testBadCertificate_SwitchToHttpPolling(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        exps.signal("CONNECTED");
      }
    };
    listener._onServerError = (code, msg) -> {
      exps.signal('$code $msg');
    };
    exps
    .then(() -> {
      client.connect();
    })
    .await("CONNECTED")
    .then(() -> {
      client.connectionDetails.setCertificatePins([
        bogusCertificate
      ]);
      setTransport("HTTP-POLLING");
    })
    .await("62 Unrecognized server's identity")
    .then(() -> async.completed())
    .verify();
  }

  function testBadCertificate_NoTLS(async: utest.Async) {
    var transport = "HTTP-POLLING";
    client = new LightstreamerClient("http://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      bogusCertificate
    ]);
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        equals("CONNECTED:" + transport, client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  function testGoodCertificate_WS(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      leafCertificate
    ]);
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        equals("CONNECTED:" + transport, client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  function testGoodCertificate_HTTP(async: utest.Async) {
    var transport = "HTTP-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      leafCertificate
    ]);
    setTransport(transport);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        equals("CONNECTED:" + transport, client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  function testGoodIntermediateCertificate(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      intermediateCertificate
    ]);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        pass();
        async.completed();
      }
    };
    client.connect();
  }

  function testGoodAndBadCertificates(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      leafCertificate,
      bogusCertificate
    ]);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        equals("CONNECTED:" + transport, client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  function testTwoGoodCertificates(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      leafCertificate,
      intermediateCertificate
    ]);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onStatusChange = function(status) {
      if (status == "CONNECTED:" + transport) {
        equals("CONNECTED:" + transport, client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  function testTwoBadCertificates(async: utest.Async) {
    var transport = "WS-STREAMING";
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    client.connectionDetails.setCertificatePins([
      bogusCertificate,
      bogusCertificate2
    ]);
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onServerError = (code, msg) -> {
      equals("62 Unrecognized server's identity", '$code $msg');
      async.completed();
    };
    client.connect();
  }
  #end

  function setTransport(_param: String) {
    client.connectionOptions.setForcedTransport(_param);
    connectedString = "CONNECTED:" + _param;
    if (_param.endsWith("POLLING")) {
      client.connectionOptions.setIdleTimeout(0);
      client.connectionOptions.setPollingInterval(100);
    }
  }
}