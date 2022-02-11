package com.lightstreamer.client.internal;

import com.lightstreamer.client.NativeTypes.NativeList;
import java.net.CookieStore;
import java.net.HttpCookie;
import java.net.URI;
import java.net.CookieManager;
import java.net.InMemoryCookieStore;
import java.net.CookieHandler;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

@:build(com.lightstreamer.client.Macros.synchronizeClass())
class CookieHelper {
  public static final instance = new CookieHelper();
  var firstTime = true;
  var cookieHandler: Null<CookieManager>;

  function new() {}

  public function addCookies(uri: URI, cookies: NativeList<HttpCookie>) {
    var store = getCookieStore();
    if (store != null) {
      if (cookieLogger.isDebugEnabled()) {
        logCookies("Before adding cookies for " + uri, store.getCookies());
        logCookies("Cookies to be added for " + uri, cookies);
      }
      for (cookie in cookies) {
        store.add(uri, cookie); 
      }
      if (cookieLogger.isDebugEnabled()) {
        logCookies("After adding cookies for " + uri, store.getCookies());
      }
    } else {
      cookieLogger.logWarn("Global CookieHandler not suitable for cookie storage");
    }
  }

  public function getCookies(uri: Null<URI>): NativeList<HttpCookie> {
    var store = getCookieStore();
    if (store != null) {
      if (uri == null) {
        if (cookieLogger.isDebugEnabled()) {
          logCookies("While extracting cookies", store.getCookies());
        }
        return store.getCookies();
      } else {
        if (cookieLogger.isDebugEnabled()) {
          logCookies("While getting cookies for " + uri, store.getCookies());
          logCookies("Result of getting cookies for " + uri, store.get(uri));
        }
        return store.get(uri);
      }
    } else {
      cookieLogger.logWarn("Global CookieHandler not suitable for cookie retrieval");
      return java.util.Collections.emptyList();
    }
  }

  public function clearCookies() {
    var store = getCookieStore();
    if (store != null) {
      store.removeAll();
    }
  }

  function getCookieStore(): Null<CookieStore> {
    var handler = getCookieHandler();
    @:nullSafety(Off)
    var manager = Std.downcast(handler, CookieManager);
    return manager == null ? null : manager.getCookieStore();
  }

  /**
   * If the first time the method is called the user hasn't set a default cookie manager
   * (see {@link CookieHandler#setDefault(CookieHandler)}), the library creates a local manager. 
   * Every successive call uses the local manager regardless of whether the user installs
   * a default manager.
   * <br>
   * On the other hand if the user has installed a default cookie manager, 
   * the library uses the default manager. If the user changes the default manager,
   * the library uses the new manager. If the user removes the default manager,
   * the library doesn't manage cookies.
   */
  public function getCookieHandler(): CookieHandler {
    if (firstTime) {
      firstTime = false;
      if (CookieHandler.getDefault() == null) {
        cookieHandler = new CookieManager(null, java.net.CookiePolicy.ACCEPT_ALL);
        cookieLogger.logInfo("Setting up custom CookieHandler: " + cookieHandler);
        var defaultStore = cookieHandler.getCookieStore();
        cookieLogger.logInfo("Default CookieStore type: " + java.Lib.getNativeType(defaultStore).getName());
        if (java.Lib.getNativeType(defaultStore).getName() == "sun.net.www.protocol.http.InMemoryCookieStore"
          || java.Lib.getNativeType(defaultStore).getName() == "java.net.CookieStoreImpl") {
          // old cookie store; some of them are flawed; use a replacement
          cookieHandler = new CookieManager(new InMemoryCookieStore(), java.net.CookiePolicy.ACCEPT_ALL);
          cookieLogger.logInfo("Improving the custom CookieHandler: " + cookieHandler);
        }
      } else {
        cookieLogger.logInfo("Will use the default CookieHandler");
      }
    }
    if (cookieHandler != null) {
      return (cookieHandler : CookieHandler);
    } else {
      var currentHandler = CookieHandler.getDefault();
      cookieLogger.logDebug("Using the current default CookieHandler: " + currentHandler);
      return currentHandler;
    }
  }

  function logCookies(message: String, cookies: NativeList<HttpCookie>) {
    for (cookie in cookies) {
      message += ("\r\n    " + cookie.toString());
      message += (" - domain " + cookie.getDomain());
      message += (" - path " + cookie.getPath());
      message += (" - expired " + cookie.hasExpired());
      message += (" - ports " + cookie.getPortlist());
      message += (" - secure " + cookie.getSecure());
      message += (" - max-age " + cookie.getMaxAge());
      message += (" - discard " + cookie.getDiscard());
      message += (" - version " + cookie.getVersion());
    }
    cookieLogger.logDebug(message);
  }
}