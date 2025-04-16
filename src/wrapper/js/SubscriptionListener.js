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
   * @exports SubscriptionListener
   * @class Interface to be implemented to listen to {@link Subscription} events
   * comprehending notifications of subscription/unsubscription, updates, errors and 
   * others.
   * <BR>Events for this listeners are executed asynchronously with respect to the code
   * that generates them.
   * <BR>Note that it is not necessary to implement all of the interface methods for 
   * the listener to be successfully passed to the {@link Subscription#addListener}
   * method.
// #ifndef START_NODE_JSDOC_EXCLUDE
   * <BR>The {@link AbstractWidget} and its subclasses, distributed together 
   * with the library, implement this interface.
   * 
   * @see DynaGrid
   * @see StaticGrid
   * @see Chart
// #endif
   */
var SubscriptionListener = function() {
};

SubscriptionListener.prototype = {
    
    /**
     * Event handler that is called by Lightstreamer each time an update
     * pertaining to an item in the Subscription has been received from the
     * Server. 
     * 
     * @param {ItemUpdate} updateInfo a value object containing the
     * updated values for all the fields, together with meta-information about
     * the update itself and some helper methods that can be used to iterate through 
     * all or new values.
     */
    onItemUpdate: function(updateInfo) {
      return;
    },
    
    /**
     * Event handler that is called by Lightstreamer to notify that, due to
     * internal resource limitations, Lightstreamer Server dropped one or more
     * updates for an item in the Subscription. Such notifications are sent only
     * if the items are delivered in an unfiltered mode; this occurs if the
     * subscription mode is:
     * <ul>
     * <li>RAW</li>
     * <li>MERGE or DISTINCT, with unfiltered dispatching specified</li>
     * <li>COMMAND, with unfiltered dispatching specified</li>
     * <li>COMMAND, without unfiltered dispatching specified (in this case,
     * notifications apply to ADD and DELETE events only)</li>
     * </ul>
     * By implementing this method it is possible to perform recovery actions.
     * 
     * @param {String} itemName name of the involved item. If the Subscription
     * was initialized using an "Item Group" then a null value is supplied.
     * @param {Number} itemPos 1-based position of the item within the "Item List" 
     * or "Item Group".
     * @param {Number} lostUpdates The number of consecutive updates dropped
     * for the item.
     * 
     * @see Subscription#setRequestedMaxFrequency
     */
    onItemLostUpdates: function(itemName, itemPos, lostUpdates) {
      return;
    },
    
    /**
     * Event handler that is called by Lightstreamer to notify that, due to
     * internal resource limitations, Lightstreamer Server dropped one or more
     * updates for an item that was subscribed to as a second-level subscription.
     * Such notifications are sent only if the Subscription was configured in 
     * unfiltered mode (second-level items are always in "MERGE" mode and 
     * inherit the frequency configuration from the first-level Subscription).
     * <BR>By implementing this method it is possible to perform recovery actions.
     * 
     * @param {Number} lostUpdates The number of consecutive updates dropped
     * for the item.
     * @param {String} key The value of the key that identifies the
     * second-level item.
     * 
     * @see Subscription#setRequestedMaxFrequency
     * @see Subscription#setCommandSecondLevelFields
     * @see Subscription#setCommandSecondLevelFieldSchema
     */
    onCommandSecondLevelItemLostUpdates: function(lostUpdates, key) {
      
    },
  
    /**
     * Event handler that is called by Lightstreamer to notify that all
     * snapshot events for an item in the Subscription have been received,
     * so that real time events are now going to be received. The received
     * snapshot could be empty.
     * Such notifications are sent only if the items are delivered in
     * DISTINCT or COMMAND subscription mode and snapshot information was
     * indeed requested for the items.
     * By implementing this method it is possible to perform actions which
     * require that all the initial values have been received.
     * <BR/>Note that, if the involved Subscription has a two-level behavior enabled, the notification
     * refers to the first-level item (which is in COMMAND mode).
     * Snapshot-related updates for the second-level items (which are in
     * MERGE mode) can be received both before and after this notification.
     *
     * @param {String} itemName name of the involved item. If the Subscription
     * was initialized using an "Item Group" then a null value is supplied.
     * @param {Number} itemPos 1-based position of the item within the "Item List" 
     * or "Item Group".
     * 
     * @see Subscription#setRequestedSnapshot
     * @see ItemUpdate#isSnapshot
     */
    onEndOfSnapshot: function(itemName, itemPos) {
      return;
    },
    
    /**
     * Event handler that is called by Lightstreamer each time a request
     * to clear the snapshot pertaining to an item in the Subscription has been
     * received from the Server.
     * More precisely, this kind of request can occur in two cases:
     * <ul>
     * <li>For an item delivered in COMMAND mode, to notify that the state
     * of the item becomes empty; this is equivalent to receiving an update
     * carrying a DELETE command once for each key that is currently active.</li>
     * <li>For an item delivered in DISTINCT mode, to notify that all the
     * previous updates received for the item should be considered as obsolete;
     * hence, if the listener were showing a list of recent updates for the
     * item, it should clear the list in order to keep a coherent view.</li>
     * </ul>
     * <BR/>Note that, if the involved Subscription has a two-level behavior enabled,
     * the notification refers to the first-level item (which is in COMMAND mode).
     * This kind of notification is not possible for second-level items (which are in
     * MERGE mode).
     * <BR/>This event can be sent by the Lightstreamer Server since version 6.0
     *
     * @param {String} itemName name of the involved item. If the Subscription
     * was initialized using an "Item Group" then a null value is supplied.
     * @param {Number} itemPos 1-based position of the item within the "Item List" 
     * or "Item Group".
     */
    onClearSnapshot: function(itemName, itemPos) {
      return;
    },

    /**
     * Event handler that is called by Lightstreamer to notify that a Subscription
     * has been successfully subscribed to through the Server.
     * This can happen multiple times in the life of a Subscription instance, 
     * in case the Subscription is performed multiple times through
     * {@link LightstreamerClient#unsubscribe} and {@link LightstreamerClient#subscribe}. 
     * This can also happen multiple times in case of automatic recovery after a connection
     * restart.
     * <BR>This notification is always issued before the other ones related
     * to the same subscription. It invalidates all data that has been received
     * previously. 
     * <BR>Note that two consecutive calls to this method are not possible, as before
     * a second onSubscription event is fired an onUnsubscription event is eventually
     * fired.
     * <BR>If the involved Subscription has a two-level behavior enabled,
     * second-level subscriptions are not notified.
     */
    onSubscription: function() {
      return;
    },
    
    /**
     * Event handler that is called by Lightstreamer to notify that a Subscription
     * has been successfully unsubscribed from.
     * This can happen multiple times in the life of a Subscription instance, 
     * in case the Subscription is performed multiple times through
     * {@link LightstreamerClient#unsubscribe} and {@link LightstreamerClient#subscribe}. 
     * This can also happen multiple times in case of automatic recovery after a connection
     * restart.
     * 
     * <BR>After this notification no more events can be recieved until a new
     * {@link SubscriptionListener#onSubscription} event.
     * <BR>Note that two consecutive calls to this method are not possible, as before
     * a second onUnsubscription event is fired an onSubscription event is eventually
     * fired.
     * <BR>If the involved Subscription has a two-level behavior enabled,
     * second-level unsubscriptions are not notified.
     */
    onUnsubscription: function() {
      return;
    },
    
    /**
     * Event handler that is called when the Server notifies an error on a Subscription. By implementing this method it 
     * is possible to perform recovery actions. <BR>
     * Note that, in order to perform a new subscription attempt, {@link LightstreamerClient#unsubscribe}
     * and {@link LightstreamerClient#subscribe} should be issued again, even if no change to the Subscription 
     * attributes has been applied.
     *
     * @param {Number} code The error code sent by the Server. It can be one of the following:
     *        <ul>
     *          <li>15 - "key" field not specified in the schema for a COMMAND mode subscription</li>
     *          <li>16 - "command" field not specified in the schema for a COMMAND mode subscription</li>
     *          <li>17 - bad Data Adapter name or default Data Adapter not defined for the current Adapter Set</li>
     *          <li>21 - bad Group name</li>
     *          <li>22 - bad Group name for this Schema</li>
     *          <li>23 - bad Schema name</li>
     *          <li>24 - mode not allowed for an Item</li>
     *          <li>25 - bad Selector name</li>
     *          <li>26 - unfiltered dispatching not allowed for an Item, because a frequency limit is associated 
     *              to the item</li>
     *          <li>27 - unfiltered dispatching not supported for an Item, because a frequency prefiltering is 
     *              applied for the item</li>
     *          <li>28 - unfiltered dispatching is not allowed by the current license terms (for special licenses 
     *              only)</li>
     *          <li>29 - RAW mode is not allowed by the current license terms (for special licenses only)</li>
     *          <li>30 - subscriptions are not allowed by the current license terms (for special licenses only)</li>
     *          <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection</li>
     *          <li>68 - the Server could not fulfill the request because of an internal error.</li>
     *          <li>&lt;= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the 
     *              code value is dependent on the specific Metadata Adapter implementation</li>
     *        </ul>
     * @param {String} message The description of the error sent by the Server;
     * it can be null.
     *
     * @see ConnectionDetails#setAdapterSet
     */
    onSubscriptionError: function(code, message) {
      return;
    },
    
    /**
     * Event handler that is called when the Server notifies an error on a second-level subscription. <BR> 
     * By implementing this method it is possible to perform recovery actions.
     * 
     * @param {Number} code The error code sent by the Server. It can be one of the following:
     *        <ul>
     *          <li>14 - the key value is not a valid name for the Item to be subscribed; only in this case, the error 
     *              is detected directly by the library before issuing the actual request to the Server</li>
     *          <li>17 - bad Data Adapter name or default Data Adapter not defined for the current Adapter Set</li>
     *          <li>21 - bad Group name</li>
     *          <li>22 - bad Group name for this Schema</li>
     *          <li>23 - bad Schema name</li>
     *          <li>24 - mode not allowed for an Item</li>
     *          <li>26 - unfiltered dispatching not allowed for an Item, because a frequency limit is associated 
     *              to the item</li>
     *          <li>27 - unfiltered dispatching not supported for an Item, because a frequency prefiltering is 
     *              applied for the item</li>
     *          <li>28 - unfiltered dispatching is not allowed by the current license terms (for special licenses 
     *              only)</li>
     *          <li>61 - there was an error in the parsing of the server response</li>
     *          <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection</li>
     *          <li>68 - the Server could not fulfill the request because of an internal error.</li>
     *          <li>&lt;= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the 
     *              code value is dependent on the specific Metadata Adapter implementation</li>
     *        </ul>
     *
     * @param {String} message The description of the error sent by the Server; it can be null.
     * @param {String} key The value of the key that identifies the second-level item.
     * 
     * @see ConnectionDetails#setAdapterSet
     * @see Subscription#setCommandSecondLevelFields
     * @see Subscription#setCommandSecondLevelFieldSchema
     */
    onCommandSecondLevelSubscriptionError: function(code, message, key) {
      
    },
    
    /**
     * Event handler that receives a notification when the SubscriptionListener instance 
     * is added to a Subscription through 
     * {@link Subscription#addListener}.
     * This is the first event to be fired on the listener.
     */
    onListenStart: function() {
      
    },
    
    /**
     * Event handler that receives a notification when the SubscriptionListener instance 
     * is removed from a Subscription through 
     * {@link Subscription#removeListener}.
     * This is the last event to be fired on the listener.
     */
    onListenEnd: function() {
      
    },
    
    /**
     * Event handler that is called by Lightstreamer to notify the client with the real maximum update frequency of the Subscription. 
     * It is called immediately after the Subscription is established and in response to a requested change
     * (see {@link Subscription#setRequestedMaxFrequency}).
     * Since the frequency limit is applied on an item basis and a Subscription can involve multiple items,
     * this is actually the maximum frequency among all items. For Subscriptions with two-level behavior
     * (see {@link Subscription#setCommandSecondLevelFields} and {@link Subscription#setCommandSecondLevelFieldSchema})
     * , the reported frequency limit applies to both first-level and second-level items. <BR>
     * The value may differ from the requested one because of restrictions operated on the server side,
     * but also because of number rounding. <BR>
     * Note that a maximum update frequency (that is, a non-unlimited one) may be applied by the Server
     * even when the subscription mode is RAW or the Subscription was done with unfiltered dispatching.
     * 
     * @param {String} frequency  A decimal number, representing the maximum frequency applied by the Server
     * (expressed in updates per second), or the string "unlimited". A null value is possible in rare cases,
     * when the frequency can no longer be determined.
     */
    onRealMaxFrequency: function(frequency) {
        
    }
};
