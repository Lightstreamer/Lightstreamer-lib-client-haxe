# Copyright (C) 2023 Lightstreamer Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
class ClientListener:
  """Interface to be implemented to listen to :class:`.LightstreamerClient` events comprehending notifications of 
 connection activity and errors. 

 Events for these listeners are dispatched by a different thread than the one that generates them. 
 This means that, upon reception of an event, it is possible that the internal state of the client has changed.
 On the other hand, all the notifications for a single LightstreamerClient, including notifications to
 :class:`ClientListener`, :class:`SubscriptionListener` and :class:`ClientMessageListener` will be dispatched by the 
 same thread.
  """

  def onStatusChange(self,status):
    """Event handler that receives a notification each time the LightstreamerClient status has changed. The status changes 
   may be originated either by custom actions (e.g. by calling :meth:`.LightstreamerClient.disconnect`) or by internal 
   actions.

   The normal cases are the following:
    
     * After issuing connect() when the current status is ``DISCONNECTED*``, the client will switch to ``CONNECTING`` first and to ``CONNECTED:STREAM-SENSING`` as soon as the pre-flight request receives its answer. As soon as the new session is established, it will switch to ``CONNECTED:WS-STREAMING`` if the environment permits WebSockets; otherwise it will switch to ``CONNECTED:HTTP-STREAMING`` if the environment permits streaming or to ``CONNECTED:HTTP-POLLING`` as a last resort.
     * On the other hand, after issuing connect when the status is already ``CONNECTED:*`` a switch to ``CONNECTING`` is usually not needed and the current session is kept.
     * After issuing :meth:`.LightstreamerClient.disconnect`, the status will switch to ``DISCONNECTED``.
     * In case of a server connection refusal, the status may switch from ``CONNECTING`` directly to ``DISCONNECTED``. After that, the :meth:`onServerError` event handler will be invoked.
   
   Possible special cases are the following:
   
     * In case of Server unavailability during streaming, the status may switch from ``CONNECTED:*-STREAMING`` to ``STALLED`` (see :meth:`.ConnectionOptions.setStalledTimeout`). If the unavailability ceases, the status will switch back to ``CONNECTED:*-STREAMING``; otherwise, if the unavailability persists (see :meth:`.ConnectionOptions.setReconnectTimeout`), the status will switch to ``DISCONNECTED:TRYING-RECOVERY`` and eventually to ``CONNECTED:*-STREAMING``.
     * In case the connection or the whole session is forcibly closed by the Server, the status may switch from ``CONNECTED:*-STREAMING`` or ``CONNECTED:*-POLLING`` directly to ``DISCONNECTED``. After that, the :meth:`onServerError` event handler will be invoked.
     * Depending on the setting in :meth:`.ConnectionOptions.setSlowingEnabled`, in case of slow update processing, the status may switch from ``CONNECTED:WS-STREAMING`` to ``CONNECTED:WS-POLLING`` or from ``CONNECTED:HTTP-STREAMING`` to ``CONNECTED:HTTP-POLLING``.
     * If the status is ``CONNECTED:*-POLLING`` and any problem during an intermediate poll occurs, the status may switch to ``CONNECTING`` and eventually to ``CONNECTED:*-POLLING``. The same may hold for the ``CONNECTED:*-STREAMING`` case, when a rebind is needed.
     * In case a forced transport was set through :meth:`.ConnectionOptions.setForcedTransport`, only the related final status or statuses are possible.
     * In case of connection problems, the status may switch from any value to ``DISCONNECTED:WILL-RETRY`` (see :meth:`.ConnectionOptions.setRetryDelay`), then to ``CONNECTING`` and a new attempt will start. However, in most cases, the client will try to recover the current session; hence, the ``DISCONNECTED:TRYING-RECOVERY`` status will be entered and the recovery attempt will start.
     * In case of connection problems during a recovery attempt, the status may stay in ``DISCONNECTED:TRYING-RECOVERY`` for long time, while further attempts are made. If the recovery is no longer possible, the current session will be abandoned and the status will switch to ``DISCONNECTED:WILL-RETRY`` before the next attempts.
   
   By setting a custom handler it is possible to perform actions related to connection and disconnection occurrences. 
   Note that :meth:`.LightstreamerClient.connect` and :meth:`.LightstreamerClient.disconnect`, as any other method, can 
   be issued directly from within a handler.
   
   :param status: The new status. It can be one of the following values:
   
     * ``CONNECTING`` the client has started a connection attempt and is waiting for a Server answer.
     * ``CONNECTED:STREAM-SENSING`` the client received a first response from the server and is now evaluating if a streaming connection is fully functional.
     * ``CONNECTED:WS-STREAMING`` a streaming connection over WebSocket has been established.
     * ``CONNECTED:HTTP-STREAMING`` a streaming connection over HTTP has been established.
     * ``CONNECTED:WS-POLLING`` a polling connection over WebSocket has been started. Note that, unlike polling over HTTP, in this case only one connection is actually opened (see :meth:`.ConnectionOptions.setSlowingEnabled`).
     * ``CONNECTED:HTTP-POLLING`` a polling connection over HTTP has been started.
     * ``STALLED`` a streaming session has been silent for a while, the status will eventually return to its previous ``CONNECTED:*-STREAMING`` status or will switch to ``DISCONNECTED:WILL-RETRY`` / ``DISCONNECTED:TRYING-RECOVERY``.
     * ``DISCONNECTED:WILL-RETRY`` a connection or connection attempt has been closed; a new attempt will be performed (possibly after a timeout).
     * ``DISCONNECTED:TRYING-RECOVERY`` a connection has been closed and the client has started a connection attempt and is waiting for a Server answer; if successful, the underlying session will be kept.
     * ``DISCONNECTED`` a connection or connection attempt has been closed. The client will not connect anymore until a new :meth:`.LightstreamerClient.connect` call is issued.
     
   .. seealso:: :meth:`.LightstreamerClient.connect`
   .. seealso:: :meth:`.LightstreamerClient.disconnect`
   .. seealso:: :meth:`.LightstreamerClient.getStatus`
   """
    pass

  def onServerError(self,code,message):
    """Event handler that is called when the Server notifies a refusal on the client attempt to open
   a new connection or the interruption of a streaming connection.
   In both cases, the :meth:`onStatusChange` event handler has already been invoked
   with a "DISCONNECTED" status and no recovery attempt has been performed.
   By setting a custom handler, however, it is possible to override this and perform custom recovery actions.
   
   :param errorCode: The error code. It can be one of the following:
   
     * 1 - user/password check failed
     * 2 - requested Adapter Set not available
     * 7 - licensed maximum number of sessions reached (this can only happen with some licenses)
     * 8 - configured maximum number of sessions reached
     * 9 - configured maximum server load reached
     * 10 - new sessions temporarily blocked
     * 11 - streaming is not available because of Server license restrictions (this can only happen with special licenses).
     * 21 - a request for this session has unexpectedly reached a wrong Server instance, which suggests that a routing issue may be in place.
     * 30-41 - the current connection or the whole session has been closed by external agents; the possible cause may be:
       
       * The session was closed on the Server side (via software or by the administrator) (32), or through a client "destroy" request (31);
       * The Metadata Adapter imposes limits on the overall open sessions for the current user and has requested the closure of the current session upon opening of a new session for the same user on a different browser window (35);
       * An unexpected error occurred on the Server while the session was in activity (33, 34);
       * An unknown or unexpected cause; any code different from the ones identified in the above cases could be issued. A detailed description for the specific cause is currently not supplied (i.e. errorMessage is None in this case).
     
     * 60 - this version of the client is not allowed by the current license terms.
     * 61 - there was an error in the parsing of the server response thus the client cannot continue with the current session.
     * 66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection.
     * 68 - the Server could not open or continue with the session because of an internal error.
     * 70 - an unusable port was configured on the server address.
     * 71 - this kind of client is not allowed by the current license terms.
     * <= 0 - the Metadata Adapter has refused the user connection; the code value is dependent on the specific Metadata Adapter implementation
   
   :param errorMessage: The description of the error as sent by the Server.
   
   .. seealso:: :meth:`onStatusChange`
   .. seealso:: :meth:`.ConnectionDetails.setAdapterSet`
   """
    pass

  def onPropertyChange(self,property):
    """Event handler that receives a notification each time  the value of a property of :attr:`.LightstreamerClient.connectionDetails` or :attr:`.LightstreamerClient.connectionOptions` is changed.

  Properties of these objects can be modified by direct calls to them or
  by server sent events.
   
  :param property: the name of the changed property.
    
    Possible values are:
  
      * adapterSet
      * serverAddress
      * user
      * password
      * contentLength
      * requestedMaxBandwidth
      * reverseHeartbeatInterval
      * httpExtraHeaders
      * httpExtraHeadersOnSessionCreationOnly
      * forcedTransport
      * retryDelay
      * firstRetryMaxDelay
      * sessionRecoveryTimeout
      * stalledTimeout
      * reconnectTimeout
      * slowingEnabled
      * serverInstanceAddressIgnored
      * cookieHandlingRequired
      * proxy
      * serverInstanceAddress
      * serverSocketName
      * clientIp
      * sessionId
      * realMaxBandwidth
      * idleTimeout
      * keepaliveInterval
      * pollingInterval
   
  .. seealso:: :attr:`.LightstreamerClient.connectionDetails`
  .. seealso:: :attr:`.LightstreamerClient.connectionOptions`
  """
    pass

  def onListenEnd(self):
    """Event handler that receives a notification when the ClientListener instance is removed from a LightstreamerClient 
   through :meth:`.LightstreamerClient.removeListener`. This is the last event to be fired on the listener.
   """
    pass

  def onListenStart(self):
    """Event handler that receives a notification when the ClientListener instance is added to a LightstreamerClient 
   through :meth:`.LightstreamerClient.addListener`. This is the first event to be fired on the listener.
   """
    pass

