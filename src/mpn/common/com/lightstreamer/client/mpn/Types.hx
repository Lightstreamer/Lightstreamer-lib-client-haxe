package com.lightstreamer.client.mpn;

import com.lightstreamer.client.NativeTypes.IllegalArgumentException;

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
}

abstract MpnSubscriptionId(String) to String {
  public inline function new(id: String) {
    this = id;
  }
}