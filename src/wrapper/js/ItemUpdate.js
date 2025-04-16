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
    * Used by the client library to provide a value object to each call of the 
    * {@link SubscriptionListener#onItemUpdate} event.
    * @constructor
    * 
    * @exports ItemUpdate
    * @class Contains all the information related to an update of the field values 
    * for an item. It reports all the new values of the fields.
    * <BR>
    * <BR>
    * <B>COMMAND Subscription</B><BR>
    * If the involved Subscription is a COMMAND Subscription, then the values for 
    * the current update are meant as relative to the same key.
    * <BR>Moreover, if the involved Subscription has a two-level behavior enabled,
    * then each update may be associated with either a first-level or a second-level 
    * item. In this case, the reported fields are always the union of the first-level 
    * and second-level fields and each single update can only change either the 
    * first-level or the second-level fields (but for the "command" field, which is 
    * first-level and is always set to "UPDATE" upon a second-level update); note 
    * that the second-level field values are always null until the first second-level
    * update occurs).
    * When the two-level behavior is enabled, in all methods where a field name
    * has to be supplied, the following convention should be followed:
    * <ul>
    * <li>
    * The field name can always be used, both for the first-level and the second-level 
    * fields. In case of name conflict, the first-level field is meant. 
    * </li>
    * <li>
    * The field position can always be used; however, the field positions for 
    * the second-level fields start at the highest position of the first-level 
    * field list + 1. If a field schema had been specified for either first-level or 
    * second-level Subscriptions, then client-side knowledge of the first-level schema 
    * length would be required.
    * </li>
    * </ul>
    */
 var ItemUpdate = function() {

};

