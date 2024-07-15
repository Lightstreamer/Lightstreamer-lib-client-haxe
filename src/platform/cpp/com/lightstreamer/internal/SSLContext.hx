package com.lightstreamer.internal;

import sys.ssl.Key;
import sys.ssl.Certificate;

class SSLContext {
  final _caFile: Null<String>;
  final _certificateFile: Null<String>;
  final _privateKeyFile: Null<String>;
  final _password: Null<String>;
  final _verifyCert: Bool;
  final _caCertificate: Null<Certificate>;
  final _certificate: Null<Certificate>;
  final _privateKey: Null<Key>;

  static public function createDefault() {
    return new SSLContext(null, null, null, null, true);
  }

  public function new(caFile: Null<String>, certificateFile: Null<String>, privateKeyFile: Null<String>, password: Null<String> , verifyCert: Bool) {
    _caFile = caFile;
    _certificateFile = certificateFile;
    _privateKeyFile = privateKeyFile;
    _password = password;
    _verifyCert = verifyCert;
    _caCertificate = caFile != null ? Certificate.loadFile(caFile) : null;
    _certificate = certificateFile != null ? Certificate.loadFile(certificateFile) : null;
    _privateKey = privateKeyFile != null ? Key.loadFile(privateKeyFile, null, password) : null;
  }

  public function createSocket() {
    var sslSock = new sys.ssl.Socket();
    if (!_verifyCert) {
      sslSock.verifyCert = false;
    }
    if (_caCertificate != null) {
      sslSock.setCA(_caCertificate);
    }
    if (_certificate != null) {
      @:nullSafety(Off)
      sslSock.setCertificate(_certificate, _privateKey);
    }
    return sslSock;
  }

  public function toString(): String {
    var map = new InfoMap();
    map["ca"] = _caFile;
    map["certificate"] = _certificateFile;
    map["privateKey"] = _privateKeyFile;
    if (!_verifyCert) {
      map["verifyCert"] = false;
    }
    return map.toString();
  }
}