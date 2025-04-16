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
package com.lightstreamer.client.hxcbridge;

import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.client.ConnectionDetails.LSConnectionDetails;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("ConnectionDetails")
@:publicFields
class HxCBridgeConnectionDetails {
  private final _delegate: LSConnectionDetails;

  function new(details: LSConnectionDetails) {
    _delegate = details;
  }

  function getAdapterSet(): CppString {
    return _delegate.getAdapterSet() ?? "";
  }

  function setAdapterSet(adapterSet: ConstStar<CppString>) {
    @:nullSafety(Off)
    _delegate.setAdapterSet(adapterSet.isEmpty() ? null : adapterSet);
  }

  function getServerAddress(): CppString {
    return _delegate.getServerAddress() ?? "";
  }

  function setServerAddress(serverAddress: ConstStar<CppString>) {
    @:nullSafety(Off)
    _delegate.setServerAddress(serverAddress.isEmpty() ? null : serverAddress);
  }

  function getUser(): CppString {
    return _delegate.getUser() ?? "";
  }

  function setUser(user: ConstStar<CppString>) {
    @:nullSafety(Off)
    return _delegate.setUser(user.isEmpty() ? null : user);
  }

  function getServerInstanceAddress(): CppString {
    return _delegate.getServerInstanceAddress() ?? "";
  }

  function getServerSocketName(): CppString {
    return _delegate.getServerSocketName() ?? "";
  }

  function getClientIp(): CppString {
    return _delegate.getClientIp() ?? "";
  }

  function getSessionId(): CppString {
    return _delegate.getSessionId() ?? "";
  }

  function setPassword(password: ConstStar<CppString>) {
    @:nullSafety(Off)
    _delegate.setPassword(password.isEmpty() ? null : password);
  }
}