ItemUpdate.prototype = {
    
    /**  
     * Inquiry method that retrieves the name of the item to which this update 
     * pertains.
     * <BR>The name will be null if the related Subscription was initialized
     * using an "Item Group".
     * 
     * @return {String} the name of the item to which this update pertains.
     * 
     * @see Subscription#setItemGroup
     * @see Subscription#setItems
     */
    getItemName: function() {

    },
    
    /**  
     * Inquiry method that retrieves the position in the "Item List" or "Item Group"
     * of the item to which this update pertains.
     * 
     * @return {Number} the 1-based position of the item to which this update pertains.
     * 
     * @see Subscription#setItemGroup
     * @see Subscription#setItems
     */
    getItemPos: function() {

    },
    
    /**
     * Inquiry method that gets the value for a specified field, as received 
     * from the Server with the current or previous update.
     * 
     * @throws {IllegalArgumentException} if the specified field is not
     * part of the Subscription.
     * 
     * @param {String} fieldNameOrPos The field name or the 1-based position of the field
     * within the "Field List" or "Field Schema".
     * 
     * @return {String} The value of the specified field; it can be null in the following 
     * cases:
     * <ul>
     * <li>a null value has been received from the Server, as null is a 
     * possible value for a field;</li>
     * <li>no value has been received for the field yet;</li>
     * <li>the item is subscribed to with the COMMAND mode and a DELETE command 
     * is received (only the fields used to carry key and command information 
     * are valued).</li>
     * </ul>
     * 
     * @see Subscription#setFieldSchema
     * @see Subscription#setFields
     */
    getValue: function(fieldNameOrPos) {

    },

    /**
     * Inquiry method that gets the difference between the new value and the previous one
     * as a JSON Patch structure, provided that the Server has used the JSON Patch format
     * to send this difference, as part of the "delta delivery" mechanism.
     * This, in turn, requires that:<ul>
     * <li>the Data Adapter has explicitly indicated JSON Patch as the privileged type of
     * compression for this field;</li>
     * <li>both the previous and new value are suitable for the JSON Patch computation
     * (i.e. they are valid JSON representations);</li>
     * <li>the item was subscribed to in MERGE or DISTINCT mode (note that, in case of
     * two-level behavior, this holds for all fields related with second-level items,
     * as these items are in MERGE mode);</li>
     * <li>sending the JSON Patch difference has been evaluated by the Server as more
     * efficient than sending the full new value.</li>
     * </ul>
     * Note that the last condition can be enforced by leveraging the Server's
     * &lt;jsonpatch_min_length&gt; configuration flag, so that the availability of the
     * JSON Patch form would only depend on the Client and the Data Adapter.
     * <BR>When the above conditions are not met, the method just returns null; in this
     * case, the new value can only be determined through {@link ItemUpdate#getValue}. For instance,
     * this will always be needed to get the first value received.
     * 
     * @throws {IllegalArgumentException} if the specified field is not
     * part of the Subscription.
     * 
     * @param {String} fieldNameOrPos The field name or the 1-based position of the field
     * within the "Field List" or "Field Schema".
     * 
     * @return {Object} A JSON Patch structure representing the difference between
     * the new value and the previous one, or null if the difference in JSON Patch format
     * is not available for any reason.
     * 
     * @see ItemUpdate#getValue
     */
    getValueAsJSONPatchIfAvailable: function(fieldNameOrPos) {
        return null;
      },
    
    /**
     * Inquiry method that asks whether the value for a field has changed after 
     * the reception of the last update from the Server for an item.
     * If the Subscription mode is COMMAND then the change is meant as 
     * relative to the same key.
     * 
     * @param {String} fieldNameOrPos The field name or the 1-based position of the field
     * within the field list or field schema.
     * 
     * @return {boolean} Unless the Subscription mode is COMMAND, the return value is true 
     * in the following cases:
     * <ul>
     * <li>It is the first update for the item;</li>
     * <li>the new field value is different than the previous field value received 
     * for the item.</li>
     * </ul>
     * If the Subscription mode is COMMAND, the return value is true in the 
     * following cases:
     * <ul>
     * <li>it is the first update for the involved key value 
     * (i.e. the event carries an "ADD" command);</li>
     * <li>the new field value is different than the previous field value 
     * received for the item, relative to the same key value (the event 
     * must carry an "UPDATE" command);</li>
     * <li>the event carries a "DELETE" command (this applies to all fields 
     * other than the field used to carry key information).</li>
     * </ul>
     * In all other cases, the return value is false.
     * 
     * @throws {IllegalArgumentException} if the specified field is not
     * part of the Subscription.
     */
    isValueChanged: function(fieldNameOrPos) {

    },
    
    /**
     * Inquiry method that asks whether the current update belongs to the 
     * item snapshot (which carries the current item state at the time of 
     * Subscription). Snapshot events are sent only if snapshot information
     * was requested for the items through {@link Subscription#setRequestedSnapshot}
     * and precede the real time events. 
     * Snapshot information take different forms in different subscription
     * modes and can be spanned across zero, one or several update events. 
     * In particular:
     * <ul>
     * <li>if the item is subscribed to with the RAW subscription mode, 
     * then no snapshot is sent by the Server;</li>
     * <li>if the item is subscribed to with the MERGE subscription mode, 
     * then the snapshot consists of exactly one event, carrying the current 
     * value for all fields;</li>
     * <li>if the item is subscribed to with the DISTINCT subscription mode, then
     * the snapshot consists of some of the most recent updates; these updates 
     * are as many as specified through 
     * {@link Subscription#setRequestedSnapshot}, unless fewer are available;</li>
     * <li>if the item is subscribed to with the COMMAND subscription mode, 
     * then the snapshot consists of an "ADD" event for each key that is 
     * currently present.</li>
     * </ul>
     * Note that, in case of two-level behavior, snapshot-related updates 
     * for both the first-level item (which is in COMMAND mode) and any 
     * second-level items (which are in MERGE mode) are qualified with this flag.
     * 
     * @return {boolean} true if the current update event belongs to the item snapshot; 
     * false otherwise.
     */
    isSnapshot: function() {

    },
    
    
    
    /**
     * Receives an iterator function and invokes it once per each field such that {@link ItemUpdate#isValueChanged} is true. 
     * <BR>Note that if the Subscription mode of the involved Subscription is 
     * COMMAND, then changed fields are meant as relative to the previous update 
     * for the same key. On such tables if a DELETE command is received, all the 
     * fields, excluding the key field, will be iterated as changed, with null value. All of this 
     * is also true on tables that have the two-level behavior enabled, but in 
     * case of DELETE commands second-level fields will not be iterated. 
     * <BR>Note that the iterator is executed before this method returns.
     * 
     * @param {ItemUpdateChangedFieldCallback} iterator Function instance that will be called once 
     * per each field changed on the last update received from the server. 
     */
    forEachChangedField: function(iterator) {

    },
    
    /**
     * Receives an iterator function and invokes it once per each field 
     * in the Subscription. 
     * <BR>Note that the iterator is executed before this method returns.
     * 
     * @param {ItemUpdateChangedFieldCallback} iterator Function instance that will be called once 
     * per each field in the Subscription. 
     */
    forEachField: function(iterator) {

    },
};

   /**
    * Callback for {@link ItemUpdate#forEachChangedField} and {@link ItemUpdate#forEachField} 
    * @callback ItemUpdateChangedFieldCallback
    * @param {String} fieldName of the involved changed field. If the related Subscription was
    * initialized using a "Field Schema" it will be null.
    * @param {Number} fieldPos 1-based position of the field within
    * the "Field List" or "Field Schema".
    * @param {String} value the value for the field. See {@link ItemUpdate#getValue} for details.
    */