package com.lightstreamer.client.mpn;

import haxe.Json;
import com.lightstreamer.internal.NativeTypes.NativeList;

private typedef JsonFormat = {
  var aps: {
    //var url-args: Array<String>;
    var alert: {
      var ?title: String;
      var ?body: String;
      var ?action: String;
    };
  };
}

#if (js || python) @:expose @:native("SafariMpnBuilder") #end
#if (java || cs || python) @:nativeGen #end
class SafariMpnBuilder {
  final obj: JsonFormat;

  public function new(?format: String) {
    var o: Null<JsonFormat> = format == null ? null : Json.parse(format);
    if (o == null) {
      o = { aps: { alert: {} }};
    }
    if (o.aps == null) {
      o.aps = { alert: {} };
    }
    if (o.aps.alert == null) {
      o.aps.alert = {};
    }
    this.obj = o;
  }

  public function build(): String {
    removeNullFields(obj.aps);
    removeNullFields(obj.aps.alert);
    return Json.stringify(obj);
  }

  function removeNullFields(o: Dynamic) {
    for (f in Reflect.fields(o)) {
      if (Reflect.field(o, f) == null) {
        Reflect.deleteField(o, f);
      }
    }
  }

  public function getTitle(): Null<String> {
    return obj.aps.alert.title;
  }
  public function setTitle(newValue: Null<String>): SafariMpnBuilder {
    obj.aps.alert.title = newValue;
    return this;
  }
  
  public function getBody(): Null<String> {
    return obj.aps.alert.body;
  }
  public function setBody(newValue: Null<String>): SafariMpnBuilder {
    obj.aps.alert.body = newValue;
    return this;
  }

  public function getAction(): Null<String> {
    return obj.aps.alert.action;
  }
  public function setAction(newValue: Null<String>): SafariMpnBuilder {
    obj.aps.alert.action = newValue;
    return this;
  }

  public function getUrlArguments(): Null<NativeList<String>> {
    var f = Reflect.field(obj.aps, "url-args");
    return f == null ? null : new NativeList(f);
  }
  public function setUrlArguments(newValue: Null<NativeList<String>>): SafariMpnBuilder {
    @:nullSafety(Off)
    Reflect.setField(obj.aps, "url-args", newValue == null ? null : newValue.toHaxe());
    return this;
  }
}