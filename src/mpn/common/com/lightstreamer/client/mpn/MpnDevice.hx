package com.lightstreamer.client.mpn;

import com.lightstreamer.internal.Types.Timestamp;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.EventDispatcher;
import com.lightstreamer.client.mpn.Types;
import com.lightstreamer.log.LoggerTools.mpnDeviceLogger;
using com.lightstreamer.log.LoggerTools;
#if java
using com.lightstreamer.client.mpn.AndroidTools;
#end

private class MpnDeviceEventDispatcher extends EventDispatcher<MpnDeviceListener> {}

private enum abstract MpnDeviceStatus(String) to String {
  var UNKNOWN;
  var REGISTERED;
  var SUSPENDED;
}

#if (js || python) @:expose @:native("MpnDevice") #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class LSMpnDevice {
  final eventDispatcher = new MpnDeviceEventDispatcher();
  final platform: Platform;
  final applicationId: ApplicationId;
  final deviceToken: DeviceToken;
  final prevDeviceToken: Null<DeviceToken>;
  var status: MpnDeviceStatus = UNKNOWN;
  var statusTs: Timestamp = new Timestamp(0);
  var deviceId: Null<DeviceId>;
  var adapterName: Null<String>;

  #if java
  public function new(appContext: android.content.Context, token: String) {
    if (appContext == null) {
        throw new IllegalArgumentException("Please specify a valid appContext");
    }
    if (token == null) {
        throw new IllegalArgumentException("Please specify a valid token");
    }
    try {
      java.lang.Class.forName("com.google.android.gms.common.GooglePlayServicesUtil");
    } catch (e: java.lang.Exception) {
      throw new IllegalStateException("Couldn't check for availability of Google Play Services", e);
    }
    if (!appContext.isGooglePlayServicesAvailable()) {
      throw new IllegalStateException("Google Play Services Not Available");
    }
    // Check last registration ID
    var previousToken = appContext.readTokenFromSharedPreferences();
    if (previousToken != null) {
      mpnDeviceLogger.logDebug("Previous registration ID found (" + previousToken + ")");
    } else {
      mpnDeviceLogger.logDebug("No previous registration ID found");
    }
    mpnDeviceLogger.logDebug("Registration ID obtained (" + token + "), storing...");
    appContext.writeTokenToSharedPreferences(token);
    mpnDeviceLogger.logDebug("Registration ID stored");
    // Set device attributes
    this.platform = Google;
    this.applicationId = new ApplicationId(appContext.getPackageName());
    this.deviceToken = new DeviceToken(token);
    this.prevDeviceToken = previousToken == null ? null : new DeviceToken(previousToken);
  }
  #elseif js
  public function new(deviceToken: String, appId: String, platform: String) {
    if (deviceToken == null) {
      throw new IllegalArgumentException("Please specify a valid device token");
    }
    if (appId == null) {
        throw new IllegalArgumentException("Please specify a valid application ID");
    }
    this.deviceToken = new DeviceToken(deviceToken);
    this.applicationId = new ApplicationId(appId);
    this.platform = switch platform {
      case "Google": Google;
      case "Apple": Apple;
      case _: throw new IllegalArgumentException("Please specify a valid platform: Google or Apple");
    };
    // Check last registration ID
    var storage = js.Browser.getLocalStorage();
    if (storage != null) {
      var prevDeviceToken = storage.getItem("com.lightstreamer.mpn.device_token");
      if (prevDeviceToken != null) {
        mpnDeviceLogger.logDebug("Previous registration ID found (" + prevDeviceToken + ")");
      } else {
        mpnDeviceLogger.logDebug("No previous registration ID found");
      }
      mpnDeviceLogger.logDebug("Registration ID obtained (" + deviceToken + "), storing...");
      storage.setItem("com.lightstreamer.mpn.device_token", deviceToken);
      mpnDeviceLogger.logDebug("Registration ID stored");
      this.prevDeviceToken = new DeviceToken(prevDeviceToken);
    } else {
      mpnDeviceLogger.logError("Local storage not available");
      this.prevDeviceToken = null;
    }
  }
  #end

  public function addListener(listener: MpnDeviceListener): Void {
    eventDispatcher.addListenerAndFireOnListenStart(listener);
  }
  public function removeListener(listener: MpnDeviceListener): Void {
    eventDispatcher.removeListenerAndFireOnListenEnd(listener);
  }
  public function getListeners(): NativeList<MpnDeviceListener> {
    return new NativeList(eventDispatcher.getListeners());
  }

  public function isRegistered(): Bool {
    return status == REGISTERED;
  }
  public function isSuspended(): Bool {
    return status == SUSPENDED;
  }
  public function getStatus(): String {
    return status;
  }
  public function getStatusTimestamp(): Long {
    return statusTs;
  }
  public function getPlatform(): String {
    return platform;
  }
  public function getApplicationId(): String {
    return applicationId;
  }
  public function getDeviceToken(): String {
    return deviceToken;
  }
  public function getPreviousDeviceToken(): Null<String> {
    return prevDeviceToken;
  }
  public function getDeviceId(): Null<String> {
    return deviceId;
  }

  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function setDeviceId(deviceId: String, adapterName: String) {
    lock.synchronized(() -> {
      this.deviceId = new DeviceId(deviceId);
      this.adapterName = adapterName;
    });
  }

  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function onRegistered(timestamp: Long) {
    lock.synchronized(() -> {
      mpnDeviceLogger.logInfo('MPN device registered: $deviceId)');
      status = REGISTERED;
      statusTs = new Timestamp(timestamp);
      
      eventDispatcher.onStatusChanged(REGISTERED, timestamp);
      eventDispatcher.onRegistered();
    });
  }

  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function onSuspend(timestamp: Long) {
    lock.synchronized(() -> {
      mpnDeviceLogger.logInfo('MPN device suspended: $deviceId');
      status = SUSPENDED;
      statusTs = new Timestamp(timestamp);
      
      eventDispatcher.onStatusChanged(SUSPENDED, timestamp);
      eventDispatcher.onSuspended();
    });
  }

  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function onResume(timestamp: Long) {
    lock.synchronized(() -> {
      mpnDeviceLogger.logInfo('MPN device resumed: $deviceId');
      status = REGISTERED;
      statusTs = new Timestamp(timestamp);
      
      eventDispatcher.onStatusChanged(REGISTERED, timestamp);
      eventDispatcher.onResumed();
    });
  }

  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function onError(code: Int, msg: String) {
    lock.synchronized(() -> {
      mpnDeviceLogger.logWarn('MPN device error: $code - $msg $deviceId');
      status = UNKNOWN;
      statusTs = new Timestamp(0);
      deviceId = null;
      adapterName = null;
      
      eventDispatcher.onRegistrationFailed(code, msg);
      eventDispatcher.onStatusChanged(UNKNOWN, 0);
    });
  }

  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function onReset() {
    lock.synchronized(() -> {
      mpnDeviceLogger.logInfo("MPN device NOT registered");
      var oldStatus = status;
      status = UNKNOWN;
      statusTs = new Timestamp(0);
      deviceId = null;
      adapterName = null;
      
      if (oldStatus != UNKNOWN) {
        eventDispatcher.onStatusChanged(UNKNOWN, 0);
      }
    });
  }

  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fireOnSubscriptionsUpdated() {
    lock.synchronized(() -> {
      mpnDeviceLogger.logInfo('MPN subscriptions have been updated: $deviceId');
      eventDispatcher.onSubscriptionsUpdated();
    });
  }

  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function fireOnBadgeResetFailed(code: Int, msg: String) {
    // Swift only
    lock.synchronized(() -> {
      mpnDeviceLogger.logWarn('MPN badge reset failed: $code - $msg $deviceId');
    });
  }
  
  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function fireOnBadgeReset() {
    // Swift only
    lock.synchronized(() -> {
      mpnDeviceLogger.logInfo('MPN badge successfully reset: $deviceId');
    });
  }
}