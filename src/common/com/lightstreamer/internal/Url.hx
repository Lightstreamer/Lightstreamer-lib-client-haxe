package com.lightstreamer.internal;

using StringTools;

class Url {
  var _protocol: String;
  var _hostname: String;
  var _port: String;
  var _pathname: String;
  public var protocol(get, set): String;
  public var hostname(get, set): String;
  public var port(get, set): String;
  public var pathname(get, set): String;
  public var href(get, never): String;

  public function new(url: String, ?path: String) {
    var schemaEnd = url.indexOf("://");
    if (schemaEnd != -1) {
      _protocol = url.substring(0, schemaEnd) + ":";
      url = url.substring(schemaEnd + 3);
    } else {
      _protocol = "";
    }
    var pathStart = url.indexOf("/");
    if (pathStart != -1) {
      _pathname = url.substring(pathStart);
      url = url.substring(0, pathStart);
    } else {
      _pathname = "/";
    }
    var portStart = @:nullSafety(Off) extractPortStart(url);
    if (portStart != -1) {
      _port = url.substring(portStart);
      _hostname = url.substring(0, portStart - 1);
    } else {
      _port = "";
      _hostname = url;
    }
    if (path != null) {
      pathname = path;
    }
  }

  public static function build(base: String, path: String) {
    if (path != null) {
      var baseEndsWithSlash = base.endsWith("/");
      var pathStartsWithSlash = path.startsWith("/");
      if (!baseEndsWithSlash) {
        if (!pathStartsWithSlash) {
          base += "/" + path;
        } else {
          base += path;
        }
      } else {
        if (!pathStartsWithSlash) {
          base += path;
        } else {
          base += path.substring(1);
        }
      }
    }
    return base;
  }

  public static function completeControlLink(clink: String, baseAddress: String) {
    var baseUrl = new Url(baseAddress);
    var clUrl = new Url(clink);
    if (clUrl.protocol == "") {
      clUrl.protocol = baseUrl.protocol;
    }
    if (clUrl.port == "") {
      clUrl.port = baseUrl.port;
    }
    return clUrl.href;
  }

  function get_protocol() return _protocol;

  function set_protocol(newValue: String) {
    if (newValue != "" && !newValue.endsWith(":")) {
      newValue += ":";
    }
    _protocol = newValue;
    return _protocol;
  }

  function get_hostname() return _hostname;

  function set_hostname(newValue: String) {
    _hostname = newValue;
    return _hostname;
  }

  function get_port() return _port;

  function set_port(newValue: String) {
    _port = newValue;
    return _port;
  }

  function get_pathname() return _pathname;

  function set_pathname(newValue: String) {
    if (!newValue.startsWith("/")) {
      newValue = "/" + newValue;
    }
    _pathname = newValue;
    return _pathname;
  }

  function get_href() {
    var url = _hostname;
    if (_protocol != "") {
        url = _protocol + "//" + url;
    }
    if (_port != "") {
        url += ":" + _port;
    }
    if (pathname != "") {
        url += _pathname;
    }
    return url;
  }

  public function toString() {
    return href;
  }

  function extractPortStart(address: String) {
    var portStarts = address.indexOf(":");
    if (portStarts <= -1) {
      return -1;
    }
    if (address.indexOf("]") > -1) {
      portStarts = address.indexOf("]:");
      if (portStarts <= -1) {
        return -1;
      }
      return portStarts + 2;
    } else if (portStarts != address.lastIndexOf(":")) {
      return -1;
    } else {
      return portStarts + 1;
    }
  }
}