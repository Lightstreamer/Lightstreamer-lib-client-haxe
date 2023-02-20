package com.lightstreamer.client.mpn;

import java.util.List;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;
import javax.annotation.concurrent.ThreadSafe;
import com.lightstreamer.client.*;
import com.lightstreamer.client.mpn.LSMpnSubscription;


/**
 * Class representing a Mobile Push Notifications (MPN) subscription to be submitted to the MPN Module of a Lightstreamer Server.<BR>
 * It contains subscription details and the listener needed to monitor its status. Real-time data is routed via native push notifications.<BR>
 * In order to successfully subscribe an MPN subscription, first an MpnDevice must be created and registered on the LightstreamerClient with
 * {@link LightstreamerClient#registerForMpn(MpnDevice)}.<BR>
 * After creation, an MpnSubscription object is in the "inactive" state. When an MpnSubscription object is subscribed to on an LightstreamerClient
 * object, through the {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} method, its state switches to "active". This means that the subscription request
 * is being sent to the Lightstreamer Server. Once the server accepted the request, it begins to send real-time events via native push notifications and
 * the MpnSubscription object switches to the "subscribed" state.<BR>
 * If a trigger expression is set, the MPN subscription does not send any push notifications until the expression evaluates to true. When this happens,
 * the MPN subscription switches to "triggered" state and a single push notification is sent. Once triggered, no other push notifications are sent.<BR>
 * When an MpnSubscription is subscribed on the server, it acquires a permanent subscription ID that the server later uses to identify the same
 * MPN subscription on subsequent sessions.<BR>
 * An MpnSubscription can be configured to use either an Item Group or an Item List to specify the items to be subscribed to, and using either a Field Schema
 * or Field List to specify the fields. The same rules that apply to {@link Subscription} apply to MpnSubscription.<BR>
 * An MpnSubscription object can also be provided by the client to represent a pre-existing MPN subscription on the server. In fact, differently than real-time
 * subscriptions, MPN subscriptions are persisted on the server's MPN Module database and survive the session they were created on.<BR>
 * MPN subscriptions are associated with the MPN device, and after the device has been registered the client retrieves pre-existing MPN subscriptions from the
 * server's database and exposes them with the {@link LightstreamerClient#getMpnSubscriptions(String)} method.
 */
public class MpnSubscription {
    /** @hidden */
    public final LSMpnSubscription delegate;

    /**
     * Creates an object to be used to describe an MPN subscription that is going to be subscribed to through the MPN Module of Lightstreamer Server.<BR>
     * The object can be supplied to {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} in order to bring the MPN subscription to "active" state.<BR>
     * Note that all of the methods used to describe the subscription to the server can only be called while the instance is in the "inactive" state.
     *
     * @param subscriptionMode The subscription mode for the items, required by Lightstreamer Server. Permitted values are:<ul>
     * <li><code>MERGE</code></li>
     * <li><code>DISTINCT</code></li>
     * </ul>
     * @param items An array of items to be subscribed to through Lightstreamer Server. It is also possible specify the "Item List" or
     * "Item Group" later through {@link #setItems(String[])} and {@link #setItemGroup(String)}.
     * @param fields An array of fields for the items to be subscribed to through Lightstreamer Server. It is also possible to specify the "Field List" or
     * "Field Schema" later through {@link #setFields(String[])} and {@link #setFieldSchema(String)}.
     * @throws IllegalArgumentException If no or invalid subscription mode is passed.
     * @throws IllegalArgumentException If either the items or the fields array is left null.
     * @throws IllegalArgumentException If the specified "Item List" or "Field List" is not valid; see {@link #setItems(String[])} and {@link #setFields(String[])} for details.
     */
    public MpnSubscription(@Nonnull String subscriptionMode, @Nonnull String[] items, @Nonnull String[] fields) {
        this.delegate = new LSMpnSubscription(subscriptionMode, items, fields, this);
    }

