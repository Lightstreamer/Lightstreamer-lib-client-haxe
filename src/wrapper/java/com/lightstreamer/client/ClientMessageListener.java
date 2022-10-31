/*
 * Copyright (c) 2004-2015 Weswit s.r.l., Via Campanini, 6 - 20124 Milano, Italy.
 * All rights reserved.
 * www.lightstreamer.com
 *
 * This software is the confidential and proprietary information of
 * Weswit s.r.l.
 * You shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the license agreement you entered
 * into with Weswit s.r.l.
 */
package com.lightstreamer.client;

import javax.annotation.Nonnull;

/**
 * Interface to be implemented to listen to {@link LightstreamerClient#sendMessage} events reporting a message processing outcome. 
 * Events for these listeners are dispatched by a different thread than the one that generates them.
 * All the notifications for a single LightstreamerClient, including notifications to
 * {@link ClientListener}s, {@link SubscriptionListener}s and {@link ClientMessageListener}s will be dispatched by the 
 * same thread.
 * Only one event per message is fired on this listener.
 */
public interface ClientMessageListener {

  /**
   * Event handler that is called by Lightstreamer when any notifications of the processing outcome of the related 
   * message haven't been received yet and can no longer be received. Typically, this happens after the session 
   * has been closed. In this case, the client has no way of knowing the processing outcome and any outcome is possible.
   * @param originalMessage the message to which this notification is related.
   * @param sentOnNetwork true if the message was sent on the network, false otherwise. 
   *        Even if the flag is true, it is not possible to infer whether the message actually reached the 
   *        Lightstreamer Server or not.
   */
  void onAbort(@Nonnull String originalMessage, boolean sentOnNetwork);  
  
  /**
   * Event handler that is called by Lightstreamer when the related message has been processed by the Server but the 
   * expected processing outcome could not be achieved for any reason.
   * @param originalMessage the message to which this notification is related.
   * @param code the error code sent by the Server. It can be one of the following:
   *        <ul><li>&lt;= 0 - the Metadata Adapter has refused the message; the code value is dependent on the 
   *        specific Metadata Adapter implementation.</li></ul>
   * @param error the description of the error sent by the Server.
   */
  void onDeny(@Nonnull String originalMessage, int code, @Nonnull String error);  
  
  /**
   * Event handler that is called by Lightstreamer to notify that the related message has been discarded by the Server.
   * This means that the message has not reached the Metadata Adapter and the message next in the sequence is considered 
   * enabled for processing.
   * @param originalMessage the message to which this notification is related.
   */
  void onDiscarded(@Nonnull String originalMessage);
    
  /**
   * Event handler that is called by Lightstreamer when the related message has been processed by the Server but the 
   * processing has failed for any reason. The level of completion of the processing by the Metadata Adapter cannot be 
   * determined.
   * @param originalMessage the message to which this notification is related.
   */
  void onError(@Nonnull String originalMessage);
  
  /**
   * Event handler that is called by Lightstreamer when the related message has been processed by the Server with success.
   * @param originalMessage the message to which this notification is related.
   */
  void onProcessed(@Nonnull String originalMessage);
}
