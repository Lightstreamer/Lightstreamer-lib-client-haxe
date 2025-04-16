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