    /**
     * Creates an object to be used to describe an MPN subscription that is going to be subscribed to through the MPN Module of Lightstreamer Server.<BR>
     * The object can be supplied to {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} in order to bring the MPN subscription to "active" state.<BR>
     * Note that all of the methods used to describe the subscription to the server can only be called while the instance is in the "inactive" state.
     * 
     * @param subscriptionMode The subscription mode for the items, required by Lightstreamer Server. Permitted values are:<ul>
     * <li><code>MERGE</code></li>
     * <li><code>DISTINCT</code></li>
     * </ul>
     * @param item The item name to be subscribed to through Lightstreamer Server.
     * @param fields An array of fields for the items to be subscribed to through Lightstreamer Server. It is also possible to specify the "Field List" or
     * "Field Schema" later through {@link #setFields(String[])} and {@link #setFieldSchema(String)}.
     * @throws IllegalArgumentException If no or invalid subscription mode is passed.
     * @throws IllegalArgumentException If either the item or the fields array is left null.
     * @throws IllegalArgumentException If the specified "Field List" is not valid; see {@link #setFields(String[])} for details.
     */
    public MpnSubscription(@Nonnull String subscriptionMode, @Nonnull String item, @Nonnull String[] fields) {
        this.delegate = new LSMpnSubscription(subscriptionMode, item, fields, this);
    }

    /**
     * Creates an object to be used to describe an MPN subscription that is going to be subscribed to through the MPN Module of Lightstreamer Server.<BR>
     * The object can be supplied to {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} in order to bring the MPN subscription to "active" state.<BR>
     * Note that all of the methods used to describe the subscription to the server can only be called while the instance is in the "inactive" state.
     * 
     * @param subscriptionMode The subscription mode for the items, required by Lightstreamer Server. Permitted values are:<ul>
     * <li><code>MERGE</code></li>
     * <li><code>DISTINCT</code></li>
     * </ul>
     * @throws IllegalArgumentException If no or invalid subscription mode is passed.
     */
    public MpnSubscription(@Nonnull String subscriptionMode) {
        this.delegate = new LSMpnSubscription(subscriptionMode, this);
    }

    /**
     * Creates an MpnSubscription object copying subscription mode, items, fields and data adapter from the specified real-time subscription.<BR>
     * The object can be supplied to {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} in order to bring the MPN subscription to "active" state.<BR>
     * Note that all of the methods used to describe the subscription to the server, except {@link #setTriggerExpression(String)} and {@link #setNotificationFormat(String)}, can only be called while the instance is in the "inactive" state.
     * 
     * @param copyFrom The Subscription object to copy properties from.
     */
    public MpnSubscription(@Nonnull Subscription copyFrom) {
        this.delegate = new LSMpnSubscription(copyFrom.delegate, this);
    }

    /**
     * Creates an MPNSubscription object copying all properties from the specified MPN subscription.
     *
     * The object can be supplied to {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} in order to bring the MPN subscription to "active" state.
     *
     * Note that all of the methods used to describe the subscription to the server, except {@link #setTriggerExpression(String)} and {@link #setNotificationFormat(String)}, can only be called while the instance is in the "inactive" state.
     * 
     * @param copyFrom The MpnSubscription object to copy properties from.
     */
    public MpnSubscription(@Nonnull MpnSubscription copyFrom) {
        this.delegate = new LSMpnSubscription(copyFrom.delegate, this);
    }

    /**
     * Adds a listener that will receive events from the MpnSubscription instance.<BR>
     * The same listener can be added to several different MpnSubscription instances.<BR>
     * 
     * @lifecycle A listener can be added at any time. A call to add a listener already present will be ignored.
     * 
     * @param listener An object that will receive the events as documented in the {@link MpnSubscriptionListener}  interface.
     * 
     * @see #removeListener(MpnSubscriptionListener)
     */
    public void addListener(@Nonnull final MpnSubscriptionListener listener) {
        delegate.addListener(listener);
    }

    /**
     * Removes a listener from the MpnSubscription instance so that it will not receive events anymore.
     * 
     * @lifecycle A listener can be removed at any time.
     * 
     * @param listener The listener to be removed.
     * 
     * @see #addListener(MpnSubscriptionListener)
     */
    public void removeListener(@Nonnull final MpnSubscriptionListener listener) {
        delegate.removeListener(listener);
    }

    /**
     * Returns the list containing the {@link MpnSubscriptionListener} instances that were added to this MpnSubscription.
     * 
     * @return a list containing the listeners that were added to this subscription.
     *
     * @see #addListener(MpnSubscriptionListener)
     */
    @Nonnull
    public List<MpnSubscriptionListener> getListeners() {
        return delegate.getListeners();
    }
    
    /**
     * Inquiry method that gets the JSON structure requested by the user to be used as the format of push notifications.<BR>
     * 
     * @return the JSON structure requested by the user to be used as the format of push notifications.
     * 
     * @see #setNotificationFormat(String)
     * @see #getActualNotificationFormat()
     */
    @Nullable
    public String getNotificationFormat() {
        return delegate.getNotificationFormat();
    }

