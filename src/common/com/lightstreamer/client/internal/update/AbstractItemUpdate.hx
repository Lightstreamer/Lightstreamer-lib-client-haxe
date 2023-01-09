package com.lightstreamer.client.internal.update;

#if cs
import com.lightstreamer.internal.NativeTypes.NativeIntMap;
import com.lightstreamer.internal.NativeTypes.NativeStringMap;
#end

abstract class AbstractItemUpdate implements ItemUpdate {
  #if cs
  abstract function getItemName(): Null<String>;
  abstract function getItemPos(): Int;
  abstract function isSnapshot(): Bool;
  abstract function getChangedFields(): NativeStringMap<Null<String>>;
  abstract function getChangedFieldsByPosition(): NativeIntMap<Null<String>>;
  abstract function getFields(): NativeStringMap<Null<String>>;
  abstract function getFieldsByPosition(): NativeIntMap<Null<String>>;

  @:property public var ItemName(get, never): Null<String>;
  @:property public var ItemPos(get, never): Int;
  @:property public var Snapshot(get, never): Bool;
  @:property public var ChangedFields(get, never): NativeStringMap<Null<String>>;
  @:property public var ChangedFieldsByPosition(get, never): NativeIntMap<Null<String>>;
  @:property public var Fields(get, never): NativeStringMap<Null<String>>;
  @:property public var FieldsByPosition(get, never): NativeIntMap<Null<String>>;

  inline function get_ItemName() return getItemName();
  inline function get_ItemPos() return getItemPos();
  inline function get_Snapshot() return isSnapshot();
  inline function get_ChangedFields() return getChangedFields();
  inline function get_ChangedFieldsByPosition() return getChangedFieldsByPosition();
  inline function get_Fields() return getFields();
  inline function get_FieldsByPosition() return getFieldsByPosition();
  #end
}