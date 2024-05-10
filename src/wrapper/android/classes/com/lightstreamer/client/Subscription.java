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
 import javax.annotation.Nullable;
 import java.util.*;
 import com.lightstreamer.client.LSSubscription;
 
 /**
  * Class representing a Subscription to be submitted to a Lightstreamer Server. It contains 
  * subscription details and the listeners needed to process the real-time data. <BR>
  * After the creation, a Subscription object is in the "inactive" state. When a Subscription 
  * object is subscribed to on a LightstreamerClient object, through the 
  * {@link LightstreamerClient#subscribe(Subscription)} method, its state becomes "active". 
  * This means that the client activates a subscription to the required items through 
  * Lightstreamer Server and the Subscription object begins to receive real-time events. <BR>
  * A Subscription can be configured to use either an Item Group or an Item List to specify the 
  * items to be subscribed to and using either a Field Schema or Field List to specify the fields. <BR>
  * "Item Group" and "Item List" are defined as follows:
  * <ul>
  *  <li>"Item Group": an Item Group is a String identifier representing a list of items. 
  *  Such Item Group has to be expanded into a list of items by the getItems method of the 
  *  MetadataProvider of the associated Adapter Set. When using an Item Group, items in the 
  *  subscription are identified by their 1-based index within the group.<BR>
  *  It is possible to configure the Subscription to use an "Item Group" using the 
  *  {@link #setItemGroup(String)} method.</li> 
  *  <li>"Item List": an Item List is an array of Strings each one representing an item. 
  *  For the Item List to be correctly interpreted a LiteralBasedProvider or a MetadataProvider 
  *  with a compatible implementation of getItems has to be configured in the associated 
  *  Adapter Set.<BR>
  *  Note that no item in the list can be empty, can contain spaces or can be a number.<BR>
  *  When using an Item List, items in the subscription are identified by their name or 
  *  by their 1-based index within the list.<BR>
  *  It is possible to configure the Subscription to use an "Item List" using the 
  *  {@link #setItems(String[])} method or by specifying it in the constructor.</li>
  * </ul>
  * "Field Schema" and "Field List" are defined as follows:
  * <ul>
  *  <li>"Field Schema": a Field Schema is a String identifier representing a list of fields. 
  *  Such Field Schema has to be expanded into a list of fields by the getFields method of 
  *  the MetadataProvider of the associated Adapter Set. When using a Field Schema, fields 
  *  in the subscription are identified by their 1-based index within the schema.<BR>
  *  It is possible to configure the Subscription to use a "Field Schema" using the 
  *  {@link #setFieldSchema(String)} method.</li>
  *  <li>"Field List": a Field List is an array of Strings each one representing a field. 
  *  For the Field List to be correctly interpreted a LiteralBasedProvider or a MetadataProvider 
  *  with a compatible implementation of getFields has to be configured in the associated 
  *  Adapter Set.<BR>
  *  Note that no field in the list can be empty or can contain spaces.<BR>
  *  When using a Field List, fields in the subscription are identified by their name or 
  *  by their 1-based index within the list.<BR>
  *  It is possible to configure the Subscription to use a "Field List" using the 
  *  {@link #setFields(String[])} method or by specifying it in the constructor.</li>
  * </ul>
  */
public class Subscription {
  /** @hidden */
  public final LSSubscription delegate;

   /**
    * Creates an object to be used to describe a Subscription that is going to be subscribed to 
    * through Lightstreamer Server. The object can be supplied to 
    * {@link LightstreamerClient#subscribe(Subscription)} and 
    * {@link LightstreamerClient#unsubscribe(Subscription)}, in order to bring the Subscription 
    * to "active" or back to "inactive" state. <BR>
    * Note that all of the methods used to describe the subscription to the server can only be 
    * called while the instance is in the "inactive" state; the only exception is 
    * {@link #setRequestedMaxFrequency(String)}.
    *
    * @param subscriptionMode the subscription mode for the items, required by Lightstreamer Server. 
    * Permitted values are:
    * <ul>
    *  <li>MERGE</li>
    *  <li>DISTINCT</li>
    *  <li>RAW</li>
    *  <li>COMMAND</li>
    * </ul>
    * @param items an array of items to be subscribed to through Lightstreamer server. <BR>
    * It is also possible specify the "Item List" or "Item Group" later through 
    * {@link #setItems(String[])} and {@link #setItemGroup}.
    * @param fields an array of fields for the items to be subscribed to through Lightstreamer Server. <BR>
    * It is also possible to specify the "Field List" or "Field Schema" later through 
    * {@link #setFields(String[])} and {@link #setFieldSchema(String)}.
    * @throws IllegalArgumentException If no or invalid subscription mode is passed.
    * @throws IllegalArgumentException If either the items or the fields array is left null.
    * @throws IllegalArgumentException If the specified "Item List" or "Field List" is not valid; 
    * see {@link #setItems(String[])} and {@link #setFields(String[])} for details.
    */
  public Subscription(@Nonnull String subscriptionMode, @Nonnull String[] items, @Nonnull String[] fields) {
    this.delegate = new LSSubscription(subscriptionMode, items, fields, this);
  }
   
