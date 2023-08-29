package com.lightstreamer.internal;

import haxe.Constraints.IMap;
import haxe.ds.IntMap;
import haxe.ds.ReadOnlyArray;

/**
  source: https://github.com/azrafe7/hxOrderedMap/blob/master/src/OrderedIntMap.hx

  OrderedIntMap allows mapping of Int keys to arbitrary values,
  and remembers the order in which key-values are inserted.

  **NB** Since OrderedIntMap is based on `MyArray`, the elements are not actually removed from the map. They are only marked as deleted.  Therefore, you need to call the `compact` method occasionally to reclaim the space and optimize the map.
**/
@:forward
@:native("OrderedIntMap")
abstract OrderedIntMap<T>(OrderedIntMapImpl<T>) from OrderedIntMapImpl<T> {

  public inline function new() {
    this = new OrderedIntMapImpl<T>();
  }

  @:arrayAccess inline function _get(key:Int)
    return this.get(key);

  @:arrayAccess inline function _set(key:Int, value:T):T {
    this.set(key, value);
    return value;
  }

  inline public function containsValue(val: T) {
    return Lambda.has(this, val);
  }
}

private typedef KeyType<T> = MyArray<T>;

class OrderedIntMapImpl<T> implements IMap<Int, T> {

  @:allow(com.lightstreamer.internal.OrderedIntMapIterator)
  var _orderedKeys:KeyType<Int> = new KeyType();
  var _innerMap:IntMap<T> = new IntMap();

  inline public function compact() {
    _orderedKeys.compact();
  }

  /**
    Creates a new OrderedIntMap.
  **/
  public function new():Void { }

  /**
    See `OrderedMap.set`
  **/
  public function set(key:Int, value:T):Void {
    if (!_innerMap.exists(key))
      _orderedKeys.push(key);
    _innerMap.set(key, value);
  }

  /**
    See `OrderedMap.get`
  **/
  public inline function get(key:Int):Null<T> {
    return _innerMap.get(key);
  }

  /**
    See `OrderedMap.exists`
  **/
  public inline function exists(key:Int):Bool {
    return _innerMap.exists(key);
  }

  /**
    See `OrderedMap.remove`
  **/
  public function remove(key:Int):Bool {
    var removed = _innerMap.remove(key);
    if (removed)
      _orderedKeys.remove(key);
    return removed;
  }

  /**
    See `OrderedMap.keys`
  **/
  public inline function keys():Iterator<Int> {
    return _orderedKeys.iterator();
  }

  /**
    See `OrderedMap.iterator`
  **/
  public inline function iterator():Iterator<T> {
    return new OrderedIntMapIterator(this);
  }

  /**
    See `OrderedMap.keyValueIterator`
  **/
  public inline function keyValueIterator():KeyValueIterator<Int, T> {
    return new haxe.iterators.MapKeyValueIterator(this);
  }

  /**
    See `OrderedMap.copy`
  **/
  public function copy():OrderedIntMapImpl<T> {
    var clone = new OrderedIntMapImpl<T>();
    clone._orderedKeys = _orderedKeys.copy();
    clone._innerMap = _innerMap.copy();
    return clone;
  }

  /**
    See `OrderedMap.length`
  **/
  public var length(get, never):Int;

  inline function get_length():Int {
    return _orderedKeys.length;
  }

  /**
    See `OrderedMap.orderedKeys`
  **/
  public var orderedKeys(get, never):ReadOnlyArray<Int>;

  inline function get_orderedKeys():ReadOnlyArray<Int> {
    return cast this._orderedKeys;
  }

  /**
    See `OrderedMap.innerMap`
  **/
  // public var innerMap(get, null):ReadOnlyMap<Int, T>;

  // inline function get_innerMap():ReadOnlyMap<Int, T> {
  //   return cast this._innerMap;
  // }

  /**
    See `OrderedMap.keysCopy`
  **/
  public inline function keysCopy():KeyType<Int> {
    return _orderedKeys.copy();
  }

  /**
    See `OrderedMap.clear`
  **/
  public function clear():Void {
    _orderedKeys = new KeyType();
    _innerMap = new IntMap();
  }

  /**
    See `OrderedMap.toString`
  **/
  public function toString():String {
    var k:Int;
    var i = 0, len = _orderedKeys.length;
    var str = "[";
    for (k in _orderedKeys) {
      str += k + " => " + _innerMap.get(k) + (i != len - 1 ? ", " : "");
      i++;
    }
    return str + "]";
  }
}

@:native("OrderedIntMapIterator")
private class OrderedIntMapIterator<V> {

  var map:OrderedIntMap<V>;
  var it: Iterator<Int>;

  public inline function new(omap:OrderedIntMap<V>) {
    map = omap;
    it = omap._orderedKeys.iterator();
  }

  public inline function hasNext():Bool {
    return it.hasNext();
  }

  @:nullSafety(Off)
  public inline function next():V {
    return map.get(it.next());
  }
}