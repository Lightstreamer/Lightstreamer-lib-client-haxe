package com.lightstreamer.client.internal;

import com.lightstreamer.internal.*;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.internal.Set;
import com.lightstreamer.client.mpn.MpnDevice;
import com.lightstreamer.client.SubscriptionListener;
import com.lightstreamer.client.internal.ParseTools;
import com.lightstreamer.client.internal.ClientRequests;
import com.lightstreamer.client.internal.MpnRequests;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using Lambda;
using com.lightstreamer.internal.NullTools;
using com.lightstreamer.internal.ArrayTools;

// TODO synchronize
class MpnClientMachine extends ClientMachine {
  final mpnSubscriptionManagers = new Array<MpnSubscriptionManager>();
  var mpn_device: Null<MpnDevice>;
  var mpn_deviceId: Null<String>;
  var mpn_deviceToken: Null<String>;
  var mpn_adapterName: Null<String>;
  var mpn_lastRegisterReqId: Null<Int>;
  final mpn_candidate_devices = new Array<MpnDevice>();
  var mpn_deviceSubscription: Null<Subscription>;
  var mpn_itemSubscription: Null<Subscription>;
  var mpn_deviceListener: Null<MpnDeviceDelegate>;
  var mpn_itemListener: Null<MpnItemDelegate>;
  final mpn_snapshotSet = new Set<String>();
  final mpn_filter_pendings = new Array<MPNSubscriptionStatus>();
  var mpn_filter_lastDeactivateReqId: Null<Int>;
  var mpn_badge_reset_requested = false;
  var mpn_badge_lastResetReqId: Null<Int>;
  // requests
  var mpnRegisterRequest: Null<MpnRequests.MpnRegisterRequest>;
  var mpnFilterUnsubscriptionRequest: Null<MpnRequests.MpnFilterUnsubscriptionRequest>;
  var mpnBadgeResetRequest: Null<MpnRequests.MpnBadgeResetRequest>;

  public function new(
    client: LightstreamerClient,
    serverAddress: Null<String>,
    adapterSet: Null<String>,
    wsFactory: IWsClientFactory,
    httpFactory: IHttpClientFactory,
    ctrlFactory: IHttpClientFactory,
    timerFactory: ITimerFactory,
    randomGenerator: Millis->Millis,
    reachabilityFactory: IReachabilityFactory) {
    super(client, serverAddress, adapterSet, wsFactory, httpFactory, ctrlFactory, timerFactory, randomGenerator, reachabilityFactory);
    mpnRegisterRequest = new MpnRegisterRequest(this);
    mpnFilterUnsubscriptionRequest = new MpnFilterUnsubscriptionRequest(this);
    mpnBadgeResetRequest = new MpnBadgeResetRequest(this);
  }

  // ---------- event handlers ----------

  override public function evtExtConnect() {
    return evtExtConnect_MpnRegion();
  }

  function evtExtConnect_MpnRegion() {
    traceEvent("mpn:connect");
    var forward = true;
    if (state.s_mpn.m == s401) {
      goto(state.s_mpn.m = s403);
      forward = super.evtExtConnect();
      genSendMpnRegister();
    }
    if (forward) {
      forward = super.evtExtConnect();
    }
    return false;
  }

  function evtDEV_Update(status: String, timestamp: Long) {
    // TODO
  }
  function evtMpnError(code: Int, msg: String) {
    // TODO
  }
  function evtSUBS_Update(mpnSubId: String, update: ItemUpdate) {
    // TODO
  }
  function evtSUBS_EOS() {
    // TODO
  }

  // ---------- event actions ----------

  function subscribeExt(subscription: Subscription, isInternal: Bool = false) {
    // TODO
  }

  function doRegisterMpnDevice() {
    assert(!mpn_candidate_devices.empty());
    mpn_device = mpn_candidate_devices.shift();
  }

  @:nullSafety(Off)
  function doRemoveMpnSpecialListeners() {
    mpn_deviceSubscription.removeListener(mpn_deviceListener);
    mpn_deviceListener.disable();
    mpn_deviceListener = null;
    mpn_itemSubscription.removeListener(mpn_itemListener);
    mpn_itemListener.disable();
    mpn_itemListener = null;
  }

  function genSendMpnRegister() {
    evtSendControl(mpnRegisterRequest.sure());
  }

  function genUnsubscribeMpnSpecialItems() {
    client.unsubscribe(mpn_deviceSubscription.sure());
    client.unsubscribe(mpn_itemSubscription.sure());
  }

