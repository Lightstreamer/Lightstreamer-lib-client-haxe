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
/**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   *
   * @exports ClientMessageListener
   * @class Interface to be implemented to listen to {@link LightstreamerClient#sendMessage}
   * events reporting a message processing outcome.
   * <BR>Events for these listeners are executed asynchronously with respect to the code
   * that generates them.
   * <BR>Note that it is not necessary to implement all of the interface methods for
   * the listener to be successfully passed to the {@link LightstreamerClient#sendMessage}
   * method. On the other hand, if all of the handlers are implemented the library will
   * ensure to call one and only one of them per message.
   */
 function ClientMessageListener() {

};

ClientMessageListener.prototype = {
  /**
   * Event handler that is called by Lightstreamer when any notifications
   * of the processing outcome of the related message haven't been received
   * yet and can no longer be received.
   * Typically, this happens after the session has been closed.
   * In this case, the client has no way of knowing the processing outcome
   * and any outcome is possible.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   * @param {boolean} sentOnNetwork true if the message was probably sent on the
   * network, false otherwise.
   * <BR>Event if the flag is true, it is not possible to infer whether the message
   * actually reached the Lightstreamer Server or not.
   */
  onAbort: function(originalMessage,sentOnNetwork) {
    return;
  },

  /**
   * Event handler that is called by Lightstreamer when the related message
   * has been processed by the Server but the processing has failed for any
   * reason. The level of completion of the processing by the Metadata Adapter
   * cannot be determined.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   */
  onError: function(originalMessage) {
    return;
  },

  /**
   * Event handler that is called by Lightstreamer to notify that the related
   * message has been discarded by the Server. This means that the message
   * has not reached the Metadata Adapter and the message next in the sequence
   * is considered enabled for processing.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   */
  onDiscarded: function(originalMessage) {
    return;
  },

  /**
   * Event handler that is called by Lightstreamer when the related message
   * has been processed by the Server but the expected processing outcome
   * could not be achieved for any reason.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   * @param {Number} code the error code sent by the Server. It can be one
   * of the following:
   * <ul>
   * <li>&lt;= 0 - the Metadata Adapter has refused the message; the code
   * value is dependent on the specific Metadata Adapter implementation.</li>
   * </ul>
   * @param {String} message the description of the error sent by the Server.
   */
  onDeny: function(originalMessage,code, message) {
    return;
  },

  /**
   * Event handler that is called by Lightstreamer when the related message
   * has been processed by the Server with success.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   * @param {String} response the response from the Metadata Adapter. If not supplied (i.e. supplied as null), an empty message is received here.
   */
  onProcessed: function(originalMessage, response) {
    return;
  }
};