package com.lightstreamer.client;

/**
 * Interface to be implemented to listen to `LightstreamerClient.sendMessage` events reporting a message processing outcome. 
 * Events for these listeners are dispatched by a different thread than the one that generates them.
 * All the notifications for a single LightstreamerClient, including notifications to
 * `ClientListener`s, `SubscriptionListener`s and `ClientMessageListener`s will be dispatched by the 
 * same thread.
 * Only one event per message is fired on this listener.
 */
interface ClientMessageListener {
  /**
   * Event handler that is called by Lightstreamer when any notifications of the processing outcome of the related 
   * message haven't been received yet and can no longer be received. Typically, this happens after the session 
   * has been closed. In this case, the client has no way of knowing the processing outcome and any outcome is possible.
   * @param originalMessage the message to which this notification is related.
   * @param sentOnNetwork true if the message was sent on the network, false otherwise. 
   *        Even if the flag is true, it is not possible to infer whether the message actually reached the 
   *        Lightstreamer Server or not.
   */
  public function onAbort(originalMessage: String, sentOnNetwork: Bool): Void;
  /**
   * Event handler that is called by Lightstreamer when the related message has been processed by the Server but the 
   * expected processing outcome could not be achieved for any reason.
   * @param originalMessage the message to which this notification is related.
   * @param code the error code sent by the Server. It can be one of the following:
   *        <ul><li>&lt;= 0 - the Metadata Adapter has refused the message; the code value is dependent on the 
   *        specific Metadata Adapter implementation.</li></ul>
   * @param error the description of the error sent by the Server.
   */
  public function onDeny(originalMessage: String, code: Int, error: String): Void;
  /**
   * Event handler that is called by Lightstreamer to notify that the related message has been discarded by the Server.
   * This means that the message has not reached the Metadata Adapter and the message next in the sequence is considered 
   * enabled for processing.
   * @param originalMessage the message to which this notification is related.
   */
  public function onDiscarded(originalMessage: String): Void;
  /**
   * Event handler that is called by Lightstreamer when the related message has been processed by the Server but the 
   * processing has failed for any reason. The level of completion of the processing by the Metadata Adapter cannot be 
   * determined.
   * @param originalMessage the message to which this notification is related.
   */
  public function onError(originalMessage: String): Void;
  /**
   * Event handler that is called by Lightstreamer when the related message has been processed by the Server with success.
   * @param originalMessage the message to which this notification is related.
   */
  public function onProcessed(originalMessage: String): Void;
}