   /**
    * Creates an object to be used to describe a Subscription that is going to be subscribed to 
    * through Lightstreamer Server. The object can be supplied to 
    * {@link LightstreamerClient#subscribe(Subscription)} and 
    * {@link LightstreamerClient#unsubscribe(Subscription)}, in order to bring the Subscription 
    * to "active" or back to "inactive" state. <BR>
    * Note that all of the methods used to describe the subscription to the server can only be 
    * called while the instance is in the "inactive" state; the only exception is 
    * {@link #setRequestedMaxFrequency(String)}.
    *
    * @param subscriptionMode the subscription mode for the items, required by Lightstreamer Server. 
    * Permitted values are:
    * <ul>
    *  <li>MERGE</li>
    *  <li>DISTINCT</li>
    *  <li>RAW</li>
    *  <li>COMMAND</li>
    * </ul>
    * @param item the item name to be subscribed to through Lightstreamer Server.  
    * @param fields an array of fields for the items to be subscribed to through Lightstreamer Server. <BR>
    * It is also possible to specify the "Field List" or "Field Schema" later through 
    * {@link #setFields(String[])} and {@link #setFieldSchema(String)}.
    * @throws IllegalArgumentException If no or invalid subscription mode is passed.
    * @throws IllegalArgumentException If either the item or the fields array is left null.
    * @throws IllegalArgumentException If the specified "Field List" is not valid; 
    * see {@link #setFields(String[])} for details..
    */
  public Subscription(@Nonnull String subscriptionMode, @Nonnull String item, @Nonnull String[] fields) {
    this.delegate = new LSSubscription(subscriptionMode, item, fields, this);
  }
     
   /**
    * Creates an object to be used to describe a Subscription that is going to be subscribed to 
    * through Lightstreamer Server. The object can be supplied to 
    * {@link LightstreamerClient#subscribe(Subscription)} and 
    * {@link LightstreamerClient#unsubscribe(Subscription)}, in order to bring the Subscription 
    * to "active" or back to "inactive" state. <BR>
    * Note that all of the methods used to describe the subscription to the server can only be 
    * called while the instance is in the "inactive" state; the only exception is 
    * {@link #setRequestedMaxFrequency(String)}.
    *
    * @param subscriptionMode the subscription mode for the items, required by Lightstreamer Server. 
    * Permitted values are:
    * <ul>
    *  <li>MERGE</li>
    *  <li>DISTINCT</li>
    *  <li>RAW</li>
    *  <li>COMMAND</li>
    * </ul>
    */
  public Subscription(@Nonnull String subscriptionMode) {
    this.delegate = new LSSubscription(subscriptionMode, this);
  }
   
   /**
    * Adds a listener that will receive events from the Subscription instance. <BR> 
    * The same listener can be added to several different Subscription instances.
    *
    * @lifecycle A listener can be added at any time. A call to add a listener already 
    * present will be ignored.
    * 
    * @param listener An object that will receive the events as documented in the 
    * SubscriptionListener interface.
    * 
    * @see #removeListener(SubscriptionListener)
    */
  public void addListener(@Nonnull SubscriptionListener listener) {
    delegate.addListener(listener);
  }
   
   /**
    * Removes a listener from the Subscription instance so that it will not receive 
    * events anymore.
    * 
    * @lifecycle a listener can be removed at any time.
    * 
    * @param listener The listener to be removed.
    * 
    * @see #addListener(SubscriptionListener)
    */
  public void removeListener(@Nonnull SubscriptionListener listener) {
    delegate.removeListener(listener);
  }
   
   /**
    * Returns a list containing the {@link SubscriptionListener} instances that were 
    * added to this client.
    * @return a list containing the listeners that were added to this client. 
    * @see #addListener(SubscriptionListener)
    */
  @Nonnull 
  public List<SubscriptionListener> getListeners() {
    return delegate.getListeners();
  }
   
   /**  
    * Inquiry method that checks if the Subscription is currently "active" or not.
    * Most of the Subscription properties cannot be modified if a Subscription 
    * is "active". <BR>
    * The status of a Subscription is changed to "active" through the  
    * {@link LightstreamerClient#subscribe(Subscription)} method and back to 
    * "inactive" through the {@link LightstreamerClient#unsubscribe(Subscription)} one.
    * 
    * @lifecycle This method can be called at any time.
    * 
    * @return true/false if the Subscription is "active" or not.
    * 
    * @see LightstreamerClient#subscribe(Subscription)
    * @see LightstreamerClient#unsubscribe(Subscription)
    */
  public boolean isActive() {
    return delegate.isActive();
  }
   /**  
    * Inquiry method that checks if the Subscription is currently subscribed to
    * through the server or not. <BR>
    * This flag is switched to true by server sent Subscription events, and 
    * back to false in case of client disconnection, 
    * {@link LightstreamerClient#unsubscribe(Subscription)} calls and server 
    * sent unsubscription events. 
    * 
    * @lifecycle This method can be called at any time.
    * 
    * @return true/false if the Subscription is subscribed to
    * through the server or not.
    */
  public boolean isSubscribed() {
    return delegate.isSubscribed();
  }
   /**
    * Inquiry method that can be used to read the name of the Data Adapter specified for this 
    * Subscription through {@link #setDataAdapter(String)}.
    * @lifecycle This method can be called at any time.
    * @return the name of the Data Adapter; returns null if no name has been configured, 
    * so that the "DEFAULT" Adapter Set is used.
    */
  @Nullable 
  public String getDataAdapter() {
    return delegate.getDataAdapter();
  }
   
