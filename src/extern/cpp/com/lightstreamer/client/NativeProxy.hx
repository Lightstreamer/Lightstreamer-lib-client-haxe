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
package com.lightstreamer.client;

#if LS_HAS_PROXY
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.client.Proxy.LSProxy;

@:forward
abstract NativeProxy(_NativeProxy) {
  @:to
  @:unreflective
  inline function to(): LSProxy {
    return new LSProxy(
      this.type, 
      this.host, 
      this.port, 
      this.user.isEmpty() ? null : this.user, 
      this.password.isEmpty() ? null : this.password);
  }
}

@:structAccess
@:native("Lightstreamer::Proxy")
@:include("Lightstreamer/Proxy.h")
private extern class _NativeProxy {
  var type: CppString;
  var host: CppString;
  var port: Int;
  var user: CppString;
  var password: CppString;
}
#end