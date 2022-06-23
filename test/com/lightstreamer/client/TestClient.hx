package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener;

@:timeout(2000)
@:build(utils.Macros.parameterize(["WS-STREAMING", "HTTP-STREAMING", "WS-POLLING", "HTTP-POLLING"]))
class TestClient extends utest.Test {
  #if android
  var host = "http://10.0.2.2:8080";
  #else
  var host = "http://localtest.me:8080";
  #end
  var client: LightstreamerClient;
  var listener: BaseClientListener;
  var subListener: BaseSubscriptionListener;
  var msgListener: BaseMessageListener;
  var connectedString: String;

  function setup() {
    client = new LightstreamerClient(host, "TEST");
    listener = new BaseClientListener();
    subListener = new BaseSubscriptionListener();
    msgListener = new BaseMessageListener();
    client.addListener(listener);
  }

  function teardown() {
    client.disconnect();
    #if LS_HAS_COOKIES
      #if cs
      com.lightstreamer.internal.CookieHelper.instance.clearCookies(host);
      #else
      com.lightstreamer.internal.CookieHelper.instance.clearCookies();
      #end
    #end
    #if (LS_HAS_TRUST_MANAGER && !cs)
    com.lightstreamer.internal.Globals.instance.clearTrustManager();
    #end
  }

