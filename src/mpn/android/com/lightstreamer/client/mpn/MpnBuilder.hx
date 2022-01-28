package com.lightstreamer.client.mpn;

import haxe.DynamicAccess;
import haxe.Json;
import com.lightstreamer.client.NativeTypes.NativeStringMap;
import com.lightstreamer.client.NativeTypes.NativeList;

private typedef JsonFormat = {
  var android: {
    var ?collapse_key: String;
    var ?priority: String;
    var ?ttl: String;
    var ?data: DynamicAccess<String>;
    var notification: {
      var ?title: String;
      var ?title_loc_key: String;
      var ?title_loc_args: Array<String>;
      var ?body: String;
      var ?body_loc_key: String;
      var ?body_loc_args: Array<String>;
      var ?icon: String;
      var ?sound: String;
      var ?tag: String;
      var ?color: String;
      var ?click_action: String;
    };
  };
}

class MpnBuilder {
  final obj: JsonFormat;

  public overload function new() {
    this.obj = { android: { notification: {} }};
  }
  public overload function new(format: String) {
    var o: JsonFormat = format == null ? null : Json.parse(format);
    if (o == null) {
      o = { android: { notification: {} }};
    }
    if (o.android == null) {
      o.android = { notification: {} };
    }
    if (o.android.notification == null) {
      o.android.notification = {};
    }
    this.obj = o;
  }

  public function build(): String {
    removeNullFields(obj.android);
    removeNullFields(obj.android.notification);
    return Json.stringify(obj);
  }

  function removeNullFields(o: Dynamic) {
    for (f in Reflect.fields(o)) {
      if (Reflect.field(o, f) == null) {
        Reflect.deleteField(o, f);
      }
    }
  }

  public overload function collapseKey(newValue: Null<String>): MpnBuilder {
    obj.android.collapse_key = newValue;
    return this;
  }
  public overload function collapseKey(): Null<String> {
    return obj.android.collapse_key;
  }

  public overload function priority(newValue: Null<String>): MpnBuilder {
    obj.android.priority = newValue;
    return this;
  }
  public overload function priority(): Null<String> {
    return obj.android.priority;
  }

  public overload function timeToLive(newValue: Null<String>): MpnBuilder {
    obj.android.ttl = newValue;
    return this;
  }
  public overload function timeToLiveAsString(): Null<String> {
    return obj.android.ttl;
  }
  public overload function timeToLive(newValue: Null<java.lang.Integer>): MpnBuilder {
    obj.android.ttl = newValue == null ? null : newValue.toString();
    return this;
  }
  public overload function timeToLiveAsInteger(): Null<java.lang.Integer> {
    var f = obj.android.ttl;
    var i = f == null ? null : Std.parseInt(f);
    return i == null ? null : java.lang.Integer.valueOf(i);
  }

  public overload function title(newValue: Null<String>): MpnBuilder {
    obj.android.notification.title = newValue;
    return this;
  }
  public overload function title(): Null<String> {
    return obj.android.notification.title;
  }

  public overload function titleLocKey(newValue: Null<String>): MpnBuilder {
    obj.android.notification.title_loc_key = newValue;
    return this;
  }
  public overload function titleLocKey(): Null<String> {
    return obj.android.notification.title_loc_key;
  }

  public overload function titleLocArguments(newValue: Null<NativeList<String>>): MpnBuilder {
    obj.android.notification.title_loc_args = newValue == null ? null : newValue.toHaxe();
    return this;
  }
  public overload function titleLocArguments(): Null<NativeList<String>> {
    var f = obj.android.notification.title_loc_args;
    return f == null ? null : new NativeList(f);
  }

  public overload function body(newValue: Null<String>): MpnBuilder {
    obj.android.notification.body = newValue;
    return this;
  }
  public overload function body(): Null<String> {
    return obj.android.notification.body;
  }

  public overload function bodyLocKey(newValue: Null<String>): MpnBuilder {
    obj.android.notification.body_loc_key = newValue;
    return this;
  }
  public overload function bodyLocKey(): Null<String> {
    return obj.android.notification.body_loc_key;
  }

  public overload function bodyLocArguments(newValue: Null<NativeList<String>>): MpnBuilder {
    obj.android.notification.body_loc_args = newValue == null ? null : newValue.toHaxe();
    return this;
  }
  public overload function bodyLocArguments(): Null<NativeList<String>> {
    var f = obj.android.notification.body_loc_args;
    return f == null ? null : new NativeList(f);
  }

  public overload function icon(newValue: Null<String>): MpnBuilder {
    obj.android.notification.icon = newValue;
    return this;
  }
  public overload function icon(): Null<String> {
    return obj.android.notification.icon;
  }

  public overload function sound(newValue: Null<String>): MpnBuilder {
    obj.android.notification.sound = newValue;
    return this;
  }
  public overload function sound(): Null<String> {
    return obj.android.notification.sound;
  }

  public overload function tag(newValue: Null<String>): MpnBuilder {
    obj.android.notification.tag = newValue;
    return this;
  }
  public overload function tag(): Null<String> {
    return obj.android.notification.tag;
  }

  public overload function color(newValue: Null<String>): MpnBuilder {
    obj.android.notification.color = newValue;
    return this;
  }
  public overload function color(): Null<String> {
    return obj.android.notification.color;
  }

  public overload function clickAction(newValue: Null<String>): MpnBuilder {
    obj.android.notification.click_action = newValue;
    return this;
  }
  public overload function clickAction(): Null<String> {
    return obj.android.notification.click_action;
  }

  public overload function data(newValue: Null<NativeStringMap>): MpnBuilder {
    if (newValue == null) {
      obj.android.data = null;
      return this;
    }
    var data = new DynamicAccess<String>();
    for (k => v in newValue.toHaxe()) {
      data[k] = v;
    }
    obj.android.data = data;
    return this;
  }
  public overload function data(): Null<NativeStringMap> {
    var f = obj.android.data;
    return f == null ? null : new NativeStringMap(f);
  }
}