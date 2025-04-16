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
using System;
using System.Collections.Generic;

namespace com.lightstreamer.client
{
    /// <summary>
    /// Class representing a Subscription to be submitted to a Lightstreamer Server. It contains 
    /// subscription details and the listeners needed to process the real-time data. <br/>
    /// After the creation, a Subscription object is in the "inactive" state. When a Subscription 
    /// object is subscribed to on a LightstreamerClient object, through the 
    /// <seealso cref="LightstreamerClient.subscribe(Subscription)"/> method, its state becomes "active". 
    /// This means that the client activates a subscription to the required items through 
    /// Lightstreamer Server and the Subscription object begins to receive real-time events. <br/>
    /// A Subscription can be configured to use either an Item Group or an Item List to specify the 
    /// items to be subscribed to and using either a Field Schema or Field List to specify the fields. <br/>
    /// "Item Group" and "Item List" are defined as follows:
    /// <ul>
    ///  <li>"Item Group": an Item Group is a String identifier representing a list of items. 
    ///  Such Item Group has to be expanded into a list of items by the getItems method of the 
    ///  MetadataProvider of the associated Adapter Set. When using an Item Group, items in the 
    ///  subscription are identified by their 1-based index within the group.<br/>
    ///  It is possible to configure the Subscription to use an "Item Group" leveraging the 
    ///  <seealso cref="Subscription.ItemGroup"/> property.</li> 
    ///  <li>"Item List": an Item List is an array of Strings each one representing an item. 
    ///  For the Item List to be correctly interpreted a LiteralBasedProvider or a MetadataProvider 
    ///  with a compatible implementation of getItems has to be configured in the associated 
    ///  Adapter Set.<br/>
    ///  Note that no item in the list can be empty, can contain spaces or can be a number.<br/>
    ///  When using an Item List, items in the subscription are identified by their name or 
    ///  by their 1-based index within the list.<br/>
    ///  It is possible to configure the Subscription to use an "Item List" leveraging the 
    ///  <seealso cref="Subscription.Items"/> property or by specifying it in the constructor.</li>
    /// </ul>
    /// "Field Schema" and "Field List" are defined as follows:
    /// <ul>
    ///  <li>"Field Schema": a Field Schema is a String identifier representing a list of fields. 
    ///  Such Field Schema has to be expanded into a list of fields by the getFields method of 
    ///  the MetadataProvider of the associated Adapter Set. When using a Field Schema, fields 
    ///  in the subscription are identified by their 1-based index within the schema.<br/>
    ///  It is possible to configure the Subscription to use a "Field Schema" leveraging the 
    ///  <seealso cref="Subscription.FieldSchema"/> property.</li>
    ///  <li>"Field List": a Field List is an array of Strings each one representing a field. 
    ///  For the Field List to be correctly interpreted a LiteralBasedProvider or a MetadataProvider 
    ///  with a compatible implementation of getFields has to be configured in the associated 
    ///  Adapter Set.<br/>
    ///  Note that no field in the list can be empty or can contain spaces.<br/>
    ///  When using a Field List, fields in the subscription are identified by their name or 
    ///  by their 1-based index within the list.<br/>
    ///  It is possible to configure the Subscription to use a "Field List" leveraging the 
    ///  <seealso cref="Subscription.Fields"/> property or by specifying it in the constructor.</li>
    /// </ul>
    /// </summary>
    public class Subscription
    {
        internal readonly LSSubscription _delegate;

        /// <summary>
        /// Creates an object to be used to describe a Subscription that is going to be subscribed to 
        /// through Lightstreamer Server. The object can be supplied to 
        /// <seealso cref="LightstreamerClient.subscribe(Subscription)"/> and 
        /// <seealso cref="LightstreamerClient.unsubscribe(Subscription)"/>, in order to bring the Subscription 
        /// to "active" or back to "inactive" state. <br/>
        /// Note that all of the methods used to describe the subscription to the server can only be 
        /// called while the instance is in the "inactive" state; the only exception is 
        /// <seealso cref="Subscription.RequestedMaxFrequency"/>.
        /// </summary>
        /// <param name="subscriptionMode"> the subscription mode for the items, required by Lightstreamer Server. 
        /// Permitted values are:
        /// <ul>
        ///  <li>MERGE</li>
        ///  <li>DISTINCT</li>
        ///  <li>RAW</li>
        ///  <li>COMMAND</li>
        /// </ul> </param>
        /// <param name="items"> an array of items to be subscribed to through Lightstreamer server. <br/>
        /// It is also possible specify the "Item List" or "Item Group" later through 
        /// <seealso cref="Subscription.Items"/> and <seealso cref="Subscription.ItemGroup"/>. </param>
        /// <param name="fields"> an array of fields for the items to be subscribed to through Lightstreamer Server. <br/>
        /// It is also possible to specify the "Field List" or "Field Schema" later through 
        /// <seealso cref="Subscription.Fields"/> and <seealso cref="Subscription.FieldSchema"/>.
        /// </param>
        public Subscription(string subscriptionMode, string[] items, string[] fields)
        {
            this._delegate = new LSSubscription(subscriptionMode, items, fields, this);
        }

