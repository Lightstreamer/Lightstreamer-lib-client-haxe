package com.lightstreamer.client.mpn;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;

import com.lightstreamer.client.ClientListener;
import com.lightstreamer.client.ClientMessageListener;
import com.lightstreamer.client.SubscriptionListener;

/**
 * Interface to be implemented to receive {@link MpnSubscription} events including subscription/unsubscription, triggering and status change.<BR>
 * Events for these listeners are dispatched by a different thread than the one that generates them. This means that, upon reception of an event,
 * it is possible that the internal state of the client has changed. On the other hand, all the notifications for a single {@link com.lightstreamer.client.LightstreamerClient}, including
 * notifications to {@link ClientListener}, {@link SubscriptionListener}, {@link ClientMessageListener}, {@link MpnDeviceListener} and MpnSubscriptionListener
 * will be dispatched by the same thread.
 */
public interface MpnSubscriptionListener {

    /**
     * Event handler called when the MpnSubscriptionListener instance is added to an {@link MpnSubscription} through 
     * {@link MpnSubscription#addListener(MpnSubscriptionListener)}.<BR>
     * This is the first event to be fired on the listener.
     */
    public void onListenStart();
    
    /**
     * Event handler called when the MpnSubscriptionListener instance is removed from an {@link MpnSubscription} through 
     * {@link MpnSubscription#removeListener(MpnSubscriptionListener)}.<BR>
     * This is the last event to be fired on the listener.
     */
    public void onListenEnd();

    /**
     * Event handler called when an {@link MpnSubscription} has been successfully subscribed to on the server's MPN Module.<BR>
     * This event handler is always called before other events related to the same subscription.<BR>
     * Note that this event can be called multiple times in the life of an MpnSubscription instance only in case it is subscribed multiple times
     * through {@link com.lightstreamer.client.LightstreamerClient#unsubscribe(MpnSubscription)} and {@link com.lightstreamer.client.LightstreamerClient#subscribe(MpnSubscription, boolean)}. Two consecutive calls 
     * to this method are not possible, as before a second <code>onSubscription()</code> event an {@link #onUnsubscription()} event is always fired.
     */
    public void onSubscription();
    
    /**
     * Event handler called when an {@link MpnSubscription} has been successfully unsubscribed from on the server's MPN Module.<BR>
     * After this call no more events can be received until a new {@link #onSubscription()} event.<BR>
     * Note that this event can be called multiple times in the life of an MpnSubscription instance only in case it is subscribed multiple times
     * through {@link com.lightstreamer.client.LightstreamerClient#unsubscribe(MpnSubscription)} and {@link com.lightstreamer.client.LightstreamerClient#subscribe(MpnSubscription, boolean)}. Two consecutive calls 
     * to this method are not possible, as before a second <code>onUnsubscription()</code> event an {@link #onSubscription()} event is always fired.
     */
    public void onUnsubscription();
    
    /**
     * Event handler called when the server notifies an error while subscribing to an {@link MpnSubscription}.<BR>
     * By implementing this method it is possible to perform recovery actions.
     * 
     * @param code The error code sent by the Server. It can be one of the following:<ul>
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
     * @param message The description of the error sent by the Server; it can be null.
     */
    public void onSubscriptionError(int code, @Nullable String message);
    
    /**
     * Event handler called when the server notifies an error while unsubscribing from an {@link MpnSubscription}.<BR>
     * By implementing this method it is possible to perform recovery actions.
     * 
     * @param code The error code sent by the Server. It can be one of the following:<ul>
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
     * @param message The description of the error sent by the Server; it can be null.
     */
    public void onUnsubscriptionError(int code, @Nullable String message);
    
    /**
     * Event handler called when the server notifies that an {@link MpnSubscription} did trigger.<BR>
     * For this event to be called the MpnSubscription must have a trigger expression set and it must have been evaluated to true at
     * least once.<BR>
     * Note that this event can be called multiple times in the life of an MpnSubscription instance only in case it is subscribed multiple times
     * through {@link com.lightstreamer.client.LightstreamerClient#unsubscribe(MpnSubscription)} and {@link com.lightstreamer.client.LightstreamerClient#subscribe(MpnSubscription, boolean)}. Two consecutive calls 
     * to this method are not possible.<BR>
     * Note also that in some server clustering configurations this event may not be called. The corrisponding push notification is always sent, though.
     * 
     * @see MpnSubscription#setTriggerExpression(String)
     */
    public void onTriggered();
    
    /**
     * Event handler called when the server notifies that an {@link MpnSubscription} changed its status.<BR>
     * Note that in some server clustering configurations the status change for the MPN subscription's trigger event may not be called. The corresponding push
     * notification is always sent, though.
     * 
     * @param status The new status of the MPN subscription. It can be one of the following:<ul>
     * <li><code>UNKNOWN</code></li>
     * <li><code>ACTIVE</code></li>
     * <li><code>SUBSCRIBED</code></li>
     * <li><code>TRIGGERED</code></li>
     * </ul>
     * @param timestamp The server-side timestamp of the new subscription status.
     * 
     * @see MpnSubscription#getStatus()
     * @see MpnSubscription#getStatusTimestamp()
     */
    public void onStatusChanged(@Nonnull String status, long timestamp);
    
    /**
     * Event handler called each time the value of a property of {@link MpnSubscription} is changed.<BR>
     * Properties can be modified by direct calls to their setter or by server sent events. A propery may be changed by a server sent event when the MPN subscription is
     * modified, or when two MPN subscriptions coalesce (see {@link com.lightstreamer.client.LightstreamerClient#subscribe(MpnSubscription, boolean)}).
     * 
     * @param propertyName The name of the changed property. It can be one of the following:<ul>
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
    public void onPropertyChanged(@Nonnull String propertyName);    

    /**
     * Event handler called when the value of a property of {@link MpnSubscription} cannot be changed.<BR>
     * Properties can be modified by direct calls to their setters. See {@link MpnSubscription#setNotificationFormat(String)} and {@link MpnSubscription#setTriggerExpression(String)}.
     * 
     * @param code The error code sent by the Server.
     * @param message The description of the error sent by the Server.
     * @param propertyName The name of the changed property. It can be one of the following:<ul>
     * <li><code>notification_format</code></li>
     * <li><code>trigger</code></li>
     * </ul>
     */
    public void onModificationError(int code, String message, String propertyName);
}