   /**
    * Setter method that sets the name of the Data Adapter
    * (within the Adapter Set used by the current session)
    * that supplies all the items for this Subscription. <BR>
    * The Data Adapter name is configured on the server side through
    * the "name" attribute of the "data_provider" element, in the
    * "adapters.xml" file that defines the Adapter Set (a missing attribute
    * configures the "DEFAULT" name). <BR>
    * Note that if more than one Data Adapter is needed to supply all the
    * items in a set of items, then it is not possible to group all the
    * items of the set in a single Subscription. Multiple Subscriptions
    * have to be defined.
    *
    * @default The default Data Adapter for the Adapter Set,
    * configured as "DEFAULT" on the Server.
    *
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    *
    * @param dataAdapter the name of the Data Adapter. A null value 
    * is equivalent to the "DEFAULT" name.
    *  
    * @see ConnectionDetails#setAdapterSet(String)
    */
  public void setDataAdapter(@Nullable String dataAdapter) {
    delegate.setDataAdapter(dataAdapter);
  }
   
   /**
    * Inquiry method that can be used to read the mode specified for this
    * Subscription.
    * 
    * @lifecycle This method can be called at any time.
    * 
    * @return the Subscription mode specified in the constructor.
    */
  @Nonnull 
  public String getMode() {
    return delegate.getMode();
  }
   /**
    * Inquiry method that can be used to read the "Item List" specified for this Subscription. 
    * Note that if the single-item-constructor was used, this method will return an array 
    * of length 1 containing such item.
    *
    * @lifecycle This method can only be called if the Subscription has been initialized 
    * with an "Item List".
    * @return the "Item List" to be subscribed to through the server, or null if the Subscription was initialized with an "Item Group" or was not initialized at all.
    */
  @Nonnull 
  public String[] getItems() {
    return delegate.getItems();
  }
   
   /**
    * Setter method that sets the "Item List" to be subscribed to through 
    * Lightstreamer Server. <BR>
    * Any call to this method will override any "Item List" or "Item Group"
    * previously specified.
    * 
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalArgumentException if any of the item names in the "Item List"
    * contains a space or is a number or is empty/null.
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * 
    * @param items an array of items to be subscribed to through the server. 
    */
  public void setItems(@Nullable String[] items) {
    delegate.setItems(items);
  }
     
   /**
    * Inquiry method that can be used to read the item group specified for this Subscription.
    *
    * @lifecycle This method can only be called if the Subscription has been initialized
    * using an "Item Group"
    * @return the "Item Group" to be subscribed to through the server, or null if the Subscription was initialized with an "Item List" or was not initialized at all.
    */
  @Nullable 
  public String getItemGroup() {
    return delegate.getItemGroup();
  }
   
   /**
    * Setter method that sets the "Item Group" to be subscribed to through 
    * Lightstreamer Server. <BR>
    * Any call to this method will override any "Item List" or "Item Group"
    * previously specified.
    * 
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * 
    * @param groupName A String to be expanded into an item list by the
    * Metadata Adapter. 
    */
  public void setItemGroup(@Nullable String groupName) {
    delegate.setItemGroup(groupName);
  }
   /**
    * Inquiry method that can be used to read the "Field List" specified for this Subscription.
    *
    * @lifecycle  This method can only be called if the Subscription has been initialized 
    * using a "Field List".
    * @return the "Field List" to be subscribed to through the server, or null if the Subscription was initialized with a "Field Schema" or was not initialized at all.
    */
  @Nonnull 
  public String[] getFields() {
    return delegate.getFields();
  }
   
   /**
    * Setter method that sets the "Field List" to be subscribed to through 
    * Lightstreamer Server. <BR>
    * Any call to this method will override any "Field List" or "Field Schema"
    * previously specified.
    * 
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalArgumentException if any of the field names in the list
    * contains a space or is empty/null.
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * 
    * @param fields an array of fields to be subscribed to through the server. 
    */
  public void setFields(@Nullable String[] fields) {
    delegate.setFields(fields);
  }
     
   /**
    * Inquiry method that can be used to read the field schema specified for this Subscription.
    *
    * @lifecycle This method can only be called if the Subscription has been initialized 
    * using a "Field Schema"
    * @return the "Field Schema" to be subscribed to through the server, or null if the Subscription was initialized with a "Field List" or was not initialized at all.
    */
  @Nullable 
  public String getFieldSchema() {
    return delegate.getFieldSchema();
  }
   
   /**
    * Setter method that sets the "Field Schema" to be subscribed to through 
    * Lightstreamer Server. <BR>
    * Any call to this method will override any "Field List" or "Field Schema"
    * previously specified.
    * 
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * 
    * @param schemaName A String to be expanded into a field list by the
    * Metadata Adapter. 
    */
  public void setFieldSchema(@Nullable String schemaName) {
    delegate.setFieldSchema(schemaName);
  }
 