    /**
     * Inquiry method that gets the JSON structure used by the Sever to send notifications.
     *
     * @return the JSON structure used by the Server to send notifications or null if the value is not available.
     *
     * @see #getNotificationFormat()
     */
    @Nullable
    public String getActualNotificationFormat() {
        return delegate.getActualNotificationFormat();
    }

    /**
     * Sets the JSON structure to be used as the format of push notifications.<BR>
     * This JSON structure is sent by the server to the push notification service provider (i.e. Google's FCM), hence it must follow
     * its specifications.<BR>
     * The JSON structure may contain named arguments with the format <code>${field}</code>, or indexed arguments with the format <code>$[1]</code>. These arguments are 
     * replaced by the server with the value of corresponding subscription fields before the push notification is sent.<BR>
     * For instance, if the subscription contains fields "stock_name" and "last_price", the notification format could be something like this:<ul>
     * <li><code>{ "android" : { "notification" : { "body" : "Stock ${stock_name} is now valued ${last_price}" } } }</code></li>
     * </ul>
     * Named arguments are available if the Metadata Adapter is a subclass of LiteralBasedProvider or provides equivalent functionality, otherwise only
     * indexed arguments may be used. In both cases common metadata rules apply: field names and indexes are checked against the Metadata Adapter, hence
     * they must be consistent with the schema and group specified.<BR>
     * A special server-managed argument may also be used:<ul>
     * <li><code>${LS_MPN_subscription_ID}</code>: the ID of the MPN subscription generating the push notification.
     * </ul>
     * The {@link com.lightstreamer.client.mpn.MpnBuilder} object provides methods to build an appropriate JSON structure from its defining fields.<BR>
     * Note: if the MpnSubscription has been created by the client, such as when obtained through {@link LightstreamerClient#getMpnSubscriptions(String)},
     * named arguments are always mapped to its corresponding indexed argument, even if originally the notification format used a named argument.<BR>
     * Note: the content of this property may be subject to length restrictions (See the "General Concepts" document for more information).
     * 
     * @lifecycle This property can be changed at any time.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>notification_format</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param format the JSON structure to be used as the format of push notifications.
     * 
     * @see com.lightstreamer.client.mpn.MpnBuilder
     */
    public void setNotificationFormat(@Nonnull String format) {
        delegate.setNotificationFormat(format);
    }

    /**
     *  Inquiry method that gets the trigger expression requested by the user.
     * 
     * @return returns the trigger requested by the user or null if the value is not available.
     * 
     * @see #setTriggerExpression(String)
     * @see #getActualTriggerExpression()
     */
    @Nullable
    public String getTriggerExpression() {
        return delegate.getTriggerExpression();
    }

    /**
     * Inquiry method that gets the trigger expression evaluated by the Sever.
     *
     * @return returns the trigger sent by the Server or null if the value is not available.
     *
     * @see #getTriggerExpression()
     */
    @Nullable
    public String getActualTriggerExpression() {
        return delegate.getActualTriggerExpression();
    }

    /**
     * Sets the boolean expression that will be evaluated against each update and will act as a trigger to deliver the push notification.<BR>
     * If a trigger expression is set, the MPN subscription does not send any push notifications until the expression evaluates to true. When this happens,
     * the MPN subscription "triggers" and a single push notification is sent. Once triggered, no other push notifications are sent. In other words, with a trigger
     * expression set, the MPN subscription sends *at most one* push notification.<BR>
     * The expression must be in Java syntax and can contain named arguments with the format <code>${field}</code>, or indexed arguments with the format <code>$[1]</code>.
     * The same rules that apply to {@link #setNotificationFormat(String)} apply also to the trigger expression. The expression is verified and evaluated on the server.<BR>
     * Named and indexed arguments are replaced by the server with the value of corresponding subscription fields before the expression is evaluated. They are
     * represented as String variables, and as such appropriate type conversion must be considered. E.g.<ul>
     * <li><code>Double.parseDouble(${last_price}) &gt; 500.0</code></li>
     * </ul>
     * Argument variables are named with the prefix <code>LS_MPN_field</code> followed by an index. Thus, variable names like <code>LS_MPN_field1</code> should be considered
     * reserved and their use avoided in the expression.<BR>
     * Consider potential impact on server performance when writing trigger expressions. Since Java code may use classes and methods of the JDK, a badly written
     * trigger may cause CPU hogging or memory exhaustion. For this reason, a server-side filter may be applied to refuse poorly written (or even
     * maliciously crafted) trigger expressions. See the "General Concepts" document for more information.<BR>
     * Note: if the MpnSubscription has been created by the client, such as when obtained through {@link LightstreamerClient#getMpnSubscriptions(String)},
     * named arguments are always mapped to its corresponding indexed argument, even if originally the trigger expression used a named argument.<BR>
     * Note: the content of this property may be subject to length restrictions (See the "General Concepts" document for more information).
     * 
     * @lifecycle This property can be changed at any time.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>trigger</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param expr the boolean expression that acts as a trigger to deliver the push notification. If the value is null, no trigger is set on the subscription.
     * 
     * @see #isTriggered()
     */
    public void setTriggerExpression(@Nullable String expr) {
        delegate.setTriggerExpression(expr);
    }