  function doResetMpnDevice() {
    mpn_deviceId = null;
    mpn_deviceToken = null;
    mpn_adapterName = null;
    mpn_lastRegisterReqId = null;
    mpn_deviceSubscription = null;
    mpn_itemSubscription = null;
    mpn_deviceListener = null;
    mpn_itemListener = null;
    mpn_snapshotSet.removeAll();
    mpn_filter_pendings.removeAll();
    mpn_filter_lastDeactivateReqId = null;
    mpn_badge_reset_requested = false;
    mpn_badge_lastResetReqId = null;
  }

  function notifyDeviceReset() {
    mpn_device.sure().onReset();
  }
  
  function notifyDeviceError(code: Int, msg: String) {
    mpn_device.sure().onError(code, msg);
  }
  
  function doMPNREG() {
    onFreshData();
  }

  function doMPNREG_Register(deviceId: String, adapterName: String) {
    assert(mpn_device != null);
    mpn_deviceId = deviceId;
    mpn_deviceToken = mpn_device.getDeviceToken();
    mpn_adapterName = adapterName;
    mpn_device.setDeviceId(deviceId, adapterName);
    createSpecialItems(deviceId, adapterName);
  }

  function doMPNZERO(deviceId: String) {
    onFreshData();
    if (mpn_deviceId != null && deviceId == mpn_deviceId) {
      mpn_device.sure().fireOnBadgeReset();
    } else {
      // WARN unknown deviceId;
    }
  }

  function createSpecialItems(deviceId: String, adapterName: String) {
    mpn_deviceListener = new MpnDeviceDelegate(this);
    var deviceSub = new Subscription("MERGE", 
      ['DEV-$deviceId'],
      ["status", "status_timestamp"]);
    deviceSub.setDataAdapter(adapterName);
    deviceSub.setRequestedMaxFrequency("unfiltered");
    deviceSub.addListener(mpn_deviceListener);
    mpn_deviceSubscription = deviceSub;
    
    mpn_itemListener = new MpnItemDelegate(this);
    var itemSub = new Subscription("COMMAND", 
      ['SUBS-$deviceId'],
      ["key", "command"]);
    itemSub.setDataAdapter(adapterName);
    itemSub.setRequestedMaxFrequency("unfiltered");
    itemSub.setCommandSecondLevelFields([
      "status", "status_timestamp", "notification_format", "trigger", "group",
      "schema", "adapter", "mode", "requested_buffer_size", "requested_max_frequency"
    ]);
    itemSub.setCommandSecondLevelDataAdapter(adapterName);
    itemSub.addListener(mpn_itemListener);
    mpn_itemSubscription = itemSub;
  }

  function genDeviceActive() {
    for (sm in mpnSubscriptionManagers) {
      sm.evtDeviceActive();
    }
  }

  function genSubscribeSpecialItems() {
    assert(mpn_deviceSubscription != null);
    assert(mpn_itemSubscription != null);
    subscribeExt(mpn_deviceSubscription, true);
    subscribeExt(mpn_itemSubscription, true);
  }

  function doMPNREG_Error() {
    // empty method
  }

  function notifyDeviceError_DifferentDevice() {
    mpn_device.sure().onError(62, "DeviceId or Adapter Name has unexpectedly been changed");
  }

  function doMPNREG_RefreshToken(deviceId: String, adapterName: String) {
    assert(mpn_device != null);
    mpn_deviceToken = mpn_device.getDeviceToken();
    mpn_device.setDeviceId(deviceId, adapterName);
  }

  function notifyDeviceRegistered(timestamp: Long) {
    mpn_device.sure().onRegistered(timestamp);
  }

  function notifyDeviceSuspended(timestamp: Long) {
    mpn_device.sure().onSuspend(timestamp);
  }

  function notifyDeviceResume(timestamp: Long) {
    mpn_device.sure().onResume(timestamp);
  }

  function doClearMpnSnapshot() {
    mpn_snapshotSet.removeAll();
  }

  function exists(mpnSubId: String): Bool {
    return mpnSubscriptionManagers.exists(sub -> sub.mpnSubId == mpnSubId);
  }

  function genSUBS_update(mpnSubId: String, update: ItemUpdate) {
    for (sm in mpnSubscriptionManagers) {
      if (mpnSubId == sm.mpnSubId) {
        sm.evtMpnUpdate(update);
      }
    }
  }