   /**
    * Inquiry method that can be used to read the buffer size, configured though
    * {@link #setRequestedBufferSize}, to be requested to the Server for 
    * this Subscription.
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
    * Setter method that sets the length to be requested to Lightstreamer
    * Server for the internal queuing buffers for the items in the Subscription.
    * A Queuing buffer is used by the Server to accumulate a burst
    * of updates for an item, so that they can all be sent to the client,
    * despite of bandwidth or frequency limits. It can be used only when the
    * subscription mode is MERGE or DISTINCT and unfiltered dispatching has
    * not been requested. Note that the Server may pose an upper limit on the
    * size of its internal buffers.
    *
    * @default null, meaning to lean on the Server default based on the subscription
    * mode. This means that the buffer size will be 1 for MERGE 
    * subscriptions and "unlimited" for DISTINCT subscriptions. See 
    * the "General Concepts" document for further details.
    *
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * @throws IllegalArgumentException if the specified value is not
    * null nor "unlimited" nor a valid positive integer number.
    *
    * @param size  An integer number, representing the length of the internal queuing buffers
    * to be used in the Server. If the string "unlimited" is supplied, then no buffer
    * size limit is requested (the check is case insensitive). It is also possible
    * to supply a null value to stick to the Server default (which currently
    * depends on the subscription mode).
    *
    * @see Subscription#setRequestedMaxFrequency(String)
    */
  public void setRequestedBufferSize(@Nullable String size) {
    delegate.setRequestedBufferSize(size);
  }
   /**
    * Inquiry method that can be used to read the snapshot preferences, 
    * configured through {@link #setRequestedSnapshot(String)}, to be requested 
    * to the Server for this Subscription.
    * 
    * @lifecycle This method can be called at any time.
    * 
    * @return  "yes", "no", null, or an integer number.
    */
  @Nullable 
  public String getRequestedSnapshot() {
    return delegate.getRequestedSnapshot();
  }
   /**
    * Setter method that enables/disables snapshot delivery request for the
    * items in the Subscription. The snapshot can be requested only if the
    * Subscription mode is MERGE, DISTINCT or COMMAND.
    *
    * @default "yes" if the Subscription mode is not "RAW",
    * null otherwise.
    * 
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * @throws IllegalArgumentException if the specified value is not
    * "yes" nor "no" nor null nor a valid integer positive number.
    * @throws IllegalArgumentException if the specified value is not
    * compatible with the mode of the Subscription: 
    * <ul>
    *  <li>In case of a RAW Subscription only null is a valid value;</li>
    *  <li>In case of a non-DISTINCT Subscription only null "yes" and "no" are
    *  valid values.</li>
    * </ul>
    *
    * @param required "yes"/"no" to request/not request snapshot
    * delivery (the check is case insensitive). If the Subscription mode is 
    * DISTINCT, instead of "yes", it is also possible to supply an integer number, 
    * to specify the requested length of the snapshot (though the length of 
    * the received snapshot may be less than requested, because of insufficient 
    * data or server side limits);
    * passing "yes"  means that the snapshot length should be determined
    * only by the Server. Null is also a valid value; if specified, no snapshot 
    * preference will be sent to the server that will decide itself whether
    * or not to send any snapshot. 
    * 
    * @see ItemUpdate#isSnapshot
    */
  public void setRequestedSnapshot(@Nullable String required) {
    delegate.setRequestedSnapshot(required);
  }
   /**
    * Inquiry method that can be used to read the max frequency, configured
    * through {@link #setRequestedMaxFrequency(String)}, to be requested to the 
    * Server for this Subscription.
    * 
    * @lifecycle This method can be called at any time.
    * 
    * @return  A decimal number, representing the max frequency to be requested to the server
    * (expressed in updates per second), or the strings "unlimited" or "unfiltered", or null.
    */
  @Nullable 
  public String getRequestedMaxFrequency() {
    return delegate.getRequestedMaxFrequency();
  }
   
