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
#ifndef INCLUDED_Lightstreamer_SubscriptionListener
#define INCLUDED_Lightstreamer_SubscriptionListener

#include "Lightstreamer/ItemUpdate.h"
#include <string>

namespace Lightstreamer {

/**
 * Interface to be implemented to listen to {@link Subscription} events comprehending notifications of subscription/unsubscription, 
 * updates, errors and others. <BR>
 * Events for these listeners are dispatched by a different thread than the one that generates them. 
 * This means that, upon reception of an event, it is possible that the internal state of the client has changed.
 * On the other hand, all the notifications for a single LightstreamerClient, including notifications to
 * {@link ClientListener}s, {@link SubscriptionListener}s and {@link ClientMessageListener}s will be dispatched by the 
 * same thread.
 */
class SubscriptionListener {
public:
  virtual ~SubscriptionListener() {}
  /**
   * Event handler that is called by Lightstreamer each time a request to clear the snapshot pertaining to an item 
   * in the Subscription has been received from the Server. More precisely, this kind of request can occur in two cases:
   * <ul>
   *   <li>For an item delivered in COMMAND mode, to notify that the state of the item becomes empty; this is 
   *       equivalent to receiving an update carrying a DELETE command once for each key that is currently active.</li>
   *   <li>For an item delivered in DISTINCT mode, to notify that all the previous updates received for the item 
   *       should be considered as obsolete; hence, if the listener were showing a list of recent updates for the item, it 
   *       should clear the list in order to keep a coherent view.</li>
   * </ul>
   * Note that, if the involved Subscription has a two-level behavior enabled
  * (see {@link Subscription#setCommandSecondLevelFields()})
   * , the notification refers to the first-level item (which is in COMMAND mode).
   * This kind of notification is not possible for second-level items (which are in MERGE 
   * mode).
   * 
  * @param itemName name of the involved item in the explicit item list.
  * @param itemPos 1-based position of the item within the item list.
   */
  virtual void onClearSnapshot(const std::string& itemName, int itemPos) {}
  /**
   * Event handler that is called by Lightstreamer to notify that, due to internal resource limitations, 
   * Lightstreamer Server dropped one or more updates for an item that was subscribed to as a second-level subscription. 
   * Such notifications are sent only if the Subscription was configured in unfiltered mode (second-level items are 
   * always in "MERGE" mode and inherit the frequency configuration from the first-level Subscription). <BR> 
   * By implementing this method it is possible to perform recovery actions.
   * 
   * @param lostUpdates The number of consecutive updates dropped for the item.
   * @param key The value of the key that identifies the second-level item.
   * 
   * @see Subscription#setRequestedMaxFrequency()
   * @see Subscription#setCommandSecondLevelFields()
   */
  virtual void onCommandSecondLevelItemLostUpdates(int lostUpdates, const std::string& key) {}
  /**
   * Event handler that is called when the Server notifies an error on a second-level subscription. <BR> 
   * By implementing this method it is possible to perform recovery actions.
   * 
   * @param code The error code sent by the Server. It can be one of the following:
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
   *          <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection</li>
   *          <li>68 - the Server could not fulfill the request because of an internal error.</li>
   *          <li>&lt;= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the 
   *              code value is dependent on the specific Metadata Adapter implementation</li>
   *        </ul>
   *
   * @param message The description of the error sent by the Server; it can be an empty string.
   * @param key The value of the key that identifies the second-level item.
   * 
   * @see ConnectionDetails#setAdapterSet()
   * @see Subscription#setCommandSecondLevelFields()
   */
  virtual void onCommandSecondLevelSubscriptionError(int code, const std::string& message, const std::string& key) {}
  /**
   * Event handler that is called by Lightstreamer to notify that all snapshot events for an item in the 
   * Subscription have been received, so that real time events are now going to be received. The received 
   * snapshot could be empty. Such notifications are sent only if the items are delivered in DISTINCT or COMMAND 
   * subscription mode and snapshot information was indeed requested for the items. By implementing this 
   * method it is possible to perform actions which require that all the initial values have been received. <BR>
   * Note that, if the involved Subscription has a two-level behavior enabled
  * (see {@link Subscription#setCommandSecondLevelFields()})
   * , the notification refers to the first-level item (which is in COMMAND mode).
   * Snapshot-related updates for the second-level items 
   * (which are in MERGE mode) can be received both before and after this notification.
   * 
  * @param itemName name of the involved item in the explicit item list.
  * @param itemPos 1-based position of the item within the item list.
   * 
   * @see Subscription#setRequestedSnapshot()
   * @see ItemUpdate#isSnapshot()
   */
  virtual void onEndOfSnapshot(const std::string& itemName, int itemPos) {}
  /**
  * Event handler that is called by Lightstreamer to report lost updates for an item in the Subscription.
  * When isOverflow is true, updates were dropped by Server buffer overflow (OV).
  * Notifications can be delivered in the following modes:
   * <ul>
   *   <li>RAW</li>
   *   <li>MERGE or DISTINCT, with unfiltered dispatching specified</li>
  *   <li>COMMAND, for ADD and DELETE events, or for all update event types when unfiltered dispatching
  *       was requested</li>
   * </ul>
  * When isOverflow is false, the Data Adapter reported lost updates (LOST). Notifications can be
  * delivered in RAW or COMMAND mode regardless of whether unfiltered dispatching was requested,
  * and in MERGE or DISTINCT mode only when unfiltered dispatching was requested. <BR>
  * For two-level COMMAND Subscriptions, this callback refers only to first-level items.
  * Second-level LOST notifications are not propagated to the parent's listeners; second-level OV
  * notifications continue through {@link #onCommandSecondLevelItemLostUpdates()}.
  *
  * @param itemName name of the involved item in the explicit item list.
  * @param itemPos 1-based position of the item within the item list.
  * @param lostUpdates integer number of lost updates, or -1 when the count is unavailable.
  * @param isOverflow true for Server buffer overflow; false for Data Adapter loss notifications.
   * 
   * @see Subscription#setRequestedMaxFrequency()
   */
  virtual void onItemLostUpdates(const std::string& itemName, int itemPos, int lostUpdates, bool isOverflow) {}
  /**
  * Event handler that is called when problems obtaining updates block an item's update event flow.<BR>
  * For two-level COMMAND Subscriptions, this callback refers only to first-level items.
  * Stale notifications for internal second-level items are not propagated to the parent's listeners.
  *
  * @param itemName name of the involved item in the explicit item list.
  * @param itemPos 1-based position of the item within the item list.
  */
  virtual void onItemStale(const std::string& itemName, int itemPos) {}
  /**
  * Event handler that is called when an item's update event flow, previously reported as blocked,
  * is no longer blocked. <BR>
  * For two-level COMMAND Subscriptions, this callback refers only to first-level items.
  * Resume notifications for internal second-level items are not propagated to the parent's listeners.
  *
  * @param itemName name of the involved item in the explicit item list.
  * @param itemPos 1-based position of the item within the item list.
  */
  virtual void onItemResume(const std::string& itemName, int itemPos) {}
  /**
   * Event handler that is called by Lightstreamer each time an update pertaining to an item in the Subscription
   * has been received from the Server.
   * 
   * @param update a value object containing the updated values for all the fields, together with meta-information 
   * about the update itself and some helper methods that can be used to iterate through all or new values.
   */
  virtual void onItemUpdate(ItemUpdate& update) {}
  /**
   * Event handler that receives a notification when the SubscriptionListener instance is removed from a Subscription 
   * through {@link Subscription#removeListener()}. This is the last event to be fired on the listener.
   */
  virtual void onListenEnd() {}
  /**
   * Event handler that receives a notification when the SubscriptionListener instance is added to a Subscription 
   * through {@link Subscription#addListener()}. This is the first event to be fired on the listener.
   */
  virtual void onListenStart() {}
  /**
   * Event handler that is called by Lightstreamer to notify that a Subscription has been successfully subscribed 
   * to through the Server. This can happen multiple times in the life of a Subscription instance, in case the 
   * Subscription is performed multiple times through {@link LightstreamerClient#unsubscribe()} and 
   * {@link LightstreamerClient#subscribe()}. This can also happen multiple times in case of automatic 
   * recovery after a connection restart. <BR> 
   * This notification is always issued before the other ones related to the same subscription. It invalidates all 
   * data that has been received previously. <BR>
   * Note that two consecutive calls to this method are not possible, as before a second onSubscription event is 
   * fired an {@link #onUnsubscription} event is eventually fired. <BR> 
   * If the involved Subscription has a two-level behavior enabled
  * (see {@link Subscription#setCommandSecondLevelFields()})
   * , second-level subscriptions are not notified.
   */
  virtual void onSubscription() {}
  /**
   * Event handler that is called when the Server notifies an error on a Subscription. By implementing this method it 
   * is possible to perform recovery actions. <BR>
   * Note that, in order to perform a new subscription attempt, {@link LightstreamerClient#unsubscribe()}
   * and {@link LightstreamerClient#subscribe()} should be issued again, even if no change to the Subscription 
   * attributes has been applied.
   *
   * @param code The error code sent by the Server. It can be one of the following:
   *        <ul>
  *          <li>6 - Cannot evaluate a subscription request because the Data Adapter is disabled (only raised with Data Adapter interface version 9 or later).</li>
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
   *          <li>61 - there was an error in the parsing of the server response</li>
  *          <li>63 - Subscription refused by the Data Adapter (only raised with Data Adapter interface version 9 or later).</li>
  *          <li>64 - An unchecked exception was thrown in the Data Adapter while managing a subscription request (only raised with Data Adapter interface version 9 or later).</li>
   *          <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection</li>
   *          <li>68 - the Server could not fulfill the request because of an internal error.</li>
   *          <li>&lt;= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the 
   *              code value is dependent on the specific Metadata Adapter implementation</li>
   *        </ul>
   *
   * @param message The description of the error sent by the Server; it can be an empty string.
   * 
   * @see ConnectionDetails#setAdapterSet()
   */
  virtual void onSubscriptionError(int code, const std::string& message) {}
  /**
   * Event handler that is called by Lightstreamer to notify that a Subscription has been successfully unsubscribed 
   * from. This can happen multiple times in the life of a Subscription instance, in case the Subscription is performed 
   * multiple times through {@link LightstreamerClient#unsubscribe()} and 
   * {@link LightstreamerClient#subscribe()}. This can also happen multiple times in case of automatic 
   * recovery after a connection restart. <BR>
   * After this notification no more events can be received until a new #onSubscription event. <BR> 
   * Note that two consecutive calls to this method are not possible, as before a second onUnsubscription event 
   * is fired an {@link #onSubscription} event is eventually fired. <BR> 
   * If the involved Subscription has a two-level behavior enabled
  * (see {@link Subscription#setCommandSecondLevelFields()})
   * , second-level unsubscriptions are not notified.
   */
  virtual void onUnsubscription() {}
  /**
   * Event handler that is called by Lightstreamer to notify the client with the real maximum update frequency of the Subscription. 
   * It is called immediately after the Subscription is established and in response to a requested change
   * (see {@link Subscription#setRequestedMaxFrequency()}).
   * Since the frequency limit is applied on an item basis and a Subscription can involve multiple items,
   * this is actually the maximum frequency among all items. For Subscriptions with two-level behavior
  * (see {@link Subscription#setCommandSecondLevelFields()})
   * , the reported frequency limit applies to both first-level and second-level items. <BR>
   * The value may differ from the requested one because of restrictions operated on the server side,
   * but also because of number rounding. <BR>
   * Note that a maximum update frequency (that is, a non-unlimited one) may be applied by the Server
   * even when the subscription mode is RAW or the Subscription was done with unfiltered dispatching.
   * 
   * @param frequency  A decimal number, representing the maximum frequency applied by the Server
   * (expressed in updates per second), or the string "unlimited". An empty string is possible in rare cases,
   * when the frequency can no longer be determined.
   */
  virtual void onRealMaxFrequency(const std::string& frequency) {}
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_SubscriptionListener