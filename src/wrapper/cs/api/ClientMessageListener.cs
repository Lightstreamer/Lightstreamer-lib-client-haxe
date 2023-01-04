/*
 * Copyright (c) 2004-2019 Lightstreamer s.r.l., Via Campanini, 6 - 20124 Milano, Italy.
 * All rights reserved.
 * www.lightstreamer.com
 *
 * This software is the confidential and proprietary information of
 * Lightstreamer s.r.l.
 * You shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the license agreement you entered
 * into with Lightstreamer s.r.l.
 */
namespace com.lightstreamer.client
{
    /// <summary>
    /// Interface to be implemented to listen to <c>LightstreamerClient.sendMessage(string) </c> events reporting a message processing outcome. 
    /// Events for these listeners are dispatched by a different thread than the one that generates them.
    /// All the notifications for a single LightstreamerClient, including notifications to
    /// <seealso cref="ClientListener"/>s, <seealso cref="SubscriptionListener"/>s and <seealso cref="ClientMessageListener"/>s will be dispatched by the 
    /// same thread.
    /// Only one event per message is fired on this listener.
    /// </summary>
    public interface ClientMessageListener
    {

        /// <summary>
        /// Event handler that is called by Lightstreamer when any notifications of the processing outcome of the related 
        /// message haven't been received yet and can no longer be received. Typically, this happens after the session 
        /// has been closed. In this case, the client has no way of knowing the processing outcome and any outcome is possible. </summary>
        /// <param name="originalMessage"> the message to which this notification is related. </param>
        /// <param name="sentOnNetwork"> true if the message was sent on the network, false otherwise. 
        ///        Even if the flag is true, it is not possible to infer whether the message actually reached the 
        ///        Lightstreamer Server or not. </param>
        void onAbort(string originalMessage, bool sentOnNetwork);

        /// <summary>
        /// Event handler that is called by Lightstreamer when the related message has been processed by the Server but the 
        /// expected processing outcome could not be achieved for any reason. </summary>
        /// <param name="originalMessage"> the message to which this notification is related. </param>
        /// <param name="code"> the error code sent by the Server. It can be one of the following:
        ///        <ul><li>&lt;= 0 - the Metadata Adapter has refused the message; the code value is dependent on the 
        ///        specific Metadata Adapter implementation.</li></ul> </param>
        /// <param name="error"> the description of the error sent by the Server. </param>
        void onDeny(string originalMessage, int code, string error);

        /// <summary>
        /// Event handler that is called by Lightstreamer to notify that the related message has been discarded by the Server.
        /// This means that the message has not reached the Metadata Adapter and the message next in the sequence is considered 
        /// enabled for processing. </summary>
        /// <param name="originalMessage"> the message to which this notification is related. </param>
        void onDiscarded(string originalMessage);

        /// <summary>
        /// Event handler that is called by Lightstreamer when the related message has been processed by the Server but the 
        /// processing has failed for any reason. The level of completion of the processing by the Metadata Adapter cannot be 
        /// determined. </summary>
        /// <param name="originalMessage"> the message to which this notification is related. </param>
        void onError(string originalMessage);

        /// <summary>
        /// Event handler that is called by Lightstreamer when the related message has been processed by the Server with success. </summary>
        /// <param name="originalMessage"> the message to which this notification is related. </param>
        void onProcessed(string originalMessage);
    }
}