   /**
    * Setter method that sets the maximum update frequency to be requested to
    * Lightstreamer Server for all the items in the Subscription. It can
    * be used only if the Subscription mode is MERGE, DISTINCT or
    * COMMAND (in the latter case, the frequency limitation applies to the
    * UPDATE events for each single key). For Subscriptions with two-level behavior
    * (see {@link Subscription#setCommandSecondLevelFields(String[])} and {@link Subscription#setCommandSecondLevelFieldSchema(String)})
    * , the specified frequency limit applies to both first-level and second-level items. <BR>
    * Note that frequency limits on the items can also be set on the
    * server side and this request can only be issued in order to furtherly
    * reduce the frequency, not to rise it beyond these limits. <BR>
    * This method can also be used to request unfiltered dispatching
    * for the items in the Subscription. However, unfiltered dispatching
    * requests may be refused if any frequency limit is posed on the server
    * side for some item.
    *
    * @general_edition_note A further global frequency limit could also be imposed by the Server,
    * depending on Edition and License Type; this specific limit also applies to RAW mode and
    * to unfiltered dispatching.
    * To know what features are enabled by your license, please see the License tab of the
    * Monitoring Dashboard (by default, available at /dashboard).
    *
    * @default null, meaning to lean on the Server default based on the subscription
    * mode. This consists, for all modes, in not applying any frequency 
    * limit to the subscription (the same as "unlimited"); see the "General Concepts"
    * document for further details.
    *
    * @lifecycle This method can can be called at any time with some
    * differences based on the Subscription status:
    * <ul>
    * <li>If the Subscription instance is in its "inactive" state then
    * this method can be called at will.</li>
    * <li>If the Subscription instance is in its "active" state then the method
    * can still be called unless the current value is "unfiltered" or the
    * supplied value is "unfiltered" or null.
    * If the Subscription instance is in its "active" state and the
    * connection to the server is currently open, then a request
    * to change the frequency of the Subscription on the fly is sent to the server.</li>
    * </ul>
    * 
    * @throws IllegalStateException if the Subscription is currently 
    * "active" and the current value of this property is "unfiltered".
    * @throws IllegalStateException if the Subscription is currently 
    * "active" and the given parameter is null or "unfiltered".
    * @throws IllegalArgumentException if the specified value is not
    * null nor one of the special "unlimited" and "unfiltered" values nor
    * a valid positive number.
    *
    * @param freq  A decimal number, representing the maximum update frequency (expressed in updates
    * per second) for each item in the Subscription; for instance, with a setting
    * of 0.5, for each single item, no more than one update every 2 seconds
    * will be received. If the string "unlimited" is supplied, then no frequency
    * limit is requested. It is also possible to supply the string 
    * "unfiltered", to ask for unfiltered dispatching, if it is allowed for the 
    * items, or a null value to stick to the Server default (which currently
    * corresponds to "unlimited").
    * The check for the string constants is case insensitive.
    */
  public void setRequestedMaxFrequency(@Nullable String freq) {
    delegate.setRequestedMaxFrequency(freq);
  }
   /**
    * Inquiry method that can be used to read the selector name  
    * specified for this Subscription through {@link #setSelector(String)}.
    * 
    * @lifecycle This method can be called at any time.
    * 
    * @return the name of the selector.
    */
  @Nullable 
  public String getSelector() {
    return delegate.getSelector();
  }
   /**
    * Setter method that sets the selector name for all the items in the
    * Subscription. The selector is a filter on the updates received. It is
    * executed on the Server and implemented by the Metadata Adapter.
    *
    * @default null (no selector).
    *
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    *
    * @param selector name of a selector, to be recognized by the
    * Metadata Adapter, or null to unset the selector.
    */
  public void setSelector(@Nullable String selector) {
    delegate.setSelector(selector);
  }
   /**
    * Returns the position of the "command" field in a COMMAND Subscription. <BR>
    * This method can only be used if the Subscription mode is COMMAND and the Subscription 
    * was initialized using a "Field Schema".
    *
    * @lifecycle This method can be called at any time after the first 
    * {@link SubscriptionListener#onSubscription} event.
    * @throws IllegalStateException if the Subscription mode is not COMMAND or if the 
    * {@link SubscriptionListener#onSubscription} event for this Subscription was not 
    * yet fired.
    * @throws IllegalStateException if a "Field List" was specified.
    * @return the 1-based position of the "command" field within the "Field Schema".
    */
  public int getCommandPosition() {
    return delegate.getCommandPosition();
  }
   
   /**
    * Returns the position of the "key" field in a COMMAND Subscription. <BR>
    * This method can only be used if the Subscription mode is COMMAND
    * and the Subscription was initialized using a "Field Schema".
    *  
    * @lifecycle This method can be called at any time.
    * 
    * @throws IllegalStateException if the Subscription mode is not 
    * COMMAND or if the {@link SubscriptionListener#onSubscription} event for this Subscription
    * was not yet fired.
    * 
    * @return the 1-based position of the "key" field within the "Field Schema".
    */
  public int getKeyPosition() {
    return delegate.getKeyPosition();
  }
   /**
    * Inquiry method that can be used to read the second-level Data Adapter name configured 
    * through {@link #setCommandSecondLevelDataAdapter(String)}.
    *
    * @lifecycle This method can be called at any time.
    * @throws IllegalStateException if the Subscription mode is not COMMAND
    * @return the name of the second-level Data Adapter.
    * @see #setCommandSecondLevelDataAdapter(String)
    */
  @Nullable 
  public String getCommandSecondLevelDataAdapter() {
    return delegate.getCommandSecondLevelDataAdapter();
  }
   
