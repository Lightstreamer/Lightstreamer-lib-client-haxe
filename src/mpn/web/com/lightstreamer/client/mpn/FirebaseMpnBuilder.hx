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
import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import haxe.DynamicAccess;

private typedef JsonFormat = {
  var webpush: {
    var ?headers: DynamicAccess<String>;
    var ?data: DynamicAccess<String>;
    var notification: {
      var ?title: String;
      var ?body: String;
      var ?icon: String;
    };
  }
}

#if (js || python) @:expose @:native("LSFirebaseMpnBuilder") #end
class FirebaseMpnBuilder {
  final obj: JsonFormat;
  
  public function new(?format: String) {
    var o: Null<JsonFormat> = format == null ? null : Json.parse(format);
    if (o == null) {
      o = { webpush: { notification: {} }};
    }
    if (o.webpush == null) {
      o.webpush = { notification: {} };
    }
    if (o.webpush.notification == null) {
      o.webpush.notification = {};
    }
    this.obj = o;
  }

  public function build(): String {
    removeNullFields(obj.webpush);
    removeNullFields(obj.webpush.notification);
    return Json.stringify(obj);
  }

  function removeNullFields(o: Dynamic) {
    for (f in Reflect.fields(o)) {
      if (Reflect.field(o, f) == null) {
        Reflect.deleteField(o, f);
      }
    }
  }

  public function getHeaders(): Null<NativeStringMap<String>> {
    var f = obj.webpush.headers;
    return f == null ? null : @:nullSafety(Off) new NativeStringMap<String>(f);
  }
  public function setHeaders(newValue: Null<NativeStringMap<String>>): FirebaseMpnBuilder {
    obj.webpush.headers = newValue == null ? null : newValue.toDynamicAccess();
    return this;
  }

  public function getTitle(): Null<String> {
    return obj.webpush.notification.title;
  }
  public function setTitle(newValue: Null<String>): FirebaseMpnBuilder {
    obj.webpush.notification.title = newValue;
    return this;
  }

  public function getBody(): Null<String> {
    return obj.webpush.notification.body;
  }
  public function setBody(newValue: Null<String>): FirebaseMpnBuilder {
    obj.webpush.notification.body = newValue;
    return this;
  }

  public function getIcon(): Null<String> {
    return obj.webpush.notification.icon;
  }
  public function setIcon(newValue: Null<String>): FirebaseMpnBuilder {
    obj.webpush.notification.icon = newValue;
    return this;
  }

  public function getData(): Null<NativeStringMap<String>> {
    var f = obj.webpush.data;
    return f == null ? null : @:nullSafety(Off) new NativeStringMap<String>(f);
  }
  public function setData(newValue: Null<NativeStringMap<String>>): FirebaseMpnBuilder {
    obj.webpush.data = newValue == null ? null : newValue.toDynamicAccess();
    return this;
  }
}