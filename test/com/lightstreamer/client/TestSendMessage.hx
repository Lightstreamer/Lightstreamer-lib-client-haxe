package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener.BaseMessageListener;

class TestSendMessage extends utest.Test {
  var ws: MockWsClient;
  var client: LightstreamerClient;
  var msgListener: BaseMessageListener;

  function setup() {
    ws = new MockWsClient(this);
    client = new LightstreamerClient("http://server", "TEST", ws.create);
    msgListener = new BaseMessageListener();
    msgListener._onAbort = (msg, sentOnNetwork) -> exps.signal('onAbort $msg');
    msgListener._onDeny = (msg, code, error) -> exps.signal('onDeny $msg $code $error');
    msgListener._onDiscarded = msg -> exps.signal('onDiscarded $msg');
    msgListener._onError = msg -> exps.signal('onError $msg');
    msgListener._onProcessed = msg -> exps.signal('onProcessed $msg');
  }

  function teardown() {
    client.disconnect();
  }

  function testRequest_SequenceAndListener(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> client._sendMessage("foo", "seq", msgListener))
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_sequence=seq&LS_msg_prog=1")
    .then(() -> async.completed())
    .verify();
  }

  function testRequest_SequenceAndNoListener(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> client._sendMessage("foo", "seq"))
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_outcome=false&LS_sequence=seq&LS_msg_prog=1")
    .then(() -> async.completed())
    .verify();
  }

  function testRequest_NoSequenceAndNoListener(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> client._sendMessage("foo"))
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_outcome=false&LS_ack=false")
    .then(() -> async.completed())
    .verify();
  }

  function testRequest_NoSequenceAndListener(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> client._sendMessage("foo", msgListener))
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .then(() -> async.completed())
    .verify();
  }

  function testEnqueueWhileDisconnected_eq_false_InDisconnected(async: utest.Async) {
    exps
    .then(() -> {
      client._sendMessage("foo", msgListener);
    })
    .await("onAbort foo")
    .then(() -> async.completed())
    .verify();
  }

  function testEnqueueWhileDisconnected_eq_false_InRetry(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onError();
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .await("ws.dispose")
    .then(() -> client._sendMessage("foo", msgListener))
    .await("onAbort foo")
    .then(() -> async.completed())
    .verify();
  }

  function testEnqueueWhileDisconnected_eq_false(async: utest.Async) {
    exps
    .then(() -> {
      client._sendMessage("m1");
      client._sendMessage("m2", msgListener);
      client._sendMessage("m3", "seq");
      client._sendMessage("m4", "seq", msgListener);
    })
    .await("onAbort m2")
    .await("onAbort m4")
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("m10");
      client._sendMessage("m20", msgListener);
      client._sendMessage("m30", "seq");
      client._sendMessage("m40", "seq", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=m10&LS_outcome=false&LS_ack=false")
    .await("msg\r\nLS_reqId=2&LS_message=m20&LS_msg_prog=1")
    .await("msg\r\nLS_reqId=3&LS_message=m30&LS_outcome=false&LS_sequence=seq&LS_msg_prog=1")
    .await("msg\r\nLS_reqId=4&LS_message=m40&LS_sequence=seq&LS_msg_prog=2")
    .then(() -> async.completed())
    .verify();
  }

  function testEnqueueWhileDisconnected_eq_true(async: utest.Async) {
    exps
    .then(() -> {
      client._sendMessage("m1", true);
      client._sendMessage("m2", msgListener, true);
      client._sendMessage("m3", "seq", true);
      client._sendMessage("m4", "seq", msgListener, true);
    })
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("m10", true);
      client._sendMessage("m20", msgListener, true);
      client._sendMessage("m30", "seq", true);
      client._sendMessage("m40", "seq", msgListener, true);
    })
    .await("msg\r\nLS_reqId=1&LS_message=m1&LS_outcome=false&LS_ack=false\r\nLS_reqId=2&LS_message=m2&LS_msg_prog=1\r\nLS_reqId=3&LS_message=m3&LS_outcome=false&LS_sequence=seq&LS_msg_prog=1\r\nLS_reqId=4&LS_message=m4&LS_sequence=seq&LS_msg_prog=2")
    .await("msg\r\nLS_reqId=5&LS_message=m10&LS_outcome=false&LS_ack=false")
    .await("msg\r\nLS_reqId=6&LS_message=m20&LS_msg_prog=2")
    .await("msg\r\nLS_reqId=7&LS_message=m30&LS_outcome=false&LS_sequence=seq&LS_msg_prog=3")
    .await("msg\r\nLS_reqId=8&LS_message=m40&LS_sequence=seq&LS_msg_prog=4")
    .then(() -> async.completed())
    .verify();
  }

  function testSequence(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", "seq1");
      client._sendMessage("bar", "seq2");
      client._sendMessage("zap");
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_outcome=false&LS_sequence=seq1&LS_msg_prog=1")
    .await("msg\r\nLS_reqId=2&LS_message=bar&LS_outcome=false&LS_sequence=seq2&LS_msg_prog=1")
    .await("msg\r\nLS_reqId=3&LS_message=zap&LS_outcome=false&LS_ack=false")
    .then(() -> async.completed())
    .verify();
  }

  function testProg(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", "seq");
      client._sendMessage("zap");
      client._sendMessage("bar", "seq");
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_outcome=false&LS_sequence=seq&LS_msg_prog=1")
    .await("msg\r\nLS_reqId=2&LS_message=zap&LS_outcome=false&LS_ack=false")
    .await("msg\r\nLS_reqId=3&LS_message=bar&LS_outcome=false&LS_sequence=seq&LS_msg_prog=2")
    .then(() -> async.completed())
    .verify();
  }

  function testTimeout(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", "seq", 100);
      client._sendMessage("zap", 100);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_outcome=false&LS_sequence=seq&LS_msg_prog=1&LS_max_wait=100")
    .await("msg\r\nLS_reqId=2&LS_message=zap&LS_outcome=false&LS_ack=false")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGDONE(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", "seq", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_sequence=seq&LS_msg_prog=1")
    .then(() -> ws.onText("MSGDONE,seq,1"))
    .await("onProcessed foo")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGDONE_NoSequence(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", msgListener);
      client._sendMessage("bar", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .await("msg\r\nLS_reqId=2&LS_message=bar&LS_msg_prog=2")
    .then(() -> ws.onText("MSGDONE,*,1"))
    .then(() -> ws.onText("MSGDONE,*,2"))
    .await("onProcessed foo")
    .await("onProcessed bar")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGFAIL(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", "seq", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_sequence=seq&LS_msg_prog=1")
    .then(() -> ws.onText("MSGFAIL,seq,1,-5,error"))
    .await("onDeny foo -5 error")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGFAIL_NoSequence(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", msgListener);
      client._sendMessage("bar", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .await("msg\r\nLS_reqId=2&LS_message=bar&LS_msg_prog=2")
    .then(() -> ws.onText("MSGFAIL,*,1,10,error"))
    .then(() -> ws.onText("MSGFAIL,*,2,10,error"))
    .await("onError foo")
    .await("onError bar")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGFAIL_error39(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo1", "seq", msgListener);
      client._sendMessage("foo2", "seq", msgListener);
      client._sendMessage("foo3", "seq", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo1&LS_sequence=seq&LS_msg_prog=1")
    .await("msg\r\nLS_reqId=2&LS_message=foo2&LS_sequence=seq&LS_msg_prog=2")
    .await("msg\r\nLS_reqId=3&LS_message=foo3&LS_sequence=seq&LS_msg_prog=3")
    .then(() -> ws.onText("MSGFAIL,seq,3,39,2"))
    .await("onDiscarded foo2")
    .await("onDiscarded foo3")
    .then(() -> async.completed())
    .verify();
  }

  function testAbort_Terminate(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", "seq", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_sequence=seq&LS_msg_prog=1")
    .then(() -> client.disconnect())
    .await("control\r\nLS_reqId=2&LS_op=destroy&LS_close_socket=true&LS_cause=api")
    .await("ws.dispose")
    .await("onAbort foo")
    .then(() -> async.completed())
    .verify();
  }

  function testREQERR(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
      ws.onOpen();
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("ws.init http://server/lightstreamer")
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      client._sendMessage("foo", "seq", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_sequence=seq&LS_msg_prog=1")
    .then(() -> ws.onText("REQERR,1,-5,error"))
    .await("onError foo")
    .then(() -> async.completed())
    .verify();
  }
}