   /**
    * Setter method that sets the name of the second-level Data Adapter (within 
    * the Adapter Set used by the current session) that supplies all the 
    * second-level items. <BR>
    * All the possible second-level items should be supplied in "MERGE" mode 
    * with snapshot available. <BR> 
    * The Data Adapter name is configured on the server side through the 
    * "name" attribute of the &lt;data_provider&gt; element, in the "adapters.xml" 
    * file that defines the Adapter Set (a missing attribute configures the 
    * "DEFAULT" name).
    * 
    * @default The default Data Adapter for the Adapter Set,
    * configured as "DEFAULT" on the Server.
    *
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    *
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * @throws IllegalStateException if the Subscription mode is not "COMMAND".
    *
    * @param dataAdapter the name of the Data Adapter. A null value 
    * is equivalent to the "DEFAULT" name.
    *  
    * @see Subscription#setCommandSecondLevelFields(String[])
    * @see Subscription#setCommandSecondLevelFieldSchema(String)
    */
  public void setCommandSecondLevelDataAdapter(@Nullable String dataAdapter) {
    delegate.setCommandSecondLevelDataAdapter(dataAdapter);
  }
   /**
    * Inquiry method that can be used to read the "Field List" specified for second-level 
    * Subscriptions.
    *
    * @lifecycle This method can only be called if the second-level of this Subscription 
    * has been initialized using a "Field List"
    * @throws IllegalStateException if the Subscription mode is not COMMAND
    * @return the list of fields to be subscribed to through the server, or null if the Subscription was initialized with a "Field Schema" or was not initialized at all.
    * @see Subscription#setCommandSecondLevelFields(String[])
    */
  @Nullable 
  public String[] getCommandSecondLevelFields() {
    return delegate.getCommandSecondLevelFields();
  }
   
   /**
    * Setter method that sets the "Field List" to be subscribed to through 
    * Lightstreamer Server for the second-level items. It can only be used on
    * COMMAND Subscriptions. <BR>
    * Any call to this method will override any "Field List" or "Field Schema"
    * previously specified for the second-level. <BR>
    * Calling this method enables the two-level behavior:<BR>
    * in synthesis, each time a new key is received on the COMMAND Subscription, 
    * the key value is treated as an Item name and an underlying Subscription for
    * this Item is created and subscribed to automatically, to feed fields specified
    * by this method. This mono-item Subscription is specified through an "Item List"
    * containing only the Item name received. As a consequence, all the conditions
    * provided for subscriptions through Item Lists have to be satisfied. The item is 
    * subscribed to in "MERGE" mode, with snapshot request and with the same maximum
    * frequency setting as for the first-level items (including the "unfiltered" 
    * case). All other Subscription properties are left as the default. When the 
    * key is deleted by a DELETE command on the first-level Subscription, the 
    * associated second-level Subscription is also unsubscribed from. <BR> 
    * Specifying null as parameter will disable the two-level behavior.
    *       
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalArgumentException if any of the field names in the "Field List"
    * contains a space or is empty/null.
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * @throws IllegalStateException if the Subscription mode is not "COMMAND".
    * 
    * @param fields An array of Strings containing a list of fields to
    * be subscribed to through the server. <BR>
    * Ensure that no name conflict is generated between first-level and second-level
    * fields. In case of conflict, the second-level field will not be accessible
    * by name, but only by position.
    * 
    * @see Subscription#setCommandSecondLevelFieldSchema(String)
    */
  public void setCommandSecondLevelFields(@Nullable String[] fields) {
    delegate.setCommandSecondLevelFields(fields);
  }
 
   /**
    * Inquiry method that can be used to read the "Field Schema" specified for second-level 
    * Subscriptions.
    *
    * @lifecycle This method can only be called if the second-level of this Subscription has 
    * been initialized using a "Field Schema".
    * @throws IllegalStateException if the Subscription mode is not COMMAND
    * @return the "Field Schema" to be subscribed to through the server, or null if the Subscription was initialized with a "Field List" or was not initialized at all.
    * @see Subscription#setCommandSecondLevelFieldSchema(String)
    */
  @Nullable 
  public String getCommandSecondLevelFieldSchema() {
    return delegate.getCommandSecondLevelFieldSchema();
  }
   
   /**
    * Setter method that sets the "Field Schema" to be subscribed to through 
    * Lightstreamer Server for the second-level items. It can only be used on
    * COMMAND Subscriptions. <BR>
    * Any call to this method will override any "Field List" or "Field Schema"
    * previously specified for the second-level. <BR>
    * Calling this method enables the two-level behavior:<BR>
    * in synthesis, each time a new key is received on the COMMAND Subscription, 
    * the key value is treated as an Item name and an underlying Subscription for
    * this Item is created and subscribed to automatically, to feed fields specified
    * by this method. This mono-item Subscription is specified through an "Item List"
    * containing only the Item name received. As a consequence, all the conditions
    * provided for subscriptions through Item Lists have to be satisfied. The item is 
    * subscribed to in "MERGE" mode, with snapshot request and with the same maximum
    * frequency setting as for the first-level items (including the "unfiltered" 
    * case). All other Subscription properties are left as the default. When the 
    * key is deleted by a DELETE command on the first-level Subscription, the 
    * associated second-level Subscription is also unsubscribed from. <BR>
    * Specify null as parameter will disable the two-level behavior.
    * 
    * @lifecycle This method can only be called while the Subscription
    * instance is in its "inactive" state.
    * 
    * @throws IllegalStateException if the Subscription is currently 
    * "active".
    * @throws IllegalStateException if the Subscription mode is not "COMMAND".
    * 
    * @param schemaName A String to be expanded into a field list by the
    * Metadata Adapter. 
    * 
    * @see Subscription#setCommandSecondLevelFields
    */
  public void setCommandSecondLevelFieldSchema(@Nullable String schemaName) {
    delegate.setCommandSecondLevelFieldSchema(schemaName);
  }
   
