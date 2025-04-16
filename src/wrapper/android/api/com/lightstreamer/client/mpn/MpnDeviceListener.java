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
package com.lightstreamer.client.mpn;

import javax.annotation.Nonnull;

import com.lightstreamer.client.ClientListener;
import com.lightstreamer.client.ClientMessageListener;
import com.lightstreamer.client.SubscriptionListener;

/**
 * Interface to be implemented to receive MPN device events including registration, suspension/resume and status change.<BR>
 * Events for these listeners are dispatched by a different thread than the one that generates them. This means that, upon reception of an event,
 * it is possible that the internal state of the client has changed. On the other hand, all the notifications for a single {@link com.lightstreamer.client.LightstreamerClient}, including
 * notifications to {@link ClientListener}, {@link SubscriptionListener}, {@link ClientMessageListener}, MpnDeviceListener and {@link MpnSubscriptionListener}
 * will be dispatched by the same thread.
 */
public interface MpnDeviceListener {

    /**
     * Event handler called when the MpnDeviceListener instance is added to an MPN device object through {@link MpnDevice#addListener(MpnDeviceListener)}.<BR>
     * This is the first event to be fired on the listener.
     */
    public void onListenStart();
    
    /**
     * Event handler called when the MpnDeviceListener instance is removed from an MPN device object through {@link MpnDevice#removeListener(MpnDeviceListener)}.<BR>
     * This is the last event to be fired on the listener.
     */
    public void onListenEnd();
    
    /**
     * Event handler called when an MPN device object has been successfully registered on the server's MPN Module.<BR>
     * This event handler is always called before other events related to the same device.<BR>
     * Note that this event can be called multiple times in the life of an MPN device object in case the client disconnects and reconnects. In this case
     * the device is registered again automatically.
     */
    public void onRegistered();
        
    /**
     * Event handler called when an MPN device object has been suspended on the server's MPN Module.<BR>
     * An MPN device may be suspended if errors occur during push notification delivery.<BR>
     * Note that in some server clustering configurations this event may not be called.
     */
    public void onSuspended();
    
    /**
     * Event handler called when an MPN device object has been resumed on the server's MPN Module.<BR>
     * An MPN device may be resumed from suspended state at the first subsequent registration.<BR>
     * Note that in some server clustering configurations this event may not be called.
     */
    public void onResumed();
    
    /**
     * Event handler called when the server notifies that an MPN device changed its status.<BR>
     * Note that in some server clustering configurations the status change for the MPN device suspend event may not be called.
     * 
     * @param status The new status of the MPN device. It can be one of the following:<ul>
     * <li><code>UNKNOWN</code></li>
     * <li><code>REGISTERED</code></li>
     * <li><code>SUSPENDED</code></li>
     * </ul>
     * @param timestamp The server-side timestamp of the new device status.
     * 
     * @see MpnDevice#getStatus()
     * @see MpnDevice#getStatusTimestamp()
     */
    public void onStatusChanged(@Nonnull String status, long timestamp);

    /**
     * Event handler called when the server notifies an error while registering an MPN device object.<BR>
     * By implementing this method it is possible to perform recovery actions.
     * 
     * @param code The error code sent by the Server. It can be one of the following:<ul>
     * <li>40 - the MPN Module is disabled, either by configuration or by license restrictions.</li>
     * <li>41 - the request failed because of some internal resource error (e.g. database connection, timeout, etc.).</li>
     * <li>43 - invalid or unknown application ID.</li>
     * <li>45 - invalid or unknown MPN device ID.</li>
     * <li>48 - MPN device suspended.</li>
     * <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection.</li>
     * <li>68 - the Server could not fulfill the request because of an internal error.</li>
     * <li>&lt;= 0 - the Metadata Adapter has refused the subscription request; the code value is dependent on the specific Metadata Adapter implementation.</li>
     * </ul>
     * @param message The description of the error sent by the Server; it can be null.
     */
    public void onRegistrationFailed(int code, @Nonnull String message);
    
    /**
     * Event handler called when the server notifies that the list of MPN subscription associated with an MPN device has been updated.<BR>
     * After registration, the list of pre-existing MPN subscriptions for the MPN device is updated and made available through the
     * {@link com.lightstreamer.client.LightstreamerClient#getMpnSubscriptions(String)} method.
     * 
     * @see com.lightstreamer.client.LightstreamerClient#getMpnSubscriptions(String)
     */
    public void onSubscriptionsUpdated();
}
