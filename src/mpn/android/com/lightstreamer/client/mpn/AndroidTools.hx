package com.lightstreamer.client.mpn;

import android.content.Context;
import com.google.android.gms.common.*;

function isGooglePlayServicesAvailable(appContext: Context) {
  return GooglePlayServicesUtil.isGooglePlayServicesAvailable(appContext) == ConnectionResult.SUCCESS;
}

function getPackageVersion(appContext: Context): haxe.Int64 {
  var packageName = appContext.getPackageName();
  return appContext.getPackageManager().getPackageInfo(packageName, 0).getLongVersionCode();
}

function readTokenFromSharedPreferences(appContext: Context) {
  var packageName = appContext.getPackageName();
  var prefs = appContext.getSharedPreferences(packageName, Context.MODE_PRIVATE);
  @:nullSafety(Off) return prefs.getString(PREFS_REG_ID, null);
}

function writeTokenToSharedPreferences(appContext: Context, value: String) {
  var packageName = appContext.getPackageName();
  var prefs = appContext.getSharedPreferences(packageName, Context.MODE_PRIVATE);
  var editor = prefs.edit();
  editor.putString(PREFS_REG_ID, value);
  editor.commit();
}

private final PREFS_REG_ID = "LS_registration_id";