   /**
    * Returns the latest value received for the specified item/field pair. <BR>
    * It is suggested to consume real-time data by implementing and adding
    * a proper {@link SubscriptionListener} rather than probing this method. <BR>
    * In case of COMMAND Subscriptions, the value returned by this
    * method may be misleading, as in COMMAND mode all the keys received, being
    * part of the same item, will overwrite each other; for COMMAND Subscriptions,
    * use {@link #getCommandValue} instead. <BR>
    * Note that internal data is cleared when the Subscription is 
    * unsubscribed from.
    *
    * @lifecycle This method can be called at any time; if called 
    * to retrieve a value that has not been received yet, then it will return null. 
    * @throws IllegalArgumentException if an invalid item name or field name is specified.
    * @param itemName an item in the configured "Item List"
    * @param fieldName a item in the configured "Field List"
    * @return the current value for the specified field of the specified item
    * (possibly null), or null if no value has been received yet.
    */
  @Nullable 
  public String getValue(@Nonnull String itemName, @Nonnull String fieldName) {
    return delegate.getValue(itemName, fieldName);
  }
   
   /**
    * Returns the latest value received for the specified item/field pair. <BR>
    * It is suggested to consume real-time data by implementing and adding
    * a proper {@link SubscriptionListener} rather than probing this method. <BR>
    * In case of COMMAND Subscriptions, the value returned by this
    * method may be misleading, as in COMMAND mode all the keys received, being
    * part of the same item, will overwrite each other; for COMMAND Subscriptions,
    * use {@link #getCommandValue} instead. <BR>
    * Note that internal data is cleared when the Subscription is 
    * unsubscribed from.
    *
    * @lifecycle This method can be called at any time; if called 
    * to retrieve a value that has not been received yet, then it will return null. 
    * @throws IllegalArgumentException if the specified item position or field position is 
    * out of bounds.
    * @param itemPos the 1-based position of an item within the configured "Item Group"
    * or "Item List" 
    * @param fieldPos the 1-based position of a field within the configured "Field Schema"
    * or "Field List"
    * @return the current value for the specified field of the specified item
    * (possibly null), or null if no value has been received yet.
    */
  @Nullable 
  public String getValue(int itemPos, int fieldPos) {
    return delegate.getValue(itemPos, fieldPos);
  }
   /**
    * Returns the latest value received for the specified item/field pair. <BR>
    * It is suggested to consume real-time data by implementing and adding
    * a proper {@link SubscriptionListener} rather than probing this method. <BR>
    * In case of COMMAND Subscriptions, the value returned by this
    * method may be misleading, as in COMMAND mode all the keys received, being
    * part of the same item, will overwrite each other; for COMMAND Subscriptions,
    * use {@link #getCommandValue} instead. <BR>
    * Note that internal data is cleared when the Subscription is 
    * unsubscribed from. 
    *
    * @lifecycle This method can be called at any time; if called 
    * to retrieve a value that has not been received yet, then it will return null. 
    * @throws IllegalArgumentException if an invalid item name is specified.
    * @throws IllegalArgumentException if the specified field position is out of bounds.
    * @param itemName an item in the configured "Item List"
    * @param fieldPos the 1-based position of a field within the configured "Field Schema"
    * or "Field List"
    * @return the current value for the specified field of the specified item
    * (possibly null), or null if no value has been received yet.
    */
  @Nullable 
  public String getValue(@Nonnull String itemName, int fieldPos) {
    return delegate.getValue(itemName, fieldPos);
  }
   /**
    * Returns the latest value received for the specified item/field pair. <BR>
    * It is suggested to consume real-time data by implementing and adding
    * a proper {@link SubscriptionListener} rather than probing this method. <BR>
    * In case of COMMAND Subscriptions, the value returned by this
    * method may be misleading, as in COMMAND mode all the keys received, being
    * part of the same item, will overwrite each other; for COMMAND Subscriptions,
    * use {@link #getCommandValue} instead. <BR>
    * Note that internal data is cleared when the Subscription is 
    * unsubscribed from. 
    *
    * @lifecycle This method can be called at any time; if called 
    * to retrieve a value that has not been received yet, then it will return null. 
    * @throws IllegalArgumentException if an invalid field name is specified.
    * @throws IllegalArgumentException if the specified item position is out of bounds.
    * @param itemPos the 1-based position of an item within the configured "Item Group"
    * or "Item List"
    * @param fieldName a item in the configured "Field List"
    * @return the current value for the specified field of the specified item
    * (possibly null), or null if no value has been received yet.
    */
  @Nullable 
  public String getValue(int itemPos, @Nonnull String fieldName) {
    return delegate.getValue(itemPos, fieldName);
  }
   /**
    * Returns the latest value received for the specified item/key/field combination. 
    * This method can only be used if the Subscription mode is COMMAND. 
    * Subscriptions with two-level behavior
    * are also supported, hence the specified field 
    * (see {@link Subscription#setCommandSecondLevelFields(String[])} and {@link Subscription#setCommandSecondLevelFieldSchema(String)})
    * can be either a first-level or a second-level one. <BR>
    * It is suggested to consume real-time data by implementing and adding a proper 
    * {@link SubscriptionListener} rather than probing this method. <BR>
    * Note that internal data is cleared when the Subscription is unsubscribed from.
    *
    * @param itemName an item in the configured "Item List"
    * @param keyValue the value of a key received on the COMMAND subscription.
    * @param fieldName a item in the configured "Field List"
    * @throws IllegalArgumentException if an invalid item name or field name is specified.
    * @throws IllegalStateException if the Subscription mode is not COMMAND.
    * @return the current value for the specified field of the specified key within the 
    * specified item (possibly null), or null if the specified key has not been added yet 
    * (note that it might have been added and then deleted).
    */
  @Nullable 
  public String getCommandValue(@Nonnull String itemName, @Nonnull String keyValue, @Nonnull String fieldName) {
    return delegate.getCommandValue(itemName, keyValue, fieldName);
  }
   
