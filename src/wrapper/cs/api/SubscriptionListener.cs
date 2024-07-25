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
    /// Interface to be implemented to listen to <c>Subscription</c> events comprehending notifications of subscription/unsubscription, 
    /// updates, errors and others.<br/>
    /// Events for this listeners are executed asynchronously with respect to the code that generates them. 
    /// This means that, upon reception of an event, it is possible that the internal state of the client has changed.
    /// On the other hand, all the notifications for a single LightstreamerClient, including notifications to
    /// <seealso cref="ClientListener"/>s, <seealso cref="SubscriptionListener"/>s and <seealso cref="ClientMessageListener"/>s will be dispatched by the 
    /// same thread.
    /// </summary>
    public interface SubscriptionListener
    {
        /// <summary>
        /// Event handler that is called by Lightstreamer each time a request to clear the snapshot pertaining to an item 
        /// in the Subscription has been received from the Server. More precisely, this kind of request can occur in two cases:
        /// <ul>
        ///   <li>For an item delivered in COMMAND mode, to notify that the state of the item becomes empty; this is 
        ///       equivalent to receiving an update carrying a DELETE command once for each key that is currently active.</li>
        ///   <li>For an item delivered in DISTINCT mode, to notify that all the previous updates received for the item 
        ///       should be considered as obsolete; hence, if the listener were showing a list of recent updates for the item, it 
        ///       should clear the list in order to keep a coherent view.</li>
        /// </ul>
        /// Note that, if the involved Subscription has a two-level behavior enabled
        /// (see <c>Subscription.CommandSecondLevelFields</c> and <c>Subscription.CommandSecondLevelFieldSchema</c>)
        /// , the notification refers to the first-level item (which is in COMMAND mode).
        /// This kind of notification is not possible for second-level items (which are in MERGE 
        /// mode).
        /// </summary>
        /// <param name="itemName"> name of the involved item. If the Subscription was initialized using an "Item Group" then a 
        ///        null value is supplied. </param>
        /// <param name="itemPos"> 1-based position of the item within the "Item List" or "Item Group". </param>
        void onClearSnapshot(string itemName, int itemPos);

        /// <summary>
        /// Event handler that is called by Lightstreamer to notify that, due to internal resource limitations, 
        /// Lightstreamer Server dropped one or more updates for an item that was subscribed to as a second-level subscription. 
        /// Such notifications are sent only if the Subscription was configured in unfiltered mode (second-level items are 
        /// always in "MERGE" mode and inherit the frequency configuration from the first-level Subscription). <br/> 
        /// By implementing this method it is possible to perform recovery actions.
        /// </summary>
        /// <param name="lostUpdates"> The number of consecutive updates dropped for the item. </param>
        /// <param name="key"> The value of the key that identifies the second-level item.
        /// </param>
        /// <c>Subscription.RequestedMaxFrequency</c>
        /// <c>Subscription.CommandSecondLevelFields</c>
        /// <c>Subscription.CommandSecondLevelFieldSchema</c>
        void onCommandSecondLevelItemLostUpdates(int lostUpdates, string key);

        /// <summary>
        /// Event handler that is called when the Server notifies an error on a second-level subscription.<br/> 
        /// By implementing this method it is possible to perform recovery actions.
        /// </summary>
        /// <param name="code"> The error code sent by the Server. It can be one of the following:
        ///        <ul>
        ///          <li>14 - the key value is not a valid name for the Item to be subscribed; only in this case, the error 
        ///              is detected directly by the library before issuing the actual request to the Server</li>
        ///          <li>17 - bad Data Adapter name or default Data Adapter not defined for the current Adapter Set</li>
        ///          <li>21 - bad Group name</li>
        ///          <li>22 - bad Group name for this Schema</li>
        ///          <li>23 - bad Schema name</li>
        ///          <li>24 - mode not allowed for an Item</li>
        ///          <li>26 - unfiltered dispatching not allowed for an Item, because a frequency limit is associated 
        ///              to the item</li>
        ///          <li>27 - unfiltered dispatching not supported for an Item, because a frequency prefiltering is 
        ///              applied for the item</li>
        ///          <li>28 - unfiltered dispatching is not allowed by the current license terms (for special licenses 
        ///              only)</li>
        ///          <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection</li>
        ///          <li>68 - the Server could not fulfill the request because of an internal error.</li>
        ///          <li>&lt;= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the 
        ///              code value is dependent on the specific Metadata Adapter implementation</li>
        ///        </ul>
        /// </param>
        /// <param name="message"> The description of the error sent by the Server; it can be null. </param>
        /// <param name="key"> The value of the key that identifies the second-level item.
        /// </param>
        /// <c>ConnectionDetails.AdapterSet</c>
        /// <c>Subscription.CommandSecondLevelFields</c>
        /// <c>Subscription.CommandSecondLevelFieldSchema</c>
        void onCommandSecondLevelSubscriptionError(int code, string message, string key);

        /// <summary>
        /// Event handler that is called by Lightstreamer to notify that all snapshot events for an item in the 
        /// Subscription have been received, so that real time events are now going to be received. The received 
        /// snapshot could be empty. Such notifications are sent only if the items are delivered in DISTINCT or COMMAND 
        /// subscription mode and snapshot information was indeed requested for the items. By implementing this 
        /// method it is possible to perform actions which require that all the initial values have been received.<br/>
        /// Note that, if the involved Subscription has a two-level behavior enabled
        /// (see <c>Subscription.CommandSecondLevelFields</c> and <c>Subscription.CommandSecondLevelFieldSchema</c>)
        /// , the notification refers to the first-level item (which is in COMMAND mode).
        /// Snapshot-related updates for the second-level items 
        /// (which are in MERGE mode) can be received both before and after this notification.
        /// </summary>
        /// <param name="itemName"> name of the involved item. If the Subscription was initialized using an "Item Group" then a 
        ///        null value is supplied. </param>
        /// <param name="itemPos"> 1-based position of the item within the "Item List" or "Item Group".
        /// </param>
        /// <c>Subscription.RequestedSnapshot</c>
        /// <c>ItemUpdate.isSnapshot</c>
        void onEndOfSnapshot(string itemName, int itemPos);

        /// <summary>
        /// Event handler that is called by Lightstreamer to notify that, due to internal resource limitations, 
        /// Lightstreamer Server dropped one or more updates for an item in the Subscription. 
        /// Such notifications are sent only if the items are delivered in an unfiltered mode; this occurs if the 
        /// subscription mode is:
        /// <ul>
        ///   <li>RAW</li>
        ///   <li>MERGE or DISTINCT, with unfiltered dispatching specified</li>
        ///   <li>COMMAND, with unfiltered dispatching specified</li>
        ///   <li>COMMAND, without unfiltered dispatching specified (in this case, notifications apply to ADD 
        ///       and DELETE events only)</li>
        /// </ul>
        /// By implementing this method it is possible to perform recovery actions.
        /// </summary>
        /// <param name="itemName"> name of the involved item. If the Subscription was initialized using an "Item Group" then a 
        ///        null value is supplied. </param>
        /// <param name="itemPos"> 1-based position of the item within the "Item List" or "Item Group". </param>
        /// <param name="lostUpdates"> The number of consecutive updates dropped for the item.
        /// </param>
        /// <c>Subscription.RequestedMaxFrequency</c>
        void onItemLostUpdates(string itemName, int itemPos, int lostUpdates);

        /// <summary>
        /// Event handler that is called by Lightstreamer each time an update pertaining to an item in the Subscription
        /// has been received from the Server. The updated values for all the fields are contained in a value object 
        /// of type <seealso cref="ItemUpdate"/>.
        /// </summary>
        /// <param name="itemUpdate"> a value object containing the updated values for all the fields, together with meta-information 
        /// about the update itself and some helper methods that can be used to iterate through all or new values. </param>
        void onItemUpdate(ItemUpdate itemUpdate);

        /// <summary>
        /// Event handler that receives a notification when the SubscriptionListener instance is removed from a Subscription 
        /// through <c>Subscription.removeListener</c>. This is the last event to be fired on the listener.
        /// </summary>
        void onListenEnd();

        /// <summary>
        /// Event handler that receives a notification when the SubscriptionListener instance is added to a Subscription 
        /// through <c>Subscription.addListener</c>. This is the first event to be fired on the listener.
        /// </summary>
        void onListenStart();

        /// <summary>
        /// Event handler that is called by Lightstreamer to notify that a Subscription has been successfully subscribed 
        /// to through the Server. This can happen multiple times in the life of a Subscription instance, in case the 
        /// Subscription is performed multiple times through <c>LightstreamerClient.unsubscribe</c> and 
        /// <c>LightstreamerClient.subscribe</c>. This can also happen multiple times in case of automatic 
        /// recovery after a connection restart.<br/> 
        /// This notification is always issued before the other ones related to the same subscription. It invalidates all 
        /// data that has been received previously.<br/>
        /// Note that two consecutive calls to this method are not possible, as before a second onSubscription event is 
        /// fired an <seealso cref="SubscriptionListener.onUnsubscription"/> event is eventually fired.<br/> 
        /// If the involved Subscription has a two-level behavior enabled
        /// (see <c>Subscription.CommandSecondLevelFields</c> and <c>Subscription.CommandSecondLevelFieldSchema</c>)
        /// , second-level subscriptions are not notified.
        /// </summary>
        void onSubscription();

        /// <summary>
        /// Event handler that is called when the Server notifies an error on a Subscription. By implementing this method it 
        /// is possible to perform recovery actions.<br/>
        /// Note that, in order to perform a new subscription attempt, <c>LightstreamerClient.unsubscribe</c>
        /// and <c>LightstreamerClient.subscribe</c> should be issued again, even if no change to the Subscription 
        /// attributes has been applied.
        /// </summary>
        /// <param name="code"> The error code sent by the Server. It can be one of the following:
        ///        <ul>
        ///          <li>15 - "key" field not specified in the schema for a COMMAND mode subscription</li>
        ///          <li>16 - "command" field not specified in the schema for a COMMAND mode subscription</li>
        ///          <li>17 - bad Data Adapter name or default Data Adapter not defined for the current Adapter Set</li>
        ///          <li>21 - bad Group name</li>
        ///          <li>22 - bad Group name for this Schema</li>
        ///          <li>23 - bad Schema name</li>
        ///          <li>24 - mode not allowed for an Item</li>
        ///          <li>25 - bad Selector name</li>
        ///          <li>26 - unfiltered dispatching not allowed for an Item, because a frequency limit is associated 
        ///              to the item</li>
        ///          <li>27 - unfiltered dispatching not supported for an Item, because a frequency prefiltering is 
        ///              applied for the item</li>
        ///          <li>28 - unfiltered dispatching is not allowed by the current license terms (for special licenses 
        ///              only)</li>
        ///          <li>29 - RAW mode is not allowed by the current license terms (for special licenses only)</li>
        ///          <li>61 - there was an error in the parsing of the server response</li>
        ///          <li>30 - subscriptions are not allowed by the current license terms (for special licenses only)</li>
        ///          <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection</li>
        ///          <li>68 - the Server could not fulfill the request because of an internal error.</li>
        ///          <li>&lt;= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the 
        ///              code value is dependent on the specific Metadata Adapter implementation</li>
        ///        </ul>
        /// </param>
        /// <param name="message"> The description of the error sent by the Server; it can be null.
        /// </param>
        /// <c>ConnectionDetails.AdapterSet</c>
        void onSubscriptionError(int code, string message);

        /// <summary>
        /// Event handler that is called by Lightstreamer to notify that a Subscription has been successfully unsubscribed 
        /// from. This can happen multiple times in the life of a Subscription instance, in case the Subscription is performed 
        /// multiple times through <c>LightstreamerClient.unsubscribe(Subscription)</c> and 
        /// <c>LightstreamerClient.subscribe(Subscription)</c>. This can also happen multiple times in case of automatic 
        /// recovery after a connection restart.<br/>
        /// After this notification no more events can be received until a new <seealso cref="SubscriptionListener.onSubscription"/> event.<br/> 
        /// Note that two consecutive calls to this method are not possible, as before a second onUnsubscription event 
        /// is fired an <seealso cref="SubscriptionListener.onSubscription"/> event is eventually fired.<br/> 
        /// If the involved Subscription has a two-level behavior enabled
        /// (see <c>Subscription.CommandSecondLevelFields</c> and <c>Subscription.CommandSecondLevelFieldSchema</c>)
        /// , second-level unsubscriptions are not notified.
        /// </summary>
        void onUnsubscription();

        /// <summary>
        /// Event handler that is called by Lightstreamer to notify the client with the real maximum update frequency of the Subscription. 
        /// It is called immediately after the Subscription is established and in response to a requested change
        /// (see <c>Subscription.requestedMaxFrequency</c>).
        /// Since the frequency limit is applied on an item basis and a Subscription can involve multiple items,
        /// this is actually the maximum frequency among all items. For Subscriptions with two-level behavior
        /// (see <c>Subscription.CommandSecondLevelFields</c> and <c>Subscription.CommandSecondLevelFieldSchema</c>)
        /// , the reported frequency limit applies to both first-level and second-level items.<br/>
        /// The value may differ from the requested one because of restrictions operated on the server side,
        /// but also because of number rounding.<br/>
        /// Note that a maximum update frequency (that is, a non-unlimited one) may be applied by the Server
        /// even when the subscription mode is RAW or the Subscription was done with unfiltered dispatching.
        /// </summary>
        /// <param name="frequency">  A decimal number, representing the maximum frequency applied by the Server
        /// (expressed in updates per second), or the string "unlimited". A null value is possible in rare cases,
        /// when the frequency can no longer be determined. </param>
        void onRealMaxFrequency(string frequency);
    }
}