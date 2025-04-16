/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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

#if (js || python) @:expose @:native("LSSafariMpnBuilder") #end
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