   /**
    * Returns the latest value received for the specified item/key/field combination. 
    * This method can only be used if the Subscription mode is COMMAND. 
    * Subscriptions with two-level behavior
    * (see {@link Subscription#setCommandSecondLevelFields(String[])} and {@link Subscription#setCommandSecondLevelFieldSchema(String)})
    * are also supported, hence the specified field 
    * can be either a first-level or a second-level one. <BR>
    * It is suggested to consume real-time data by implementing and adding a proper 
    * {@link SubscriptionListener} rather than probing this method. <BR>
    * Note that internal data is cleared when the Subscription is unsubscribed from.
    *
    * @param itemPos the 1-based position of an item within the configured "Item Group"
    * or "Item List" 
    * @param keyValue the value of a key received on the COMMAND subscription.
    * @param fieldPos the 1-based position of a field within the configured "Field Schema"
    * or "Field List"
    * @throws IllegalArgumentException if the specified item position or field position is 
    * out of bounds.
    * @throws IllegalStateException if the Subscription mode is not COMMAND.
    * @return the current value for the specified field of the specified key within the 
    * specified item (possibly null), or null if the specified key has not been added yet 
    * (note that it might have been added and then deleted).
    */
  @Nullable 
  public String getCommandValue(int itemPos, @Nonnull String keyValue, int fieldPos) {
    return delegate.getCommandValue(itemPos, keyValue, fieldPos);
  }
   
   /**
    * Returns the latest value received for the specified item/key/field combination. 
    * This method can only be used if the Subscription mode is COMMAND. 
    * Subscriptions with two-level behavior
    * (see {@link Subscription#setCommandSecondLevelFields(String[])} and {@link Subscription#setCommandSecondLevelFieldSchema(String)})
    * are also supported, hence the specified field 
    * can be either a first-level or a second-level one. <BR>
    * It is suggested to consume real-time data by implementing and adding a proper 
    * {@link SubscriptionListener} rather than probing this method. <BR>
    * Note that internal data is cleared when the Subscription is unsubscribed from.
    *
    * @param itemPos the 1-based position of an item within the configured "Item Group"
    * or "Item List"
    * @param keyValue the value of a key received on the COMMAND subscription.
    * @param fieldName a item in the configured "Field List"
    * @throws IllegalArgumentException if an invalid field name is specified.
    * @throws IllegalArgumentException if the specified item position is out of bounds.
    * @throws IllegalStateException if the Subscription mode is not COMMAND.
    * @return the current value for the specified field of the specified key within the 
    * specified item (possibly null), or null if the specified key has not been added yet 
    * (note that it might have been added and then deleted).
    */
  @Nullable 
  public String getCommandValue(int itemPos, @Nonnull String keyValue, @Nonnull String fieldName) {
    return delegate.getCommandValue(itemPos, keyValue, fieldName);
  }
   
   /**
    * Returns the latest value received for the specified item/key/field combination. 
    * This method can only be used if the Subscription mode is COMMAND. 
    * Subscriptions with two-level behavior
    * (see {@link Subscription#setCommandSecondLevelFields(String[])} and {@link Subscription#setCommandSecondLevelFieldSchema(String)})
    * are also supported, hence the specified field 
    * can be either a first-level or a second-level one. <BR>
    * It is suggested to consume real-time data by implementing and adding a proper 
    * {@link SubscriptionListener} rather than probing this method. <BR>
    * Note that internal data is cleared when the Subscription is unsubscribed from.
    *
    * @param itemName an item in the configured "Item List" 
    * @param keyValue the value of a key received on the COMMAND subscription.
    * @param fieldPos the 1-based position of a field within the configured "Field Schema"
    * or "Field List"
    * @throws IllegalArgumentException if an invalid item name is specified.
    * @throws IllegalArgumentException if the specified field position is out of bounds.
    * @return the current value for the specified field of the specified key within the 
    * specified item (possibly null), or null if the specified key has not been added yet 
    * (note that it might have been added and then deleted).
    */
  @Nullable 
  public String getCommandValue(@Nonnull String itemName, @Nonnull String keyValue, int fieldPos) {
    return delegate.getCommandValue(itemName, keyValue, fieldPos);
  }
} 
 