        /// <summary>
        /// Creates an object to be used to describe a Subscription that is going to be subscribed to 
        /// through Lightstreamer Server. The object can be supplied to 
        /// <seealso cref="LightstreamerClient.subscribe(Subscription)"/> and 
        /// <seealso cref="LightstreamerClient.unsubscribe(Subscription)"/>, in order to bring the Subscription 
        /// to "active" or back to "inactive" state. <br/>
        /// Note that all of the methods used to describe the subscription to the server can only be 
        /// called while the instance is in the "inactive" state; the only exception is 
        /// <seealso cref="Subscription.RequestedMaxFrequency"/>.
        /// </summary>
        /// <param name="subscriptionMode"> the subscription mode for the items, required by Lightstreamer Server. 
        /// Permitted values are:
        /// <ul>
        ///  <li>MERGE</li>
        ///  <li>DISTINCT</li>
        ///  <li>RAW</li>
        ///  <li>COMMAND</li>
        /// </ul> </param>
        /// <param name="item"> the item name to be subscribed to through Lightstreamer Server. </param>
        /// <param name="fields"> an array of fields for the items to be subscribed to through Lightstreamer Server. <br/>
        /// It is also possible to specify the "Field List" or "Field Schema" later through 
        /// <seealso cref="Subscription.Fields"/> and <seealso cref="Subscription.FieldSchema"/>.
        /// </param>
        public Subscription(string subscriptionMode, string item, string[] fields)
        {
            this._delegate = new LSSubscription(subscriptionMode, item, fields, this);
        }

        /// <summary>
        /// Creates an object to be used to describe a Subscription that is going to be subscribed to 
        /// through Lightstreamer Server. The object can be supplied to 
        /// <seealso cref="LightstreamerClient.subscribe(Subscription)"/> and 
        /// <seealso cref="LightstreamerClient.unsubscribe(Subscription)"/>, in order to bring the Subscription 
        /// to "active" or back to "inactive" state. <br/>
        /// Note that all of the methods used to describe the subscription to the server can only be 
        /// called while the instance is in the "inactive" state; the only exception is 
        /// <seealso cref="Subscription.RequestedMaxFrequency"/>.
        /// </summary>
        /// <param name="subscriptionMode"> the subscription mode for the items, required by Lightstreamer Server. 
        /// Permitted values are:
        /// <ul>
        ///  <li>MERGE</li>
        ///  <li>DISTINCT</li>
        ///  <li>RAW</li>
        ///  <li>COMMAND</li>
        /// </ul> </param>
        public Subscription(string subscriptionMode)
        {
            this._delegate = new LSSubscription(subscriptionMode, this);
        }

        /// <summary>
        /// Adds a listener that will receive events from the Subscription instance. <br/> 
        /// The same listener can be added to several different Subscription instances.
        /// 
        /// <b>Lifecycle:</b>  A listener can be added at any time. A call to add a listener already 
        /// present will be ignored.
        /// </summary>
        /// <param name="listener"> An object that will receive the events as documented in the 
        /// SubscriptionListener interface.
        /// </param>
        /// <seealso cref="Subscription.removeListener(SubscriptionListener)" />
        public virtual void addListener(SubscriptionListener listener)
        {
          _delegate.addListener(listener);
        }

        /// <summary>
        /// Removes a listener from the Subscription instance so that it will not receive 
        /// events anymore.
        /// 
        /// <b>Lifecycle:</b>  a listener can be removed at any time.
        /// </summary>
        /// <param name="listener"> The listener to be removed.
        /// </param>
        /// <seealso cref="Subscription.addListener(SubscriptionListener)" />
        public virtual void removeListener(SubscriptionListener listener)
        {
          _delegate.removeListener(listener);
        }

