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
        /// <param name="response"> the response from the Metadata Adapter. If not supplied (i.e. supplied as null), an empty message is received here. </param>
        void onProcessed(string originalMessage, string response);
    }
}