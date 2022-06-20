package utils;

import com.lightstreamer.client.ClientMessageListener;
import com.lightstreamer.client.LightstreamerClient;

function _sendMessage(client: LightstreamerClient, message: String, sequence: Null<String> = null, delayTimeout: Null<Int> = -1, listener: Null<ClientMessageListener> = null, enqueueWhileDisconnected: Null<Bool> = false): Void {
  client.sendMessage(message, sequence, delayTimeout, listener, enqueueWhileDisconnected);
}