    /**
     * Checks if the MpnSubscription is currently "active" or not.<BR>
     * Most of the MpnSubscription properties cannot be modified if an MpnSubscription is "active".<BR>
     * The status of an MpnSubscription is changed to "active" through the {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} method and back to "inactive"
     * through the {@link LightstreamerClient#unsubscribe(MpnSubscription)} and {@link LightstreamerClient#unsubscribeMpnSubscriptions(String)} ones.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return true if the MpnSubscription is currently "active", false otherwise.
     * 
     * @see #getStatus()
     * @see LightstreamerClient#subscribe(MpnSubscription, boolean)
     * @see LightstreamerClient#unsubscribe(MpnSubscription)
     * @see LightstreamerClient#unsubscribeMpnSubscriptions(String)
     */
    public boolean isActive() {
        return delegate.isActive();
    }

    /**
     * Checks if the MpnSubscription is currently subscribed to through the server or not.<BR>
     * This flag is switched to true by server sent subscription events, and back to false in case of client disconnection,
     * {@link LightstreamerClient#unsubscribe(MpnSubscription)} or {@link LightstreamerClient#unsubscribeMpnSubscriptions(String)} calls, and server sent 
     * unsubscription events.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return true if the MpnSubscription has been successfully subscribed on the server, false otherwise.
     * 
     * @see #getStatus()
     * @see LightstreamerClient#unsubscribe(MpnSubscription)
     * @see LightstreamerClient#unsubscribeMpnSubscriptions(String)
     */
    public boolean isSubscribed() {
        return delegate.isSubscribed();
    }

    /**
     * Checks if the MpnSubscription is currently triggered or not.<BR>
     * This flag is switched to true when a trigger expression has been set and it evaluated to true at least once. For this to happen, the subscription
     * must already be in "active" and "subscribed" states. It is switched back to false if the subscription is modified with a
     * {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} call on a copy of it, deleted with {@link LightstreamerClient#unsubscribe(MpnSubscription)} or
     * {@link LightstreamerClient#unsubscribeMpnSubscriptions(String)} calls, and server sent subscription events.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return true if the MpnSubscription's trigger expression has been evaluated to true at least once, false otherwise.
     * 
     * @see #getStatus()
     * @see LightstreamerClient#subscribe(MpnSubscription, boolean)
     * @see LightstreamerClient#unsubscribe(MpnSubscription)
     * @see LightstreamerClient#unsubscribeMpnSubscriptions(String)
     */
    public boolean isTriggered() {
        return delegate.isTriggered();
    }

    /**
     * The status of the subscription.<BR>
     * The status can be:<ul>
     * <li><code>UNKNOWN</code>: when the MPN subscription has just been created or deleted (i.e. unsubscribed). In this status {@link #isActive()}, {@link #isSubscribed} 
     * and {@link #isTriggered()} are all false.</li>
     * <li><code>ACTIVE</code>: when the MPN susbcription has been submitted to the server, but no confirm has been received yet. In this status {@link #isActive()} is true, 
     * {@link #isSubscribed} and {@link #isTriggered()} are false.</li>
     * <li><code>SUBSCRIBED</code>: when the MPN subscription has been successfully subscribed on the server. If a trigger expression is set, it has not been
     * evaluated to true yet. In this status {@link #isActive()} and {@link #isSubscribed} are true, {@link #isTriggered()} is false.</li>
     * <li><code>TRIGGERED</code>: when the MPN subscription has a trigger expression set, has been successfully subscribed on the server and
     * the trigger expression has been evaluated to true at least once. In this status {@link #isActive()}, {@link #isSubscribed} and {@link #isTriggered()} are all true.</li>
     * </ul>
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return the status of the subscription.
     * 
     * @see #isActive()
     * @see #isSubscribed()
     * @see #isTriggered()
     */
    @Nonnull
    public String getStatus() {
        return delegate.getStatus();
    }