        /// <summary>
        /// Returns a list containing the <seealso cref="SubscriptionListener"/> instances that were 
        /// added to this client. </summary>
        /// <returns> a list containing the listeners that were added to this client. </returns>
        /// <seealso cref="Subscription.addListener(SubscriptionListener)" />
        public virtual IList<SubscriptionListener> Listeners
        {
            get
            {
              return _delegate.getListeners();
            }
        }

        /// <value>
        /// Read-only property <c>Active</c> checks if the Subscription is currently "active" or not.
        /// Most of the Subscription properties cannot be modified if a Subscription is "active".<br/>
        /// The status of a Subscription is changed to "active" through the  
        /// <seealso cref="LightstreamerClient.subscribe(Subscription)"/> method and back to 
        /// "inactive" through the <seealso cref="LightstreamerClient.unsubscribe(Subscription)"/> one.<br/>
        /// Returns true/false if the Subscription is "active" or not.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time.
        /// </value>
        /// <seealso cref="LightstreamerClient.subscribe(Subscription)" />
        /// <seealso cref="LightstreamerClient.unsubscribe(Subscription)" />
        public virtual bool Active
        {
            get
            {
              return _delegate.isActive();
            }
        }

        /// <value>
        /// Read-only property <c>Subscribed</c> thtat checks if the Subscription is currently subscribed
        /// to through the server or not.<br/>
        /// This flag is switched to true by server sent Subscription events, and 
        /// back to false in case of client disconnection, 
        /// <seealso cref="LightstreamerClient.unsubscribe(Subscription)"/> calls and server 
        /// sent unsubscription events.<br/>
        /// Returns true/false if the Subscription is subscribed to through the server or not.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time.
        /// </value>
        public virtual bool Subscribed
        {
            get
            {
              return _delegate.isSubscribed();
            }
        }

        /// <value>
        /// Property <c>DataAdapter</c> represents the name of the Data Adapter (within the Adapter Set used by the current session)
        /// that supplies all the items for this Subscription.<br/>
        /// The Data Adapter name is configured on the server side through the "name" attribute of the
        /// "data_provider" element, in the "adapters.xml" file that defines the Adapter Set (a missing
        /// attribute configures the "DEFAULT" name).<br/>
        /// Note that if more than one Data Adapter is needed to supply all the items in a set of items, then
        /// it is not possible to group all the items of the set in a single Subscription. Multiple
        /// Subscriptions have to be defined.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can only be called while the Subscription instance is in its
        /// "inactive" state.<br/>
        /// <br/>
        /// <b>Default value:</b> The default Data Adapter for the Adapter Set, configured as "DEFAULT" on the Server.
        /// </value>
        public virtual string DataAdapter
        {
            get
            {
              return _delegate.getDataAdapter();
            }
            set
            {
              _delegate.setDataAdapter(value);
            }
        }

        /// <value>
        /// Read-only property <c>Mode</c> represents the mode specified in the constructor for
        /// this Subscription.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time.
        /// </value>
        public virtual string Mode
        {
            get
            {
              return _delegate.getMode();
            }
        }

        /// <value>
        /// Property <c>Items</c> represents the "Item List"  to be subscribed to through Lightstreamer Server.
        /// Any call to set this property will override any "Item List" or "Item Group" previously specified.
        /// Note that if the single-item-constructor was used, this method will return an array 
        /// of length 1 containing such item.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can only be called if the Subscription has been initialized 
        /// with an "Item List".
        /// </value>
        public virtual string[] Items
        {
            get
            {
              return _delegate.getItems();
            }
            set
            {
              _delegate.setItems(value);
            }
        }

        /// <value>
        /// Property <c>ItemGroup</c> represents the the "Item Group" to be subscribed to through
        /// Lightstreamer Server.
        /// Any call to set this property will override any "Item List" or "Item Group" previously specified.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can only be called if the Subscription has been initialized
        /// using an "Item Group".
        /// </value>
        public virtual string ItemGroup
        {
            get
            {
              return _delegate.getItemGroup();
            }
            set
            {
              _delegate.setItemGroup(value);
            }
        }

        /// <value>
        /// Property <c>Fields</c> represents the "Field  List"  to be subscribed to through Lightstreamer Server.
        /// Any call to set this property will override any "Field  List" or "Field Schema" previously specified.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This property can be set only while the Subscription instance is in its "inactive" state.
        /// </value>
        public virtual string[] Fields
        {
            get
            {
              return _delegate.getFields();
            }
            set
            {
              _delegate.setFields(value);
            }
        }

