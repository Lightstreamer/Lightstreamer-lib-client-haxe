package com.lightstreamer.client.internal;

class Request {
  static final EOL_LEN =  lengthOfBytes("\r\n");
  var body = "";

  public function new() {}

  public function getByteSize() {
    return lengthOfBytes(body);
  }

  public function getBody() {
    return body;
  }

  public function addSubRequest(req: String) {
    if (isEmpty(body))  {
      body = req;
    } else {
      body += "\r\n" + req;
    }
  }

  public function addSubRequestOnlyIfBodyIsLessThan(req: String, requestLimit: Int) {
    if (isEmpty(body) && lengthOfBytes(req) <= requestLimit) {
      body = req;
      return true;
    } else if (lengthOfBytes(body) + EOL_LEN + lengthOfBytes(req) <= requestLimit) {
      body += "\r\n" + req;
      return true;
    }
    return false;
  }

  static function isEmpty(s: String) {
    return s.length == 0;
  }

  static function lengthOfBytes(req: String) {
    return haxe.io.Bytes.ofString(req, haxe.io.Encoding.UTF8).length;
  }
}