  function doAddToMpnSnapshot(mpnSubId: String) {
    mpn_snapshotSet.insert(mpnSubId);
  }

  function doRemoveFromMpnSnapshot(mpnSubId: String) {
    mpn_snapshotSet.remove(mpnSubId);
  }

  function doAddMpnSubscription(mpnSubId: String) {
    var sm = new MpnSubscriptionManager(mpnSubId, this);
    sm.start();
  }

  function notifyOnSubscriptionsUpdated() {
    mpn_device.sure().fireOnSubscriptionsUpdated();
  }

  function genSUBS_EOS() {
    for (sm in mpnSubscriptionManagers) {
      sm.evtMpnEOS();
    }
  }

  function genSendMpnUnsubscribeFilter() {
    evtSendControl(mpnFilterUnsubscriptionRequest.sure());
  }

  function genSendMpnResetBadge() {
    evtSendControl(mpnBadgeResetRequest.sure());
  }

  function doREQMpnUnsubscribeFilter() {
    mpn_filter_pendings.shift();
  }

  function doREQOKMpnResetBadge() {
    mpn_badge_reset_requested = false;
  }

  function doREQERRMpnResetBadge() {
    mpn_badge_reset_requested = false;
  }

  function notifyOnBadgeResetFailed(code: Int, msg: String) {
    mpn_device.sure().fireOnBadgeResetFailed(code, msg);
  }

  function doMPNOK(subId: Int, mpnSubId: String) {
    onFreshData();
    for (sm in mpnSubscriptionManagers) {
      if (sm.m_subId == subId) {
        sm.evtMPNOK(mpnSubId);
      }
    }
  }

  function doMPNDEL(mpnSubId: String) {
    onFreshData();
    for (sm in mpnSubscriptionManagers) {
      if (sm.mpnSubId == mpnSubId) {
        sm.evtMPNDEL();
      }
    }
  }

  function doMPNCONF(mpnSubId: String) {
    onFreshData();
  }

  function encodeMpnRegister() {
    assert(mpn_device != null);
    var req = new RequestBuilder();
    var deviceToken = mpn_device.getDeviceToken();
    var prevDeviceToken = mpn_device.getPreviousDeviceToken();
    mpn_lastRegisterReqId = generateFreshReqId();
    req.LS_reqId(mpn_lastRegisterReqId);
    req.LS_op("register");
    req.PN_type(mpn_device.getPlatform());
    req.PN_appId(mpn_device.getApplicationId());
    if (prevDeviceToken == null || prevDeviceToken == deviceToken) {
      req.PN_deviceToken(deviceToken);
    } else {
      req.PN_deviceToken(prevDeviceToken);
      req.PN_newDeviceToken(deviceToken);
    }
    protocolLogger.logInfo('Sending MPNDevice register: $req');
    return req.getEncodedString();
  }

  function encodeMpnRefreshToken() {
    assert(mpn_device != null);
    var req = new RequestBuilder();
    mpn_lastRegisterReqId = generateFreshReqId();
    req.LS_reqId(mpn_lastRegisterReqId);
    req.LS_op("register");
    req.PN_type(mpn_device.getPlatform());
    req.PN_appId(mpn_device.getApplicationId());
    req.PN_deviceToken(mpn_deviceToken.sure());
    req.PN_newDeviceToken(mpn_device.getDeviceToken());
    req.LS_cause("refresh.token");
    protocolLogger.logInfo('Sending MPNDevice refresh: $req');
    return req.getEncodedString();
  }

  function encodeMpnRestore() {
    assert(mpn_device != null);
    var req = new RequestBuilder();
    mpn_lastRegisterReqId = generateFreshReqId();
    req.LS_reqId(mpn_lastRegisterReqId);
    req.LS_op("register");
    req.PN_type(mpn_device.getPlatform());
    req.PN_appId(mpn_device.getApplicationId());
    req.PN_deviceToken(mpn_deviceToken.sure());
    req.PN_newDeviceToken(mpn_device.getDeviceToken());
    req.LS_cause("restore.token");
    protocolLogger.logInfo('Sending MPNDevice restore: $req');
    return req.getEncodedString();
  }