    /**
     * The server-side timestamp of the subscription status.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>status_timestamp</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @return The server-side timestamp of the subscription status, expressed as a Java time.
     * 
     * @see #getStatus()
     */
    public long getStatusTimestamp() {
        return delegate.getStatusTimestamp();
    }

    /**
     * Setter method that sets the "Item List" to be subscribed to through 
     * Lightstreamer Server. <BR>
     * Any call to this method will override any "Item List" or "Item Group"
     * previously specified.
     * 
     * @lifecycle This method can only be called while the MpnSubscription
     * instance is in its "inactive" state.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>group</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param items an array of items to be subscribed to through the server. 
     * @throws IllegalArgumentException if any of the item names in the "Item List"
     * contains a space or is a number or is empty/null.
     * @throws IllegalStateException if the MpnSubscription is currently 
     * "active".
     */
    public void setItems(@Nullable String[] items) {
        delegate.setItems(items);
    }

    /**
     * Inquiry method that can be used to read the "Item List" specified for this MpnSubscription.<BR> 
     * Note that if the single-item-constructor was used, this method will return an array 
     * of length 1 containing such item.<BR>
     * Note: if the MpnSubscription has been created by the client, such as when obtained through {@link LightstreamerClient#getMpnSubscriptions(String)},
     * items are always expressed with an "Item Group"", even if originally the MPN subscription used an "Item List".
     *
     * @lifecycle This method can only be called if the MpnSubscription has been initialized 
     * with an "Item List".

     * @return the "Item List" to be subscribed to through the server, or null if the MpnSubscription was initialized with an "Item Group" or was not initialized at all.
     */
    @Nonnull
    public String[] getItems() {
        return delegate.getItems();
    }

    /**
     * Setter method that sets the "Item Group" to be subscribed to through 
     * Lightstreamer Server. <BR>
     * Any call to this method will override any "Item List" or "Item Group"
     * previously specified.
     * 
     * @lifecycle This method can only be called while the MpnSubscription
     * instance is in its "inactive" state.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>group</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param groupName A String to be expanded into an item list by the
     * Metadata Adapter. 
     * @throws IllegalStateException if the MpnSubscription is currently 
     * "active".
     */
    public void setItemGroup(@Nonnull String groupName) {
        delegate.setItemGroup(groupName);
    }

    /**
     * Inquiry method that can be used to read the item group specified for this MpnSubscription.<BR>
     * Note: if the MpnSubscription has been created by the client, such as when obtained through {@link LightstreamerClient#getMpnSubscriptions(String)},
     * items are always expressed with an "Item Group"", even if originally the MPN subscription used an "Item List".
     *
     * @lifecycle This method can only be called if the MpnSubscription has been initialized
     * using an "Item Group"
     * 
     * @return the "Item Group" to be subscribed to through the server, or null if the MpnSubscription was initialized with an "Item List" or was not initialized at all.
     */
    @Nonnull
    public String getItemGroup() {
        return delegate.getItemGroup();
    }

    /**
     * Setter method that sets the "Field List" to be subscribed to through 
     * Lightstreamer Server. <BR>
     * Any call to this method will override any "Field List" or "Field Schema"
     * previously specified.
     * 
     * @lifecycle This method can only be called while the MpnSubscription
     * instance is in its "inactive" state.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>schema</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param fields an array of fields to be subscribed to through the server. 
     * @throws IllegalArgumentException if any of the field names in the list
     * contains a space or is empty/null.
     * @throws IllegalStateException if the MpnSubscription is currently 
     * "active".
     */
    public void setFields(@Nullable String[] fields) {
        delegate.setFields(fields);
    }

