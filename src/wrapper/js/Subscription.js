/**
   * Creates an object to be used to describe a Subscription that is going
   * to be subscribed to through Lightstreamer Server.
   * The object can be supplied to {@link LightstreamerClient#subscribe} and
   * {@link LightstreamerClient#unsubscribe}, in order to bring the Subscription to
   * "active" or back to "inactive" state.
   * <BR>Note that all of the methods used to describe the subscription to the server
   * can only be called while the instance is in the "inactive" state; the only
   * exception is {@link Subscription#setRequestedMaxFrequency}.
   * @constructor
   * 
   * @exports Subscription
   * 
   * @throws {IllegalArgumentException} If no or invalid subscription mode is 
   * passed.
   * @throws {IllegalArgumentException} If the list of items is specified while
   * the list of fields is not, or viceversa.
   * @throws {IllegalArgumentException} If the specified "Item List" or "Field List"
   * is not valid; see {@link Subscription#setItems} and {@link Subscription#setFields} for details.
   *
   * @param {String} subscriptionMode the subscription mode for the
   * items, required by Lightstreamer Server. Permitted values are:
   * <ul>
   * <li>MERGE</li>
   * <li>DISTINCT</li>
   * <li>RAW</li>
   * <li>COMMAND</li>
   * </ul>
   * 
   * @param {String|String[]} [items] an array of Strings containing a list of items to
   * be subscribed to through the server. In case of a single-item subscription the String
   * containing the item name can be passed in place of the array; both of the 
   * following examples represent a valid subscription:
   * <BR><code>new Subscription(mode,"item1",fieldList);</code>
   * <BR><code>new Subscription(mode,["item1","item2"],fieldList);</code>
   * <BR>It is also possible to pass null (or nothing) and specify the
   * "Item List" or "Item Group" later through {@link Subscription#setItems} and
   * {@link Subscription#setItemGroup}. In this case the fields parameter must not be specified.
   
   * 
   * @param {String[]} [fields] An array of Strings containing a list of fields 
   * for the items to be subscribed to through Lightstreamer Server.
   * <BR>It is also possible to pass null (or nothing) and specify the
   * "Field List" or "Field Schema" later through {@link Subscription#setFields} and
   * {@link Subscription#setFieldSchema}. In this case the items parameter must not be specified.
   *
   * @class Class representing a Subscription to be submitted to a Lightstreamer
   * Server. It contains subscription details and the listeners needed to process the
   * real-time data. 
   * <BR>After the creation, a Subscription object is in the "inactive"
   * state. When a Subscription object is subscribed to on a {@link LightstreamerClient} 
   * object, through the {@link LightstreamerClient#subscribe} method, its state 
   * becomes "active". This means that the client activates a subscription to the 
   * required items through Lightstreamer Server and the Subscription object begins 
   * to receive real-time events.
   * 
   * <BR>A Subscritpion can be configured to use either an Item Group or an Item List to 
   * specify the items to be subscribed to and using either a Field Schema or Field List
   * to specify the fields.
   * <BR>"Item Group" and "Item List" are defined as follows:
   * <ul>
   * <li>"Item Group": an Item Group is a String identifier representing a list of items.
   * Such Item Group has to be expanded into a list of items by the getItems method of the
   * MetadataProvider of the associated Adapter Set. When using an Item Group, items in the 
   * subscription are identified by their 1-based index within the group.
   * <BR>It is possible to configure the Subscription to use an "Item Group" using the {@link Subscription#setItemGroup}
   * method.
   * </li> 
   * <li>"Item List": an Item List is an array of Strings each one representing an item.
   * For the Item List to be correctly interpreted a LiteralBasedProvider or a MetadataProvider
   * with a compatible implementation of getItems has to be configured in the associated Adapter Set.
   * <BR>Note that no item in the list can be empty, can contain spaces or can 
   * be a number. 
   * <BR>When using an Item List, items in the subscription are identified by their name or by
   * their 1-based index within the list.
   * <BR>It is possible to configure the Subscription to use an "Item List" using the {@link Subscription#setItems}
   * method or by specifying it in the constructor.
   * </li> 
   * </ul>
   * <BR>"Field Schema" and "Field List" are defined as follows:
   * <ul>
   * <li>"Field Schema": a Field Schema is a String identifier representing a list of fields.
   * Such Field Schema has to be expanded into a list of fields by the getFields method of the
   * MetadataProvider of the associated Adapter Set. When using a Field Schema, fields in the 
   * subscription are identified by their 1-based index within the schema.
   * <BR>It is possible to configure the Subscription to use a "Field Schema" using the {@link Subscription#setFieldSchema}
   * method.
   * </li>
   * <li>"Field List": a Field List is an array of Strings each one representing a field.
   * For the Field List to be correctly interpreted a LiteralBasedProvider or a MetadataProvider
   * with a compatible implementation of getFields has to be configured in the associated Adapter Set.
   * <BR>Note that no field in the list can be empty or can contain spaces. 
   * <BR>When using a Field List, fields in the subscription are identified by their name or by
   * their 1-based index within the list.
   * <BR>It is possible to configure the Subscription to use a "Field List" using the {@link Subscription#setFields}
   * method or by specifying it in the constructor.
   * </li> 
   * </ul>
   */
 var Subscription = function(subscriptionMode, items, fields) {
 
};

