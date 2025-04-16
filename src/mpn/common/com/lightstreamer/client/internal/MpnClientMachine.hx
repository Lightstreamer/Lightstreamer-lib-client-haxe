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
package com.lightstreamer.client.internal;

import com.lightstreamer.internal.*;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.internal.Set;
import com.lightstreamer.client.SubscriptionListener;
import com.lightstreamer.client.internal.ParseTools;
import com.lightstreamer.client.internal.MpnRequests;
import com.lightstreamer.client.internal.ClientMachine;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using Lambda;
using StringTools;
using com.lightstreamer.internal.NullTools;
using com.lightstreamer.internal.ArrayTools;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class MpnClientMachine extends ClientMachine {
  final mpnSubscriptionManagers = new MyArray<MpnSubscriptionManager>();
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
  final mpnRegisterRequest: MpnRequests.MpnRegisterRequest;
  final mpnFilterUnsubscriptionRequest: MpnRequests.MpnFilterUnsubscriptionRequest;
  final mpnBadgeResetRequest: MpnRequests.MpnBadgeResetRequest;

  public function new(client: LightstreamerClient, factory: IFactory) {
    super(client, factory);
    mpnRegisterRequest = new MpnRegisterRequest(@:nullSafety(Off) this);
    mpnFilterUnsubscriptionRequest = new MpnFilterUnsubscriptionRequest(@:nullSafety(Off) this);
    mpnBadgeResetRequest = new MpnBadgeResetRequest(@:nullSafety(Off) this);
  }

  // ---------- event handlers ----------

  override public function evtExtConnect_NextRegion(): Bool {
    return evtExtConnect_MpnRegion();
  }

  function evtExtConnect_MpnRegion() {
    var forward = true;
    if (state.s_mpn.m == s401) {
      goto(state.s_mpn.m = s403);
      forward = evtExtConnect_NetworkReachabilityRegion();
      genSendMpnRegister();
    }
    if (forward) {
      forward = evtExtConnect_NetworkReachabilityRegion();
    }
    return false;
  }

  override function evtREQOK_Forward(reqId: Int) {
    traceEvent("mpn:REQOK");
    var forward = true;
    if (state.s_mpn.m == s403 && reqId == mpn_lastRegisterReqId) {
      goto(state.s_mpn.m = s404);
      forward = evtREQOK_TransportRegion(reqId);
    } else if (state.s_mpn.m == s406 && reqId == mpn_lastRegisterReqId) {
      goto(state.s_mpn.m = s407);
      forward = evtREQOK_TransportRegion(reqId);
    } else if (state.s_mpn.tk == s453 && reqId == mpn_lastRegisterReqId) {
      goto(state.s_mpn.tk = s454);
      forward = evtREQOK_TransportRegion(reqId);
    } else if (state.s_mpn.ft == s432 && reqId == mpn_filter_lastDeactivateReqId) {
      doREQMpnUnsubscribeFilter();
      goto(state.s_mpn.ft = s430);
      forward = evtREQOK_TransportRegion(reqId);
      evtMpnCheckFilter();
    } else if (state.s_mpn.bg == s442 && reqId == mpn_badge_lastResetReqId) {
      doREQOKMpnResetBadge();
      forward = evtREQOK_TransportRegion(reqId);
      goto(state.s_mpn.bg = s440);
      evtMpnCheckReset();
    }
    return forward;
  }

  override function evtREQERR_Forward(reqId: Int, code: Int, msg: String) {
    traceEvent("mpn:REQERR");
    var forward = true;
    if (state.s_mpn.m == s403 && reqId == mpn_lastRegisterReqId) {
      notifyDeviceError(code, msg);
      goto(state.s_mpn.m = s402);
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckNext();
    } else if (state.s_mpn.m == s406 && reqId == mpn_lastRegisterReqId) {
      notifyDeviceError(code, msg);
      goto(state.s_mpn.m = s408);
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckNext();
    } else if (state.s_mpn.tk == s453 && reqId == mpn_lastRegisterReqId) {
      notifyDeviceError(code, msg);
      goto(state.s_mpn.tk = s452);
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckNext();
    } else if (state.s_mpn.ft == s432 && reqId == mpn_filter_lastDeactivateReqId) {
      doREQMpnUnsubscribeFilter();
      goto(state.s_mpn.ft = s430);
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckFilter();
    } else if (state.s_mpn.bg == s442 && reqId == mpn_badge_lastResetReqId) {
      doREQERRMpnResetBadge();
      notifyOnBadgeResetFailed(code, msg);
      goto(state.s_mpn.bg = s440);
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckReset();
    }
    return forward;
  }

  override function evtRetry_NextRegion() {
    return evtRetry_MpnRegion();
  }

  function evtRetry_MpnRegion() {
    switch state.s_mpn.m {
    case s403, s404:
      goto(state.s_mpn.m = s403);
    case s406, s407:
      goto(state.s_mpn.m = s406);
    case s405:
      doRemoveMpnSpecialListeners();
      goto({
        state.s_mpn.m = s406;
        state.s_mpn.st = null;
        state.s_mpn.tk = null;
        state.s_mpn.sbs = null;
        state.s_mpn.ft = null;
        state.s_mpn.bg = null;
      });
      genUnsubscribeMpnSpecialItems();
    default:
      // ignore
    }
    return false;
  }

  override function evtTerminate_NextRegion() {
    return evtTerminate_MpnRegion();
  }

  function evtTerminate_MpnRegion() {
    var forward = true;
    switch state.s_mpn.m {
    case s403, s404:
      goto(state.s_mpn.m = s401);
      forward = evtTerminate_NetworkReachabilityRegion();
      evtResetMpnDevice();
    case s406, s407:
      goto(state.s_mpn.m = s401);
      forward = evtTerminate_NetworkReachabilityRegion();
      evtResetMpnDevice();
    case s405:
      doRemoveMpnSpecialListeners();
      goto({
        state.s_mpn.m = s401;
        state.s_mpn.st = null;
        state.s_mpn.tk = null;
        state.s_mpn.sbs = null;
        state.s_mpn.ft = null;
        state.s_mpn.bg = null;
      });
      forward = evtTerminate_NetworkReachabilityRegion();
      genUnsubscribeMpnSpecialItems();
      evtResetMpnDevice();
    default:
      // ignore
    }
    if (forward) {
      forward = evtTerminate_NetworkReachabilityRegion();
    }
    return false;
  }

  override function evtMessage(line: String) {
    if (super.evtMessage(line)) {
      // message already processed by super
    } else if (line.startsWith("MPNREG")) {
      // MPNREG,<device id>,<adapter name>
      var args = line.split(",");
      var deviceId = args[1];
      var adapterName = args[2];
      evtMPNREG(deviceId, adapterName);
    } else if (line.startsWith("MPNZERO")) {
      // MPNZERO,<device id>
      var args = line.split(",");
      var deviceId = args[1];
      evtMPNZERO(deviceId);
    } else if (line.startsWith("MPNOK")) {
      // MPNOK,<subscription id>, <mpn subscription id>
      var args = line.split(",");
      var subId = parseInt(args[1]);
      var mpnSubId = args[2];
      evtMPNOK(subId, mpnSubId);
    } else if (line.startsWith("MPNDEL")) {
      // MPNDEL,<mpn subscription id>
      var args = line.split(",");
      var mpnSubId = args[1];
      evtMPNDEL(mpnSubId);
    } else if (line.startsWith("MPNCONF")) {
      // MPNCONF,<mpn subscription id>
      var args = line.split(",");
      var mpnSubId = args[1];
      evtMPNCONF(mpnSubId);
    }
    return true;
  }

  function evtExtMpnRegister() {
    traceEvent("mpn.register");
    if (state.s_mpn.m == s400) {
      goto(state.s_mpn.m = s402);
      evtMpnCheckNext();
    } else if (state.s_mpn.m == s401) {
      goto(state.s_mpn.m = s402);
      evtMpnCheckNext();
    } else if (state.s_mpn.tk == s451) {
      goto(state.s_mpn.tk = s452);
      evtMpnCheckNext();
    }
  }

  function evtMpnCheckNext() {
    traceEvent("mpn.check.next");
    if (state.s_mpn.m == s402) {
      if (mpn_candidate_devices.empty()) {
        goto(state.s_mpn.m = s401);
        evtResetMpnDevice();
      } else {
        doRegisterMpnDevice();
        goto(state.s_mpn.m = s403);
        genSendMpnRegister();
      }
    } else if (state.s_mpn.m == s408) {
      if (mpn_candidate_devices.empty()) {
        goto(state.s_mpn.m = s401);
        evtResetMpnDevice();
      } else {
        doRegisterMpnDevice();
        goto(state.s_mpn.m = s406);
        genSendMpnRegister();
      }
    } else if (state.s_mpn.tk == s452) {
      if (mpn_candidate_devices.empty()) {
        doRemoveMpnSpecialListeners();
        goto({
          state.s_mpn.m = s401;
          state.s_mpn.st = null;
          state.s_mpn.tk = null;
          state.s_mpn.sbs = null;
          state.s_mpn.ft = null;
          state.s_mpn.bg = null;
        });
        genUnsubscribeMpnSpecialItems();
        evtResetMpnDevice();
      } else {
        doRegisterMpnDevice();
        goto(state.s_mpn.tk = s453);
        genSendMpnRegister();
      }
    }
  }

  function evtResetMpnDevice() {
    traceEvent("reset.mpn.device");
    if (state.s_mpn.m == s401) {
      doResetMpnDevice();
      notifyDeviceReset();
      goto(state.s_mpn.m = s401);
    }
  }

  public function evtMpnError(code: Int, msg: String) {
    traceEvent("mpn.error");
    if (state.s_mpn.m == s405) {
      doRemoveMpnSpecialListeners();
      notifyDeviceError(code, msg);
      goto({
        state.s_mpn.m = s401;
        state.s_mpn.st = null;
        state.s_mpn.sbs = null;
        state.s_mpn.ft = null;
        state.s_mpn.bg = null;
        state.s_mpn.tk = null;
      });
      genUnsubscribeMpnSpecialItems();
      evtResetMpnDevice();
    }
  }

  function evtMPNREG(deviceId: String, adapterName: String) {
    traceEvent("MPNREG");
    protocolLogger.logDebug('MPNREG $deviceId $adapterName');
    var forward = true;
    if (state.inPushing()) {
      if (isFreshData()) {
        doMPNREG();
        var inStreaming = state.inStreaming();
        forward = evtMPNREG_MpnRegion(deviceId, adapterName);
        if (inStreaming) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        var inStreaming = state.inStreaming();
        forward = evtMPNREG_MpnRegion(deviceId, adapterName);
        if (inStreaming) {
          evtRestartKeepalive();
        }
      }
    }
    if (forward) {
      forward = evtMPNREG_MpnRegion(deviceId, adapterName);
    }
  }

  function evtMPNREG_MpnRegion(deviceId: String, adapterName: String) {
    if (state.s_mpn.m == s403 || state.s_mpn.m == s404) {
      doMPNREG_Register(deviceId, adapterName);
      notifyDeviceRegistered(0);
      goto({
        state.s_mpn.m = s405;
        state.s_mpn.st = s410;
        state.s_mpn.sbs = s420;
        state.s_mpn.ft = s430;
        state.s_mpn.bg = s440;
        state.s_mpn.tk = s450;
      });
      genDeviceActive();
      genSubscribeSpecialItems();
      evtMpnCheckPending();
      evtSUBS_Init();
      evtMpnCheckFilter();
      evtMpnCheckReset();
    } else if (state.s_mpn.m == s406 || state.s_mpn.m == s407) {
      if (deviceId == mpn_deviceId && adapterName == mpn_adapterName) {
        doMPNREG_Register(deviceId, adapterName);
        notifyDeviceRegistered(0);
        goto({
          state.s_mpn.m = s405;
          state.s_mpn.st = s410;
          state.s_mpn.sbs = s420;
          state.s_mpn.ft = s430;
          state.s_mpn.bg = s440;
          state.s_mpn.tk = s450;
        });
        genDeviceActive();
        genSubscribeSpecialItems();
        evtMpnCheckPending();
        evtSUBS_Init();
        evtMpnCheckFilter();
        evtMpnCheckReset();
      } else {
        doMPNREG_Error();
        notifyDeviceError_DifferentDevice();
        goto(state.s_mpn.m = s408);
        evtMpnCheckNext();
      }
    } else if (state.s_mpn.tk == s453 || state.s_mpn.tk == s454) {
      if (deviceId == mpn_deviceId && adapterName == mpn_adapterName) {
        doMPNREG_RefreshToken(deviceId, adapterName);
        goto(state.s_mpn.tk = s450);
        evtMpnCheckPending();
      } else {
        doMPNREG_Error();
        notifyDeviceError_DifferentDevice();
        goto(state.s_mpn.tk = s452);
        evtMpnCheckNext();
      }
    }
    return false;
  }

  function evtMPNZERO(deviceId: String) {
    traceEvent("MPNZERO");
    protocolLogger.logDebug('MPNZERO $deviceId');
    if (state.inPushing()) {
      if (isFreshData()) {
        doMPNZERO(deviceId);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtMPNOK(subId: Int, mpnSubId: String) {
    traceEvent("MPNOK");
    protocolLogger.logDebug('MPNOK $subId $mpnSubId');
    if (state.inPushing()) {
      if (isFreshData()) {
        doMPNOK(subId, mpnSubId);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtMPNDEL(mpnSubId: String) {
    traceEvent("MPNDEL");
    protocolLogger.logDebug('MPNDEL $mpnSubId');
    if (state.inPushing()) {
      if (isFreshData()) {
        doMPNDEL(mpnSubId);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtMPNCONF(mpnSubId: String) {
    traceEvent("MPNCONF");
    protocolLogger.logDebug('MPNCONF $mpnSubId');
    if (state.inPushing()) {
      if (isFreshData()) {
        doMPNCONF(mpnSubId);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  public function evtDEV_Update(status: String, timestamp: Long) {
    traceEvent("DEV.update");
    if (state.s_mpn.st == s410) {
      if (status == "ACTIVE") {
        if (!mpn_device.sure().isRegistered()) {
          notifyDeviceRegistered(timestamp);
        }
        goto(state.s_mpn.st = s410);
      } else if (status == "SUSPENDED") {
        if (!mpn_device.sure().isSuspended()) {
          notifyDeviceSuspended(timestamp);
        }
        goto(state.s_mpn.st = s411);
      }
    } else if (state.s_mpn.st == s411) {
      if (status == "ACTIVE") {
        notifyDeviceResume(timestamp);
        goto(state.s_mpn.st = s410);
      }
    }
  }

  function evtMpnCheckPending() {
    traceEvent("mpn.check.pending");
    if (state.s_mpn.tk == s450) {
      if (mpn_candidate_devices.empty()) {
        goto(state.s_mpn.tk = s451);
      } else {
        goto(state.s_mpn.tk = s452);
        evtMpnCheckNext();
      }
    }
  }

  function evtSUBS_Init() {
    traceEvent("SUBS.init");
    if (state.s_mpn.sbs == s420) {
      doClearMpnSnapshot();
      goto(state.s_mpn.sbs = s421);
    }
  }

  public function evtSUBS_Update(mpnSubId: String, update: ItemUpdate) {
    traceEvent("SUBS.update");
    var command = update.getValue("command");
    var status = update.getValue("status");
    if (state.s_mpn.sbs != null && exists(mpnSubId)) {
      state.traceState();
      genSUBS_update(mpnSubId, update);
    } else if (state.s_mpn.sbs == s421 && command != "DELETE" && !exists(mpnSubId)) {
      if (status == null) {
        doAddToMpnSnapshot(mpnSubId);
        goto(state.s_mpn.sbs = s423);
      } else {
        doRemoveFromMpnSnapshot(mpnSubId);
        doAddMpnSubscription(mpnSubId);
        goto(state.s_mpn.sbs = s423);
        genSUBS_update(mpnSubId, update);
      }
    } else if (state.s_mpn.sbs == s423 && command != "DELETE" && !exists(mpnSubId)) {
      if (status == null) {
        doAddToMpnSnapshot(mpnSubId);
        goto(state.s_mpn.sbs = s423);
      } else {
        doRemoveFromMpnSnapshot(mpnSubId);
        doAddMpnSubscription(mpnSubId);
        goto(state.s_mpn.sbs = s423);
        genSUBS_update(mpnSubId, update);
      }
    } else if (state.s_mpn.sbs == s424 && !exists(mpnSubId)) {
      if (command == "DELETE") {
        if (mpn_snapshotSet.contains(mpnSubId)) {
          if (mpn_snapshotSet.count() == 1) {
            doRemoveFromMpnSnapshot(mpnSubId);
            goto(state.s_mpn.sbs = s424);
            notifyOnSubscriptionsUpdated();
          } else {
            doRemoveFromMpnSnapshot(mpnSubId);
            goto(state.s_mpn.sbs = s424);
          }
        }
      } else {
        if (status != null) {
          if (mpn_snapshotSet.contains(mpnSubId)) {
            if (mpn_snapshotSet.count() == 1) {
              doRemoveFromMpnSnapshot(mpnSubId);
              doAddMpnSubscription(mpnSubId);
              goto(state.s_mpn.sbs = s424);
              genSUBS_update(mpnSubId, update);
              notifyOnSubscriptionsUpdated();
            } else {
              doRemoveFromMpnSnapshot(mpnSubId);
              doAddMpnSubscription(mpnSubId);
              goto(state.s_mpn.sbs = s424);
              genSUBS_update(mpnSubId, update);
            }
          } else {
            if (mpn_snapshotSet.count() == 0) {
              doAddMpnSubscription(mpnSubId);
              goto(state.s_mpn.sbs = s424);
              genSUBS_update(mpnSubId, update);
              notifyOnSubscriptionsUpdated();
            } else {
              doAddMpnSubscription(mpnSubId);
              goto(state.s_mpn.sbs = s424);
              genSUBS_update(mpnSubId, update);
            }
          }
        }
      }
    }
  }

  public function evtSUBS_EOS() {
    traceEvent("SUBS.EOS");
    if (state.s_mpn.sbs == s421) {
      goto(state.s_mpn.sbs = s424);
      genSUBS_EOS();
      notifyOnSubscriptionsUpdated();
    } else if (state.s_mpn.sbs == s423) {
      if (mpn_snapshotSet.count() > 0) {
        goto(state.s_mpn.sbs = s424);
        genSUBS_EOS();
      } else {
        goto(state.s_mpn.sbs = s424);
        genSUBS_EOS();
        notifyOnSubscriptionsUpdated();
      }
    }
  }

  function evtExtMpnUnsubscribeFilter() {
    traceEvent("mpn.unsubscribe.filter");
    if (state.s_mpn.ft == s431) {
      goto(state.s_mpn.ft = s430);
      evtMpnCheckFilter();
    }
  }

  function evtMpnCheckFilter() {
    traceEvent("mpn.check.filter");
    if (state.s_mpn.ft == s430) {
      if (mpn_filter_pendings.empty()) {
        goto(state.s_mpn.ft = s431);
      } else {
        goto(state.s_mpn.ft = s432);
        genSendMpnUnsubscribeFilter();
      }
    }
  }

  function evtExtMpnResetBadge() {
    traceEvent("mpn.reset.badge");
    if (state.s_mpn.bg == s441) {
      goto(state.s_mpn.bg = s440);
      evtMpnCheckReset();
    }
  }
  
  function evtMpnCheckReset() {
    traceEvent("mpn.check.reset");
    if (state.s_mpn.bg == s440) {
      if (mpn_badge_reset_requested) {
        goto(state.s_mpn.bg = s442);
        genSendMpnResetBadge();
      } else {
        goto(state.s_mpn.bg = s441);
      }
    }
  }

  // ---------- event actions ----------

  override function doREQOK(reqId: Int) {
    super.doREQOK(reqId);
    for (sub in mpnSubscriptionManagers) {
      sub.evtREQOK(reqId);
    }
    mpnSubscriptionManagers.compact();
  }

  override function doREQERR(reqId: Int, errorCode: Int, errorMsg: String) {
    super.doREQERR(reqId, errorCode, errorMsg);
    for (sub in mpnSubscriptionManagers) {
      sub.evtREQERR(reqId, errorCode, errorMsg);
    }
    mpnSubscriptionManagers.compact();
  }

  override function genAbortSubscriptions() {
    super.genAbortSubscriptions();
    for (sub in mpnSubscriptionManagers) {
      sub.evtAbort();
    }
    mpnSubscriptionManagers.compact();
  }

  override function getPendingControls() {
    var res = super.getPendingControls();
    if (mpnRegisterRequest.isPending()) {
      res.push(mpnRegisterRequest);
    }
    for (sub in mpnSubscriptionManagers.filter(sub -> sub.isPending())) {
      res.push(sub);
    }
    if (mpnFilterUnsubscriptionRequest.isPending()) {
      res.push(mpnFilterUnsubscriptionRequest);
    }
    if (mpnBadgeResetRequest.isPending()) {
      res.push(mpnBadgeResetRequest);
    }
    return res;
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
    evtSendControl(mpnRegisterRequest);
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
    deviceSub.setInternal();
    deviceSub.setDataAdapter(adapterName);
    deviceSub.setRequestedMaxFrequency("unfiltered");
    deviceSub.addListener(mpn_deviceListener);
    mpn_deviceSubscription = deviceSub;
    
    mpn_itemListener = new MpnItemDelegate(this);
    var itemSub = new Subscription("COMMAND", 
      ['SUBS-$deviceId'],
      ["key", "command"]);
    itemSub.setInternal();
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
    mpnSubscriptionManagers.compact();
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
    return mpnSubscriptionManagers.exists(sub -> sub.fetch_mpnSubId() == mpnSubId);
  }

  function genSUBS_update(mpnSubId: String, update: ItemUpdate) {
    for (sm in mpnSubscriptionManagers) {
      if (mpnSubId == sm.fetch_mpnSubId()) {
        sm.evtMpnUpdate(update);
      }
    }
    mpnSubscriptionManagers.compact();
  }

  function doAddToMpnSnapshot(mpnSubId: String) {
    mpn_snapshotSet.insert(mpnSubId);
  }

  function doRemoveFromMpnSnapshot(mpnSubId: String) {
    mpn_snapshotSet.remove(mpnSubId);
  }

  function doAddMpnSubscription(mpnSubId: String) {
    var sm = new MpnSubscriptionManager(Ctor2(mpnSubId, this));
    sm.start();
  }

  function notifyOnSubscriptionsUpdated() {
    mpn_device.sure().fireOnSubscriptionsUpdated();
  }

  function genSUBS_EOS() {
    for (sm in mpnSubscriptionManagers) {
      sm.evtMpnEOS();
    }
    mpnSubscriptionManagers.compact();
  }

  function genSendMpnUnsubscribeFilter() {
    evtSendControl(mpnFilterUnsubscriptionRequest);
  }

  function genSendMpnResetBadge() {
    evtSendControl(mpnBadgeResetRequest);
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
    mpnSubscriptionManagers.compact();
  }

  function doMPNDEL(mpnSubId: String) {
    onFreshData();
    for (sm in mpnSubscriptionManagers) {
      if (sm.fetch_mpnSubId() == mpnSubId) {
        sm.evtMPNDEL();
      }
    }
    mpnSubscriptionManagers.compact();
  }

  function doMPNCONF(mpnSubId: String) {
    onFreshData();
  }

  public function encodeMpnRegister(): String {
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

  public function encodeMpnRefreshToken(): String {
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

  public function encodeMpnRestore(): String {
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

  public function encodeDeactivateFilter(): String {
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

  public function encodeBadgeReset(): String {
    var req = new RequestBuilder();
    mpn_badge_lastResetReqId = generateFreshReqId();
    req.LS_reqId(mpn_badge_lastResetReqId);
    req.LS_op("reset_badge");
    req.PN_deviceId(mpn_deviceId.sure());
    protocolLogger.logInfo('Sending MPNDevice badge reset: $req');
    return req.getEncodedString();
  }

  public function relate(subManager: MpnSubscriptionManager) {
    assert(!mpnSubscriptionManagers.contains(subManager));
    mpnSubscriptionManagers.push(subManager);
  }

  public function unrelate(subManager: MpnSubscriptionManager) {
    mpnSubscriptionManagers.remove(subManager);
  }

  public function fetch_mpn_deviceId(): Null<String> {
    return mpn_deviceId;
  }

  public function fetch_mpn_device(): Null<MpnDevice> {
    return mpn_device;
  }

  public function registerForMpn(mpnDevice: MpnDevice) {
    if (mpnDevice == null) {
      throw new IllegalArgumentException("Device cannot be null");
    }
    mpn_candidate_devices.push(mpnDevice);
    actionLogger.logInfo('MPN registration requested: $mpnDevice');
    evtExtMpnRegister();
  }

  public function subscribeMpn(mpnSubscription: MpnSubscription, coalescing: Bool) {
    if (mpn_device == null) {
      throw new IllegalStateException(NO_DEVICE);
    }
    if (mpnSubscription.isActive()) {
      throw new IllegalArgumentException(IS_ACTIVE_MPN);
    }
    if (mpnSubscription.getNotificationFormat() == null) {
      throw new IllegalArgumentException(NO_FORMAT);
    }
    if (mpnSubscription.getItems() == null && mpnSubscription.getItemGroup() == null) {
      throw new IllegalArgumentException("Specify property 'items' or 'itemGroup'");
    }
    if (mpnSubscription.getFields() == null && mpnSubscription.getFieldSchema() == null) {
      throw new IllegalArgumentException("Specify property 'fields' or 'fieldSchema'");
    }
    var sm = new MpnSubscriptionManager(Ctor1(mpnSubscription, coalescing, this));
    actionLogger.logInfo('MPN Subscription requested: subId: ${sm.m_subId} $mpnSubscription coalescing: $coalescing');
    sm.evtExtMpnSubscribe();
  }

  public function unsubscribeMpn(mpnSubscription: MpnSubscription) {
    if (mpn_device == null) {
      throw new IllegalStateException(NO_DEVICE);
    }
    var sm = mpnSubscription.fetch_subManager();
    if (sm != null) {
      if (!mpnSubscriptionManagers.contains(sm)) {
        throw new IllegalStateException("The MPNSubscription is not subscribed to this Client");
      }
      actionLogger.logInfo('MPN Unsubscription requested: pnSubId: ${mpnSubscription.getSubscriptionId()} $mpnSubscription');
      sm.evtExtMpnUnsubscribe();
    }
  }

  public function unsubscribeMpnSubscriptions(filter: Null<String>) {
    if (mpn_device == null) {
      throw new IllegalStateException(NO_DEVICE);
    }
    var filter = parseStatusFilter(filter);
    mpn_filter_pendings.push(filter);
    actionLogger.logInfo('Multiple MPN Unsubscriptions requested: $filter');
    evtExtMpnUnsubscribeFilter();
  }

  public function getMpnSubscriptions(filter: Null<String>): Array<MpnSubscription> {
    if (mpn_device == null) {
      throw new IllegalStateException(NO_DEVICE);
    }
    var filter = parseStatusFilter(filter); 
    var filteredSubs = switch filter {
      case ALL: 
        mpnSubscriptionManagers.map(sub -> sub.m_subscription).filter(sub -> sub.fetch_status() == Subscribed || sub.fetch_status() == Triggered);
      case SUBSCRIBED:
        mpnSubscriptionManagers.map(sub -> sub.m_subscription).filter(sub -> sub.fetch_status() == Subscribed);
      case TRIGGERED:
        mpnSubscriptionManagers.map(sub -> sub.m_subscription).filter(sub -> sub.fetch_status() == Triggered);
    };
    var mapBySubId = new Map<String, Array<MpnSubscription>>();
    for (sub in filteredSubs) {
      var subId = sub.getSubscriptionId();
      if (subId != null) {
        var ls = mapBySubId[subId];
        if (ls == null) {
          mapBySubId[subId] = [sub];
        } else {
          ls.push(sub);
        }
      }
    }
    var res = [];
    for (_ => subs in mapBySubId) {
      // for each subscriptionId add to the result an user subscription, if it exists;
      // otherwise add the first one, that is a server subscription;
      var assigned = false;
      for (sub in subs) {
        if (!sub.fetch_madeByServer()) {
          res.push(sub);
          assigned = true;
          break;
        }
      }
      if (!assigned && subs[0] != null) {
        res.push(subs[0]);
      }
    }
    return res;
  }

  public function findMpnSubscription(subscriptionId: String): Null<MpnSubscription> {
    if (subscriptionId == null) {
      throw new IllegalArgumentException("Subscription id must be not null");
    }
    if (mpn_device == null) {
      throw new IllegalStateException(NO_DEVICE);
    }
    for (sm in mpnSubscriptionManagers) {
      if (sm.m_subscription.getSubscriptionId() == subscriptionId) {
        return (sm.m_subscription : Null<MpnSubscription>);
      }
    }
    return null;
  }
}

private final IS_ACTIVE_MPN = "Cannot subscribe to an active MPNSubscription";
private final NO_DEVICE = "No MPNDevice Registered";
private final NO_FORMAT = "Specify property 'notificationFormat'";

private enum MPNSubscriptionStatus {
  ALL; SUBSCRIBED; TRIGGERED;
}

private function parseStatusFilter(filter: Null<String>) {
  return switch filter {
    case null: ALL;
    case "ALL": ALL;
    case "SUBSCRIBED": SUBSCRIBED;
    case "TRIGGERED": TRIGGERED;
    case _:
      throw new IllegalArgumentException("The given value is not valid for this setting. Use null, ALL, TRIGGERED or SUBSCRIBED instead");
  };
}

private class SubscriptionDelegateBase implements SubscriptionListener {
  final client: MpnClientMachine;
  var m_disabled = false;
  
  public function new(client: MpnClientMachine) {
    this.client = client;
  }

  public function disable() {
    client.lock.synchronized(() -> {
      m_disabled = true;
    });
  }

  function synchronized(block: () -> Void) {
    client.lock.synchronized(() -> {
      if (!m_disabled) {
        block();
      }
    });
  }

  public function onClearSnapshot(itemName: String, itemPos: Int): Void {}
  public function onCommandSecondLevelItemLostUpdates(lostUpdates: Int, key: String): Void {}
  public function onCommandSecondLevelSubscriptionError(code: Int, message: String, key: String): Void {}
  public function onEndOfSnapshot(itemName: String, itemPos: Int): Void {}
  public function onItemLostUpdates(itemName: String, itemPos: Int, lostUpdates: Int): Void {}
  public function onItemUpdate(update: ItemUpdate): Void {}
  public function onListenEnd(#if js sub: Subscription #end): Void {}
  public function onListenStart(#if js sub: Subscription #end): Void {}
  public function onSubscription(): Void {}
  public function onSubscriptionError(code: Int, message: String): Void {}
  public function onUnsubscription(): Void {}
  public function onRealMaxFrequency(frequency: String): Void {}
}

private class MpnDeviceDelegate extends SubscriptionDelegateBase {

  override public function onItemUpdate(itemUpdate: ItemUpdate): Void {
    synchronized(() -> {
      var status = itemUpdate.getValue("status");
      var timestamp = itemUpdate.getValue("status_timestamp");
      if (status != null) {
        client.evtDEV_Update(status, parseLong(timestamp ?? "0"));
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