    /**
     * Inquiry method that can be used to read the "Field List" specified for this MpnSubscription.<BR>
     * Note: if the MpnSubscription has been created by the client, such as when obtained through {@link LightstreamerClient#getMpnSubscriptions(String)},
     * fields are always expressed with a "Field Schema"", even if originally the MPN subscription used a "Field List".
     *
     * @lifecycle  This method can only be called if the MpnSubscription has been initialized 
     * using a "Field List".
     * 
     * @return the "Field List" to be subscribed to through the server, or null if the MpnSubscription was initialized with a "Field Schema" or was not initialized at all.
     */
    @Nonnull
    public String[] getFields() {
        return delegate.getFields();
    }

    /**
     * Setter method that sets the "Field Schema" to be subscribed to through 
     * Lightstreamer Server. <BR>
     * Any call to this method will override any "Field List" or "Field Schema"
     * previously specified.
     * 
     * @lifecycle This method can only be called while the MpnSubscription
     * instance is in its "inactive" state.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>schema</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param schemaName A String to be expanded into a field list by the
     * Metadata Adapter. 
     * 
     * @throws IllegalStateException if the MpnSubscription is currently 
     * "active".
     */
    public void setFieldSchema(@Nonnull String schemaName) {
        delegate.setFieldSchema(schemaName);
    }

    /**
     * Inquiry method that can be used to read the field schema specified for this MpnSubscription.<BR>
     * Note: if the MpnSubscription has been created by the client, such as when obtained through {@link LightstreamerClient#getMpnSubscriptions(String)},
     * fields are always expressed with a "Field Schema"", even if originally the MPN subscription used a "Field List".
     *
     * @lifecycle This method can only be called if the MpnSubscription has been initialized 
     * using a "Field Schema"
     * 
     * @return the "Field Schema" to be subscribed to through the server, or null if the MpnSubscription was initialized with a "Field List" or was not initialized at all.
     */
    @Nonnull
    public String getFieldSchema() {
        return delegate.getFieldSchema();
    }

    /**
     * Setter method that sets the name of the Data Adapter
     * (within the Adapter Set used by the current session)
     * that supplies all the items for this MpnSubscription. <BR>
     * The Data Adapter name is configured on the server side through
     * the "name" attribute of the "data_provider" element, in the
     * "adapters.xml" file that defines the Adapter Set (a missing attribute
     * configures the "DEFAULT" name). <BR>
     * Note that if more than one Data Adapter is needed to supply all the
     * items in a set of items, then it is not possible to group all the
     * items of the set in a single MpnSubscription. Multiple MpnSubscriptions
     * have to be defined.
     *
     * @default The default Data Adapter for the Adapter Set,
     * configured as "DEFAULT" on the Server.
     *
     * @lifecycle This method can only be called while the MpnSubscription
     * instance is in its "inactive" state.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>adapter</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param dataAdapter the name of the Data Adapter. A null value 
     * is equivalent to the "DEFAULT" name.
     * @throws IllegalStateException if the Subscription is currently 
     * "active".
     *
     * @see ConnectionDetails#setAdapterSet(String)
     */
    public void setDataAdapter(@Nullable String dataAdapter) {
        delegate.setDataAdapter(dataAdapter);
    }

    /**
     * Inquiry method that can be used to read the name of the Data Adapter specified for this 
     * MpnSubscription through {@link #setDataAdapter(String)}.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return the name of the Data Adapter; returns null if no name has been configured, 
     * so that the "DEFAULT" Adapter Set is used.
     */
    @Nullable
    public String getDataAdapter() {
        return delegate.getDataAdapter();
    }
    
    /**
     * Setter method that sets the length to be requested to Lightstreamer
     * Server for the internal queuing buffers for the items in the MpnSubscription.<BR>
     * A Queuing buffer is used by the Server to accumulate a burst
     * of updates for an item, so that they can all be sent to the client,
     * despite of bandwidth or frequency limits.<BR>
     * Note that the Server may pose an upper limit on the size of its internal buffers.
     *
     * @default null, meaning to lean on the Server default based on the subscription
     * mode. This means that the buffer size will be 1 for MERGE 
     * subscriptions and "unlimited" for DISTINCT subscriptions. See 
     * the "General Concepts" document for further details.
     *
     * @lifecycle This method can only be called while the MpnSubscription
     * instance is in its "inactive" state.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>requested_buffer_size</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param size  An integer number, representing the length of the internal queuing buffers
     * to be used in the Server. If the string "unlimited" is supplied, then no buffer
     * size limit is requested (the check is case insensitive). It is also possible
     * to supply a null value to stick to the Server default (which currently
     * depends on the subscription mode).
     * @throws IllegalStateException if the MpnSubscription is currently 
     * "active".
     * @throws IllegalArgumentException if the specified value is not
     * null nor "unlimited" nor a valid positive integer number.
     *
     * @see #setRequestedMaxFrequency(String)
     */
    public void setRequestedBufferSize(@Nullable String size) {
        delegate.setRequestedBufferSize(size);
    }
    
