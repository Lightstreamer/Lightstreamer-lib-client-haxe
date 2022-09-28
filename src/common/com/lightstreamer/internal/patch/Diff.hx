package com.lightstreamer.internal.patch;

#if LS_TLCP_DIFF
abstract DiffPatch(String) {
  public inline function new(patch: String) this = patch;
  public inline function apply(base: String) return DiffDecoder.apply(base, this);
}

class DiffDecoder {
  static inline final VARINT_RADIX = "z".code - "a".code + 1;
  final diff: String;
  final base: String;
  var diffPos = 0;
  var basePos = 0;
  final buf = new StringBuf();

  public static inline function apply(base: String, diff: String) {
    return new DiffDecoder(base, diff).decode();
  }

  public function new(base: String, diff: String) {
    this.diff = diff;
    this.base = base;
  }

  public function decode() {
    while (true) {
      if (diffPos == diff.length) {
        break;
      }
      applyCopy();
      if (diffPos == diff.length) {
        break;
      }
      applyAdd();
      if (diffPos == diff.length) {
        break;
      }
      applyDel();
    }
    return buf.toString();
  }

  function applyCopy() {
    var count = decodeVarint();
    if (count > 0) {
      buf.addSub(base, basePos, count);
      basePos += count;
    }
  }

  function applyAdd() {
    var count = decodeVarint();
    if (count > 0) {
      buf.addSub(diff, diffPos, count);
      diffPos += count;
    }
  }

  function applyDel() {
    var count = decodeVarint();
    if (count > 0) {
      basePos += count;
    }
  }

  function decodeVarint() {
    // the number is encoded with letters as digits
    var n = 0;
    while (true) {
      @:nullSafety(Off)
      var c: Int = diff.charAt(diffPos).charCodeAt(0);
      diffPos += 1;
      if (c >= "a".code && c < ("a".code + VARINT_RADIX)) {
        // small letters used to mark the end of the number
        return n * VARINT_RADIX + (c - "a".code);
      } else {
        //assert (c >= "A".code && c < ("A".code + VARINT_RADIX));
        n = n * VARINT_RADIX + (c - "A".code);
      }
    }
  }
}
#end