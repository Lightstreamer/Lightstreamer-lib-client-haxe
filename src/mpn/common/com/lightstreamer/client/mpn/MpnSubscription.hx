package com.lightstreamer.client.mpn;

@:expose("MpnSubscription")
class MpnSubscription {

  #if android
  public function new(appContext: android.content.Context) {
    var pkg = com.lightstreamer.client.mpn.AndroidUtils.getPackageName(appContext);
    trace("MPNSub.new", pkg);
  }
  #end
}