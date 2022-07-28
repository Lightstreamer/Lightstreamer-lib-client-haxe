package utils;

import com.lightstreamer.client.ClientMessageListener;
import com.lightstreamer.client.LightstreamerClient;

function _sendMessage(client: LightstreamerClient, message: String, sequence: Null<String> = null, delayTimeout: Null<Int> = -1, listener: Null<ClientMessageListener> = null, enqueueWhileDisconnected: Null<Bool> = false): Void {
  client.sendMessage(message, sequence, delayTimeout, listener, enqueueWhileDisconnected);
}

function patch2str(patch: Dynamic) {
  return patch == null ? null : patch is String ? patch : haxe.Json.stringify(patch);
}

function patch2json(patch: Dynamic) {
  return patch == null ? null : patch is String ? haxe.Json.parse(patch) : patch;
}