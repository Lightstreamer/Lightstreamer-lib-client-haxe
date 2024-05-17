package com.lightstreamer.client;

import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.client.ConnectionDetails.LSConnectionDetails;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("ConnectionDetails")
@:publicFields
class HxConnectionDetails {
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