class ClientMessageListener:
  """Interface to be implemented to listen to :meth:`.LightstreamerClient.sendMessage` events reporting a message processing outcome. 
 Events for these listeners are dispatched by a different thread than the one that generates them.
 All the notifications for a single LightstreamerClient, including notifications to
 :class:`ClientListener`, :class:`SubscriptionListener` and :class:`ClientMessageListener` will be dispatched by the 
 same thread.
 Only one event per message is fired on this listener.
 """

  def onProcessed(self,msg,response):
    """Event handler that is called by Lightstreamer when the related message has been processed by the Server with success.

   :param originalMessage: the message to which this notification is related.
   :param response: the response from the Metadata Adapter. If not supplied (i.e. supplied as null), an empty message is received here.
   """
    pass

  def onDeny(self,msg,code,error):
    """Event handler that is called by Lightstreamer when the related message has been processed by the Server but the 
   expected processing outcome could not be achieved for any reason.

   :param originalMessage: the message to which this notification is related.
   :param code: the error code sent by the Server. It can be one of the following:
          
          * <= 0 - the Metadata Adapter has refused the message; the code value is dependent on the specific Metadata Adapter implementation.

   :param error: the description of the error sent by the Server.
   """
    pass

  def onAbort(self,msg,sentOnNetwork):
    """Event handler that is called by Lightstreamer when any notifications of the processing outcome of the related 
   message haven't been received yet and can no longer be received. Typically, this happens after the session 
   has been closed. In this case, the client has no way of knowing the processing outcome and any outcome is possible.

   :param originalMessage: the message to which this notification is related.
   :param sentOnNetwork: true if the message was sent on the network, false otherwise. Even if the flag is true, it is not possible to infer whether the message actually reached the Lightstreamer Server or not.
    """
    pass

  def onDiscarded(self,msg):
    """Event handler that is called by Lightstreamer to notify that the related message has been discarded by the Server.
   This means that the message has not reached the Metadata Adapter and the message next in the sequence is considered 
   enabled for processing.

   :param originalMessage: the message to which this notification is related.
   """
    pass

  def onError(self,msg):
    """Event handler that is called by Lightstreamer when the related message has been processed by the Server but the processing has failed for any reason. The level of completion of the processing by the Metadata Adapter cannot be determined.

   :param originalMessage: the message to which this notification is related.
   """
    pass

