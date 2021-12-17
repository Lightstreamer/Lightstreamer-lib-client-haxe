package com.lightstreamer.client.mpn;

import android.content.Context;

class AndroidUtils {
  //private function new () {}

  public static function getPackageName(appContext: Context): String {
    return appContext.getPackageName();
  }

  public static function getPackageVersion(appContext: Context)/*: Int*/ {
    var packageName = getPackageName(appContext);
    return appContext.getPackageManager().getPackageInfo(packageName, 0).getLongVersionCode();
  }
}

