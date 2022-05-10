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

  public static function equals(a: Null<MpnRequestedMaxFrequency>, b: Null<MpnRequestedMaxFrequency>) {
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