class SubscriptionListener:
  """Interface to be implemented to listen to :class:`.Subscription` events comprehending notifications of subscription/unsubscription, 
 updates, errors and others. 

 Events for these listeners are dispatched by a different thread than the one that generates them. 
 This means that, upon reception of an event, it is possible that the internal state of the client has changed.
 On the other hand, all the notifications for a single LightstreamerClient, including notifications to
 :class:`ClientListener`, :class:`SubscriptionListener` and :class:`ClientMessageListener` will be dispatched by the 
 same thread.
 """

  def onSubscription(self):
    """Event handler that is called by Lightstreamer to notify that a Subscription has been successfully subscribed 
   to through the Server. This can happen multiple times in the life of a Subscription instance, in case the 
   Subscription is performed multiple times through :meth:`.LightstreamerClient.unsubscribe` and 
   :meth:`.LightstreamerClient.subscribe`. This can also happen multiple times in case of automatic 
   recovery after a connection restart. 
 
   This notification is always issued before the other ones related to the same subscription. It invalidates all 
   data that has been received previously. 

   Note that two consecutive calls to this method are not possible, as before a second onSubscription event is 
   fired an :meth:`onUnsubscription` event is eventually fired. 
 
   If the involved Subscription has a two-level behavior enabled
   (see :meth:`.Subscription.setCommandSecondLevelFields` and :meth:`.Subscription.setCommandSecondLevelFieldSchema`), second-level subscriptions are not notified.
   """
    pass
  
  def onSubscriptionError(self,code,message):
    """Event handler that is called when the Server notifies an error on a Subscription. By implementing this method it 
   is possible to perform recovery actions. 

   Note that, in order to perform a new subscription attempt, :meth:`.LightstreamerClient.unsubscribe`
   and :meth:`.LightstreamerClient.subscribe` should be issued again, even if no change to the Subscription 
   attributes has been applied.

   :param code: The error code sent by the Server. It can be one of the following:
          
            * 15 - "key" field not specified in the schema for a COMMAND mode subscription
            * 16 - "command" field not specified in the schema for a COMMAND mode subscription
            * 17 - bad Data Adapter name or default Data Adapter not defined for the current Adapter Set
            * 21 - bad Group name
            * 22 - bad Group name for this Schema
            * 23 - bad Schema name
            * 24 - mode not allowed for an Item
            * 25 - bad Selector name
            * 26 - unfiltered dispatching not allowed for an Item, because a frequency limit is associated to the item
            * 27 - unfiltered dispatching not supported for an Item, because a frequency prefiltering is applied for the item
            * 28 - unfiltered dispatching is not allowed by the current license terms (for special licenses only)
            * 29 - RAW mode is not allowed by the current license terms (for special licenses only)
            * 30 - subscriptions are not allowed by the current license terms (for special licenses only)
            * 61 - there was an error in the parsing of the server response
            * 66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection
            * 68 - the Server could not fulfill the request because of an internal error.
            * <= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the code value is dependent on the specific Metadata Adapter implementation
          
   :param message: The description of the error sent by the Server; it can be None.
   
   .. seealso:: :meth:`.ConnectionDetails.setAdapterSet`
   """
    pass

  def onUnsubscription(self):
    """Event handler that is called by Lightstreamer to notify that a Subscription has been successfully unsubscribed 
   from. This can happen multiple times in the life of a Subscription instance, in case the Subscription is performed 
   multiple times through :meth:`.LightstreamerClient.unsubscribe` and 
   :meth:`.LightstreamerClient.subscribe`. This can also happen multiple times in case of automatic 
   recovery after a connection restart. 

   After this notification no more events can be received until a new #onSubscription event. 
 
   Note that two consecutive calls to this method are not possible, as before a second onUnsubscription event 
   is fired an :meth:`onSubscription` event is eventually fired. 
 
   If the involved Subscription has a two-level behavior enabled
   (see :meth:`.Subscription.setCommandSecondLevelFields` and :meth:`.Subscription.setCommandSecondLevelFieldSchema`)
   , second-level unsubscriptions are not notified.
   """
    pass

  def onClearSnapshot(self,itemName,itemPos):
    """Event handler that is called by Lightstreamer each time a request to clear the snapshot pertaining to an item 
   in the Subscription has been received from the Server. More precisely, this kind of request can occur in two cases:
   
     * For an item delivered in COMMAND mode, to notify that the state of the item becomes empty; this is equivalent to receiving an update carrying a DELETE command once for each key that is currently active.
     * For an item delivered in DISTINCT mode, to notify that all the previous updates received for the item should be considered as obsolete; hence, if the listener were showing a list of recent updates for the item, it should clear the list in order to keep a coherent view.
   
   Note that, if the involved Subscription has a two-level behavior enabled
   (see :meth:`.Subscription.setCommandSecondLevelFields` and :meth:`.Subscription.setCommandSecondLevelFieldSchema`)
   , the notification refers to the first-level item (which is in COMMAND mode).
   This kind of notification is not possible for second-level items (which are in MERGE 
   mode).
   
   :param itemName: name of the involved item. If the Subscription was initialized using an "Item Group" then a None value is supplied.
   :param itemPos: 1-based position of the item within the "Item List" or "Item Group".
   """
    pass

  def onItemUpdate(self,update):
    """Event handler that is called by Lightstreamer each time an update pertaining to an item in the Subscription
   has been received from the Server.
   
   :param itemUpdate: a value object containing the updated values for all the fields, together with meta-information about the update itself and some helper methods that can be used to iterate through all or new values.
   """
    pass

  def onEndOfSnapshot(self,itemName,itemPos):
    """Event handler that is called by Lightstreamer to notify that all snapshot events for an item in the 
   Subscription have been received, so that real time events are now going to be received. The received 
   snapshot could be empty. Such notifications are sent only if the items are delivered in DISTINCT or COMMAND 
   subscription mode and snapshot information was indeed requested for the items. By implementing this 
   method it is possible to perform actions which require that all the initial values have been received. 

   Note that, if the involved Subscription has a two-level behavior enabled
   (see :meth:`.Subscription.setCommandSecondLevelFields` and :meth:`.Subscription.setCommandSecondLevelFieldSchema`)
   , the notification refers to the first-level item (which is in COMMAND mode).
   Snapshot-related updates for the second-level items 
   (which are in MERGE mode) can be received both before and after this notification.
   
   :param itemName: name of the involved item. If the Subscription was initialized using an "Item Group" then a 
          None value is supplied.
   :param itemPos: 1-based position of the item within the "Item List" or "Item Group".
   
   .. seealso:: :meth:`.Subscription.setRequestedSnapshot`
   .. seealso:: :meth:`ItemUpdate.isSnapshot`
   """
    pass

  def onItemLostUpdates(self,itemName,itemPos,lostUpdates):
    """Event handler that is called by Lightstreamer to notify that, due to internal resource limitations, 
   Lightstreamer Server dropped one or more updates for an item in the Subscription. 
   Such notifications are sent only if the items are delivered in an unfiltered mode; this occurs if the 
   subscription mode is:
   
     * RAW
     * MERGE or DISTINCT, with unfiltered dispatching specified
     * COMMAND, with unfiltered dispatching specified
     * COMMAND, without unfiltered dispatching specified (in this case, notifications apply to ADD and DELETE events only)
   
   By implementing this method it is possible to perform recovery actions.
   
   :param itemName: name of the involved item. If the Subscription was initialized using an "Item Group" then a None value is supplied.
   :param itemPos: 1-based position of the item within the "Item List" or "Item Group".
   :param lostUpdates: The number of consecutive updates dropped for the item.
   
   .. seealso:: :meth:`.Subscription.setRequestedMaxFrequency`
   """
    pass

  def onRealMaxFrequency(self,frequency):
    """Event handler that is called by Lightstreamer to notify the client with the real maximum update frequency of the Subscription. 
   It is called immediately after the Subscription is established and in response to a requested change
   (see :meth:`.Subscription.setRequestedMaxFrequency`).
   Since the frequency limit is applied on an item basis and a Subscription can involve multiple items,
   this is actually the maximum frequency among all items. For Subscriptions with two-level behavior
   (see :meth:`.Subscription.setCommandSecondLevelFields` and :meth:`.Subscription.setCommandSecondLevelFieldSchema`)
   , the reported frequency limit applies to both first-level and second-level items. 

   The value may differ from the requested one because of restrictions operated on the server side,
   but also because of number rounding. 

   Note that a maximum update frequency (that is, a non-unlimited one) may be applied by the Server
   even when the subscription mode is RAW or the Subscription was done with unfiltered dispatching.
   
   :param frequency:  A decimal number, representing the maximum frequency applied by the Server (expressed in updates per second), or the string "unlimited". A None value is possible in rare cases, when the frequency can no longer be determined.
   """
    pass

  def onCommandSecondLevelSubscriptionError(self,code,message,key):
    """Event handler that is called when the Server notifies an error on a second-level subscription. 
 
   By implementing this method it is possible to perform recovery actions.
   
   :param code: The error code sent by the Server. It can be one of the following:
          
            * 14 - the key value is not a valid name for the Item to be subscribed; only in this case, the error is detected directly by the library before issuing the actual request to the Server
            * 17 - bad Data Adapter name or default Data Adapter not defined for the current Adapter Set
            * 21 - bad Group name
            * 22 - bad Group name for this Schema
            * 23 - bad Schema name
            * 24 - mode not allowed for an Item
            * 26 - unfiltered dispatching not allowed for an Item, because a frequency limit is associated to the item
            * 27 - unfiltered dispatching not supported for an Item, because a frequency prefiltering is applied for the item
            * 28 - unfiltered dispatching is not allowed by the current license terms (for special licenses only)
            * 66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection
            * 68 - the Server could not fulfill the request because of an internal error.
            * <= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the code value is dependent on the specific Metadata Adapter implementation

   :param message: The description of the error sent by the Server; it can be None.
   :param key: The value of the key that identifies the second-level item.
   
   .. seealso:: :meth:`.ConnectionDetails.setAdapterSet`
   .. seealso:: :meth:`.Subscription.setCommandSecondLevelFields`
   .. seealso:: :meth:`.Subscription.setCommandSecondLevelFieldSchema`
    """
    pass

  def onCommandSecondLevelItemLostUpdates(self,lostUpdates,key):
    """Event handler that is called by Lightstreamer to notify that, due to internal resource limitations, 
   Lightstreamer Server dropped one or more updates for an item that was subscribed to as a second-level subscription. 
   Such notifications are sent only if the Subscription was configured in unfiltered mode (second-level items are 
   always in "MERGE" mode and inherit the frequency configuration from the first-level Subscription). 
 
   By implementing this method it is possible to perform recovery actions.
   
   :param lostUpdates: The number of consecutive updates dropped for the item.
   :param key: The value of the key that identifies the second-level item.
   
   .. seealso:: :meth:`.Subscription.setRequestedMaxFrequency`
   .. seealso:: :meth:`.Subscription.setCommandSecondLevelFields`
   .. seealso:: :meth:`.Subscription.setCommandSecondLevelFieldSchema`
   """
    pass

  def onListenEnd(self):
    """Event handler that receives a notification when the SubscriptionListener instance is removed from a Subscription 
   through :meth:`.Subscription.removeListener`. This is the last event to be fired on the listener.
   """
    pass

  def onListenStart(self):
    """Event handler that receives a notification when the SubscriptionListener instance is added to a Subscription through :meth:`.Subscription.addListener`. This is the first event to be fired on the listener.
   """
    pass