    /**
     * Inquiry method that can be used to read the buffer size, configured though
     * {@link #setRequestedBufferSize}, to be requested to the Server for 
     * this MpnSubscription.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return  An integer number, representing the buffer size to be requested to the server,
     * or the string "unlimited", or null.
     */
    @Nullable
    public String getRequestedBufferSize() {
        return delegate.getRequestedBufferSize();
    }
    
    /**
     * Setter method that sets the maximum update frequency to be requested to
     * Lightstreamer Server for all the items in the MpnSubscription.<BR>
     * Note that frequency limits on the items can also be set on the
     * server side and this request can only be issued in order to further
     * reduce the frequency, not to rise it beyond these limits.
     *
     * @general_edition_note A further global frequency limit could also be imposed by the Server,
     * depending on Edition and License Type.
     * To know what features are enabled by your license, please see the License tab of the
     * Monitoring Dashboard (by default, available at /dashboard).
     *
     * @default null, meaning to lean on the Server default based on the subscription
     * mode. This consists, for all modes, in not applying any frequency 
     * limit to the subscription (the same as "unlimited"); see the "General Concepts"
     * document for further details.
     *
     * @lifecycle This method can only be called while the MpnSubscription
     * instance is in its "inactive" state.
     * 
     * @notification A change to this setting will be notified through a call to {@link MpnSubscriptionListener#onPropertyChanged(String)}
     * with argument <code>requested_max_frequency</code> on any {@link MpnSubscriptionListener} listening to the related MpnSubscription.
     * 
     * @param freq  A decimal number, representing the maximum update frequency (expressed in updates
     * per second) for each item in the Subscription; for instance, with a setting
     * of 0.5, for each single item, no more than one update every 2 seconds
     * will be received. If the string "unlimited" is supplied, then no frequency
     * limit is requested. It is also possible to supply the null value to stick 
     * to the Server default (which currently corresponds to "unlimited").
     * The check for the string constants is case insensitive.
     * @throws IllegalStateException if the MpnSubscription is currently 
     * "active".
     * @throws IllegalArgumentException if the specified value is not
     * null nor the special "unlimited" value nor a valid positive number.
     */
    public void setRequestedMaxFrequency(@Nullable String freq) {
        delegate.setRequestedMaxFrequency(freq);
    }
    
    /**
     * Inquiry method that can be used to read the max frequency, configured
     * through {@link #setRequestedMaxFrequency(String)}, to be requested to the 
     * Server for this MpnSubscription.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return  A decimal number, representing the max frequency to be requested to the server
     * (expressed in updates per second), or the string "unlimited", or null.
     */
    @Nullable
    public String getRequestedMaxFrequency() {
        return delegate.getRequestedMaxFrequency();
    }
    
    /**
     * Inquiry method that can be used to read the mode specified for this
     * MpnSubscription.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return the MpnSubscription mode specified in the constructor.
     */
    @Nonnull
    public String getMode() {
        return delegate.getMode();
    }
    
    /**
     * The server-side unique persistent ID of the MPN subscription.<BR>
     * The ID is available only after the MPN subscription has been successfully subscribed on the server. I.e. when its status is <code>SUBSCRIBED</code> or
     * <code>TRIGGERED</code>.<BR>
     * Note: more than one MpnSubscription may exists at any given time referring to the same MPN subscription, and thus with the same subscription ID.
     * For instace, copying an MpnSubscription with the copy initializer creates a second MpnSubscription instance with the same subscription ID. Also,
     * the <code>coalescing</code> flag of {@link LightstreamerClient#subscribe(MpnSubscription, boolean)} may cause the assignment of a pre-existing MPN subscription ID 
     * to the new subscription.<BR>
     * Two MpnSubscription objects with the same subscription ID always represent the same server-side MPN subscription. It is the client's duty to keep the status
     * and properties of these objects up to date and aligned.
     * 
     * @lifecycle This method can be called at any time.
     * 
     * @return the MPN subscription ID.
     */
    @Nullable
    public String getSubscriptionId() {
        return delegate.getSubscriptionId();
    }
}
