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

import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;

enum abstract MpnSubscriptionMode(String) to String {
  var Merge = "MERGE";
  var Distinct = "DISTINCT";

  public static function fromString(mode: String): MpnSubscriptionMode {
    return switch (mode) {
      case "MERGE": Merge;
      case "DISTINCT": Distinct;
      case _: throw new IllegalArgumentException("The given value is not a valid subscription mode. Admitted values are MERGE, DISTINCT");
    };
  }
}

@:using(com.lightstreamer.client.mpn.Types.MpnRequestedMaxFrequencyTools)
enum MpnRequestedMaxFrequency {
  FreqLimited(max: Float);
  FreqUnlimited;
}

class MpnRequestedMaxFrequencyTools {
  public static function fromString(freq: Null<String>): Null<MpnRequestedMaxFrequency> {
    return if (freq == null) null
    else switch freq {
      case _.toLowerCase() => "unlimited": FreqUnlimited;
      case Std.parseFloat(_) => max if (!Math.isNaN(max) && max > 0): FreqLimited(max);
      case _: throw new IllegalArgumentException("The given value is not valid for this setting; use null, 'unlimited' or a positive number instead");
    }
  }

  public static function toString(freq: Null<MpnRequestedMaxFrequency>) {
    return switch freq {
      case null: null;
      case FreqUnlimited: "unlimited";
      case FreqLimited(max): Std.string(max);
    }
  }

  public static function extEquals(a: Null<MpnRequestedMaxFrequency>, b: Null<MpnRequestedMaxFrequency>) {
    return switch [a, b] {
      case [null, null]: true;
      case [_, null] | [null, _]: false;
      case _: a.equals(b);
    }
  }
}

abstract MpnSubscriptionId(String) to String {
  public inline function new(id: String) this = id;
}

abstract ApplicationId(String) to String {
  public inline function new(id: String) this = id;
}

abstract DeviceToken(String) to String {
  public inline function new(token: String) this = token;
}

abstract DeviceId(String) to String {
  public inline function new(id: String) this = id;
}

enum abstract Platform(String) to String {
  var Google;
  var Apple;
}