Subscription.prototype = {

  /**  
   * Inquiry method that checks if the Subscription is currently "active" or not.
   * Most of the Subscription properties cannot be modified if a Subscription is "active".
   * <BR>The status of a Subscription is changed to "active" through the  
   * {@link LightstreamerClient#subscribe} method and back to "inactive" through the
   * {@link LightstreamerClient#unsubscribe} one.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {boolean} true/false if the Subscription is "active" or not.
   * 
   * @see LightstreamerClient#subscribe
   * @see LightstreamerClient#unsubscribe
   */
  isActive: function() {

  },
  
  /**  
   * Inquiry method that checks if the Subscription is currently subscribed to
   * through the server or not.
   * <BR>This flag is switched to true by server sent Subscription events, and 
   * back to false in case of client disconnection, 
   * {@link LightstreamerClient#unsubscribe} calls and server sent unsubscription
   * events. 
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {boolean} true/false if the Subscription is subscribed to
   * through the server or not.
   */
  isSubscribed: function() {

  },
 
  /**
   * Setter method that sets the "Item List" to be subscribed to through 
   * Lightstreamer Server.
   * <BR>Any call to this method will override any "Item List" or "Item Group"
   * previously specified.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalArgumentException} if the given object is not an array.
   * @throws {IllegalArgumentException} if any of the item names in the "Item List"
   * contains a space or is a number or is empty/null.
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * 
   * @param {String[]} items An array of Strings containing an "Item List" to
   * be subscribed to through the server. 
   */
  setItems: function(items) {

  },
  
  /**
   * Inquiry method that can be used to read the "Item List" specified for this
   * Subscription.
   * <BR>Note that if a single item was specified in the constructor, this method
   * will return an array of length 1 containing such item.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called if the Subscription has
   * been initialized with an "Item List".
   * </p>
   * 
   * @throws {IllegalStateException} if the Subscription was initialized
   * with an "Item Group" or was not initialized at all.
   * 
   * @return {String[]} the "Item List" to be subscribed to through the server. 
   */
  getItems: function() {

  },
  
  /**
   * Setter method that sets the "Item Group" to be subscribed to through 
   * Lightstreamer Server.
   * <BR>Any call to this method will override any "Item List" or "Item Group"
   * previously specified.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * 
   * @param {String} groupName A String to be expanded into an item list by the
   * Metadata Adapter. 
   */
  setItemGroup: function(groupName) {

  },

  /**
   * Inquiry method that can be used to read the item group specified for this
   * Subscription.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called if the Subscription has
   * been initialized using an "Item Group"
   * </p>
   *
   * @throws {IllegalStateException} if the Subscription was initialized
   * with an "Item List" or was not initialized at all.
   * 
   * @return {String} the "Item Group" to be subscribed to through the server. 
   */
  getItemGroup: function() {

  },
  
  /**
   * Setter method that sets the "Field List" to be subscribed to through 
   * Lightstreamer Server.
   * <BR>Any call to this method will override any "Field List" or "Field Schema"
   * previously specified.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalArgumentException} if the given object is not an array.
   * @throws {IllegalArgumentException} if any of the field names in the list
   * contains a space or is empty/null.
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * 
   * @param {String[]} fields An array of Strings containing a list of fields to
   * be subscribed to through the server. 
   */
  setFields: function(fields) {

  },

  /**
   * Inquiry method that can be used to read the "Field List" specified for this
   * Subscription.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called if the Subscription has
   * been initialized using a "Field List". 
   * </p>
   * 
   * @throws {IllegalStateException} if the Subscription was initialized
   * with a "Field Schema" or was not initialized at all.
   * 
   * @return {String[]} the "Field List" to be subscribed to through the server. 
   */
  getFields: function() {

  },
  
  /**
   * Setter method that sets the "Field Schema" to be subscribed to through 
   * Lightstreamer Server.
   * <BR>Any call to this method will override any "Field List" or "Field Schema"
   * previously specified.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * 
   * @param {String} schemaName A String to be expanded into a field list by the
   * Metadata Adapter. 
   */
  setFieldSchema: function(schemaName) {

  },

  /**
   * Inquiry method that can be used to read the field schema specified for this
   * Subscription.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called if the Subscription has
   * been initialized using a "Field Schema" 
   * </p>
   * 
   * @throws {IllegalStateException} if the Subscription was initialized
   * with a "Field List" or was not initialized at all.
   * 
   * @return {String} the "Field Schema" to be subscribed to through the server. 
   */
  getFieldSchema: function() {

  },
  
  /**
   * Inquiry method that can be used to read the mode specified for this
   * Subscription.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {String} the Subscription mode specified in the constructor.
   */
  getMode: function() {

  },
 
  /**
   * Setter method that sets the name of the Data Adapter
   * (within the Adapter Set used by the current session)
   * that supplies all the items for this Subscription.
   * <BR>The Data Adapter name is configured on the server side through
   * the "name" attribute of the "data_provider" element, in the
   * "adapters.xml" file that defines the Adapter Set (a missing attribute
   * configures the "DEFAULT" name).
   * <BR>Note that if more than one Data Adapter is needed to supply all the
   * items in a set of items, then it is not possible to group all the
   * items of the set in a single Subscription. Multiple Subscriptions
   * have to be defined.
   *
   * <p class="default-value"><b>Default value:</b> The default Data Adapter for the Adapter Set,
   * configured as "DEFAULT" on the Server.</p>
   *
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   *
   * @param {String} dataAdapter the name of the Data Adapter. A null value 
   * is equivalent to the "DEFAULT" name.
   *  
   * @see ConnectionDetails#setAdapterSet
   */
  setDataAdapter: function(dataAdapter) {

  },
  
  /**
   * Inquiry method that can be used to read the name of the Data Adapter 
   * specified for this Subscription through {@link Subscription#setDataAdapter}.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {String} the name of the Data Adapter; returns null if no name
   * has been configured, so that the "DEFAULT" Adapter Set is used.
   */
  getDataAdapter: function() {

  },
  
  /**
   * Setter method that sets the selector name for all the items in the
   * Subscription. The selector is a filter on the updates received. It is
   * executed on the Server and implemented by the Metadata Adapter.
   *
   * <p class="default-value"><b>Default value:</b> null (no selector).</p>
   *
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   *
   * @param {String} selector name of a selector, to be recognized by the
   * Metadata Adapter, or null to unset the selector.
   */
  setSelector: function(selector) {

  },
  
  /**
   * Inquiry method that can be used to read the selctor name  
   * specified for this Subscription through {@link Subscription#setSelector}.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {String} the name of the selector.
   */
  getSelector: function() {

  },
    
  /**
   * Setter method that sets the maximum update frequency to be requested to
   * Lightstreamer Server for all the items in the Subscription. It can
   * be used only if the Subscription mode is MERGE, DISTINCT or
   * COMMAND (in the latter case, the frequency limitation applies to the
   * UPDATE events for each single key). For Subscriptions with two-level behavior
   * (see {@link Subscription#setCommandSecondLevelFields} and {@link Subscription#setCommandSecondLevelFieldSchema})
   * , the specified frequency limit applies to both first-level and second-level items. <BR>
   * Note that frequency limits on the items can also be set on the
   * server side and this request can only be issued in order to furtherly
   * reduce the frequency, not to rise it beyond these limits. <BR>
   * This method can also be used to request unfiltered dispatching
   * for the items in the Subscription. However, unfiltered dispatching
   * requests may be refused if any frequency limit is posed on the server
   * side for some item.
   *
   * <p class="edition-note"><B>Edition Note:</B> A further global frequency limit could also
 * be imposed by the Server, depending on Edition and License Type; this specific limit also applies to RAW mode
 * and to unfiltered dispatching.
 * To know what features are enabled by your license, please see the License tab of the
 * Monitoring Dashboard (by default, available at /dashboard).</p>
   *
   * <p class="default-value"><b>Default value:</b> null, meaning to lean on the Server default based on the subscription
   * mode. This consists, for all modes, in not applying any frequency 
   * limit to the subscription (the same as "unlimited"); see the "General Concepts"
   * document for further details.</p>
   *
   * <p class="lifecycle"><b>Lifecycle:</b> This method can can be called at any time with some
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
   * </p>
   * 
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active" and the current value of this property is "unfiltered".
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active" and the given parameter is null or "unfiltered".
   * @throws {IllegalArgumentException} if the specified value is not
   * null nor one of the special "unlimited" and "unfiltered" values nor
   * a valid positive number.
   *
   * @param {Number} freq A decimal number, representing the maximum update frequency (expressed in updates
   * per second) for each item in the Subscription; for instance, with a setting
   * of 0.5, for each single item, no more than one update every 2 seconds
   * will be received. If the string "unlimited" is supplied, then no frequency
   * limit is requested. It is also possible to supply the string 
   * "unfiltered", to ask for unfiltered dispatching, if it is allowed for the 
   * items, or a null value to stick to the Server default (which currently
   * corresponds to "unlimited").
   * The check for the string constants is case insensitive.
   */
  setRequestedMaxFrequency: function(freq) {

  },
  
  /**
   * Inquiry method that can be used to read the max frequency, configured
   * through {@link Subscription#setRequestedMaxFrequency}, to be requested to the 
   * Server for this Subscription.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {String} A decimal number, representing the max frequency to be requested to the server
   * (expressed in updates per second), or the strings "unlimited" or "unfiltered", or null.
   */
  getRequestedMaxFrequency: function() {

  },

  /**
   * Setter method that sets the length to be requested to Lightstreamer
   * Server for the internal queueing buffers for the items in the Subscription.
   * A Queueing buffer is used by the Server to accumulate a burst
   * of updates for an item, so that they can all be sent to the client,
   * despite of bandwidth or frequency limits. It can be used only when the
   * subscription mode is MERGE or DISTINCT and unfiltered dispatching has
   * not been requested. Note that the Server may pose an upper limit on the
   * size of its internal buffers.
   *
   * <p class="default-value"><b>Default value:</b> null, meaning to lean
   * on the Server default based on the subscription mode. This means that
   * the buffer size will be 1 for MERGE subscriptions and "unlimited" for
   * DISTINCT subscriptions. See the "General Concepts" document for further details.</p>
   *
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * @throws {IllegalArgumentException} if the specified value is not
   * null nor  "unlimited" nor a valid positive integer number.
   *
   * @param {Number} size The length of the internal queueing buffers to be
   * used in the Server. If the string "unlimited" is supplied, then no buffer
   * size limit is requested (the check is case insensitive). It is also possible
   * to supply a null value to stick to the Server default (which currently
   * depends on the subscription mode).
   *
   * @see Subscription#setRequestedMaxFrequency
   */
  setRequestedBufferSize: function(size) {

  },
  
  /**
   * Inquiry method that can be used to read the buffer size, configured though
   * {@link Subscription#setRequestedBufferSize}, to be requested to the Server for
   * this Subscription.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {String} the buffer size to be requested to the server.
   */
  getRequestedBufferSize: function() {

  },


  /**
   * Setter method that enables/disables snapshot delivery request for the
   * items in the Subscription. The snapshot can be requested only if the
   * Subscription mode is MERGE, DISTINCT or COMMAND.
   *
   * <p class="default-value"><b>Default value:</b> "yes" if the Subscription mode is not "RAW",
   * null otherwise.</p>
   *
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * @throws {IllegalArgumentException} if the specified value is not
   * "yes" nor "no" nor null nor a valid integer positive number.
   * @throws {IllegalArgumentException} if the specified value is not
   * compatible with the mode of the Subscription: 
   * <ul>
   *  <li>In case of a RAW Subscription only null is a valid value;</li>
   *  <li>In case of a non-DISTINCT Subscription only null "yes" and "no" are
   *  valid values.</li>
   * </ul>
   *
   * @param {String} required "yes"/"no" to request/not request snapshot
   * delivery (the check is case insensitive). If the Subscription mode is 
   * DISTINCT, instead of "yes", it is also possible to supply a number, 
   * to specify the requested length of the snapshot (though the length of 
   * the received snapshot may be less than requested, because of insufficient 
   * data or server side limits);
   * passing "yes"  means that the snapshot length should be determined
   * only by the Server. Null is also a valid value; if specified no snapshot 
   * preference will be sent to the server that will decide itself whether
   * or not to send any snapshot. 
   * 
   * @see ItemUpdate#isSnapshot
   */
  setRequestedSnapshot: function(required) {

  },
  
  /**
   * Inquiry method that can be used to read the snapshot preferences, configured
   * through {@link Subscription#setRequestedSnapshot}, to be requested to the Server for
   * this Subscription.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {String} the snapshot preference to be requested to the server.
   */
  getRequestedSnapshot: function() {

  },
  
  /**
   * Setter method that sets the "Field List" to be subscribed to through 
   * Lightstreamer Server for the second-level items. It can only be used on
   * COMMAND Subscriptions.
   * <BR>Any call to this method will override any "Field List" or "Field Schema"
   * previously specified for the second-level.
   * <BR>Calling this method enables the two-level behavior:
   * <BR>in synthesis, each time a new key is received on the COMMAND Subscription, 
   * the key value is treated as an Item name and an underlying Subscription for
   * this Item is created and subscribed to automatically, to feed fields specified
   * by this method. This mono-item Subscription is specified through an "Item List"
   * containing only the Item name received. As a consequence, all the conditions
   * provided for subscriptions through Item Lists have to be satisfied. The item is 
   * subscribed to in "MERGE" mode, with snapshot request and with the same maximum
   * frequency setting as for the first-level items (including the "unfiltered" 
   * case). All other Subscription properties are left as the default. When the 
   * key is deleted by a DELETE command on the first-level Subscription, the 
   * associated second-level Subscription is also unsubscribed from. 
   * <BR>Specifying null as parameter will disable the two-level behavior.
   *       
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalArgumentException} if the given object is not null nor 
   * an array.
   * @throws {IllegalArgumentException} if any of the field names in the "Field List"
   * contains a space or is empty/null.
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * @throws {IllegalStateException} if the Subscription mode is not "COMMAND".
   * 
   * @param {String[]} fields An array of Strings containing a list of fields to
   * be subscribed to through the server.
   * <BR>Ensure that no name conflict is generated between first-level and second-level
   * fields. In case of conflict, the second-level field will not be accessible
   * by name, but only by position.
   * 
   * @see Subscription#setCommandSecondLevelFieldSchema
   */
  setCommandSecondLevelFields: function(fields) {

  },
  
  /**
   * Inquiry method that can be used to read the "Field List" specified for 
   * second-level Subscriptions.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called if the second-level of
   * this Subscription has been initialized using a "Field List"  
   * </p>
   * 
   * @throws {IllegalStateException} if the Subscription was initialized
   * with a field schema or was not initialized at all.
   * 
   * @return {String[]} the list of fields to be subscribed to through the server. 
   */
  getCommandSecondLevelFields: function() {

  },
  
  /**
   * Setter method that sets the "Field Schema" to be subscribed to through 
   * Lightstreamer Server for the second-level items. It can only be used on
   * COMMAND Subscriptions.
   * <BR>Any call to this method will override any "Field List" or "Field Schema"
   * previously specified for the second-level.
   * <BR>Calling this method enables the two-level behavior:
   * <BR>in synthesis, each time a new key is received on the COMMAND Subscription, 
   * the key value is treated as an Item name and an underlying Subscription for
   * this Item is created and subscribed to automatically, to feed fields specified
   * by this method. This mono-item Subscription is specified through an "Item List"
   * containing only the Item name received. As a consequence, all the conditions
   * provided for subscriptions through Item Lists have to be satisfied. The item is 
   * subscribed to in "MERGE" mode, with snapshot request and with the same maximum
   * frequency setting as for the first-level items (including the "unfiltered" 
   * case). All other Subscription properties are left as the default. When the 
   * key is deleted by a DELETE command on the first-level Subscription, the 
   * associated second-level Subscription is also unsubscribed from. 
   * <BR>Specify null as parameter will disable the two-level behavior.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   * 
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * @throws {IllegalStateException} if the Subscription mode is not "COMMAND".
   * 
   * @param {String} schemaName A String to be expanded into a field list by the
   * Metadata Adapter. 
   * 
   * @see Subscription#setCommandSecondLevelFields
   */
  setCommandSecondLevelFieldSchema: function(schemaName) {

  },
  
  /**
   * Inquiry method that can be used to read the "Field Schema" specified for 
   * second-level Subscriptions.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called if the second-level of
   * this Subscription has been initialized using a "Field Schema".
   * </p>
   * 
   * @throws {IllegalStateException} if the Subscription was initialized
   * with a "Field List" or was not initialized at all.
   * 
   * @return {String} the "Field Schema" to be subscribed to through the server. 
   */
  getCommandSecondLevelFieldSchema: function() {

  },
  
  /**
   * Setter method that sets the name of the second-level Data Adapter (within 
   * the Adapter Set used by the current session) that supplies all the 
   * second-level items.
   * All the possible second-level items should be supplied in "MERGE" mode 
   * with snapshot available. 
   * The Data Adapter name is configured on the server side through the 
   * "name" attribute of the &lt;data_provider&gt; element, in the "adapters.xml" 
   * file that defines the Adapter Set (a missing attribute configures the 
   * "DEFAULT" name).
   * 
   * <p class="default-value"><b>Default value:</b> The default Data Adapter for the Adapter Set,
   * configured as "DEFAULT" on the Server.</p>
   *
   * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called while the Subscription
   * instance is in its "inactive" state.</p>
   *
   * @throws {IllegalStateException} if the Subscription is currently 
   * "active".
   * @throws {IllegalStateException} if the Subscription mode is not "COMMAND".
   *
   * @param {String} dataAdapter the name of the Data Adapter. A null value 
   * is equivalent to the "DEFAULT" name.
   *  
   * @see Subscription#setCommandSecondLevelFields
   * @see Subscription#setCommandSecondLevelFieldSchema
   */
  setCommandSecondLevelDataAdapter: function(dataAdapter) {

  },
  
  /**
   * Inquiry method that can be used to read the second-level Data 
   * Adapter name configured through {@link Subscription#setCommandSecondLevelDataAdapter}.
   *  
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @return {String} the name of the second-level Data Adapter.
   */
  getCommandSecondLevelDataAdapter : function() {

  },
  
  /**
   * Returns the latest value received for the specified item/field pair.
   * <BR>It is suggested to consume real-time data by implementing and adding
   * a proper {@link SubscriptionListener} rather than probing this method.
   * In case of COMMAND Subscriptions, the value returned by this
   * method may be misleading, as in COMMAND mode all the keys received, being
   * part of the same item, will overwrite each other; for COMMAND Subscriptions,
   * use {@link Subscription#getCommandValue} instead.
   * <BR>Note that internal data is cleared when the Subscription is 
   * unsubscribed from. 
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time; if called 
   * to retrieve a value that has not been received yet, then it will return null. 
   * </p>
   * 
   * @throws {IllegalArgumentException} if an invalid item name or field
   * name is specified or if the specified item position or field position is
   * out of bounds.
   * 
   * @param {String} itemIdentifier a String representing an item in the 
   * configured item list or a Number representing the 1-based position of the item
   * in the specified item group. (In case an item list was specified, passing 
   * the item position is also possible).
   * 
   * @param {String} fieldIdentifier a String representing a field in the 
   * configured field list or a Number representing the 1-based position of the field
   * in the specified field schema. (In case a field list was specified, passing 
   * the field position is also possible).
   * 
   * @return {String} the current value for the specified field of the specified item
   * (possibly null), or null if no value has been received yet.
   */
  getValue: function(itemIdentifier, fieldIdentifier) {

  },
  
  /**
   * Returns the latest value received for the specified item/key/field combination.
   * This method can only be used if the Subscription mode is COMMAND.
   * Subscriptions with two-level behavior are also supported, hence the specified
   * field can be either a first-level or a second-level one.
   * <BR>It is suggested to consume real-time data by implementing and adding
   * a proper {@link SubscriptionListener} rather than probing this method.
   * <BR>Note that internal data is cleared when the Subscription is 
   * unsubscribed from. 
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time; if called 
   * to retrieve a value that has not been received yet, then it will return null.
   * </p>
   * 
   * @throws {IllegalArgumentException} if an invalid item name or field
   * name is specified or if the specified item position or field position is
   * out of bounds.
   * @throws {IllegalStateException} if the Subscription mode is not 
   * COMMAND.
   * 
   * @param {String} itemIdentifier a String representing an item in the 
   * configured item list or a Number representing the 1-based position of the item
   * in the specified item group. (In case an item list was specified, passing 
   * the item position is also possible).
   * 
   * @param {String} keyValue a String containing the value of a key received
   * on the COMMAND subscription.
   * 
   * @param {String} fieldIdentifier a String representing a field in the 
   * configured field list or a Number representing the 1-based position of the field
   * in the specified field schema. (In case a field list was specified, passing
   * the field position is also possible).
   * 
   * @return {String} the current value for the specified field of the specified
   * key within the specified item (possibly null), or null if the specified
   * key has not been added yet (note that it might have been added and eventually deleted).
   */
  getCommandValue: function(itemIdentifier, keyValue, fieldIdentifier) {

  },  
  
  /**
   * Returns the position of the "key" field in a COMMAND Subscription.
   * <BR>This method can only be used if the Subscription mode is COMMAND
   * and the Subscription was initialized using a "Field Schema".
   *  
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @throws {IllegalStateException} if the Subscription mode is not 
   * COMMAND or if the {@link SubscriptionListener#onSubscription} event for this Subscription
   * was not yet fired.
   * 
   * @return {Number} the 1-based position of the "key" field within the "Field Schema".
   */
  getKeyPosition: function() {

  },
  
  /**
   * Returns the position of the "command" field in a COMMAND Subscription.
   * <BR>This method can only be used if the Subscription mode is COMMAND
   * and the Subscription was initialized using a "Field Schema".
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
   * 
   * @throws {IllegalStateException} if the Subscription mode is not 
   * COMMAND or if the {@link SubscriptionListener#onSubscription} event for this Subscription
   * was not yet fired.
   * 
   * @return {Number} the 1-based position of the "command" field within the "Field Schema".
   */
  getCommandPosition: function() {

  },
  
  /**
   * Adds a listener that will receive events from the Subscription 
   * instance.
   * <BR>The same listener can be added to several different Subscription 
   * instances.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> a listener can be added at any time.</p>
   * 
   * @param {SubscriptionListener} listener An object that will receive the events
   * as shown in the {@link SubscriptionListener} interface.
   * <BR>Note that the given instance does not have to implement all of the 
   * methods of the SubscriptionListener interface. In fact it may also 
   * implement none of the interface methods and still be considered a valid 
   * listener. In the latter case it will obviously receive no events.
   */
  addListener: function(listener) {

  },
  
  /**
   * Removes a listener from the Subscription instance so that it
   * will not receive events anymore.
   * 
   * <p class="lifecycle"><b>Lifecycle:</b> a listener can be removed at any time.</p>
   * 
   * @param {SubscriptionListener} listener The listener to be removed.
   */
  removeListener: function(listener) {

  },
  
  /**
   * Returns an array containing the {@link SubscriptionListener} instances that
   * were added to this client.
   * 
   * @return {SubscriptionListener[]} an Array containing the listeners that were added to this client.
   * Listeners added multiple times are included multiple times in the array.
   */
  getListeners: function() {

  },
};

export default Subscription;
