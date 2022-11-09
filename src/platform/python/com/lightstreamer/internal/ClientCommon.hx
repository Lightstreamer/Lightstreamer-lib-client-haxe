package com.lightstreamer.internal;

import com.lightstreamer.client.Proxy.LSProxy as Proxy;

using StringTools;

function buildProxy(proxy: Proxy): TypesPy.Proxy {
  var proxyUrl = proxy.host + ":" + proxy.port;
  if (!(proxyUrl.startsWith("http://") || proxyUrl.startsWith("https://"))) {
    proxyUrl = "http://" + proxyUrl;
  }
  return {
    url: proxyUrl,
    user: proxy.user,
    password: proxy.password
  };
}