        /// <value>
        /// Property <c>FieldSchema</c> represents the "Field Schema" to be subscribed to through Lightstreamer Server.
        /// Any call to set this property will override any "Field  List" or "Field Schema" previously specified.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This property can be set only while the Subscription instance is in its "inactive" state.
        /// </value>
        public virtual string FieldSchema
        {
            get
            {
              return _delegate.getFieldSchema();
            }
            set
            {
              _delegate.setFieldSchema(value);
            }
        }

        /// <value>
        /// Property <c>RequestedBufferSize</c> represents the length to be requested to Lightstreamer Server
        /// for the internal queuing buffers for the items in the Subscription. A Queuing buffer is used by
        /// the Server to accumulate a burst of updates for an item, so that they can all be sent to the
        /// client, despite of bandwidth or frequency limits. It can be used only when the subscription mode
        /// is MERGE or DISTINCT and unfiltered dispatching has not been requested. Note that the Server may
        /// pose an upper limit on the size of its internal buffers.<br/>
        /// The value of this property is integer number, representing the length of the internal queuing
        /// buffers to be used in the Server. If the string "unlimited" is supplied, then no buffer size
        /// limit is requested (the check is case insensitive). It is also possible to supply a null value
        /// to stick to the Server default (which currently depends on the subscription mode).<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can only be called while the Subscription instance is in its
        /// "inactive" state.<br/>
        /// <br/>
        /// <b>Default value:</b> null, meaning to lean on the Server default based on the subscription mode.
        /// This means that the buffer size will be 1 for MERGE subscriptions and "unlimited" for DISTINCT
        /// subscriptions. See the "General Concepts" document for further details.
        /// </value>
        public virtual string RequestedBufferSize
        {
            get
            {
              return _delegate.getRequestedBufferSize();
            }
            set
            {
              _delegate.setRequestedBufferSize(value);
            }
        }

        /// <value>
        /// Property <c>RequestedSnapshot</c> enables/disables snapshot delivery request for the items in
        /// the Subscription. The snapshot can be requested only if the Subscription mode is
        /// MERGE, DISTINCT or COMMAND.
        /// The value can be "yes"/"no" to request/not request snapshot delivery (the check is case insensitive).
        /// If the Subscription mode is DISTINCT, instead of "yes", it is also possible to supply an integer
        /// number, to specify the requested length of the snapshot (though the length of the received
        /// snapshot may be less than requested, because of insufficient data or server side limits);
        /// passing "yes" means that the snapshot length should be determined only by the Server. Null is
        /// also a valid value; if specified, no snapshot preference will be sent to the server that will
        /// decide itself whether or not to send any snapshot.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can only be called while the Subscription instance is in its "inactive" state.<br/>
        /// <br/>
        /// <b>Default value:</b> "yes" if the Subscription mode is not "RAW", null otherwise.
        /// </value>
        public virtual string RequestedSnapshot
        {
            get
            {
              return _delegate.getRequestedSnapshot();
            }
            set
            {
              _delegate.setRequestedSnapshot(value);
            }
        }

        /// <value>
        /// Property <c>RequestedMaxFrequency</c> represents the maximum update frequency to be requested to
        /// Lightstreamer Server for all the items in the Subscription. It can be used only if the
        /// Subscription mode is MERGE, DISTINCT or COMMAND (in the latter case, the frequency limitation
        /// applies to the UPDATE events for each single key). For Subscriptions with two-level behavior
        /// (see <seealso cref="Subscription.CommandSecondLevelFields"/> and 
        /// <seealso cref="Subscription.CommandSecondLevelFieldSchema"/>,
        /// the specified frequency limit applies to both first-level and second-level items.<br/>
        /// Note that frequency limits on the items can also be set on the server side and this request can
        /// only be issued in order to furtherly reduce the frequency, not to rise it beyond these limits.<br/>
        /// This method can also be used to request unfiltered dispatching for the items in the Subscription.
        /// However, unfiltered dispatching requests may be refused if any frequency limit is posed on the
        /// server side for some item.<br/>
        /// The value can be a decimal number, representing the maximum update frequency (expressed in updates per
        /// second) for each item in the Subscription; for instance, with a setting of 0.5, for each single
        /// item, no more than one update every 2 seconds will be received. If the string "unlimited" is
        /// supplied, then no frequency limit is requested. It is also possible to supply the string
        /// "unfiltered", to ask for unfiltered dispatching, if it is allowed for the items, or a null value
        /// to stick to the Server default (which currently corresponds to "unlimited"). The check for the
        /// string constants is case insensitive.<br/>
        /// <br/>
        /// <b>Edition Note:</b> A further global frequency limit could also be imposed by the Server,
        /// depending on Edition and License Type; this specific limit also applies to RAW mode and to
        /// unfiltered dispatching.
        /// To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
        /// available at /dashboard).<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can can be called at any time with some differences based on the
        /// Subscription status:
        /// <ul>
        /// <li>If the Subscription instance is in its "inactive" state then this method can be called at will.</li>
        /// <li>If the Subscription instance is in its "active" state then the method can still be called
        /// unless the current value is "unfiltered" or the supplied value is "unfiltered" or null. If the
        /// Subscription instance is in its "active" state and the connection to the server is currently open,
        /// then a request to change the frequency of the Subscription on the fly is sent to the server.</li>
        /// </ul>
        /// <br/>
        /// <b>Default value:</b> null, meaning to lean on the Server default based on the subscription mode.
        /// This consists, for all modes, in not applying any frequency limit to the subscription (the same
        /// as "unlimited"); see the "General Concepts" document for further details.
        /// </value>
        public virtual string RequestedMaxFrequency
        {
            get
            {
              return _delegate.getRequestedMaxFrequency();
            }
            set
            {
              _delegate.setRequestedMaxFrequency(value);
            }
        }

