package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes;
using StringTools;
using Lambda;

typedef Pos = Int;

enum FieldValue {
  unchanged;
  changed(val: Null<String>);
  #if LS_JSON_PATCH
  jsonPatch(patch: com.lightstreamer.internal.patch.Json.JsonPatch);
  #end
}

enum abstract ClientStatus(String) to String {
  var CONNECTING = "CONNECTING";
  var CONNECTED_STREAM_SENSING = "CONNECTED:STREAM-SENSING";
  var CONNECTED_WS_STREAMING = "CONNECTED:WS-STREAMING";
  var CONNECTED_HTTP_STREAMING = "CONNECTED:HTTP-STREAMING";
  var CONNECTED_WS_POLLING = "CONNECTED:WS-POLLING";
  var CONNECTED_HTTP_POLLING = "CONNECTED:HTTP-POLLING";
  var STALLED = "STALLED";
  var DISCONNECTED_WILL_RETRY = "DISCONNECTED:WILL-RETRY";
  var DISCONNECTED_TRYING_RECOVERY = "DISCONNECTED:TRYING-RECOVERY";
  var DISCONNECTED = "DISCONNECTED";
}

abstract RequestLimit(Int) from Int to Int {}

abstract Millis(Long) to Long {
  public static final ZERO = new Millis(0);

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

  @:op(A > B)
  public inline function gti(rhs: Int) {
    return this > rhs;
  }

  @:op(A > B)
  public inline function gt(rhs: Millis) {
    return this > (rhs : Long);
  }

  @:op(A < B)
  public inline function lt(rhs: Millis) {
    return this < (rhs : Long);
  }

  @:op(A + B)
  public function plus(rhs: Millis): Millis {
    return new Millis(this + rhs);
  }

  @:op(A - B)
  public function minus(rhs: Millis): Millis {
    return new Millis(this - rhs);
  }

  @:op(A == B)
  public static function eq(a: Millis, b: Int): Bool;

  @:op(A != B)
  public static function neq(a: Millis, b: Int): Bool;

  public inline function toInt(): Int {
    return cast this;
  }
}

