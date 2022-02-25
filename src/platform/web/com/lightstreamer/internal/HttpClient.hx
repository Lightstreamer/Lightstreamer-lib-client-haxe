package com.lightstreamer.internal;

import js.html.XMLHttpRequest;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class HttpClient {
  final xhr: XMLHttpRequest;
  final reader = new StreamReader();
  var isCanceled: Bool = false;

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>, 
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onDone: HttpClient->Void) {
    streamLogger.logDebug('HTTP sending: $url $body headers($headers)');
    this.xhr = new XMLHttpRequest();
    xhr.open("POST", url);
    // set headers
    if (headers != null) {
      for (k => v in headers) {
        xhr.setRequestHeader(k, v);
      }
    }
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xhr.send(body);
    xhr.onreadystatechange = () -> {
      var state = xhr.readyState;
      if (state == XMLHttpRequest.HEADERS_RECEIVED) {
        var status = xhr.status;
        // in local files, status is 0 upon success in Mozilla Firefox
        if (!(status == 0 || (status >= 200 && status < 300))) {
          streamLogger.logDebug('HTTP event: error(HTTP code $status)');
          onError(this, "Unexpected HTTP code: " + status);
          xhr.abort();
        }
      } else if (state > XMLHttpRequest.HEADERS_RECEIVED) {
        var lines = if (state == XMLHttpRequest.LOADING) 
          reader.streamProgress(xhr.responseText);
        else
          reader.streamComplete(xhr.responseText);
        for (line in lines) {
          if (line == "") continue;
          streamLogger.logDebug('HTTP event: text($line)');
          onText(this, line);
        }
        if (state == XMLHttpRequest.DONE) {
          streamLogger.logDebug("HTTP event: complete");
          onDone(this);
        }
      }
    };
    xhr.onerror = () -> {
      var error = "Network error";
      streamLogger.logDebug('HTTP event: error($error)');
      onError(this, error);
    };
  }

  public function dispose() {
    streamLogger.logDebug("HTTP disposing");
    isCanceled = true;
    xhr.abort();
  }

  inline public function isDisposed() {
    return isCanceled;
  }
}