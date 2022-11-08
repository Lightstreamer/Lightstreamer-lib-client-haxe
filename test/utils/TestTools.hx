package utils;

import com.lightstreamer.client.ClientMessageListener;
import com.lightstreamer.client.LightstreamerClient.LSLightstreamerClient as LightstreamerClient;

function _sendMessage(client: LightstreamerClient, message: String, sequence: Null<String> = null, delayTimeout: Null<Int> = -1, listener: Null<ClientMessageListener> = null, enqueueWhileDisconnected: Null<Bool> = false): Void {
  client.sendMessage(message, sequence, delayTimeout, listener, enqueueWhileDisconnected);
}

function patch2str(patch: Dynamic) {
  return patch == null ? null : patch is String ? patch : haxe.Json.stringify(patch);
}

function patch2json(patch: Dynamic) {
  return patch == null ? null : patch is String ? haxe.Json.parse(patch) : patch;
}

#if java
function getResourceAsJavaBytes(name: String) {
  #if android
  var ksIn = AndroidTools.openRawResource("server_certificate");
  #else
  var bytes = haxe.Resource.getBytes("server_certificate").getData();
  var ksIn = new java.io.ByteArrayInputStream(bytes);
  #end
  return ksIn;
}

// keep references to loggers to prevent their configuration from being GC'd
var okhttpLogger: java.util.logging.Logger;

// see https://square.github.io/okhttp//contribute/debug_logging/
function enableOkHttpLogger() {
  okhttpLogger = java.util.logging.Logger.getLogger("okhttp3.OkHttpClient");
  var handler = new java.util.logging.ConsoleHandler();
  handler.setLevel(java.util.logging.Level.FINE);
  okhttpLogger.addHandler(handler);
  okhttpLogger.setLevel(java.util.logging.Level.FINE);
}
#end