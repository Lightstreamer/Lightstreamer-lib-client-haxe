package com.lightstreamer.client.hxcbridge;

import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.cpp.CppIntMap;
import com.lightstreamer.cpp.CppStringMap;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("ItemUpdate")
@:publicFields
class HxCBridgeItemUpdate {
  private final _upd: ItemUpdate;

  @:allow(com.lightstreamer.client.hxcbridge.SubscriptionListenerAdapter)
  private function new(upd: ItemUpdate) {
    _upd = upd;
  }

  function getItemName(): CppString {
    return _upd.getItemName() ?? "";
  }

  function getItemPos(): Int {
    return _upd.getItemPos();
  }

  function getValueByName(@:nullSafety(Off) fieldName: ConstStar<CppString>): CppString {
    return _upd.getValueByName(fieldName) ?? "";
  }

  function getValueByPos(fieldPos: Int): CppString {
    return _upd.getValueByPos(fieldPos) ?? "";
  }

  function isNullByName(@:nullSafety(Off) fieldName: ConstStar<CppString>): Bool {
    return _upd.getValueByName(fieldName) == null;
  }

  function isNullByPos(fieldPos: Int): Bool {
    return _upd.getValueByPos(fieldPos) == null;
  }

  function isSnapshot(): Bool {
    return _upd.isSnapshot();
  }

  function isValueChangedByName(@:nullSafety(Off) fieldName: ConstStar<CppString>): Bool {
    return _upd.isValueChangedByName(fieldName);
  }

  function isValueChangedByPos(fieldPos: Int): Bool {
    return _upd.isValueChangedByPos(fieldPos);
  }

  function getChangedFields(): CppStringMap {
    return _upd.getChangedFields();
  }

  function getChangedFieldsByPosition(): CppIntMap {
    return _upd.getChangedFieldsByPosition();
  }

  function getFields(): CppStringMap {
    return _upd.getFields();
  }

  function getFieldsByPosition(): CppIntMap {
    return _upd.getFieldsByPosition();
  }
}