        /// <value>
        /// Property <c>Selector</c> represents the selector name for all the items in the Subscription.
        /// The selector is a filter on the updates received. It is executed on the Server and implemented
        /// by the Metadata Adapter.<br/>
        /// The name of a selector should be recognized by the Metadata Adapter, or can be null to unset
        /// the selector.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can only be called while the Subscription instance is in its
        /// "inactive" state.<br/>
        /// <br/>
        /// <b>Default value:</b> null (no selector).
        /// </value>
        public virtual string Selector
        {
            get
            {
              return _delegate.getSelector();
            }
            set
            {
              _delegate.setSelector(value);
            }
        }

        /// <value>
        /// Read-only property <c>CommandPosition</c> represents the "command" field in a COMMAND
        /// Subscription.<br/>
        /// This method can only be used if the Subscription mode is COMMAND and the Subscription 
        /// was initialized using a "Field Schema".<br/>
        /// The value is the 1-based position of the "command" field within the "Field Schema".<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time after the first 
        /// <seealso cref="SubscriptionListener.onSubscription"/> event.
        /// </value>
        public virtual int CommandPosition
        {
            get
            {
              return _delegate.getCommandPosition();
            }
        }

        /// <value>
        /// Read-only property <c>KeyPosition</c> represents the position of the "key" field in a
        /// COMMAND Subscription.<br/>
        /// This method can only be used if the Subscription mode is COMMAND
        /// and the Subscription was initialized using a "Field Schema".<br/>
        /// The value is the 1-based position of the "key" field within the "Field Schema".<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time.
        /// </value>
        public virtual int KeyPosition
        {
            get
            {
              return _delegate.getKeyPosition();
            }
        }

        /// <value>
        /// Property <c>CommandSecondLevelDataAdapter</c> represents the name of the second-level Data Adapter
        /// (within the Adapter Set used by the current session) that supplies all the second-level items.<br/>
        /// All the possible second-level items should be supplied in "MERGE" mode with snapshot available.<br/>
        /// The Data Adapter name is configured on the server side through the "name" attribute of the 
        /// data_provider element, in the "adapters.xml" file that defines the Adapter Set (a missing
        /// attribute configures the "DEFAULT" name).<br/>
        /// A null value is equivalent to the "DEFAULT" name.<br/>
        /// See also: <seealso cref="Subscription.CommandSecondLevelFields"/>, <seealso cref="Subscription.CommandSecondLevelFieldSchema"/><br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can only be called while the Subscription instance is in its
        /// "inactive" state.<br/>
        /// <br/>
        /// <b>Default value:</b> The default Data Adapter for the Adapter Set, configured as "DEFAULT"
        /// on the Server.
        /// </value>
        public virtual string CommandSecondLevelDataAdapter
        {
            get
            {
              return _delegate.getCommandSecondLevelDataAdapter();
            }
            set
            {
              _delegate.setCommandSecondLevelDataAdapter(value);
            }
        }

