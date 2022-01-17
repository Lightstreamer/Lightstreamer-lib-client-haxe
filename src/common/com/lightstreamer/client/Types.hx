package com.lightstreamer.client;

import com.lightstreamer.client.NativeTypes;
using StringTools;

abstract Millis(Long) to Long {
  public inline function new(millis) {
    this = millis;
  }

  public static function fromIntGt0(millis: Long) {
    if (millis <= 0) {
      throw new IllegalArgumentException("value must be greater than zero");
    }
    return new Millis(millis);
  }

  public static function fromIntGtEq0(millis: Long) {
    if (millis < 0) {
      throw new IllegalArgumentException("value must be greater than or equal to zero");
    }
    return new Millis(millis);
  }
}

abstract ContentLength(Long) to Long {
  public inline function new(length) {
    this = length;
  }

  public static function fromIntGt0(millis: Long) {
    if (millis <= 0) {
      throw new IllegalArgumentException("value must be greater than zero");
    }
    return new ContentLength(millis);
  }
}

enum abstract TransportSelection(String) to String {
  var WS = "WS";
  var WS_STREAMING = "WS-STREAMING";
  var WS_POLLING = "WS-POLLING";
  var HTTP = "HTTP";
  var HTTP_STREAMING = "HTTP-STREAMING";
  var HTTP_POLLING = "HTTP-POLLING";

  public static function fromString(transport: Null<String>): Null<TransportSelection> {
    return switch (transport) {
      case null: null;
      case "WS": WS;
      case "WS-STREAMING": WS_STREAMING;
      case "WS-POLLING": WS_POLLING;
      case "HTTP": HTTP;
      case "HTTP-STREAMING": HTTP_STREAMING;
      case "HTTP-POLLING": HTTP_POLLING;
      case _: throw new IllegalArgumentException("The given value is not valid. Use one of: HTTP-STREAMING, HTTP-POLLING, WS-STREAMING, WS-POLLING, WS, HTTP or null");
    };
  }
}

abstract ServerAddress(String) to String {
  public inline function new(address: String) {
    this = address;
  }

  public static function fromString(address: Null<String>): Null<ServerAddress> {
    return switch (address) {
      case null: null;
      case s if (s.startsWith("http://") || s.startsWith("https://")): new ServerAddress(s);
      case _: throw new IllegalArgumentException("address is malformed");
    }
  }
}

@:using(com.lightstreamer.client.Types.RequestedMaxBandwidthTools)
enum RequestedMaxBandwidth {
  BWLimited(bw: Float);
  BWUnlimited;
}

class RequestedMaxBandwidthTools {
  public static function fromString(bandwidth: String): RequestedMaxBandwidth {
    return switch (bandwidth) {
      case _.toLowerCase() => "unlimited": BWUnlimited;
      case Std.parseFloat(_) => bw if (!Math.isNaN(bw) && bw > 0): BWLimited(bw);
      case _: throw new IllegalArgumentException("The given value is a not valid value for RequestedMaxBandwidth. Use a positive number or the string \"unlimited\"");
    }
  }

  public static function toString(bandwidth: RequestedMaxBandwidth) {
    return switch bandwidth {
      case BWUnlimited: "unlimited";
      case BWLimited(bw): Std.string(bw);
    }
  }
}

@:using(com.lightstreamer.client.Types.RealMaxBandwidthTools)
enum RealMaxBandwidth {
  BWLimited(bw: Float);
  BWUnlimited;
  BWUnmanaged;
}

class RealMaxBandwidthTools {
  public static function toString(bandwidth: RealMaxBandwidth) {
    return switch bandwidth {
      case BWUnlimited: "unlimited";
      case BWLimited(bw): Std.string(bw);
      case BWUnmanaged: "unmanaged";
    }
  }
}