class ItemUpdate:
  """Contains all the information related to an update of the field values for an item. 
 It reports all the new values of the fields. 

 
 **COMMAND Subscription**

 If the involved Subscription is a COMMAND Subscription, then the values for the current 
 update are meant as relative to the same key. 

 Moreover, if the involved Subscription has a two-level behavior enabled, then each update 
 may be associated with either a first-level or a second-level item. In this case, the reported 
 fields are always the union of the first-level and second-level fields and each single update 
 can only change either the first-level or the second-level fields (but for the "command" field, 
 which is first-level and is always set to "UPDATE" upon a second-level update); note 
 that the second-level field values are always None until the first second-level update 
 occurs). When the two-level behavior is enabled, in all methods where a field name has to 
 be supplied, the following convention should be followed:

  * The field name can always be used, both for the first-level and the second-level fields. In case of name conflict, the first-level field is meant.
  * The field position can always be used; however, the field positions for the second-level fields start at the highest position of the first-level field list + 1. If a field schema had been specified for either first-level or second-level Subscriptions, then client-side knowledge of the first-level schema length would be required.
 """

  def getItemName(self):
    """Inquiry method that retrieves the name of the item to which this update pertains. 
 
   The name will be None if the related Subscription was initialized using an "Item Group".

   :return: The name of the item to which this update pertains.

   .. seealso:: :meth:`.Subscription.setItemGroup`
   .. seealso:: :meth:`.Subscription.setItems`
   """
    pass

  def getItemPos(self):
    """Inquiry method that retrieves the position in the "Item List" or "Item Group" of the item to which this update pertains.

   :return: The 1-based position of the item to which this update pertains.

   .. seealso:: :meth:`.Subscription.setItemGroup`
   .. seealso:: :meth:`.Subscription.setItems`
    """
    pass

  def isSnapshot(self):
    """Inquiry method that asks whether the current update belongs to the item snapshot (which carries the current item state at the time of Subscription). Snapshot events are sent only if snapshot information was requested for the items through :meth:`.Subscription.setRequestedSnapshot` and precede the real time events. Snapshot information take different forms in different subscription modes and can be spanned across zero, one or several update events. In particular:
   
  * if the item is subscribed to with the RAW subscription mode, then no snapshot is sent by the Server;
  * if the item is subscribed to with the MERGE subscription mode, then the snapshot consists of exactly one event, carrying the current value for all fields;
  * if the item is subscribed to with the DISTINCT subscription mode, then the snapshot consists of some of the most recent updates; these updates are as many as specified through :meth:`.Subscription.setRequestedSnapshot`, unless fewer are available;
  * if the item is subscribed to with the COMMAND subscription mode, then the snapshot consists of an "ADD" event for each key that is currently present.
   
  Note that, in case of two-level behavior, snapshot-related updates for both the first-level item (which is in COMMAND mode) and any second-level items (which are in MERGE mode) are qualified with this flag.

  :return: true if the current update event belongs to the item snapshot; false otherwise.
    """
    pass

  def getValue(self,fieldNameOrPos):
    """Inquiry method that gets the value for a specified field, as received from the Server with the current or previous update.

  :raises IllegalArgumentException: if the specified field is not part of the Subscription.

  :param fieldNameOrPos: The field name or the 1-based position of the field within the "Field List" or "Field Schema".

  :return: The value of the specified field; it can be None in the following cases:
  
    * a None value has been received from the Server, as None is a possible value for a field;
    * no value has been received for the field yet;
    * the item is subscribed to with the COMMAND mode and a DELETE command is received (only the fields used to carry key and command information are valued).
  
  .. seealso:: :meth:`.Subscription.setFieldSchema`
  .. seealso:: :meth:`.Subscription.setFields`
    """
    pass

  def isValueChanged(self,fieldNameOrPos):
    """Inquiry method that asks whether the value for a field has changed after the reception of the last update from the Server for an item. If the Subscription mode is COMMAND then the change is meant as relative to the same key.
        
  :param fieldNameOrPos: The field name or the 1-based position of the field within the field list or field schema.
        
  :return: Unless the Subscription mode is COMMAND, the return value is true in the following cases:
        
    * It is the first update for the item;
    * the new field value is different than the previous field value received for the item.
        
    If the Subscription mode is COMMAND, the return value is true in the following cases:
        
      * it is the first update for the involved key value (i.e. the event carries an "ADD" command);
      * the new field value is different than the previous field value received for the item, relative to the same key value (the event must carry an "UPDATE" command);
      * the event carries a "DELETE" command (this applies to all fields other than the field used to carry key information).
        
    In all other cases, the return value is false.
        
  :raises IllegalArgumentException: if the specified field is not part of the Subscription.
    """
    pass

  def getValueAsJSONPatchIfAvailable(self,fieldNameOrPos):
    """Inquiry method that gets the difference between the new value and the previous one as a JSON Patch structure, provided that the Server has used the JSON Patch format to send this difference, as part of the "delta delivery" mechanism. This, in turn, requires that:
    
    * the Data Adapter has explicitly indicated JSON Patch as the privileged type of compression for this field;
    * both the previous and new value are suitable for the JSON Patch computation (i.e. they are valid JSON representations);
    * the item was subscribed to in MERGE or DISTINCT mode (note that, in case of two-level behavior, this holds for all fields related with second-level items, as these items are in MERGE mode);
    * sending the JSON Patch difference has been evaluated by the Server as more efficient than sending the full new value.
        
Note that the last condition can be enforced by leveraging the Server's <jsonpatch_min_length> configuration flag, so that the availability of the JSON Patch form would only depend on the Client and the Data Adapter.
    
When the above conditions are not met, the method just returns None; in this case, the new value can only be determined through :meth:`ItemUpdate.getValue`. For instance, this will always be needed to get the first value received.
        
:raises IllegalArgumentException: if the specified field is not part of the Subscription.
        
:param fieldNameOrPos: The field name or the 1-based position of the field within the "Field List" or "Field Schema".
        
:return: A JSON Patch structure representing the difference between the new value and the previous one, or None if the difference in JSON Patch format is not available for any reason.
        
.. seealso:: :meth:`ItemUpdate.getValue`
    """
    pass

  def getChangedFields(self):
    """Returns a map containing the values for each field changed with the last server update. 
   The related field name is used as key for the values in the map. 
   Note that if the Subscription mode of the involved Subscription is COMMAND, then changed fields 
   are meant as relative to the previous update for the same key. On such tables if a DELETE command 
   is received, all the fields, excluding the key field, will be present as changed, with None value. 
   All of this is also true on tables that have the two-level behavior enabled, but in case of 
   DELETE commands second-level fields will not be iterated.
   
   :raises IllegalStateException: if the Subscription was initialized using a field schema.
   
   :return: A map containing the values for each field changed with the last server update.
   
   .. seealso:: :meth:`.Subscription.setFieldSchema`
   .. seealso:: :meth:`.Subscription.setFields`
   """
    pass

  def getChangedFieldsByPosition(self):
    """Returns a map containing the values for each field changed with the last server update. 
   The 1-based field position within the field schema or field list is used as key for the values in the map. 
   Note that if the Subscription mode of the involved Subscription is COMMAND, then changed fields 
   are meant as relative to the previous update for the same key. On such tables if a DELETE command 
   is received, all the fields, excluding the key field, will be present as changed, with None value. 
   All of this is also true on tables that have the two-level behavior enabled, but in case of 
   DELETE commands second-level fields will not be iterated.
   
   :return: A map containing the values for each field changed with the last server update.
   
   .. seealso:: :meth:`.Subscription.setFieldSchema`
   .. seealso:: :meth:`.Subscription.setFields`
   """
    pass

  def getFields(self):
    """Returns a map containing the values for each field in the Subscription.
   The related field name is used as key for the values in the map. 
   
   :raises IllegalStateException: if the Subscription was initialized using a field schema.
   
   :return: A map containing the values for each field in the Subscription.
   
   .. seealso:: :meth:`.Subscription.setFieldSchema`
   .. seealso:: :meth:`.Subscription.setFields`
   """
    pass

  def getFieldsByPosition(self):
    """Returns a map containing the values for each field in the Subscription.
   The 1-based field position within the field schema or field list is used as key for the values in the map. 
   
   :return: A map containing the values for each field in the Subscription.
   
   .. seealso:: :meth:`.Subscription.setFieldSchema`
   .. seealso:: :meth:`.Subscription.setFields`
   """
    pass