        /// <value>
        /// Property <c>CommandSecondLevelFields</c> represents the "Field List" to be subscribed to
        /// through Lightstreamer Server for the second-level items. It can only be used on COMMAND
        /// Subscriptions.<br/>
        /// Any call to this method will override any "Field List" or "Field Schema" previously specified
        /// for the second-level.<br/>
        /// Calling this method enables the two-level behavior: in synthesis, each time a new key is received
        /// on the COMMAND Subscription, the key value is treated as an Item name and an underlying
        /// Subscription for this Item is created and subscribed to automatically, to feed fields specified
        /// by this method. This mono-item Subscription is specified through an "Item List" containing only
        /// the Item name received. As a consequence, all the conditions provided for subscriptions through
        /// Item Lists have to be satisfied. The item is subscribed to in "MERGE" mode, with snapshot request
        /// and with the same maximum frequency setting as for the first-level items (including the
        /// "unfiltered" case). All other Subscription properties are left as the default. When the key is
        /// deleted by a DELETE command on the first-level Subscription, the associated second-level
        /// Subscription is also unsubscribed from.<br/>
        /// Specifying null as parameter will disable the two-level behavior.<br/>
        /// Ensure that no name conflict is generated between first-level and second-level fields. In case
        /// of conflict, the second-level field will not be accessible by name, but only by position.<br/>
        /// See also: <seealso cref="Subscription.CommandSecondLevelFieldSchema"/><br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can only be called while the Subscription instance is in its
        /// "inactive" state.<br/>
        /// </value>
        public virtual string[] CommandSecondLevelFields
        {
            get
            {
              return _delegate.getCommandSecondLevelFields();
            }
            set
            {
              _delegate.setCommandSecondLevelFields(value);
            }
        }

        /// <value>
        /// Property <c>CommandSecondLevelFieldSchema</c> represents the "Field Schema" to be subscribed to
        /// through Lightstreamer Server for the second-level items. It can only be used on
        /// COMMAND Subscriptions.<br/>
        /// Any call to this method will override any "Field List" or "Field Schema" previously specified for
        /// the second-level.<br/>
        /// Calling this method enables the two-level behavior: in synthesis, each time a new key is received
        /// on the COMMAND Subscription, the key value is treated as an Item name and an underlying
        /// Subscription for this Item is created and subscribed to automatically, to feed fields specified
        /// by this method. This mono-item Subscription is specified through an "Item List" containing only
        /// the Item name received. As a consequence, all the conditions provided for subscriptions through
        /// Item Lists have to be satisfied. The item is subscribed to in "MERGE" mode, with snapshot request
        /// and with the same maximum frequency setting as for the first-level items (including the
        /// "unfiltered" case). All other Subscription properties are left as the default. When the key is
        /// deleted by a DELETE command on the first-level Subscription, the associated second-level
        /// Subscription is also unsubscribed from.<br/>
        /// Specify null as parameter will disable the two-level behavior.<br/>
        /// See also: <seealso cref="Subscription.CommandSecondLevelFields"/><br/>
        /// <br/>
        /// 
        /// <b>Lifecycle:</b> This method can only be called while the Subscription instance is in
        /// its "inactive" state.
        /// </value>
        public virtual string CommandSecondLevelFieldSchema
        {
            get
            {
              return _delegate.getCommandSecondLevelFieldSchema();
            }
            set
            {
              _delegate.setCommandSecondLevelFieldSchema(value);
            }
        }

        /// <summary>
        /// Returns the latest value received for the specified item/field pair.<br/>
        /// It is suggested to consume real-time data by implementing and adding
        /// a proper <seealso cref="SubscriptionListener"/> rather than probing this method.<br/>
        /// In case of COMMAND Subscriptions, the value returned by this
        /// method may be misleading, as in COMMAND mode all the keys received, being
        /// part of the same item, will overwrite each other; for COMMAND Subscriptions,
        /// use <seealso cref="Subscription.getCommandValue(string, string, string)"/> instead.<br/>
        /// Note that internal data is cleared when the Subscription is 
        /// unsubscribed from.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time; if called 
        /// to retrieve a value that has not been received yet, then it will return null.
        /// </summary>
        /// <param name="itemName"> an item in the configured "Item List" </param>
        /// <param name="fieldName"> a field in the configured "Field List" </param>
        /// <returns> the current value for the specified field of the specified item
        /// (possibly null), or null if no value has been received yet.
        /// </returns>
        public virtual string getValue(string itemName, string fieldName)
        {
          return _delegate.getValue(itemName, fieldName);
        }