  function _testConnect(async: utest.Async) {
    setTransport();
    var expected = "CONNECTED:" + _param;
    listener._onStatusChange = function(status) {
      if (status == expected) {
        equals(expected, client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  function _testOnlineServer(async: utest.Async) {
    var transport = _param;
    client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
    setTransport();
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

  function _testError(async: utest.Async) {
    client = new LightstreamerClient(host, "XXX");
    setTransport();
    listener = new BaseClientListener();
    client.addListener(listener);
    listener._onServerError = (code, msg) -> {
      equals("2 Requested Adapter Set not available", '$code $msg');
      async.completed();
    };
    client.connect();
  }

  function _testDisconnect(async: utest.Async) {
    var transport = _param;
    setTransport();
    listener._onStatusChange = (status) -> {
      if (status == "CONNECTED:" + transport) {
        client.disconnect();
      } else if (status == "DISCONNECTED") {
        equals("DISCONNECTED", client.getStatus());
        async.completed();
      }
    };
    client.connect();
  }

  function _testSubscribe(async: utest.Async) {
    setTransport();
    var sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setDataAdapter("COUNT");
    sub.addListener(subListener);
    subListener._onSubscription = () -> {
      isTrue(sub.isSubscribed());
      async.completed();
    };
    client.subscribe(sub);
    client.connect();
  }

  function _testSubscriptionError(async: utest.Async) {
    setTransport();
    var sub = new Subscription("RAW", ["count"], ["count"]);
    sub.setDataAdapter("COUNT");
    sub.addListener(subListener);
    subListener._onSubscriptionError = (code, msg) -> {
      equals("24 Invalid mode for these items", '$code $msg');
      async.completed();
    };
    client.subscribe(sub);
    client.connect();
  }

  function _testSubscribeCommand(async: utest.Async) {
    setTransport();
    var sub = new Subscription("COMMAND", ["mult_table"], ["key", "value1", "value2", "command"]);
    sub.setDataAdapter("MULT_TABLE");
    sub.addListener(subListener);
    subListener._onSubscription = () -> {
      isTrue(sub.isSubscribed());
      equals(1, sub.getKeyPosition());
      equals(4, sub.getCommandPosition());
      async.completed();
    };
    client.subscribe(sub);
    client.connect();
  }

  function _testSubscribeCommand2Level(async: utest.Async) {
    setTransport();
    var sub = new Subscription("COMMAND", ["two_level_command_count"], ["key", "command"]);
    sub.setDataAdapter("TWO_LEVEL_COMMAND");
    sub.setCommandSecondLevelDataAdapter("COUNT");
    sub.setCommandSecondLevelFields(["count"]);
    sub.addListener(subListener);
    subListener._onSubscription = () -> {
      isTrue(sub.isSubscribed());
      equals(1, sub.getKeyPosition());
      equals(2, sub.getCommandPosition());
      async.completed();
    };
    client.subscribe(sub);
    client.connect();
  }

  function _testUnsubscribe(async: utest.Async) {
    setTransport();
    var sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setDataAdapter("COUNT");
    sub.addListener(subListener);
    subListener._onSubscription = () -> {
      isTrue(sub.isSubscribed());
      client.unsubscribe(sub);
    };
    subListener._onUnsubscription = () -> {
      isFalse(sub.isSubscribed());
      isFalse(sub.isActive());
      async.completed();
    };
    client.subscribe(sub);
    client.connect();
  }

  function _testSubscribeNonAscii(async: utest.Async) {
    setTransport();
    var sub = new Subscription("MERGE", ["strange:àìùòlè"], ["value🌐-", "value&+=\r\n%"]);
    sub.setDataAdapter("STRANGE_NAMES");
    sub.addListener(subListener);
    subListener._onSubscription = () -> {
      isTrue(sub.isSubscribed());
      async.completed();
    };
    client.subscribe(sub);
    client.connect();
  }

  function _testBandwidth(async: utest.Async) {
    setTransport();
    listener._onPropertyChange = prop -> {
      switch prop {
      case "realMaxBandwidth":
        exps.signal("realMaxBandwidth=" + client.connectionOptions.getRealMaxBandwidth());
      }
    };
    equals("unlimited", client.connectionOptions.getRequestedMaxBandwidth());
    exps
    .then(() -> client.connect())
    .await("realMaxBandwidth=40") // after the connection, the server sends the default bandwidth
    // request a bandwidth equal to 20.1: the request is accepted
    .then(() -> client.connectionOptions.setRequestedMaxBandwidth("20.1"))
    .await("realMaxBandwidth=20.1")
    // request a bandwidth equal to 70.1: the meta-data adapter cuts it to 40 (which is the configured limit)
    .then(() -> client.connectionOptions.setRequestedMaxBandwidth("70.1"))
    .await("realMaxBandwidth=40")
    // request an unlimited bandwidth: the meta-data adapter cuts it to 40 (which is the configured limit)
    .then(() -> client.connectionOptions.setRequestedMaxBandwidth("unlimited"))
    .await("realMaxBandwidth=40")
    .then(() -> async.completed())
    .verify();
  }

  function _testClearSnapshot(async: utest.Async) {
    setTransport();
    var sub = new Subscription("DISTINCT", ["clear_snapshot"], ["dummy"]);
    sub.setDataAdapter("CLEAR_SNAPSHOT");
    sub.addListener(subListener);
    subListener._onClearSnapshot = (name, pos) -> {
      equals("clear_snapshot", name);
      equals(1, pos);
      async.completed();
    };
    client.subscribe(sub);
    client.connect();
  }

  function _testRoundTrip(async: utest.Async) {
    setTransport();
    var sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setDataAdapter("COUNT");
    sub.addListener(subListener);
    subListener._onSubscription = () -> exps.signal("onSubscription");
    subListener._onItemUpdate = _ -> exps.signal("onItemUpdate");
    subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
    listener._onPropertyChange = prop -> {
      switch prop {
      case "sessionId":
        notNull(client.connectionDetails.getSessionId());
      case "keepaliveInterval":
        equals(5000, client.connectionOptions.getKeepaliveInterval());
      case "serverSocketName":
        equals("Lightstreamer HTTP Server", client.connectionDetails.getServerSocketName());
      case "realMaxBandwidth":
        equals("40", client.connectionOptions.getRealMaxBandwidth());
      }
    };
    exps
    .then(() -> client.connect())
    .then(() -> client.subscribe(sub))
    .await("onSubscription")
    .await("onItemUpdate")
    .then(() -> client.unsubscribe(sub))
    .await("onUnsubscription")
    .then(() -> async.completed())
    .verify();
  }

  function _testMessage(async: utest.Async) {
    setTransport();
    exps
    .then(() -> client.connect())
    .then(() -> client.sendMessage("test message ()", null, 0, null, true))
    // no outcome expected
    .then(() -> client.sendMessage("test message (sequence)", "test_seq", 0, null, true))
    // no outcome expected
    .then(() -> {
      msgListener = new BaseMessageListener();
      msgListener._onProcessed = msg -> exps.signal("onProcessed " + msg);
      client.sendMessage("test message (listener)", null, -1, msgListener, true);
    })
    .await("onProcessed test message (listener)")
    .then(() -> {
      msgListener = new BaseMessageListener();
      msgListener._onProcessed = msg -> exps.signal("onProcessed " + msg);
      client.sendMessage("test message (sequence+listener)", "test_seq", -1, msgListener, true);
    })
    .await("onProcessed test message (sequence+listener)")
    .then(() -> {
      async.completed();
    })
    .verify();
  }

  function _testMessageWithSpecialChars(async: utest.Async) {
    setTransport();
    msgListener._onProcessed = msg -> {
      equals("hello +&=%\r\n", msg);
      async.completed();
    };
    client.connect();
    client.sendMessage("hello +&=%\r\n", null, -1, msgListener, false);
  }

  function _testUnorderedMessage(async: utest.Async) {
    setTransport();
    msgListener._onProcessed = msg -> {
      equals("test message", msg);
      async.completed();
    };
    client.connect();
    client.sendMessage("test message", "UNORDERED_MESSAGES", -1, msgListener, false);
  }

  function _testMessageError(async: utest.Async) {
    setTransport();
    msgListener._onDeny = (msg, code, error) -> {
      equals("throw me an error", msg);
      equals(-123, code);
      equals("test error", error);
      async.completed();
    };
    client.connect();
    client.sendMessage("throw me an error", "test_seq", -1, msgListener, false);
  }

  function _testLongMessage(async: utest.Async) {
    setTransport();
    var msg = "{\"n\":\"MESSAGE_SEND\",\"c\":{\"u\":\"GEiIxthxD-1gf5Tk5O1NTw\",\"s\":\"S29120e92e162c244T2004863\",\"p\":\"localhost:3000/html/widget-responsive.html\",\"t\":\"2017-08-08T10:20:05.665Z\"},\"d\":\"{\\\"p\\\":\\\"🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐\\\"}\"}";
    msgListener._onProcessed = _ -> {
      pass();
      async.completed();
    };
    client.connect();
    client.sendMessage(msg, "test_seq", -1, msgListener, false);
  }

  function _testEndOfSnapshot(async: utest.Async) {
    setTransport();
    var sub = new Subscription("DISTINCT", ["end_of_snapshot"], ["value"]);
    sub.setRequestedSnapshot("yes");
    sub.setDataAdapter("END_OF_SNAPSHOT");
    subListener._onEndOfSnapshot = (name, pos) -> {
      equals("end_of_snapshot", name);
      equals(1, pos);
      async.completed();
    };
    sub.addListener(subListener);
    client.subscribe(sub);
    client.connect();
  }

   /**
   * Subscribes to an item and verifies the overflow event is notified to the client.
   * <br>To ease the overflow event, the test
   * <ul>
   * <li>limits the event buffer size (see max_buffer_size in Test_integration/conf/test_conf.xml)</li>
   * <li>limits the bandwidth (see {@link ConnectionOptions#setRequestedMaxBandwidth(String)})</li>
   * <li>requests "unfiltered" messages (see {@link Subscription#setRequestedMaxFrequency(String)}).</li>
   * </ul>
   */
  function _testOverflow(async: utest.Async) {
    setTransport();
    var sub = new Subscription("MERGE", ["overflow"], ["value"]);
    sub.setRequestedSnapshot("no");
    sub.setDataAdapter("OVERFLOW");
    sub.setRequestedMaxFrequency("unfiltered");
    subListener._onItemLostUpdates = (name, pos, lost) -> {
      equals("overflow", name);
      equals(1, pos);
      async.completed();
    };
    sub.addListener(subListener);
    client.subscribe(sub);
    client.connectionOptions.setRequestedMaxBandwidth("1");
    client.connect();
  }

  function _testFrequency(async: utest.Async) {
    setTransport();
    var sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setDataAdapter("COUNT");
    sub.addListener(subListener);
    subListener._onRealMaxFrequency = freq -> {
      equals("unlimited", freq);
      async.completed();
    };
    client.subscribe(sub);
    client.connect();
  }

  function _testChangeFrequency(async: utest.Async) {
    setTransport();
    var sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setDataAdapter("COUNT");
    sub.addListener(subListener);
    subListener._onRealMaxFrequency = freq -> {
      exps.signal("frequency=" + freq);
    };
    sub.setRequestedMaxFrequency("unlimited");
    client.subscribe(sub);
    client.connect();
    exps
    .await("frequency=unlimited")
    .then(() -> sub.setRequestedMaxFrequency("2.5"))
    .await("frequency=2.5")
    .then(() -> sub.setRequestedMaxFrequency("unlimited"))
    .await("frequency=unlimited")
    .then(() -> {
      async.completed();
    })
    .verify();
  }

  function _testHeaders(async: utest.Async) {
    setTransport();
    exps
    .then(() -> {
      client.connectionOptions.setHttpExtraHeaders(["X-Header" => "header"]);
      listener._onStatusChange = status -> if (status == connectedString) exps.signal("connected");
      client.connect();
    })
    .await("connected")
    .then(() -> async.completed())
    .verify();
  }

  #if LS_HAS_COOKIES
  function _testCookies(async: utest.Async) {
    setTransport();
    exps
    .then(() -> {
      #if python
      equals(0, LightstreamerClient.getCookies(host).toHaxeArray().count());

      var dict = new python.Dict<String, String>();
      dict.set("X-Client", "client");
      var cookies = new com.lightstreamer.internal.SimpleCookie(dict);
      LightstreamerClient.addCookies(host, cookies);
      #else
      fail("TODO");
      #end

      listener._onStatusChange = status -> if (status == connectedString) exps.signal("connected");
      client.connect();
    })
    .await("connected")
    .then(() -> {
      #if python
      var cookies = LightstreamerClient.getCookies(host).toHaxeArray();
      equals(2, cookies.count());
      var nCookies = [for (c in cookies) c.output()];
      contains("Set-Cookie: X-Client=client", nCookies);
      contains("Set-Cookie: X-Server=server", nCookies);
      #else
      fail("TODO");
      #end
    })
    .then(() -> async.completed())
    .verify();
  }
  #end

  #if LS_HAS_PROXY
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
  #end

  #if (LS_HAS_TRUST_MANAGER && !cs)
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
      #else
      fail("TODO");
      #end
      listener._onStatusChange = status -> if (status == connectedString) exps.signal("connected");
      client.connect();
    })
    .await("connected")
    .then(() -> async.completed())
    .verify();
  }
  #end

  function setTransport() {
    client.connectionOptions.setForcedTransport(_param);
    connectedString = "CONNECTED:" + _param;
    if (_param.endsWith("POLLING")) {
      client.connectionOptions.setIdleTimeout(0);
      client.connectionOptions.setPollingInterval(100);
    }
  }
}