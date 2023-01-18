package com.lightstreamer.client.mpn;

import utils.Expectations;
import com.lightstreamer.client.mpn.MpnListener;

using com.lightstreamer.client.mpn.TestMpnClient;

@:timeout(3000)
@:build(utils.Macros.parameterize(["WS-STREAMING", "HTTP-STREAMING", "WS-POLLING", "HTTP-POLLING"]))
class TestMpnClient extends utest.Test {
  final host = "http://127.0.0.1:8080";
  var device: MpnDevice;
  var sub: MpnSubscription;
  var client: LightstreamerClient;
  var connectedString: String;
  var devListener: BaseDeviceListener;
  var subListener: BaseMpnSubscriptionListener;

  function setup() {
    client = new LightstreamerClient(host, "TEST");
    /* create an Android device */
    device = new MpnDevice(getFreshToken(), "com.lightstreamer.demo.android.stocklistdemo", "Google");
    devListener = new BaseDeviceListener();
    device.addListener(devListener);
    /* create notification descriptor */
    var descriptor = new FirebaseMpnBuilder()
            .setTitle("my_title")
            .setBody("my_body")
            .setIcon("my_icon")
            .build();
    /* create MPN subscription */
    sub = new MpnSubscription("MERGE");
    sub.setDataAdapter("COUNT");
    sub.setItemGroup("count");
    sub.setFieldSchema("count");
    sub.setNotificationFormat(descriptor);
    subListener = new BaseMpnSubscriptionListener();
    sub.addListener(subListener);
  }

  function teardown() {
    client.disconnect();
    #if js
    js.Browser.getLocalStorage().clear();
    #end
  }

  // unsubscribe from all the MPN item to keep the tests isolated as much as possible
  static public function cleanup(exps: Expectations, test: TestMpnClient): Expectations {
    return exps
    .then(() -> {
      if (test.client.getStatus() != "DISCONNECTED" && test.client.getMpnSubscriptions(null).toHaxe().length > 0) {
        test.devListener._onSubscriptionsUpdated = () -> test.exps.signal("onSubscriptionsUpdated " + test.client.getMpnSubscriptions(null).toHaxe().length);
        test.client.unsubscribeMpnSubscriptions("ALL");
      } else {
        exps.signal("onSubscriptionsUpdated 0");
      }
    })
    .awaitUntil("onSubscriptionsUpdated 0");
  }

  function getFreshToken() {
    return "devtok" + haxe.Timer.stamp();
  }

  function setTransport() {
    client.connectionOptions.setForcedTransport(_param);
    connectedString = "CONNECTED:" + _param;
    if (_param.endsWith("POLLING")) {
      client.connectionOptions.setIdleTimeout(0);
      client.connectionOptions.setPollingInterval(100);
    }
  }