        /// <summary>
        /// Returns the latest value received for the specified item/field pair.<br/>
        /// It is suggested to consume real-time data by implementing and adding
        /// a proper <seealso cref="SubscriptionListener"/> rather than probing this method.<br/>
        /// In case of COMMAND Subscriptions, the value returned by this
        /// method may be misleading, as in COMMAND mode all the keys received, being
        /// part of the same item, will overwrite each other; for COMMAND Subscriptions,
        /// use <seealso cref="Subscription.getCommandValue(int, string, int)"/> instead. <br/>
        /// Note that internal data is cleared when the Subscription is 
        /// unsubscribed from.<br/>
        /// Returns null if no value has been received yet for the specified item/field pair.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time; if called 
        /// to retrieve a value that has not been received yet, then it will return null.
        /// </summary>
        /// <param name="itemPos"> the 1-based position of an item within the configured "Item Group"
        /// or "Item List" </param>
        /// <param name="fieldPos"> the 1-based position of a field within the configured "Field Schema"
        /// or "Field List" </param>
        /// <returns> the current value for the specified field of the specified item
        /// (possibly null), or null if no value has been received yet.
        /// </returns>
        public virtual string getValue(int itemPos, int fieldPos)
        {
          return _delegate.getValue(itemPos, fieldPos);
        }
        /// <summary>
        /// Returns the latest value received for the specified item/field pair.<br/>
        /// It is suggested to consume real-time data by implementing and adding
        /// a proper <seealso cref="SubscriptionListener"/> rather than probing this method.<br/>
        /// In case of COMMAND Subscriptions, the value returned by this
        /// method may be misleading, as in COMMAND mode all the keys received, being
        /// part of the same item, will overwrite each other; for COMMAND Subscriptions,
        /// use <seealso cref="Subscription.getCommandValue(string, string, int)"/> instead.<br/>
        /// Note that internal data is cleared when the Subscription is 
        /// unsubscribed from.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time; if called 
        /// to retrieve a value that has not been received yet, then it will return null.
        /// </summary>
        /// <param name="itemName"> an item in the configured "Item List" </param>
        /// <param name="fieldPos"> the 1-based position of a field within the configured "Field Schema"
        /// or "Field List" </param>
        /// <returns> the current value for the specified field of the specified item
        /// (possibly null), or null if no value has been received yet.
        /// </returns>
        public virtual string getValue(string itemName, int fieldPos)
        {
          return _delegate.getValue(itemName, fieldPos);
        }

        /// <summary>
        /// Returns the latest value received for the specified item/field pair.<br/>
        /// It is suggested to consume real-time data by implementing and adding
        /// a proper <seealso cref="SubscriptionListener"/> rather than probing this method.<br/>
        /// In case of COMMAND Subscriptions, the value returned by this
        /// method may be misleading, as in COMMAND mode all the keys received, being
        /// part of the same item, will overwrite each other; for COMMAND Subscriptions,
        /// use <seealso cref="Subscription.getCommandValue(int, string, string)"/> instead.<br/>
        /// Note that internal data is cleared when the Subscription is 
        /// unsubscribed from.<br/>
        /// <br/>
        /// <b>Lifecycle:</b>  This method can be called at any time; if called 
        /// to retrieve a value that has not been received yet, then it will return null. </summary>
        /// <param name="itemPos"> the 1-based position of an item within the configured "Item Group"
        /// or "Item List" </param>
        /// <param name="fieldName"> a field in the configured "Field List" </param>
        /// <returns> the current value for the specified field of the specified item
        /// (possibly null), or null if no value has been received yet.
        /// </returns>
        public virtual string getValue(int itemPos, string fieldName)
        {
          return _delegate.getValue(itemPos, fieldName);
        }
        /// <summary>
        /// Returns the latest value received for the specified item/key/field combination. 
        /// This method can only be used if the Subscription mode is COMMAND. 
        /// Subscriptions with two-level behavior
        /// are also supported, hence the specified field 
        /// (see <seealso cref="Subscription.CommandSecondLevelFields"/> and <seealso cref="Subscription.CommandSecondLevelFieldSchema"/>)
        /// can be either a first-level or a second-level one. <br/>
        /// It is suggested to consume real-time data by implementing and adding a proper 
        /// <seealso cref="SubscriptionListener"/> rather than probing this method.<br/>
        /// Note that internal data is cleared when the Subscription is unsubscribed from.
        /// </summary>
        /// <param name="itemName"> an item in the configured "Item List" </param>
        /// <param name="keyValue"> the value of a key received on the COMMAND subscription. </param>
        /// <param name="fieldName"> a field in the configured "Field List" </param>
        /// <returns> the current value for the specified field of the specified key within the 
        /// specified item (possibly null), or null if the specified key has not been added yet 
        /// (note that it might have been added and then deleted). </returns>
        public virtual string getCommandValue(string itemName, string keyValue, string fieldName)
        {
          return _delegate.getCommandValue(itemName, keyValue, fieldName);
        }

