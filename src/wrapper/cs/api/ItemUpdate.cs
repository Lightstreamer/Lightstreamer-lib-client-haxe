using System.Collections.Generic;

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
    /// Contains all the information related to an update of the field values for an item. 
    /// It reports all the new values of the fields.<br/>
    /// <br/>
    /// <b>COMMAND Subscription</b><br/>
    /// If the involved Subscription is a COMMAND Subscription, then the values for the current 
    /// update are meant as relative to the same key.<br/>
    /// Moreover, if the involved Subscription has a two-level behavior enabled, then each update 
    /// may be associated with either a first-level or a second-level item. In this case, the reported 
    /// fields are always the union of the first-level and second-level fields and each single update 
    /// can only change either the first-level or the second-level fields (but for the "command" field, 
    /// which is first-level and is always set to "UPDATE" upon a second-level update); note 
    /// that the second-level field values are always null until the first second-level update 
    /// occurs). When the two-level behavior is enabled, in all methods where a field name has to 
    /// be supplied, the following convention should be followed:<br/>
    /// <br/>
    /// <ul>
    ///  <li>The field name can always be used, both for the first-level and the second-level fields. 
    ///  In case of name conflict, the first-level field is meant.</li>
    ///  <li>The field position can always be used; however, the field positions for the second-level 
    ///  fields start at the highest position of the first-level field list + 1. If a field schema had 
    ///  been specified for either first-level or second-level Subscriptions, then client-side knowledge 
    ///  of the first-level schema length would be required.</li>
    /// </ul>
    /// </summary>
    public interface ItemUpdate
    {
        /// <value>
        /// Read-only property <c>ItemName</c> represents the name of the item to which this update pertains.<br/> 
        /// The name will be null if the related Subscription was initialized using an "Item Group".<br/>
        /// See also: <seealso cref="Subscription.ItemGroup"/>, <seealso cref="Subscription.Items"/>.<br/>
        /// </value>
        public string ItemName
        {
            get;
        }

        /// <value>
        /// Read-only property <c>ItemPos</c> represents the 1-based the position in the "Item List" or
        /// "Item Group" of the item to which this update pertains.<br/>
        /// See also: <seealso cref="Subscription.ItemGroup"/>, <seealso cref="Subscription.Items"/>.<br/>
        /// </value>
        public int ItemPos
        {
            get;
        }

        /// <summary>
        /// Returns the current value for the specified field 
        /// </summary>
        /// <param name="fieldName"> The field name as specified within the "Field List". </param>
        /// <returns> The value of the specified field; it can be null in the following cases:<br/>
        /// <ul>
        ///  <li>a null value has been received from the Server, as null is a possible value for a field;</li>
        ///  <li>no value has been received for the field yet;</li>
        ///  <li>the item is subscribed to with the COMMAND mode and a DELETE command is received 
        ///  (only the fields used to carry key and command informations are valued).</li>
        /// </ul> 
        /// </returns>
        /// <seealso cref="Subscription.Fields" />
        public string getValue(string fieldName);

        /// <summary>
        /// Returns the current value for the specified field </summary>
        /// <param name="fieldPos"> The 1-based position of the field within the "Field List" or
        /// "Field Schema".</param>
        /// <returns> The value of the specified field; it can be null in the following cases:<br/>
        /// <ul>
        ///  <li>a null value has been received from the Server, as null is a possible value for a field;</li>
        ///  <li>no value has been received for the field yet;</li>
        ///  <li>the item is subscribed to with the COMMAND mode and a DELETE command is received 
        ///  (only the fields used to carry key and command informations are valued).</li>
        /// </ul> </returns>
        /// <seealso cref="Subscription.FieldSchema" />
        /// <seealso cref="Subscription.Fields" />
        public string getValue(int fieldPos);

        /// <summary>
        /// Inquiry method that asks whether the current update belongs to the item snapshot (which carries 
        /// the current item state at the time of Subscription). Snapshot events are sent only if snapshot 
        /// information was requested for the items through <seealso cref="Subscription.RequestedSnapshot"/> 
        /// and precede the real time events. Snapshot informations take different forms in different 
        /// subscription modes and can be spanned across zero, one or several update events. In particular:
        /// <ul>
        ///  <li>if the item is subscribed to with the RAW subscription mode, then no snapshot is 
        ///  sent by the Server;</li>
        ///  <li>if the item is subscribed to with the MERGE subscription mode, then the snapshot consists 
        ///  of exactly one event, carrying the current value for all fields;</li>
        ///  <li>if the item is subscribed to with the DISTINCT subscription mode, then the snapshot 
        ///  consists of some of the most recent updates; these updates are as many as specified 
        ///  through <seealso cref="Subscription.RequestedSnapshot"/>, unless fewer are available;</li>
        ///  <li>if the item is subscribed to with the COMMAND subscription mode, then the snapshot 
        ///  consists of an "ADD" event for each key that is currently present.</li>
        /// </ul>
        /// Note that, in case of two-level behavior, snapshot-related updates for both the first-level item
        /// (which is in COMMAND mode) and any second-level items (which are in MERGE mode) are qualified with 
        /// this flag. </summary>
        /// <returns> true if the current update event belongs to the item snapshot; false otherwise. </returns>
        public bool Snapshot
        {
            get;
        }

        /// <summary>
        /// Inquiry method that asks whether the value for a field has changed after the reception of the last 
        /// update from the Server for an item. If the Subscription mode is COMMAND then the change is meant as 
        /// relative to the same key. </summary>
        /// <param name="fieldName"> The field name as specified within the "Field List". </param>
        /// <returns> Unless the Subscription mode is COMMAND, the return value is true in the following cases:
        /// <ul>
        ///  <li>It is the first update for the item;</li>
        ///  <li>the new field value is different than the previous field 
        ///  value received for the item.</li>
        /// </ul>
        ///  If the Subscription mode is COMMAND, the return value is true in the following cases:
        /// <ul>
        ///  <li>it is the first update for the involved key value (i.e. the event carries an "ADD" command);</li>
        ///  <li>the new field value is different than the previous field value received for the item, 
        ///  relative to the same key value (the event must carry an "UPDATE" command);</li>
        ///  <li>the event carries a "DELETE" command (this applies to all fields other than the field 
        ///  used to carry key information).</li>
        /// </ul>
        /// In all other cases, the return value is false. </returns>
        /// <seealso cref="Subscription.Fields" />
        public bool isValueChanged(string fieldName);

        /// <summary>
        /// Inquiry method that asks whether the value for a field has changed after the reception of the last 
        /// update from the Server for an item. If the Subscription mode is COMMAND then the change is meant as 
        /// relative to the same key. </summary>
        /// <param name="fieldPos"> The 1-based position of the field within the "Field List" or "Field Schema". </param>
        /// <returns> Unless the Subscription mode is COMMAND, the return value is true in the following cases:
        /// <ul>
        ///  <li>It is the first update for the item;</li>
        ///  <li>the new field value is different than the previous field 
        ///  value received for the item.</li>
        /// </ul>
        ///  If the Subscription mode is COMMAND, the return value is true in the following cases:
        /// <ul>
        ///  <li>it is the first update for the involved key value (i.e. the event carries an "ADD" command);</li>
        ///  <li>the new field value is different than the previous field value received for the item, 
        ///  relative to the same key value (the event must carry an "UPDATE" command);</li>
        ///  <li>the event carries a "DELETE" command (this applies to all fields other than the field 
        ///  used to carry key information).</li>
        /// </ul>
        /// In all other cases, the return value is false. </returns>
        /// <seealso cref="Subscription.FieldSchema" />
        /// <seealso cref="Subscription.Fields" />
        public bool isValueChanged(int fieldPos);

        /// <summary>
        /// Inquiry method that gets the difference between the new value and the previous one
        /// as a JSON Patch structure, provided that the Server has used the JSON Patch format
        /// to send this difference, as part of the "delta delivery" mechanism.
        /// This, in turn, requires that:<ul>
        /// <li>the Data Adapter has explicitly indicated JSON Patch as the privileged type of
        /// compression for this field;</li>
        /// <li>both the previous and new value are suitable for the JSON Patch computation
        /// (i.e. they are valid JSON representations);</li>
        /// <li>the item was subscribed to in MERGE or DISTINCT mode (note that, in case of
        /// two-level behavior, this holds for all fields related with second-level items,
        /// as these items are in MERGE mode);</li>
        /// <li>sending the JSON Patch difference has been evaluated by the Server as more
        /// efficient than sending the full new value.</li>
        /// </ul>
        /// Note that the last condition can be enforced by leveraging the Server's
        /// &lt;jsonpatch_min_length&gt; configuration flag, so that the availability of the
        /// JSON Patch form would only depend on the Client and the Data Adapter.
        /// <br/>When the above conditions are not met, the method just returns null; in this
        /// case, the new value can only be determined through {@link ItemUpdate#getValue}. For instance,
        /// this will always be needed to get the first value received.</summary>
        /// 
        /// <exception cref="ArgumentException"> if the specified field is not
        /// part of the Subscription.</exception>
        /// 
        /// <param name="fieldName"> The field name as specified within the "Field List".</param>
        /// 
        /// <returns> A JSON Patch structure representing the difference between
        /// the new value and the previous one, or null if the difference in JSON Patch format
        /// is not available for any reason.</returns>
        /// 
        /// <seealso cref="ItemUpdate.getValue"/>
        public string getValueAsJSONPatchIfAvailable(string fieldName);

        /// <summary>
        /// Inquiry method that gets the difference between the new value and the previous one
        /// as a JSON Patch structure, provided that the Server has used the JSON Patch format
        /// to send this difference, as part of the "delta delivery" mechanism.
        /// This, in turn, requires that:<ul>
        /// <li>the Data Adapter has explicitly indicated JSON Patch as the privileged type of
        /// compression for this field;</li>
        /// <li>both the previous and new value are suitable for the JSON Patch computation
        /// (i.e. they are valid JSON representations);</li>
        /// <li>the item was subscribed to in MERGE or DISTINCT mode (note that, in case of
        /// two-level behavior, this holds for all fields related with second-level items,
        /// as these items are in MERGE mode);</li>
        /// <li>sending the JSON Patch difference has been evaluated by the Server as more
        /// efficient than sending the full new value.</li>
        /// </ul>
        /// Note that the last condition can be enforced by leveraging the Server's
        /// &lt;jsonpatch_min_length&gt; configuration flag, so that the availability of the
        /// JSON Patch form would only depend on the Client and the Data Adapter.
        /// <br/>When the above conditions are not met, the method just returns null; in this
        /// case, the new value can only be determined through {@link ItemUpdate#getValue}. For instance,
        /// this will always be needed to get the first value received.</summary>
        /// 
        /// <exception cref="ArgumentException"> if the specified field is not
        /// part of the Subscription.</exception>
        /// 
        /// <param name="fieldPos"> The 1-based position of the field within the "Field List" or "Field Schema".</param>
        /// 
        /// <returns> A JSON Patch structure representing the difference between
        /// the new value and the previous one, or null if the difference in JSON Patch format
        /// is not available for any reason.</returns>
        /// 
        /// <seealso cref="ItemUpdate.getValue"/>
        public string getValueAsJSONPatchIfAvailable(int fieldPos);

        /// <summary>
        /// Returns an immutable Map containing the values for each field changed with the last server update. 
        /// The related field name is used as key for the values in the map. 
        /// Note that if the Subscription mode of the involved Subscription is COMMAND, then changed fields 
        /// are meant as relative to the previous update for the same key. On such tables if a DELETE command 
        /// is received, all the fields, excluding the key field, will be present as changed, with null value. 
        /// All of this is also true on tables that have the two-level behavior enabled, but in case of 
        /// DELETE commands second-level fields will not be iterated.
        /// </summary>
        /// <returns> An immutable Map containing the values for each field changed with the last
        /// server update.
        /// </returns>
        /// <seealso cref="Subscription.FieldSchema" />
        /// <seealso cref="Subscription.Fields" />
        public IDictionary<string, string> ChangedFields
        {
            get;
        }

        /// <summary>
        /// Returns an immutable Map containing the values for each field changed with the last server update. 
        /// The 1-based field position within the field schema or field list is used as key for the values in the map. 
        /// Note that if the Subscription mode of the involved Subscription is COMMAND, then changed fields 
        /// are meant as relative to the previous update for the same key. On such tables if a DELETE command 
        /// is received, all the fields, excluding the key field, will be present as changed, with null value. 
        /// All of this is also true on tables that have the two-level behavior enabled, but in case of 
        /// DELETE commands second-level fields will not be iterated.
        /// </summary>
        /// <returns> An immutable Map containing the values for each field changed with the last server update.
        /// </returns>
        /// <seealso cref="Subscription.FieldSchema" />
        /// <seealso cref="Subscription.Fields" />
        public IDictionary<int, string> ChangedFieldsByPosition
        {
            get;
        }

        /// <summary>
        /// Returns an immutable Map containing the values for each field in the Subscription.
        /// The related field name is used as key for the values in the map. 
        /// </summary>
        /// <returns> An immutable Map containing the values for each field in the Subscription.
        /// </returns>
        /// <seealso cref="Subscription.FieldSchema" />
        /// <seealso cref="Subscription.Fields" />
        public IDictionary<string, string> Fields
        {
            get;
        }

        /// <summary>
        /// Returns an immutable Map containing the values for each field in the Subscription.
        /// The 1-based field position within the field schema or field list is used as key for the values in the map. 
        /// </summary>
        /// <returns> An immutable Map containing the values for each field in the Subscription.
        /// </returns>
        /// <seealso cref="Subscription.FieldSchema" />
        /// <seealso cref="Subscription.Fields" />
        public IDictionary<int, string> FieldsByPosition
        {
            get;
        }
    }
}