  /**
   * Verifies that the client registers to the MPN module.
   */
  function _testRegister(async: utest.Async) {
    setTransport();
    devListener._onRegistered = () -> exps.signal("onRegistered");
    devListener._onStatusChanged = (status, ts) -> exps.signal("onStatusChanged " + status);
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
    })
    .await("onStatusChanged REGISTERED")
    .await("onRegistered")
    .then(() -> {
      equals("REGISTERED", device.getStatus());
      isTrue(device.isRegistered());
      isFalse(device.isSuspended());
      isTrue(device.getStatusTimestamp() >= 0);
      equals("Google", device.getPlatform());
      equals("com.lightstreamer.demo.android.stocklistdemo", device.getApplicationId());
      notNull(device.getDeviceId());
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that when the registration fails the device listener is notified.
   */
  function _testRegister_error(async: utest.Async) {
    setTransport();
    device = new MpnDevice(getFreshToken(), "unknwon.app", "Google");
    devListener = new BaseDeviceListener();
    device.addListener(devListener);
    devListener._onRegistrationFailed = (code, msg) -> exps.signal('onRegistrationFailed $code $msg');
     exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
    })
    .await("onRegistrationFailed 43 MPN invalid application ID")
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that the client subscribes to an MPN item.
   */
  function _testSubscribe(async: utest.Async) {
    setTransport();
    subListener._onStatusChanged = (status, ts) -> exps.signal('onStatusChanged $status');
    subListener._onSubscription = () -> exps.signal("onSubscription");
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
    })
    .await("onStatusChanged ACTIVE")
    .await("onStatusChanged SUBSCRIBED")
    .await("onSubscription")
    .then(() -> {
      isTrue(sub.isActive());
      isTrue(sub.isSubscribed());
      isFalse(sub.isTriggered());
      equals("SUBSCRIBED", sub.getStatus());
      isTrue(sub.getStatusTimestamp() >= 0);
      var descriptor = new FirebaseMpnBuilder()
              .setTitle("my_title")
              .setBody("my_body")
              .setIcon("my_icon")
              .build();
      var expectedFormat = descriptor;
      var actualFormat = sub.getNotificationFormat();
      equals(expectedFormat, actualFormat);
      isNull(sub.getTriggerExpression());
      equals("COUNT", sub.getDataAdapter());
      isNull(sub.getRequestedBufferSize());
      isNull(sub.getRequestedMaxFrequency());
      equals("MERGE", sub.getMode());
      equals("count", sub.getItemGroup());
      equals("count", sub.getFieldSchema());
      notNull(sub.getSubscriptionId());
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that, when the client modifies an active subscription, the changes
   * are propagated back to the subscription.
   * <p>
   * The following scenario is exercised:
   * <ul>
   * <li>the client subscribes to an item</li>
   * <li>the changes are propagated back to the original subscription</li>
   * </ul>
   */
  function _testSubscribe_modify(async: utest.Async) {
    setTransport();
    subListener._onSubscription = () -> exps.signal("onSubscription");
    subListener._onPropertyChanged = (prop) -> switch (prop) {
      case "trigger": exps.signal("trigger " + sub.getActualTriggerExpression());
      case "notification_format": exps.signal("format " + sub.getActualNotificationFormat());
    };
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
    })
    .await("onSubscription")
    .then(() -> {
      isNull(sub.getActualTriggerExpression());
      isNull(sub.getActualNotificationFormat());

      sub.setTriggerExpression("0<1");
      equals("0<1", sub.getTriggerExpression());
    })
    .awaitUntil("trigger 0<1")
    .then(() -> {
      sub.setNotificationFormat(new FirebaseMpnBuilder().setTitle("my_title_2").build());
      equals("{\"webpush\":{\"notification\":{\"title\":\"my_title_2\"}}}", sub.getNotificationFormat());
    })
    .awaitUntil("format {\"webpush\":{\"notification\":{\"title\":\"my_title_2\"}}}")
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that, when the client modifies a TRIGGERED subscription, the state changes to SUBSCRIBED.
   */
  function _testSubscribe_modify_reactivate(async: utest.Async) {
    setTransport();
    subListener._onStatusChanged = (status, _) -> exps.signal("onStatusChanged " +  status);
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      sub.setTriggerExpression("true"); // so we are sure that the item becomes triggered
      client.subscribeMpn(sub, false);
    })
    .await("onStatusChanged ACTIVE")
    .await("onStatusChanged SUBSCRIBED")
    .await("onStatusChanged TRIGGERED")
    .then(() -> {
      equals("true", sub.getActualTriggerExpression());

      sub.setTriggerExpression("false");
    })
    .await("onStatusChanged SUBSCRIBED")
    .then(() -> equals("false", sub.getActualTriggerExpression()))
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that, when the client overrides an active subscription using the coalescing option, the changes
   * are propagated back to the subscription.
   * <p>
   * The following scenario is exercised:
   * <ul>
   * <li>the client subscribes to an item</li>
   * <li>the client creates a copy of the subscription</li>
   * <li>the client modifies a few parameters of the copy</li>
   * <li>the client subscribes using the copy specifying the coalescing option</li>
   * <li>the changes are propagated back to the original subscription</li>
   * </ul>
   */
  function _testSubscribe_modify_coalesce(async: utest.Async) {
    setTransport();
    subListener._onSubscription = () -> exps.signal("onSubscription");
    subListener._onPropertyChanged = (prop) -> switch (prop) {
      case "notification_format": exps.signal("format " + sub.getActualNotificationFormat());
    };
    var subCopy = new MpnSubscription("MERGE");
    subCopy.setDataAdapter("COUNT");
    subCopy.setItemGroup("count");
    subCopy.setFieldSchema("count");
    subCopy.setNotificationFormat(new FirebaseMpnBuilder().setTitle("my_title_2").build());
    var subCopyListener = new BaseMpnSubscriptionListener();
    subCopy.addListener(subCopyListener);
    subCopyListener._onSubscription = () -> exps.signal("onSubscription copy");
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
    })
    .await("onSubscription")
    .then(() -> {
      client.subscribeMpn(subCopy, true);
    })
    .awaitUntil("onSubscription copy")
    .awaitUntil('format {"webpush":{"notification":{"title":"my_title_2"}}}')
    .then(() -> {
      equals("{\"webpush\":{\"notification\":{\"title\":\"my_title\",\"body\":\"my_body\",\"icon\":\"my_icon\"}}}", sub.getNotificationFormat());

      equals(sub.getSubscriptionId(), subCopy.getSubscriptionId());
      equals(1, client.getMpnSubscriptions("ALL").toHaxe().length);
      isTrue(sub == client.findMpnSubscription(sub.getSubscriptionId()));
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that, when the subscription fails, the subscription listener is notified.
   */
  function _testSubscribe_error(async: utest.Async) {
    setTransport();
    sub.setDataAdapter("unknown.adapter");
    subListener._onSubscriptionError = (code, msg) -> exps.signal('onSubscriptionError $code $msg');
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
    })
    .await("onSubscriptionError 17 Data Adapter not found")
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that the client unsubscribes from an MPN item.
   */
  function _testUnsubscribe(async: utest.Async) {
    setTransport();
    subListener._onStatusChanged = (status, ts) -> exps.signal('onStatusChanged $status');
    subListener._onSubscription = () -> exps.signal("onSubscription");
    subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
    })
    .await("onStatusChanged ACTIVE")
    .await("onStatusChanged SUBSCRIBED")
    .await("onSubscription")
    .then(() -> {
      equals("SUBSCRIBED", sub.getStatus());
      client.unsubscribeMpn(sub);
    })
    .await("onStatusChanged UNKNOWN")
    .await("onUnsubscription")
    .then(() -> equals("UNKNOWN", sub.getStatus()))
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that the client doesn't send a subscription request if an unsubscription request follows immediately.
   */
  function _testUnsubscribe_fastUnsubscription(async: utest.Async) {
    setTransport();
    subListener._onSubscription = () -> exps.signal("onSubscription");
    subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
      client.unsubscribeMpn(sub);
    })
    // .await("onSubscription")
    // .await("onUnsubscription")
    // must not fire any listeners
    .then(() -> pass())
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that the client unsubscribes from all the subscribed items.
   */
  function _testUnsubscribe_filter_subscribed(async: utest.Async) {
    setTransport();
    var descriptor = new FirebaseMpnBuilder()
    .setTitle("my_title")
    .setBody("my_body")
    .setIcon("my_icon")
    .build();

    var sub1 = new MpnSubscription("MERGE");
    sub1.setDataAdapter("COUNT");
    sub1.setItemGroup("count");
    sub1.setFieldSchema("count");
    sub1.setNotificationFormat(descriptor);
    var sub1Listener = new BaseMpnSubscriptionListener();
    sub1.addListener(sub1Listener);
    sub1Listener._onSubscription = () -> exps.signal("onSubscription sub1");
    sub1Listener._onUnsubscription = () -> exps.signal("onUnsubscription sub1");

    var sub2 = new MpnSubscription("MERGE");
    sub2.setDataAdapter("COUNT");
    sub2.setItemGroup("count");
    sub2.setFieldSchema("count");
    sub2.setNotificationFormat(descriptor);
    // this expression is always true because the counter is >= 0
    sub2.setTriggerExpression("Integer.parseInt(${count}) > -1");
    var sub2Listener = new BaseMpnSubscriptionListener();
    sub2.addListener(sub2Listener);
    sub2Listener._onTriggered = () -> exps.signal("onTriggered sub2");
    sub2Listener._onUnsubscription = () -> exps.signal("onUnsubscription sub2");
    exps
    .then(() -> {
      client.registerForMpn(device);
      client.subscribeMpn(sub1, false);
      client.subscribeMpn(sub2, false);
      client.connect();
    })
    .await("onSubscription sub1", "onTriggered sub2")
    .then(() -> {
      var subscribedLs = client.getMpnSubscriptions("SUBSCRIBED").toHaxe();
      equals(1, subscribedLs.length);
      equals(sub1, subscribedLs[0]);

      var triggeredLs = client.getMpnSubscriptions("TRIGGERED").toHaxe();
      equals(1, triggeredLs.length);
      equals(sub2, triggeredLs[0]);

      var allLs = client.getMpnSubscriptions("ALL").toHaxe();
      equals(2, allLs.length);

      client.unsubscribeMpnSubscriptions("SUBSCRIBED");
    })
    .await("onUnsubscription sub1")
    .then(() -> {
      var subscribedLs = client.getMpnSubscriptions("SUBSCRIBED").toHaxe();
      equals(0, subscribedLs.length);

      var triggeredLs = client.getMpnSubscriptions("TRIGGERED").toHaxe();
      equals(1, triggeredLs.length);
      equals(sub2, triggeredLs[0]);

      var allLs = client.getMpnSubscriptions("ALL").toHaxe();
      equals(1, allLs.length);
      equals(sub2, allLs[0]);

      client.unsubscribeMpnSubscriptions(null);
    })
    .await("onUnsubscription sub2")
    .then(() ->  equals(0, client.getMpnSubscriptions("ALL").toHaxe().length))
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that the client unsubscribes from all the triggered items.
   */  
  function _testUnsubscribe_filter_triggered(async: utest.Async) {
    setTransport();
    var descriptor = new FirebaseMpnBuilder()
    .setTitle("my_title")
    .setBody("my_body")
    .setIcon("my_icon")
    .build();

    var sub1 = new MpnSubscription("MERGE");
    sub1.setDataAdapter("COUNT");
    sub1.setItemGroup("count");
    sub1.setFieldSchema("count");
    sub1.setNotificationFormat(descriptor);
    var sub1Listener = new BaseMpnSubscriptionListener();
    sub1.addListener(sub1Listener);
    sub1Listener._onSubscription = () -> exps.signal("onSubscription sub1");
    sub1Listener._onUnsubscription = () -> exps.signal("onUnsubscription sub1");

    var sub2 = new MpnSubscription("MERGE");
    sub2.setDataAdapter("COUNT");
    sub2.setItemGroup("count");
    sub2.setFieldSchema("count");
    sub2.setNotificationFormat(descriptor);
    // this expression is always true because the counter is >= 0
    sub2.setTriggerExpression("Integer.parseInt(${count}) > -1");
    var sub2Listener = new BaseMpnSubscriptionListener();
    sub2.addListener(sub2Listener);
    sub2Listener._onTriggered = () -> exps.signal("onTriggered sub2");
    sub2Listener._onUnsubscription = () -> exps.signal("onUnsubscription sub2");
    exps
    .then(() -> {
      client.registerForMpn(device);
      client.subscribeMpn(sub1, false);
      client.subscribeMpn(sub2, false);
      client.connect();
    })
    .await("onSubscription sub1", "onTriggered sub2")
    .then(() -> {
      var subscribedLs = client.getMpnSubscriptions("SUBSCRIBED").toHaxe();
      equals(1, subscribedLs.length);
      equals(sub1, subscribedLs[0]);

      var triggeredLs = client.getMpnSubscriptions("TRIGGERED").toHaxe();
      equals(1, triggeredLs.length);
      equals(sub2, triggeredLs[0]);

      var allLs = client.getMpnSubscriptions("ALL").toHaxe();
      equals(2, allLs.length);

      client.unsubscribeMpnSubscriptions("TRIGGERED");
    })
    .await("onUnsubscription sub2")
    .then(() -> {
      var subscribedLs = client.getMpnSubscriptions("SUBSCRIBED").toHaxe();
      equals(1, subscribedLs.length);
      equals(sub1, subscribedLs[0]);

      var triggeredLs = client.getMpnSubscriptions("TRIGGERED").toHaxe();
      equals(0, triggeredLs.length);

      var allLs = client.getMpnSubscriptions("ALL").toHaxe();
      equals(1, allLs.length);
      equals(sub1, allLs[0]);

      client.unsubscribeMpnSubscriptions(null);
    })
    .await("onUnsubscription sub1")
    .then(() ->  equals(0, client.getMpnSubscriptions("ALL").toHaxe().length))
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that the client unsubscribes from all the triggered items.
   */
  function _testUnsubscribe_filter_all(async: utest.Async) {
    setTransport();
    var descriptor = new FirebaseMpnBuilder()
    .setTitle("my_title")
    .setBody("my_body")
    .setIcon("my_icon")
    .build();

    var sub1 = new MpnSubscription("MERGE");
    sub1.setDataAdapter("COUNT");
    sub1.setItemGroup("count");
    sub1.setFieldSchema("count");
    sub1.setNotificationFormat(descriptor);
    var sub1Listener = new BaseMpnSubscriptionListener();
    sub1.addListener(sub1Listener);
    sub1Listener._onSubscription = () -> exps.signal("onSubscription sub1");
    sub1Listener._onUnsubscription = () -> exps.signal("onUnsubscription sub1");

    var sub2 = new MpnSubscription("MERGE");
    sub2.setDataAdapter("COUNT");
    sub2.setItemGroup("count");
    sub2.setFieldSchema("count");
    sub2.setNotificationFormat(descriptor);
    // this expression is always true because the counter is >= 0
    sub2.setTriggerExpression("Integer.parseInt(${count}) > -1");
    var sub2Listener = new BaseMpnSubscriptionListener();
    sub2.addListener(sub2Listener);
    sub2Listener._onTriggered = () -> exps.signal("onTriggered sub2");
    sub2Listener._onUnsubscription = () -> exps.signal("onUnsubscription sub2");
    exps
    .then(() -> {
      client.registerForMpn(device);
      client.subscribeMpn(sub1, false);
      client.subscribeMpn(sub2, false);
      client.connect();
    })
    .await("onSubscription sub1", "onTriggered sub2")
    .then(() -> {
      var subscribedLs = client.getMpnSubscriptions("SUBSCRIBED").toHaxe();
      equals(1, subscribedLs.length);
      equals(sub1, subscribedLs[0]);

      var triggeredLs = client.getMpnSubscriptions("TRIGGERED").toHaxe();
      equals(1, triggeredLs.length);
      equals(sub2, triggeredLs[0]);

      var allLs = client.getMpnSubscriptions("ALL").toHaxe();
      equals(2, allLs.length);

      client.unsubscribeMpnSubscriptions("ALL");
    })
    .await("onUnsubscription sub1", "onUnsubscription sub2")
    .then(() -> {
      var subscribedLs = client.getMpnSubscriptions("SUBSCRIBED").toHaxe();
      equals(0, subscribedLs.length);

      var triggeredLs = client.getMpnSubscriptions("TRIGGERED").toHaxe();
      equals(0, triggeredLs.length);

      var allLs = client.getMpnSubscriptions("ALL").toHaxe();
      equals(0, allLs.length);
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that a subscription can start in state TRIGGERED.
   */
  function _testTrigger_1(async: utest.Async) {
    setTransport();
    subListener._onStatusChanged = (status, ts) -> exps.signal('onStatusChanged $status');
    subListener._onTriggered = () -> exps.signal("onTriggered");
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      // this expression is always true because the counter is >= 0
      sub.setTriggerExpression("Integer.parseInt(${count}) > -1");
      client.subscribeMpn(sub, false);
    })
    .await("onStatusChanged ACTIVE")
    .await("onStatusChanged SUBSCRIBED")
    .await("onStatusChanged TRIGGERED")
    .await("onTriggered")
    .then(() -> {
      isTrue(sub.isTriggered());
      equals("TRIGGERED", sub.getStatus());
      isTrue(sub.getStatusTimestamp() > 0);
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that, when the triggering condition holds, the subscription becomes TRIGGERED.
   * <p>
   * The following scenario is exercised:
   * <ul>
   * <li>the client subscribes to an item</li>
   * <li>the client modifies the subscription adding a trigger</li>
   * <li>the trigger fires on the server</li>
   * <li>the client method onTriggered is notified</li>
   * </ul>
   */
  function _testTrigger_2(async: utest.Async) {
    setTransport();
    subListener._onStatusChanged = (status, ts) -> exps.signal('onStatusChanged $status');
    subListener._onSubscription = () -> exps.signal("onSubscription");
    subListener._onTriggered = () -> exps.signal("onTriggered");
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
    })
    .await("onStatusChanged ACTIVE")
    .await("onStatusChanged SUBSCRIBED")
    .await("onSubscription")
    .then(() -> {
      // this expression is always true because the counter is >= 0
      sub.setTriggerExpression("Integer.parseInt(${count}) > -1");
    })
    .await("onStatusChanged TRIGGERED")
    .await("onTriggered")
    .then(() -> {
      isTrue(sub.isTriggered());
      equals("TRIGGERED", sub.getStatus());
      isTrue(sub.getStatusTimestamp() > 0);
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that the two subscription objects become subscribed.
   */
  function _testDoubleSubscription(async: utest.Async) {
    setTransport();
    var descriptor = new FirebaseMpnBuilder()
    .setTitle("my_title")
    .setBody("my_body")
    .setIcon("my_icon")
    .build();

    var sub1 = new MpnSubscription("MERGE");
    sub1.setDataAdapter("COUNT");
    sub1.setItemGroup("count");
    sub1.setFieldSchema("count");
    sub1.setNotificationFormat(descriptor);
    var sub1Listener = new BaseMpnSubscriptionListener();
    sub1.addListener(sub1Listener);
    sub1Listener._onSubscription = () -> exps.signal("onSubscription sub1");

    var sub2 = new MpnSubscription("MERGE");
    sub2.setDataAdapter("COUNT");
    sub2.setItemGroup("count");
    sub2.setFieldSchema("count");
    sub2.setNotificationFormat(descriptor);
    var sub2Listener = new BaseMpnSubscriptionListener();
    sub2.addListener(sub2Listener);
    sub2Listener._onSubscription = () -> exps.signal("onSubscription sub2");
    exps
    .then(() -> {
      client.registerForMpn(device);
      client.connect();
      client.subscribeMpn(sub1, false);
      client.subscribeMpn(sub2, false);
    })
    .await("onSubscription sub1", "onSubscription sub2")
    .then(() -> {
      equals(2, client.getMpnSubscriptions(null).toHaxe().length);
      notEquals(sub1.getSubscriptionId(), sub2.getSubscriptionId());
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that the MPN subscriptions are preserved upon disconnection.
   * <p>
   * The scenario exercised is the following:
   * <ul>
   * <li>the client subscribes to two items</li>
   * <li>the client disconnects</li>
   * <li>the client reconnects</li>
   * <li>the server sends to the client the data about the two subscriptions</li>
   * </ul>
   */
  function _testDoubleSubscription_disconnect(async: utest.Async) {
    setTransport();
    var descriptor = new FirebaseMpnBuilder()
    .setTitle("my_title")
    .setBody("my_body")
    .setIcon("my_icon")
    .build();
    
    devListener._onSubscriptionsUpdated = () -> exps.signal("onSubscriptionsUpdated " + client.getMpnSubscriptions("SUBSCRIBED").toHaxe().length);
    /*
     * NB the following trigger conditions are always false because
     * the counter value is always bigger than zero.
     */
    var sub1 = new MpnSubscription("MERGE");
    sub1.setDataAdapter("COUNT");
    sub1.setItemGroup("count");
    sub1.setFieldSchema("count");
    sub1.setNotificationFormat(descriptor);
    sub1.setTriggerExpression("Integer.parseInt(${count}) < -1");

    var sub2 = new MpnSubscription("MERGE");
    sub2.setDataAdapter("COUNT");
    sub2.setItemGroup("count");
    sub2.setFieldSchema("count");
    sub2.setNotificationFormat(descriptor);
    sub2.setTriggerExpression("Integer.parseInt(${count}) < -2");
    exps
    .then(() -> {
      client.registerForMpn(device);
      client.connect();
    })
    .await("onSubscriptionsUpdated 0")
    .then(() -> {
      client.subscribeMpn(sub1, false);
    })
    .await("onSubscriptionsUpdated 1")
    .then(() -> {
      client.subscribeMpn(sub2, false);
    })
    .await("onSubscriptionsUpdated 2")
    .then(() -> {
      client.disconnect();
      client.connect();
    })
    .await("onSubscriptionsUpdated 2")
    .then(() -> {
      notEquals(sub1.getSubscriptionId(), sub2.getSubscriptionId());
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  function _testStatusChange(async: utest.Async) {
    setTransport();
    subListener._onStatusChanged = (status, ts) -> exps.signal('onStatusChanged $status');
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      equals("UNKNOWN", sub.getStatus());
      client.subscribeMpn(sub, false);
      equals("ACTIVE", sub.getStatus());
    })
    .await("onStatusChanged ACTIVE")
    .await("onStatusChanged SUBSCRIBED")
    .then(() -> {
      equals("SUBSCRIBED", sub.getStatus());

      client.unsubscribeMpn(sub);
    })
    .await("onStatusChanged UNKNOWN")
    .then(() -> {
      equals("UNKNOWN", sub.getStatus());
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that {@code onSubscriptionsUpdated} is notified even if the snapshot doesn't contain any subscriptions.
   * <p>
   * The following scenario is exercised:
   * <ul>
   * <li>the client registers to MPN module</li>
   * <li>SUBS adapter publishes an empty snapshot</li>
   * <li>{@code onSubscriptionsUpdated} is fired</li>
   * </ul>
   */
  function _testOnSubscriptionsUpdated_empty(async: utest.Async) {
    setTransport();
    devListener._onSubscriptionsUpdated = () -> exps.signal("onSubscriptionsUpdated");
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
    })
    .await("onSubscriptionsUpdated")
    .then(() -> {
      equals(0, client.getMpnSubscriptions("ALL").toHaxe().length);
    })
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Verifies that {@code onSubscriptionsUpdated} is notified when the cached subscriptions change.
   * <p>
   * The following scenario is exercised:
   * <ul>
   * <li>the client subscribes to two MPN items</li>
   * <li>when MPNOK is received, {@code onSubscriptionsUpdated} is fired</li>
   * <li>the client disconnects</li>
   * <li>the client reconnects</li>
   * <li>when SUBS adapter publishes the two previous MPN items, {@code onSubscriptionsUpdated} is fired</li>
   * <li>the client unsubscribes from the two items</li>
   * <li>when DELETE is received, {@code onSubscriptionsUpdated} is fired</li>
   * </ul>
   */
  function _testOnSubscriptionsUpdated(async: utest.Async) {
    setTransport();
    var descriptor = new FirebaseMpnBuilder()
    .setTitle("my_title")
    .setBody("my_body")
    .setIcon("my_icon")
    .build();
    
    devListener._onSubscriptionsUpdated = () -> exps.signal("onSubscriptionsUpdated " + client.getMpnSubscriptions("ALL").toHaxe().length);
    /*
     * NB the following trigger conditions are always false because
     * the counter value is always bigger than zero.
     */
    var sub1 = new MpnSubscription("MERGE");
    sub1.setDataAdapter("COUNT");
    sub1.setItemGroup("count");
    sub1.setFieldSchema("count");
    sub1.setNotificationFormat(descriptor);
    sub1.setTriggerExpression("Integer.parseInt(${count}) < -1");

    var sub2 = new MpnSubscription("MERGE");
    sub2.setDataAdapter("COUNT");
    sub2.setItemGroup("count");
    sub2.setFieldSchema("count");
    sub2.setNotificationFormat(descriptor);
    sub2.setTriggerExpression("Integer.parseInt(${count}) < -2");
    exps
    .then(() -> {
      client.registerForMpn(device);
      client.connect();
    })
    .await("onSubscriptionsUpdated 0")
    .then(() -> {
      client.subscribeMpn(sub1, false);
    })
    .await("onSubscriptionsUpdated 1")
    .then(() -> {
      client.subscribeMpn(sub2, false);
    })
    .await("onSubscriptionsUpdated 2")
    .then(() -> {
      client.disconnect();
      client.connect();
    })
    .await("onSubscriptionsUpdated 2")
    .then(() -> {
      client.unsubscribeMpn(sub1);
    })
    .await("onSubscriptionsUpdated 1")
    .then(() -> {
      client.unsubscribeMpn(sub2);
    })
    .await("onSubscriptionsUpdated 0")
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  function _testUnsubscribe_error(async: utest.Async) {
    setTransport();
    subListener._onSubscriptionError  = (code, msg) -> exps.signal('onSubscriptionError $code $msg');
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
      client.unsubscribeMpn(sub);
    })
    .await("onSubscriptionError 55 The request was discarded because the operation could not be completed")
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  function _testSetTrigger_error(async: utest.Async) {
    setTransport();
    devListener._onStatusChanged = (status, ts) -> exps.signal('onStatusChanged $status');
    subListener._onSubscription = () -> exps.signal("onSubscription");
    subListener._onModificationError = (code, msg, prop) -> exps.signal('onModificationError $code $msg ($prop)');
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
    })
    .await("onStatusChanged REGISTERED")
    .await("onSubscription")
    .then(() -> {
        sub.setTriggerExpression("1==2");
        client.disconnect();
    })
    .await("onStatusChanged UNKNOWN",
      "onModificationError 54 The request was aborted because the operation could not be completed (trigger)")
    .then(() -> client.connect())
    .await("onStatusChanged REGISTERED")
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }

  function _testSetNotification_error(async: utest.Async) {
    setTransport();
    devListener._onStatusChanged = (status, ts) -> exps.signal('onStatusChanged $status');
    subListener._onSubscription = () -> exps.signal("onSubscription");
    subListener._onModificationError = (code, msg, prop) -> exps.signal('onModificationError $code $msg ($prop)');
    exps
    .then(() -> {
      client.connect();
      client.registerForMpn(device);
      client.subscribeMpn(sub, false);
    })
    .await("onStatusChanged REGISTERED")
    .await("onSubscription")
    .then(() -> {
        sub.setNotificationFormat("{}");
        client.disconnect();
    })
    .await("onStatusChanged UNKNOWN",
      "onModificationError 54 The request was aborted because the operation could not be completed (notification_format)")
    .then(() -> client.connect())
    .await("onStatusChanged REGISTERED")
    .cleanup(this)
    .then(() -> async.completed())
    .verify();
  }
}