  function encodeDeactivateFilter() {
    var req = new RequestBuilder();
    mpn_filter_lastDeactivateReqId = generateFreshReqId();
    req.LS_reqId(mpn_filter_lastDeactivateReqId);
    req.LS_op("deactivate");
    req.PN_deviceId(mpn_deviceId.sure());
    switch mpn_filter_pendings[0] {
    case SUBSCRIBED:
      req.PN_subscriptionStatus("ACTIVE");
    case TRIGGERED:
      req.PN_subscriptionStatus("TRIGGERED");
    default:
      // if PN_subscriptionStatus is omitted, all subscriptions are deactivated
    }
    protocolLogger.logInfo('Sending multiple MPNSubscription deactivate: $req');
    return req.getEncodedString();
  }

  function encodeBadgeReset() {
    var req = new RequestBuilder();
    mpn_badge_lastResetReqId = generateFreshReqId();
    req.LS_reqId(mpn_badge_lastResetReqId);
    req.LS_op("reset_badge");
    req.PN_deviceId(mpn_deviceId.sure());
    protocolLogger.logInfo('Sending MPNDevice badge reset: $req');
    return req.getEncodedString();
  }
}

private enum MPNSubscriptionStatus {
  ALL; SUBSCRIBED; TRIGGERED;
}

// TODO synchronize
private class SubscriptionDelegateBase implements SubscriptionListener {
  final client: MpnClientMachine;
  var m_disabled = false;
  
  public function new(client: MpnClientMachine) {
    this.client = client;
  }

  public function disable() {
    // TODO synchronize
    m_disabled = true;
  }

  function synchronized(block: () -> Void) {
    // TODO synchronize
    if (!m_disabled) {
      block();
    }
  }

  public function onClearSnapshot(itemName: String, itemPos: Int): Void {}
  public function onCommandSecondLevelItemLostUpdates(lostUpdates: Int, key: String): Void {}
  public function onCommandSecondLevelSubscriptionError(code: Int, message: String, key: String): Void {}
  public function onEndOfSnapshot(itemName: String, itemPos: Int): Void {}
  public function onItemLostUpdates(itemName: String, itemPos: Int, lostUpdates: Int): Void {}
  public function onItemUpdate(update: ItemUpdate): Void {}
  public function onListenEnd(subscription: Subscription): Void {}
  public function onListenStart(subscription: Subscription): Void {}
  public function onSubscription(): Void {}
  public function onSubscriptionError(code: Int, message: String): Void {}
  public function onUnsubscription(): Void {}
  public function onRealMaxFrequency(frequency: String): Void {}
}

@:access(com.lightstreamer.client.internal.MpnClientMachine)
private class MpnDeviceDelegate extends SubscriptionDelegateBase {

  override public function onItemUpdate(itemUpdate: ItemUpdate): Void {
    synchronized(() -> {
      var status = itemUpdate.getValue("status");
      var timestamp = itemUpdate.getValue("status_timestamp");
      if (status != null) {
        client.evtDEV_Update(status, parseInt(timestamp ?? "0"));
      }
    });
  }

  override public function onSubscriptionError(code: Int, message: String): Void {
    synchronized(() -> {
      client.evtMpnError(62, "MPN device activation can't be completed (62/1)");
    });
  }

  override public function onUnsubscription(): Void {
    synchronized(() -> {
      client.evtMpnError(62, "MPN device activation can't be completed (62/2)");
    });
  }
}

@:access(com.lightstreamer.client.internal.MpnClientMachine)
private class MpnItemDelegate extends SubscriptionDelegateBase {

  override public function onItemUpdate(itemUpdate: ItemUpdate): Void {
    synchronized(() -> {
      var key = itemUpdate.getValue("key");
      if (key != null) {
        // key has the form "SUB-<id>"
        var mpnSubId = key.substring(4);
        client.evtSUBS_Update(mpnSubId, itemUpdate);
      }
    });
  }

  override public function onEndOfSnapshot(itemName: String, itemPos: Int): Void {
    synchronized(() -> {
      client.evtSUBS_EOS();
    });
  }

  override public function onSubscriptionError(code: Int, message: String): Void {
    synchronized(() -> {
      client.evtMpnError(62, "MPN device activation can't be completed (62/3)");
    });
  }

  override public function onUnsubscription(): Void {
    synchronized(() -> {
      client.evtMpnError(62, "MPN device activation can't be completed (62/4)");
    });
  }

  override public function onCommandSecondLevelSubscriptionError(code: Int, message: String, key: String): Void {
    synchronized(() -> {
      mpnDeviceLogger.logWarn('MPN device can\'t complete the subscription of $key');
    });
  }
}