class LoggerProvider:
  """Simple interface to be implemented to provide custom log consumers to the library. 

 An instance of the custom implemented class has to be passed to the library through the 
 :meth:`.LightstreamerClient.setLoggerProvider`."""
  
  def getLogger(self, category):
    """Request for a Logger instance that will be used for logging occuring on the given 
     category. It is suggested, but not mandatory, that subsequent calls to this method
     related to the same category return the same Logger instance.
     
     :param category: the log category all messages passed to the given Logger instance will pertain to.
     
     :return: A Logger instance that will receive log lines related to the given category.
    """
    pass

class Logger:
  """Interface to be implemented to consume log from the library.

 Instances of implemented classes are obtained by the library through the LoggerProvider instance set on :meth:`.LightstreamerClient.setLoggerProvider`.
  """

  def fatal(self,line,exception = None):
    """Receives log messages at Fatal level and a related exception.
     
    :param line: The message to be logged.
     
    :param exception: An Exception instance related to the current log message.
    """
    pass

  def error(self,line,exception = None):
    """Receives log messages at Error level.
     
    :param line: The message to be logged.

    :param exception: An Exception instance related to the current log message.
    """
    pass

  def warn(self,line,exception = None):
    """Receives log messages at Warn level and a related exception.
     
    :param line: The message to be logged.
     
    :param exception: An Exception instance related to the current log message.
    """
    pass

  def info(self,line,exception = None):
    """Receives log messages at Info level and a related exception.
     
    :param line: The message to be logged.
     
    :param exception: An Exception instance related to the current log message.
    """
    pass

  def debug(self,line,exception = None):
    """Receives log messages at Debug level and a related exception.
     
    :param line: The message to be logged.
     
    :param exception: An Exception instance related to the current log message.
    """
    pass

  def trace(self,line,exception = None):
    """Receives log messages at Trace level and a related exception.
     
    :param line: The message to be logged.
     
    :param exception: An Exception instance related to the current log message.
    """
    pass

  def isFatalEnabled(self):
    """Checks if this logger is enabled for the Fatal level. 

     The property should be true if this logger is enabled for Fatal events, false otherwise. 
 
     This property is intended to lessen the computational cost of disabled log Fatal statements. Note 
     that even if the property is false, Fatal log lines may be received anyway by the Fatal methods.
     """
    pass

  def isErrorEnabled(self):
    """Checks if this logger is enabled for the Error level. 

     The property should be true if this logger is enabled for Error events, false otherwise. 
 
     This property is intended to lessen the computational cost of disabled log Error statements. Note 
     that even if the property is false, Error log lines may be received anyway by the Error methods.
     """
    pass

  def isWarnEnabled(self):
    """Checks if this logger is enabled for the Warn level. 

     The property should be true if this logger is enabled for Warn events, false otherwise. 
 
     This property is intended to lessen the computational cost of disabled log Warn statements. Note 
     that even if the property is false, Warn log lines may be received anyway by the Warn methods.
     """
    pass

  def isInfoEnabled(self):
    """Checks if this logger is enabled for the Info level. 

     The property should be true if this logger is enabled for Info events, false otherwise. 
 
     This property is intended to lessen the computational cost of disabled log Info statements. Note 
     that even if the property is false, Info log lines may be received anyway by the Info methods.
     """
    pass

  def isDebugEnabled(self):
    """Checks if this logger is enabled for the Debug level. 

     The property should be true if this logger is enabled for Debug events, false otherwise. 
 
     This property is intended to lessen the computational cost of disabled log Debug statements. Note 
     that even if the property is false, Debug log lines may be received anyway by the Debug methods.
     """
    pass

  def isTraceEnabled(self):
    """Checks if this logger is enabled for the Trace level. 

     The property should be true if this logger is enabled for Trace events, false otherwise. 
 
     This property is intended to lessen the computational cost of disabled log Trace statements. Note 
     that even if the property is false, Trace log lines may be received anyway by the Trace methods.
     """
    pass
