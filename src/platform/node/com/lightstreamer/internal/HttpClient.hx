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
package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi.IHttpClient;
import xmlhttprequest.*;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class HttpClient implements IHttpClient {
  final xhr: XMLHttpRequest;
  final reader = new StreamReader();
  var isCanceled: Bool = false;
  
  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>, 
    withCredentials: Bool,
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onDone: HttpClient->Void) {
    streamLogger.logDebug('HTTP sending: $url $body headers($headers)');
    this.xhr = new XMLHttpRequest();
    xhr.open("POST", url);
    // send croos-site credentials (e.g. cookies)
    xhr.withCredentials = withCredentials;
    // set headers
    if (headers != null) {
      for (k => v in headers) {
        xhr.setRequestHeader(k, v);
      }
    }
    // set cookies
    var cookies = CookieHelper.instance.getCookieHeader(url);
    switch cookies {
      case Some(header):
        xhr.setDisableHeaderCheck(true);
        xhr.setRequestHeader("Cookie", header);
        xhr.setDisableHeaderCheck(false);
      case _:
    }
    // set content-type
    xhr.setRequestHeader("Content-Type","text/plain; charset=utf-8");
    xhr.send(body);
    xhr.onreadystatechange = () -> {
      if (isCanceled) return;
      var state = xhr.readyState;
      if (state == XMLHttpRequest.HEADERS_RECEIVED) {
        // store cookies
        var cookies = xhr.getResponseHeader("Set-Cookie");
        if (cookies != null) {
          CookieHelper.instance.addCookies(url, cookies);
        }
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
          if (isCanceled) return;
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
      if (isCanceled) return;
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