        /// <summary>
        /// Returns the latest value received for the specified item/key/field combination. 
        /// This method can only be used if the Subscription mode is COMMAND. 
        /// Subscriptions with two-level behavior
        /// (see <seealso cref="Subscription.CommandSecondLevelFields"/> and <seealso cref="Subscription.CommandSecondLevelFieldSchema"/>)
        /// are also supported, hence the specified field 
        /// can be either a first-level or a second-level one. <br/>
        /// It is suggested to consume real-time data by implementing and adding a proper 
        /// <seealso cref="SubscriptionListener"/> rather than probing this method. <br/>
        /// Note that internal data is cleared when the Subscription is unsubscribed from.
        /// </summary>
        /// <param name="itemPos"> the 1-based position of an item within the configured "Item Group"
        /// or "Item List" </param>
        /// <param name="keyValue"> the value of a key received on the COMMAND subscription. </param>
        /// <param name="fieldPos"> the 1-based position of a field within the configured "Field Schema"
        /// or "Field List" </param>
        /// <returns> the current value for the specified field of the specified key within the 
        /// specified item (possibly null), or null if the specified key has not been added yet 
        /// (note that it might have been added and then deleted). </returns>
        public virtual string getCommandValue(int itemPos, string keyValue, int fieldPos)
        {
          return _delegate.getCommandValue(itemPos, keyValue, fieldPos);
        }

        /// <summary>
        /// Returns the latest value received for the specified item/key/field combination. 
        /// This method can only be used if the Subscription mode is COMMAND. 
        /// Subscriptions with two-level behavior
        /// (see <seealso cref="Subscription.CommandSecondLevelFields"/> and <seealso cref="Subscription.CommandSecondLevelFieldSchema"/>)
        /// are also supported, hence the specified field 
        /// can be either a first-level or a second-level one.<br/>
        /// It is suggested to consume real-time data by implementing and adding a proper 
        /// <seealso cref="SubscriptionListener"/> rather than probing this method.<br/>
        /// Note that internal data is cleared when the Subscription is unsubscribed from.
        /// </summary>
        /// <param name="itemPos"> the 1-based position of an item within the configured "Item Group"
        /// or "Item List" </param>
        /// <param name="keyValue"> the value of a key received on the COMMAND subscription. </param>
        /// <param name="fieldName"> a field in the configured "Field List" </param>
        /// <returns> the current value for the specified field of the specified key within the 
        /// specified item (possibly null), or null if the specified key has not been added yet 
        /// (note that it might have been added and then deleted). </returns>
        public virtual string getCommandValue(int itemPos, string keyValue, string fieldName)
        {
          return _delegate.getCommandValue(itemPos, keyValue, fieldName);
        }

        /// <summary>
        /// Returns the latest value received for the specified item/key/field combination. 
        /// This method can only be used if the Subscription mode is COMMAND. 
        /// Subscriptions with two-level behavior
        /// (see <seealso cref="Subscription.CommandSecondLevelFields"/> and <seealso cref="Subscription.CommandSecondLevelFieldSchema"/>)
        /// are also supported, hence the specified field 
        /// can be either a first-level or a second-level one.<br/>
        /// It is suggested to consume real-time data by implementing and adding a proper 
        /// <seealso cref="SubscriptionListener"/> rather than probing this method.<br/>
        /// Note that internal data is cleared when the Subscription is unsubscribed from.
        /// </summary>
        /// <param name="itemName"> an item in the configured "Item List" </param>
        /// <param name="keyValue"> the value of a key received on the COMMAND subscription. </param>
        /// <param name="fieldPos"> the 1-based position of a field within the configured "Field Schema"
        /// or "Field List" </param>
        /// <returns> the current value for the specified field of the specified key within the 
        /// specified item (possibly null), or null if the specified key has not been added yet 
        /// (note that it might have been added and then deleted). </returns>
        public virtual string getCommandValue(string itemName, string keyValue, int fieldPos)
        {
          return _delegate.getCommandValue(itemName, keyValue, fieldPos);
        }
    }
}