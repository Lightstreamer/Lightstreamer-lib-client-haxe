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
     * @exports MpnSubscriptionListener
     * 
     * @class Interface to be implemented to receive {@link MpnSubscription} events including subscription/unsubscription, triggering and status change.<BR>
     */
  var MpnSubscriptionListener = function() {};
    
  MpnSubscriptionListener.prototype = {
          
          /**
           * Event handler called when the MpnSubscriptionListener instance is added to an {@link MpnSubscription} through 
           * {@link MpnSubscription#addListener}.<BR>
           * This is the first event to be fired on the listener.
           */
          onListenStart: function() {},
          
          /**
           * Event handler called when the MpnSubscriptionListener instance is removed from an {@link MpnSubscription} through 
           * {@link MpnSubscription#removeListener}.<BR>
           * This is the last event to be fired on the listener.
           */
          onListenEnd: function() {},

          /**
           * Event handler called when an {@link MpnSubscription} has been successfully subscribed to on the server's MPN Module.<BR>
           * This event handler is always called before other events related to the same subscription.<BR>
           * Note that this event can be called multiple times in the life of an MpnSubscription instance only in case it is subscribed multiple times
           * through {@link LightstreamerClient#unsubscribeMpn} and {@link LightstreamerClient#subscribeMpn}. Two consecutive calls 
           * to this method are not possible, as before a second <code>onSubscription()</code> event an {@link MpnSubscriptionListener#onUnsubscription} event is always fired.
           */
          onSubscription: function() {},
          
          /**
           * Event handler called when an {@link MpnSubscription} has been successfully unsubscribed from on the server's MPN Module.<BR>
           * After this call no more events can be received until a new {@link MpnSubscriptionListener#onSubscription} event.<BR>
           * Note that this event can be called multiple times in the life of an MpnSubscription instance only in case it is subscribed multiple times
           * through {@link LightstreamerClient#unsubscribeMpn} and {@link LightstreamerClient#subscribeMpn}. Two consecutive calls 
           * to this method are not possible, as before a second <code>onUnsubscription()</code> event an {@link MpnSubscriptionListener#onSubscription} event is always fired.
           */
          onUnsubscription: function() {},
          
          /**
           * Event handler called when the server notifies an error while subscribing to an {@link MpnSubscription}.<BR>
           * By implementing this method it is possible to perform recovery actions.
           * 
           * @param {Number} code The error code sent by the Server. It can be one of the following:<ul>
           * <li>17 - bad Data Adapter name or default Data Adapter not defined for the current Adapter Set.</li>
           * <li>21 - bad Group name.</li>
           * <li>22 - bad Group name for this Schema.</li>
           * <li>23 - bad Schema name.</li>
           * <li>24 - mode not allowed for an Item.</li>
           * <li>30 - subscriptions are not allowed by the current license terms (for special licenses only).</li>
           * <li>40 - the MPN Module is disabled, either by configuration or by license restrictions.</li>
           * <li>41 - the request failed because of some internal resource error (e.g. database connection, timeout, etc.).</li>
           * <li>43 - invalid or unknown application ID.</li>
           * <li>44 - invalid syntax in trigger expression.</li>
           * <li>45 - invalid or unknown MPN device ID.</li>
           * <li>46 - invalid or unknown MPN subscription ID (for MPN subscription modifications).</li>
           * <li>47 - invalid argument name in notification format or trigger expression.</li>
           * <li>48 - MPN device suspended.</li>
           * <li>49 - one or more subscription properties exceed maximum size.</li>
           * <li>50 - no items or fields have been specified.</li>
           * <li>52 - the notification format is not a valid JSON structure.</li>
           * <li>53 - the notification format is empty.</li>
           * <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection.</li>
           * <li>68 - the Server could not fulfill the request because of an internal error.</li>
           * <li>&lt;= 0 - the Metadata Adapter has refused the subscription request; the code value is dependent on the specific Metadata Adapter implementation.</li>
           * </ul>
           * @param {String} message The description of the error sent by the Server; it can be null.
           */
          onSubscriptionError: function(code, message) {},
          
          /**
           * Event handler called when the server notifies an error while unsubscribing from an {@link MpnSubscription}.<BR>
           * By implementing this method it is possible to perform recovery actions.
           * 
           * @param {Number} code The error code sent by the Server. It can be one of the following:<ul>
           * <li>30 - subscriptions are not allowed by the current license terms (for special licenses only).</li>
           * <li>40 - the MPN Module is disabled, either by configuration or by license restrictions.</li>
           * <li>41 - the request failed because of some internal resource error (e.g. database connection, timeout, etc.).</li>
           * <li>43 - invalid or unknown application ID.</li>
           * <li>45 - invalid or unknown MPN device ID.</li>
           * <li>46 - invalid or unknown MPN subscription ID.</li>
           * <li>48 - MPN device suspended.</li>
           * <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection.</li>
           * <li>68 - the Server could not fulfill the request because of an internal error.</li>
           * <li>&lt;= 0 - the Metadata Adapter has refused the unsubscription request; the code value is dependent on the specific Metadata Adapter implementation.</li>
           * </ul>
           * @param {String} message The description of the error sent by the Server; it can be null.
           */
          onUnsubscriptionError: function(code, message) {},
          
          /**
           * Event handler called when the server notifies that an {@link MpnSubscription} did trigger.<BR>
           * For this event to be called the MpnSubscription must have a trigger expression set and it must have been evaluated to true at
           * least once.<BR>
           * Note that this event can be called multiple times in the life of an MpnSubscription instance only in case it is subscribed multiple times
           * through {@link LightstreamerClient#unsubscribeMpn} and {@link LightstreamerClient#subscribeMpn}. Two consecutive calls 
           * to this method are not possible.<BR>
           * Note also that in some server clustering configurations this event may not be called. The corresponding push notification is always sent, though.
           * 
           * @see MpnSubscription#setTriggerExpression
           */
          onTriggered: function() {},
          
          /**
           * Event handler called when the server notifies that an {@link MpnSubscription} changed its status.<BR>
           * Note that in some server clustering configurations the status change for the MPN subscription's trigger event may not be called. The corresponding push
           * notification is always sent, though.
           * 
           * @param {String} status The new status of the MPN subscription. It can be one of the following:<ul>
           * <li><code>UNKNOWN</code></li>
           * <li><code>ACTIVE</code></li>
           * <li><code>SUBSCRIBED</code></li>
           * <li><code>TRIGGERED</code></li>
           * </ul>
           * @param {Number} timestamp The server-side timestamp of the new subscription status.
           * 
           * @see MpnSubscription#getStatus
           * @see MpnSubscription#getStatusTimestamp
           */
          onStatusChanged: function(status, timestamp) {},
          
          /**
           * Event handler called each time the value of a property of {@link MpnSubscription} is changed.<BR>
           * Properties can be modified by direct calls to their setter or by server sent events. A property may be changed by a server sent event when the MPN subscription is
           * modified, or when two MPN subscriptions coalesce (see {@link LightstreamerClient#subscribeMpn}).
           * 
           * @param {String} propertyName The name of the changed property. It can be one of the following:<ul>
           * <li><code>mode</code></li>
           * <li><code>group</code></li>
           * <li><code>schema</code></li>
           * <li><code>adapter</code></li>
           * <li><code>notification_format</code></li>
           * <li><code>trigger</code></li>
           * <li><code>requested_buffer_size</code></li>
           * <li><code>requested_max_frequency</code></li>
           * <li><code>status_timestamp</code></li>
           * </ul>
           */
          onPropertyChanged: function(propertyName) {},

          /**
           * Event handler called when the value of a property of {@link MpnSubscription} cannot be changed.<BR>
           * Properties can be modified by direct calls to their setters. See {@link MpnSubscription#setNotificationFormat} and {@link MpnSubscription#setTriggerExpression}.
           * 
           * @param {Number} code The error code sent by the Server.
           * @param {String} message The description of the error sent by the Server.
           * @param {String} propertyName The name of the changed property. It can be one of the following:<ul>
           * <li><code>notification_format</code></li>
           * <li><code>trigger</code></li>
           * </ul>
           */
          onModificationError: function(code, message, propertyName) {}
  };