abstract Timestamp(Long) to Long {
  public inline function new(ts: Long) {
    this = ts;
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

@:using(com.lightstreamer.internal.Types.RequestedMaxBandwidthTools)
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

@:using(com.lightstreamer.internal.Types.RequestedBufferSizeTools)
enum RequestedBufferSize {
  BSLimited(size: Int);
  BSUnlimited;
}

class RequestedBufferSizeTools {
  public static function fromString(size: Null<String>): Null<RequestedBufferSize> {
    return if (size == null) null 
    else switch size {
      case _.toLowerCase() => "unlimited": BSUnlimited;
      case Std.parseInt(_) => num if (num != null && num > 0): BSLimited(num);
      case _: throw new IllegalArgumentException("The given value is not valid for this setting; use null, 'unlimited' or a positive integer instead");
    }
  }

  public static function toString(size: Null<RequestedBufferSize>) {
    return switch size {
      case null: null;
      case BSUnlimited: "unlimited";
      case BSLimited(sz): Std.string(sz);
    }
  }

  public static function extEquals(a: Null<RequestedBufferSize>, b: Null<RequestedBufferSize>) {
    return switch [a, b] {
      case [null, null]: true;
      case [_, null] | [null, _]: false;
      case _: a.equals(b);
    }
  }
}

@:using(com.lightstreamer.internal.Types.RequestedSnapshotTools)
enum RequestedSnapshot {
  SnpYes;
  SnpNo;
  SnpLength(len: Int);
}

class RequestedSnapshotTools {
  public static function fromString(snapshot: Null<String>): Null<RequestedSnapshot> {
    return if (snapshot == null) null
    else switch snapshot {
      case _.toLowerCase() => "yes": SnpYes;
      case _.toLowerCase() => "no": SnpNo;
      case Std.parseInt(_) => len if (len != null && len > 0): SnpLength(len);
      case _: throw new IllegalArgumentException("The given value is not valid for this setting; use null, 'yes', 'no' or a positive number instead");
    }
  }

  public static function toString(snapshot: Null<RequestedSnapshot>) {
    return switch snapshot {
      case null: null;
      case SnpYes: "yes";
      case SnpNo: "no";
      case SnpLength(len): Std.string(len);
    }
  }
}

@:using(com.lightstreamer.internal.Types.RequestedMaxFrequencyTools)
enum RequestedMaxFrequency {
  FreqLimited(max: Float);
  FreqUnlimited;
  FreqUnfiltered;
}

class RequestedMaxFrequencyTools {
  public static function fromString(freq: Null<String>): Null<RequestedMaxFrequency> {
    return if (freq == null) null
    else switch freq {
      case _.toLowerCase() => "unlimited": FreqUnlimited;
      case _.toLowerCase() => "unfiltered": FreqUnfiltered;
      case Std.parseFloat(_) => max if (!Math.isNaN(max) && max > 0): FreqLimited(max);
      case _: throw new IllegalArgumentException("The given value is not valid for this setting; use null, 'unlimited', 'unfiltered' or a positive number instead");
    }
  }

  public static function toString(freq: Null<RequestedMaxFrequency>) {
    return switch freq {
      case null: null;
      case FreqUnlimited: "unlimited";
      case FreqUnfiltered: "unfiltered";
      case FreqLimited(max): Std.string(max);
    }
  }

  public static function extEquals(a: Null<RequestedMaxFrequency>, b: Null<RequestedMaxFrequency>) {
    return switch [a, b] {
      case [null, null]: true;
      case [_, null] | [null, _]: false;
      case _: a.equals(b);
    }
  }
}

enum RealMaxFrequency {
  RFreqLimited(freq: Float);
  RFreqUnlimited;
}

function realFrequencyAsString(freq: Null<RealMaxFrequency>) {
  return switch freq {
  case null: "null";
  case RFreqLimited(f): '$f';
  case RFreqUnlimited: "unlimited";
  }
}

function realFrequencyEquals(a: Null<RealMaxFrequency>, b: Null<RealMaxFrequency>) {
  return switch [a, b] {
    case [null, null]: true;
    case [_, null] | [null, _]: false;
    case _: a.equals(b);
  }
}

@:using(com.lightstreamer.internal.Types.RealMaxBandwidthTools)
enum RealMaxBandwidth {
  BWLimited(bw: Float);
  BWUnlimited;
  BWUnmanaged;
}

class RealMaxBandwidthTools {
  public static function toString(bandwidth: Null<RealMaxBandwidth>) {
    return switch bandwidth {
      case null: null;
      case BWUnlimited: "unlimited";
      case BWLimited(bw): Std.string(bw);
      case BWUnmanaged: "unmanaged";
    }
  }
}

enum abstract SubscriptionMode(String) to String {
  var Merge = "MERGE";
  var Distinct = "DISTINCT";
  var Command = "COMMAND";
  var Raw = "RAW";

  public static function fromString(mode: String): SubscriptionMode {
    return switch (mode) {
      case "MERGE": Merge;
      case "DISTINCT": Distinct;
      case "COMMAND": Command;
      case "RAW": Raw;
      case _: throw new IllegalArgumentException("The given value is not a valid subscription mode. Admitted values are MERGE, DISTINCT, RAW, COMMAND");
    };
  }
}

abstract Items(Array<String>) to Array<String> {
  public inline function new(a: Array<String>) {
    this = a;
  }

  public function getPos(name: String): Pos {
    var pos = this.indexOf(name);
    return pos != -1 ? pos + 1 : -1;
  }

  public static function allValidNames(names: Array<String>) {
    @:nullSafety(Off)
    return !names.exists(item -> ~/^$| |^\d/.match(item));
  }

  public static function fromArray(array: Null<Array<String>>): Null<Items> {
    switch array {
      case null: 
        return null;
      case []:
        throw new IllegalArgumentException("Item List is empty");
      case a if (!allValidNames(a)):
        // an item name is invalid when it is empty, contains spaces or starts with a digit
        throw new IllegalArgumentException("Item List is invalid");
      case a:
        return new Items(a);
    }  
  }
}

abstract Fields(Array<String>) to Array<String> {
  public inline function new(a: Array<String>) {
    this = a;
  }

  public function getPos(name: String): Pos {
    var pos = this.indexOf(name);
    return pos != -1 ? pos + 1 : -1;
  }

  public inline function hasKeyField() {
    return this.contains("key");
  }

  public inline function hasCommandField() {
    return this.contains("command");
  }

  public static function fromArray(array: Null<Array<String>>): Null<Fields> {
    switch array {
      case null:
        return null;
      case []:
        throw new IllegalArgumentException("Field List is empty");
      case a if (@:nullSafety(Off) a.exists(field -> ~/^$| /.match(field))):
        // a field name is invalid when it is empty or contains spaces
        throw new IllegalArgumentException("Field List is invalid");
      case a:
        return new Fields(a);
    }
  }
}

abstract Name(String) to String {
  public inline function new(name: String) this = name;

  public static function fromString(name: Null<String>): Null<Name> {
    switch name {
      case null:
        return null;
      case "":
        throw new IllegalArgumentException("The value is empty");
      case n:
        return new Name(n);
    }
  }
}

abstract TriggerExpression(String) to String {
  public inline function new(trigger: String) {
    this = trigger;
  }

  public static inline function fromString(trigger: Null<String>): Null<TriggerExpression> {
    return trigger == null ? null : new TriggerExpression(trigger);
  }
}

abstract NotificationFormat(String) to String {
  public inline function new(format: String) {
    this = format;
  }

  public static inline function fromString(format: Null<String>): Null<NotificationFormat> {
    return format == null ? null : new NotificationFormat(format);
  }
}