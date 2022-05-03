package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Set;
import com.lightstreamer.internal.Types;

class ItemUpdate2Level implements ItemUpdate {
  public function new(itemIdx: Pos, sub: Subscription, newValues: Map<Pos, Null<String>>, changedFields: Set<Pos>, isSnapshot: Bool) {
    // TODO
  }

  public function getItemName():String {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }

  public function getItemPos():Int {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }

  public function getValue(fieldName:String):String {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }

  public function isSnapshot():Bool {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }

  public function isValueChanged(fieldName:String):Bool {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }

  public function getChangedFields():Map<String, String> {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }

  public function getChangedFieldsByPosition():Map<Int, String> {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }

  public function getFields():Map<String, String> {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }

  public function getFieldsByPosition():Map<Int, String> {
    // TODO
    throw new haxe.exceptions.NotImplementedException();
  }
}