class ClientListener:
  """Interface to be implemented to listen to :class:`LightstreamerClient` events comprehending notifications of 
 connection activity and errors. 

 Events for these listeners are dispatched by a different thread than the one that generates them. 
 This means that, upon reception of an event, it is possible that the internal state of the client has changed.
 On the other hand, all the notifications for a single LightstreamerClient, including notifications to
 :class:`ClientListener`, :class:`SubscriptionListener` and :class:`ClientMessageListener` will be dispatched by the 
 same thread.
  """

  def onStatusChange(self,status):
    """Event handler that receives a notification each time the LightstreamerClient status has changed. The status changes 
   may be originated either by custom actions (e.g. by calling :meth:`LightstreamerClient.disconnect`) or by internal 
   actions.

   The normal cases are the following:
    
     * After issuing connect() when the current status is ``DISCONNECTED*``, the client will switch to ``CONNECTING`` first and to ``CONNECTED:STREAM-SENSING`` as soon as the pre-flight request receives its answer. As soon as the new session is established, it will switch to ``CONNECTED:WS-STREAMING`` if the environment permits WebSockets; otherwise it will switch to ``CONNECTED:HTTP-STREAMING`` if the environment permits streaming or to ``CONNECTED:HTTP-POLLING`` as a last resort.
     * On the other hand, after issuing connect when the status is already ``CONNECTED:*`` a switch to ``CONNECTING`` is usually not needed and the current session is kept.
     * After issuing :meth:`LightstreamerClient.disconnect`, the status will switch to ``DISCONNECTED``.
     * In case of a server connection refusal, the status may switch from ``CONNECTING`` directly to ``DISCONNECTED``. After that, the :meth:`onServerError` event handler will be invoked.
   
   Possible special cases are the following:
   
     * In case of Server unavailability during streaming, the status may switch from ``CONNECTED:*-STREAMING`` to ``STALLED`` (see :meth:`ConnectionOptions.setStalledTimeout`). If the unavailability ceases, the status will switch back to ``CONNECTED:*-STREAMING``; otherwise, if the unavailability persists (see :meth:`ConnectionOptions.setReconnectTimeout`), the status will switch to ``DISCONNECTED:TRYING-RECOVERY`` and eventually to ``CONNECTED:*-STREAMING``.
     * In case the connection or the whole session is forcibly closed by the Server, the status may switch from ``CONNECTED:*-STREAMING`` or ``CONNECTED:*-POLLING`` directly to ``DISCONNECTED``. After that, the :meth:`onServerError` event handler will be invoked.
     * Depending on the setting in :meth:`ConnectionOptions.setSlowingEnabled`, in case of slow update processing, the status may switch from ``CONNECTED:WS-STREAMING`` to ``CONNECTED:WS-POLLING`` or from ``CONNECTED:HTTP-STREAMING`` to ``CONNECTED:HTTP-POLLING``.
     * If the status is ``CONNECTED:*-POLLING`` and any problem during an intermediate poll occurs, the status may switch to ``CONNECTING`` and eventually to ``CONNECTED:*-POLLING``. The same may hold for the ``CONNECTED:*-STREAMING`` case, when a rebind is needed.
     * In case a forced transport was set through :meth:`ConnectionOptions.setForcedTransport`, only the related final status or statuses are possible.
     * In case of connection problems, the status may switch from any value to ``DISCONNECTED:WILL-RETRY`` (see :meth:`ConnectionOptions.setRetryDelay`), then to ``CONNECTING`` and a new attempt will start. However, in most cases, the client will try to recover the current session; hence, the ``DISCONNECTED:TRYING-RECOVERY`` status will be entered and the recovery attempt will start.
     * In case of connection problems during a recovery attempt, the status may stay in ``DISCONNECTED:TRYING-RECOVERY`` for long time, while further attempts are made. If the recovery is no longer possible, the current session will be abandoned and the status will switch to ``DISCONNECTED:WILL-RETRY`` before the next attempts.
   
   By setting a custom handler it is possible to perform actions related to connection and disconnection occurrences. 
   Note that :meth:`LightstreamerClient.connect` and :meth:`LightstreamerClient.disconnect`, as any other method, can 
   be issued directly from within a handler.
   
   :param status: The new status. It can be one of the following values:
   
     * ``CONNECTING`` the client has started a connection attempt and is waiting for a Server answer.
     * ``CONNECTED:STREAM-SENSING`` the client received a first response from the server and is now evaluating if a streaming connection is fully functional.
     * ``CONNECTED:WS-STREAMING`` a streaming connection over WebSocket has been established.
     * ``CONNECTED:HTTP-STREAMING`` a streaming connection over HTTP has been established.
     * ``CONNECTED:WS-POLLING`` a polling connection over WebSocket has been started. Note that, unlike polling over HTTP, in this case only one connection is actually opened (see :meth:`ConnectionOptions.setSlowingEnabled`).
     * ``CONNECTED:HTTP-POLLING`` a polling connection over HTTP has been started.
     * ``STALLED`` a streaming session has been silent for a while, the status will eventually return to its previous ``CONNECTED:*-STREAMING`` status or will switch to ``DISCONNECTED:WILL-RETRY`` / ``DISCONNECTED:TRYING-RECOVERY``.
     * ``DISCONNECTED:WILL-RETRY`` a connection or connection attempt has been closed; a new attempt will be performed (possibly after a timeout).
     * ``DISCONNECTED:TRYING-RECOVERY`` a connection has been closed and the client has started a connection attempt and is waiting for a Server answer; if successful, the underlying session will be kept.
     * ``DISCONNECTED`` a connection or connection attempt has been closed. The client will not connect anymore until a new :meth:`LightstreamerClient.connect` call is issued.
     
   .. seealso:: :meth:`LightstreamerClient.connect`
   .. seealso:: :meth:`LightstreamerClient.disconnect`
   .. seealso:: :meth:`LightstreamerClient.getStatus`
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
       * An unknown or unexpected cause; any code different from the ones identified in the above cases could be issued. A detailed description for the specific cause is currently not supplied (i.e. errorMessage is null in this case).
     
     * 60 - this version of the client is not allowed by the current license terms.
     * 61 - there was an error in the parsing of the server response thus the client cannot continue with the current session.
     * 66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection.
     * 68 - the Server could not open or continue with the session because of an internal error.
     * 71 - this kind of client is not allowed by the current license terms.
     * <= 0 - the Metadata Adapter has refused the user connection; the code value is dependent on the specific Metadata Adapter implementation
   
   :param errorMessage: The description of the error as sent by the Server.
   
   .. seealso:: :meth:`onStatusChange`
   .. seealso:: :meth:`ConnectionDetails.setAdapterSet`
   """
    pass

  def onPropertyChange(self,property):
    """Event handler that receives a notification each time  the value of a property of :meth:`LightstreamerClient.connectionDetails` or :meth:`LightstreamerClient.connectionOptions` is changed.

  Properties of these objects can be modified by direct calls to them or
  by server sent events.
   
  :param property: the name of the changed property.
  
  Possible values are:

  
  * adapterSet
  * serverAddress
  * user
  * password
  * serverInstanceAddress
  * serverSocketName
  * clientIp
  * sessionId
  * contentLength
  * idleTimeout
  * keepaliveInterval
  * requestedMaxBandwidth
  * realMaxBandwidth
  * pollingInterval
  * reconnectTimeout
  * stalledTimeout
  * retryDelay
  * firstRetryMaxDelay
  * slowingEnabled
  * forcedTransport
  * serverInstanceAddressIgnored
  * reverseHeartbeatInterval
  * earlyWSOpenEnabled
  * httpExtraHeaders
  * httpExtraHeadersOnSessionCreationOnly
  
  
   
  .. seealso:: :meth:`LightstreamerClient.connectionDetails`
  .. seealso:: :meth:`LightstreamerClient.connectionOptions`
  """
    pass

  def onListenEnd(self,client):
    """Event handler that receives a notification when the ClientListener instance is removed from a LightstreamerClient 
   through :meth:`LightstreamerClient.removeListener`. This is the last event to be fired on the listener.
   :param client: the LightstreamerClient this instance was removed from. 
   """
    pass

  def onListenStart(self,client):
    """Event handler that receives a notification when the ClientListener instance is added to a LightstreamerClient 
   through :meth:`LightstreamerClient.addListener`. This is the first event to be fired on the listener.
   :param client: the LightstreamerClient this instance was added to.
   """
    pass

class ClientMessageListener:
  """Interface to be implemented to listen to :meth:`LightstreamerClient.sendMessage` events reporting a message processing outcome. 
 Events for these listeners are dispatched by a different thread than the one that generates them.
 All the notifications for a single LightstreamerClient, including notifications to
 :class:`ClientListener`, :class:`SubscriptionListener` and :class:`ClientMessageListener` will be dispatched by the 
 same thread.
 Only one event per message is fired on this listener.
 """

  def onProcessed(self,msg):
    """Event handler that is called by Lightstreamer when the related message has been processed by the Server with success.

   :param originalMessage: the message to which this notification is related.
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
  """Interface to be implemented to listen to :class:`Subscription` events comprehending notifications of subscription/unsubscription, 
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
   Subscription is performed multiple times through :meth:`LightstreamerClient.unsubscribe` and 
   :meth:`LightstreamerClient.subscribe`. This can also happen multiple times in case of automatic 
   recovery after a connection restart. 
 
   This notification is always issued before the other ones related to the same subscription. It invalidates all 
   data that has been received previously. 

   Note that two consecutive calls to this method are not possible, as before a second onSubscription event is 
   fired an :meth:`onUnsubscription` event is eventually fired. 
 
   If the involved Subscription has a two-level behavior enabled
   (see :meth:`Subscription.setCommandSecondLevelFields` and :meth:`Subscription.setCommandSecondLevelFieldSchema`), second-level subscriptions are not notified.
   """
    pass
  
  def onSubscriptionError(self,code,message):
    """Event handler that is called when the Server notifies an error on a Subscription. By implementing this method it 
   is possible to perform recovery actions. 

   Note that, in order to perform a new subscription attempt, :meth:`LightstreamerClient.unsubscribe`
   and :meth:`LightstreamerClient.subscribe` should be issued again, even if no change to the Subscription 
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
            * 66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection
            * 68 - the Server could not fulfill the request because of an internal error.
            * <= 0 - the Metadata Adapter has refused the subscription or unsubscription request; the code value is dependent on the specific Metadata Adapter implementation
          
   :param message: The description of the error sent by the Server; it can be null.
   
   .. seealso:: :meth:`ConnectionDetails.setAdapterSet`
   """
    pass

  def onUnsubscription(self):
    """Event handler that is called by Lightstreamer to notify that a Subscription has been successfully unsubscribed 
   from. This can happen multiple times in the life of a Subscription instance, in case the Subscription is performed 
   multiple times through :meth:`LightstreamerClient.unsubscribe` and 
   :meth:`LightstreamerClient.subscribe`. This can also happen multiple times in case of automatic 
   recovery after a connection restart. 

   After this notification no more events can be received until a new #onSubscription event. 
 
   Note that two consecutive calls to this method are not possible, as before a second onUnsubscription event 
   is fired an :meth:`onSubscription` event is eventually fired. 
 
   If the involved Subscription has a two-level behavior enabled
   (see :meth:`Subscription.setCommandSecondLevelFields` and :meth:`Subscription.setCommandSecondLevelFieldSchema`)
   , second-level unsubscriptions are not notified.
   """
    pass

  def onClearSnapshot(self,itemName,itemPos):
    """Event handler that is called by Lightstreamer each time a request to clear the snapshot pertaining to an item 
   in the Subscription has been received from the Server. More precisely, this kind of request can occur in two cases:
   
     * For an item delivered in COMMAND mode, to notify that the state of the item becomes empty; this is equivalent to receiving an update carrying a DELETE command once for each key that is currently active.
     * For an item delivered in DISTINCT mode, to notify that all the previous updates received for the item should be considered as obsolete; hence, if the listener were showing a list of recent updates for the item, it should clear the list in order to keep a coherent view.
   
   Note that, if the involved Subscription has a two-level behavior enabled
   (see :meth:`Subscription.setCommandSecondLevelFields` and :meth:`Subscription.setCommandSecondLevelFieldSchema`)
   , the notification refers to the first-level item (which is in COMMAND mode).
   This kind of notification is not possible for second-level items (which are in MERGE 
   mode).
   
   :param itemName: name of the involved item. If the Subscription was initialized using an "Item Group" then a null value is supplied.
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
   (see :meth:`Subscription.setCommandSecondLevelFields` and :meth:`Subscription.setCommandSecondLevelFieldSchema`)
   , the notification refers to the first-level item (which is in COMMAND mode).
   Snapshot-related updates for the second-level items 
   (which are in MERGE mode) can be received both before and after this notification.
   
   :param itemName: name of the involved item. If the Subscription was initialized using an "Item Group" then a 
          null value is supplied.
   :param itemPos: 1-based position of the item within the "Item List" or "Item Group".
   
   .. seealso:: :meth:`Subscription.setRequestedSnapshot`
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
   
   :param itemName: name of the involved item. If the Subscription was initialized using an "Item Group" then a null value is supplied.
   :param itemPos: 1-based position of the item within the "Item List" or "Item Group".
   :param lostUpdates: The number of consecutive updates dropped for the item.
   
   .. seealso:: :meth:`Subscription.setRequestedMaxFrequency`
   """
    pass

  def onRealMaxFrequency(self,frequency):
    """Event handler that is called by Lightstreamer to notify the client with the real maximum update frequency of the Subscription. 
   It is called immediately after the Subscription is established and in response to a requested change
   (see :meth:`Subscription.setRequestedMaxFrequency`).
   Since the frequency limit is applied on an item basis and a Subscription can involve multiple items,
   this is actually the maximum frequency among all items. For Subscriptions with two-level behavior
   (see :meth:`Subscription.setCommandSecondLevelFields` and :meth:`Subscription.setCommandSecondLevelFieldSchema`)
   , the reported frequency limit applies to both first-level and second-level items. 

   The value may differ from the requested one because of restrictions operated on the server side,
   but also because of number rounding. 

   Note that a maximum update frequency (that is, a non-unlimited one) may be applied by the Server
   even when the subscription mode is RAW or the Subscription was done with unfiltered dispatching.
   
   :param frequency:  A decimal number, representing the maximum frequency applied by the Server (expressed in updates per second), or the string "unlimited". A null value is possible in rare cases, when the frequency can no longer be determined.
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

   :param message: The description of the error sent by the Server; it can be null.
   :param key: The value of the key that identifies the second-level item.
   
   .. seealso:: :meth:`ConnectionDetails.setAdapterSet`
   .. seealso:: :meth:`Subscription.setCommandSecondLevelFields`
   .. seealso:: :meth:`Subscription.setCommandSecondLevelFieldSchema`
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
   
   .. seealso:: :meth:`Subscription.setRequestedMaxFrequency`
   .. seealso:: :meth:`Subscription.setCommandSecondLevelFields`
   .. seealso:: :meth:`Subscription.setCommandSecondLevelFieldSchema`
   """
    pass

  def onListenEnd(self,subscription):
    """Event handler that receives a notification when the SubscriptionListener instance is removed from a Subscription 
   through :meth:`Subscription.removeListener`. This is the last event to be fired on the listener.
   
   :param subscription: the Subscription this instance was removed from.
   """
    pass

  def onListenStart(self,subscription):
    """Event handler that receives a notification when the SubscriptionListener instance is added to a Subscription through :meth:`Subscription.addListener`. This is the first event to be fired on the listener.

   :param subscription: the Subscription this instance was added to.
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
 that the second-level field values are always null until the first second-level update 
 occurs). When the two-level behavior is enabled, in all methods where a field name has to 
 be supplied, the following convention should be followed:

  * The field name can always be used, both for the first-level and the second-level fields. In case of name conflict, the first-level field is meant.
  * The field position can always be used; however, the field positions for the second-level fields start at the highest position of the first-level field list + 1. If a field schema had been specified for either first-level or second-level Subscriptions, then client-side knowledge of the first-level schema length would be required.
 """

  def getItemName(self):
    """Inquiry method that retrieves the name of the item to which this update pertains. 
 
   The name will be null if the related Subscription was initialized using an "Item Group".

   :return: The name of the item to which this update pertains.

   .. seealso:: :meth:`Subscription.setItemGroup`
   .. seealso:: :meth:`Subscription.setItems`
   """
    pass

  def getItemPos(self):
    """Inquiry method that retrieves the position in the "Item List" or "Item Group" of the item to which this update pertains.

   :return: The 1-based position of the item to which this update pertains.

   .. seealso:: :meth:`Subscription.setItemGroup`
   .. seealso:: :meth:`Subscription.setItems`
    """
    pass

  def isSnapshot(self):
    """Inquiry method that asks whether the current update belongs to the item snapshot (which carries the current item state at the time of Subscription). Snapshot events are sent only if snapshot information was requested for the items through :meth:`Subscription.setRequestedSnapshot` and precede the real time events. Snapshot information take different forms in different subscription modes and can be spanned across zero, one or several update events. In particular:
   
  * if the item is subscribed to with the RAW subscription mode, then no snapshot is sent by the Server;
  * if the item is subscribed to with the MERGE subscription mode, then the snapshot consists of exactly one event, carrying the current value for all fields;
  * if the item is subscribed to with the DISTINCT subscription mode, then the snapshot consists of some of the most recent updates; these updates are as many as specified through :meth:`Subscription.setRequestedSnapshot`, unless fewer are available;
  * if the item is subscribed to with the COMMAND subscription mode, then the snapshot consists of an "ADD" event for each key that is currently present.
   
  Note that, in case of two-level behavior, snapshot-related updates for both the first-level item (which is in COMMAND mode) and any second-level items (which are in MERGE mode) are qualified with this flag.

  :return: true if the current update event belongs to the item snapshot; false otherwise.
    """
    pass

  def getValue(self,fieldNameOrPos):
    """Inquiry method that gets the value for a specified field, as received from the Server with the current or previous update.

  :raises IllegalArgumentException: if the specified field is not part of the Subscription.

  :param fieldNameOrPos: The field name or the 1-based position of the field within the "Field List" or "Field Schema".

  :return: The value of the specified field; it can be null in the following cases:
  
    * a null value has been received from the Server, as null is a possible value for a field;
    * no value has been received for the field yet;
    * the item is subscribed to with the COMMAND mode and a DELETE command is received (only the fields used to carry key and command information are valued).
  
  .. seealso:: :meth:`Subscription.setFieldSchema`
  .. seealso:: :meth:`Subscription.setFields`
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
    
When the above conditions are not met, the method just returns null; in this case, the new value can only be determined through :meth:`ItemUpdate.getValue`. For instance, this will always be needed to get the first value received.
        
:raises IllegalArgumentException: if the specified field is not part of the Subscription.
        
:param fieldNameOrPos: The field name or the 1-based position of the field within the "Field List" or "Field Schema".
        
:return: A JSON Patch structure representing the difference between the new value and the previous one, or null if the difference in JSON Patch format is not available for any reason.
        
.. seealso:: :meth:`ItemUpdate.getValue`
    """
    pass

  def getChangedFields(self):
    """Returns a map containing the values for each field changed with the last server update. 
   The related field name is used as key for the values in the map. 
   Note that if the Subscription mode of the involved Subscription is COMMAND, then changed fields 
   are meant as relative to the previous update for the same key. On such tables if a DELETE command 
   is received, all the fields, excluding the key field, will be present as changed, with null value. 
   All of this is also true on tables that have the two-level behavior enabled, but in case of 
   DELETE commands second-level fields will not be iterated.
   
   :raises IllegalStateException: if the Subscription was initialized using a field schema.
   
   :return: A map containing the values for each field changed with the last server update.
   
   .. seealso:: :meth:`Subscription.setFieldSchema`
   .. seealso:: :meth:`Subscription.setFields`
   """
    pass

  def getChangedFieldsByPosition(self):
    """Returns a map containing the values for each field changed with the last server update. 
   The 1-based field position within the field schema or field list is used as key for the values in the map. 
   Note that if the Subscription mode of the involved Subscription is COMMAND, then changed fields 
   are meant as relative to the previous update for the same key. On such tables if a DELETE command 
   is received, all the fields, excluding the key field, will be present as changed, with null value. 
   All of this is also true on tables that have the two-level behavior enabled, but in case of 
   DELETE commands second-level fields will not be iterated.
   
   :return: A map containing the values for each field changed with the last server update.
   
   .. seealso:: :meth:`Subscription.setFieldSchema`
   .. seealso:: :meth:`Subscription.setFields`
   """
    pass

  def getFields(self):
    """Returns a map containing the values for each field in the Subscription.
   The related field name is used as key for the values in the map. 
   
   :raises IllegalStateException: if the Subscription was initialized using a field schema.
   
   :return: A map containing the values for each field in the Subscription.
   
   .. seealso:: :meth:`Subscription.setFieldSchema`
   .. seealso:: :meth:`Subscription.setFields`
   """
    pass

  def getFieldsByPosition(self):
    """Returns a map containing the values for each field in the Subscription.
   The 1-based field position within the field schema or field list is used as key for the values in the map. 
   
   :return: A map containing the values for each field in the Subscription.
   
   .. seealso:: :meth:`Subscription.setFieldSchema`
   .. seealso:: :meth:`Subscription.setFields`
   """
    pass

class LoggerProvider:
  """Simple interface to be implemented to provide custom log consumers to the library. 

 An instance of the custom implemented class has to be passed to the library through the 
 :meth:`LightstreamerClient.setLoggerProvider`."""
  
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

 Instances of implemented classes are obtained by the library through the LoggerProvider instance set on :meth:`LightstreamerClient.setLoggerProvider`.
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

class ConnectionDetails:
    """Used by LightstreamerClient to provide a basic connection properties data object.
 
 Data object that contains the configuration settings needed
 to connect to a Lightstreamer Server. 

 An instance of this class is attached to every :class:`LightstreamerClient`
 as :meth:`LightstreamerClient.connectionDetails`

 
 .. seealso:: :class:`LightstreamerClient`
    """

    def __init__(self,client):
      pass

    def getServerAddress(self):
      """Inquiry method that gets the configured address of Lightstreamer Server.
   
   :return: the serverAddress the configured address of Lightstreamer Server.
   """
      pass

    def setServerAddress(self,serverAddress):
      """Setter method that sets the address of Lightstreamer Server. 
 
   Note that the addresses specified must always have the http: or https: scheme. In case WebSockets are used, 
   the specified scheme is internally converted to match the related WebSocket protocol (i.e. http becomes ws 
   while https becomes wss).
   
   **general edition note** WSS/HTTPS is an optional feature, available depending on Edition and License Type.
   To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
   available at /dashboard).
   
   **default** if no server address is supplied the client will be unable to connect.
   
   **lifecycle** This method can be called at any time. If called while connected, it will be applied when the next 
   session creation request is issued. This setting can also be specified in the :class:`LightstreamerClient`
   constructor.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "serverAddress" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param serverAddress: The full address of Lightstreamer Server. A null value can also be used, to restore the default value. 
   An IPv4 or IPv6 can also be used in place of a hostname. Some examples of valid values include: ::
    
    http://push.mycompany.com
    http://push.mycompany.com:8080
    http://79.125.7.252
    http://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]
    http://[2001:0db8:85a3::8a2e:0370:7334]:8080
   
   :raises IllegalArgumentException: if the given address is not valid.
      """
      pass

    def getAdapterSet(self):
      """Inquiry method that gets the name of the Adapter Set (which defines the Metadata Adapter and one or several 
   Data Adapters) mounted on Lightstreamer Server that supply all the items used in this application.
   
   :return: the adapterSet the name of the Adapter Set; returns null if no name has been configured, that 
   means that the "DEFAULT" Adapter Set is used.
   
   .. seealso:: :meth:`setAdapterSet`
      """
      pass

    def setAdapterSet(self,adapterSet):
      """Setter method that sets the name of the Adapter Set mounted on Lightstreamer Server to be used to handle 
   all requests in the session. 
 
   An Adapter Set defines the Metadata Adapter and one or several Data Adapters. It is configured on the 
   server side through an "adapters.xml" file; the name is configured through the "id" attribute in 
   the <adapters_conf> element.
   
   **default** The default Adapter Set, configured as "DEFAULT" on the Server.
   
   **lifecycle** The Adapter Set name should be set on the :meth:`LightstreamerClient.connectionDetails` object 
   before calling the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: 
   the supplied value will be used for the next time a new session is requested to the server. 

   This setting can also be specified in the :class:`LightstreamerClient` constructor.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "adapterSet" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param adapterSet: The name of the Adapter Set to be used. A null value is equivalent to the "DEFAULT" name.
      """
      pass

    def getUser(self):
      """ Inquiry method that gets the username to be used for the authentication on Lightstreamer Server when 
   initiating the session.
   
   :return: the username to be used for the authentication on Lightstreamer Server; returns null if no 
   user name has been configured.
   """
      pass

    def setUser(self,user):
      """Setter method that sets the username to be used for the authentication on Lightstreamer Server when initiating
   the session. The Metadata Adapter is responsible for checking the credentials (username and password).
   
   **default** If no username is supplied, no user information will be sent at session initiation. 
   The Metadata Adapter, however, may still allow the session.
   
   **lifecycle** The username should be set on the :meth:`LightstreamerClient.connectionDetails` object before 
   calling the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the 
   supplied value will be used for the next time a new session is requested to the server.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "user" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param user: The username to be used for the authentication on Lightstreamer Server. The username can be null.
   
   .. seealso:: :meth:`setPassword`
   """
      pass

    def setPassword(self,password):
      """Setter method that sets the password to be used for the authentication on Lightstreamer Server when initiating 
   the session. The Metadata Adapter is responsible for checking the credentials (username and password).
   
   **default**  If no password is supplied, no password information will be sent at session initiation. 
   The Metadata Adapter, however, may still allow the session.
   
   **lifecycle** The username should be set on the :meth:`LightstreamerClient.connectionDetails` object before calling 
   the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the supplied 
   value will be used for the next time a new session is requested to the server. 

   NOTE: The password string will be stored in the current instance. That is necessary in order to allow 
   automatic reconnection/reauthentication for fail-over. For maximum security, avoid using an actual private 
   password to authenticate on Lightstreamer Server; rather use a session-id originated by your web/application 
   server, that can be checked by your Metadata Adapter.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "password" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param password: The password to be used for the authentication on Lightstreamer Server. 
          The password can be null.
          
   .. seealso:: :meth:`setUser`
      """
      pass

    def getSessionId(self):
      """Inquiry method that gets the ID associated by the server to this client session.
   
   **lifecycle** The method gives a meaningful answer only when a session is currently active.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "sessionId" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return: ID assigned by the Server to this client session."""
      pass

    def getServerInstanceAddress(self):
      """Inquiry method that gets the server address to be used to issue all requests related to the current session. 
   In fact, when a Server cluster is in place, the Server address specified through :meth:`setServerAddress` can 
   identify various Server instances; in order to ensure that all requests related to a session are issued to 
   the same Server instance, the Server can answer to the session opening request by providing an address which 
   uniquely identifies its own instance. When this is the case, this address is returned by the method; otherwise,
   null is returned. 
 
   Note that the addresses will always have the http: or https: scheme. In case WebSockets are used, the specified 
   scheme is internally converted to match the related WebSocket protocol (i.e. http becomes ws while 
   https becomes wss).
   
   **general edition note** Server Clustering is an optional feature, available depending on Edition and License Type.
   To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
   available at /dashboard).
   
   **lifecycle** The method gives a meaningful answer only when a session is currently active.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "serverInstanceAddress" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return: address used to issue all requests related to the current session.
   """
      pass

    def getServerSocketName(self):
      """ Inquiry method that gets the instance name of the Server which is serving the current session. To be more precise, 
   each answering port configured on a Server instance (through a <http_server> or <https_server> element in the 
   Server configuration file) can be given a different name; the name related to the port to which the session 
   opening request has been issued is returned. 
 
   Note that each rebind to the same session can, potentially, reach the Server on a port different than the one
   used for the previous request, depending on the behavior of intermediate nodes. However, the only meaningful case
   is when a Server cluster is in place and it is configured in such a way that the port used for all bind_session requests
   differs from the port used for the initial create_session request.
   
   **general edition note** Server Clustering is an optional feature, available depending on Edition and License Type.
   To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).
   
   **lifecycle** If a session is not currently active, null is returned;
   soon after a session is established, the value will become available.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "serverSocketName" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return: name configured for the Server instance which is managing the current session, or null.
   """
      pass

    def getClientIp(self):
      """Inquiry method that gets the IP address of this client as seen by the Server which is serving
   the current session as the client remote address (note that it may not correspond to the client host;
   for instance it may refer to an intermediate proxy). If, upon a new session, this address changes,
   it may be a hint that the intermediary network nodes handling the connection have changed, hence the network
   capabilities may be different. The library uses this information to optimize the connection. 
  
   Note that in case of polling or in case rebind requests are needed, subsequent requests related to the same 
   session may, in principle, expose a different IP address to the Server; these changes would not be reported.
   
   **lifecycle** If a session is not currently active, null is returned;
   soon after a session is established, the value may become available; but it is possible
   that this information is not provided by the Server and that it will never be available.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "clientIp" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return:  A canonical representation of an IP address (it can be either IPv4 or IPv6), or null.
   """
      pass

class ConnectionOptions:
  """Used by LightstreamerClient to provide an extra connection properties data object.

 Data object that contains the policy settings used to connect to a Lightstreamer Server. 

 An instance of this class is attached to every :class:`LightstreamerClient`
 as :meth:`LightstreamerClient.connectionOptions`

 .. seealso:: :class:`LightstreamerClient`
 """

  def __init__(self,client):
    pass

  def getContentLength(self):
    """Inquiry method that gets the length expressed in bytes to be used by the Server for the response body on a HTTP stream connection.

   :return: The length to be used by the Server for the response body on a HTTP stream connection
   .. seealso:: :meth:`setContentLength`
   """
    pass

  def setContentLength(self,contentLength):
    """Setter method that sets the length in bytes to be used by the Server for the response body on a stream connection 
   (a minimum length, however, is ensured by the server). After the content length exhaustion, the connection will
   be closed and a new bind connection will be automatically reopened.

   NOTE that this setting only applies to the "HTTP-STREAMING" case (i.e. not to WebSockets).
   
   **default** A length decided by the library, to ensure the best performance.
   It can be of a few MB or much higher, depending on the environment.
   
   **lifecycle** The content length should be set before calling 
   the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the supplied value will 
   be used for the next streaming connection (either a bind or a brand new session).
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "contentLength" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param contentLength: The length to be used by the Server for the response body on a HTTP stream connection.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   """
    pass

  def getFirstRetryMaxDelay(self):
    """Inquiry method that gets the maximum time to wait before trying a new connection to the Server in case the previous one is unexpectedly closed while correctly working.

   :return: The max time (in milliseconds) to wait before trying a new connection.

   .. seealso:: :meth:`setFirstRetryMaxDelay`
   """
    pass

  def setFirstRetryMaxDelay(self,firstRetryMaxDelay):
    """Setter method that sets the maximum time to wait before trying a new connection to the Server
   in case the previous one is unexpectedly closed while correctly working.
   The new connection may be either the opening of a new session or an attempt to recovery
   the current session, depending on the kind of interruption. 

   The actual delay is a randomized value between 0 and this value. 
   This randomization might help avoid a load spike on the cluster due to simultaneous reconnections, should one of 
   the active servers be stopped. Note that this delay is only applied before the first reconnection: should such 
   reconnection fail, only the setting of :meth:`setRetryDelay` will be applied.
   
   **default** 100 (0.1 seconds)
   
   **lifecycle** This value can be set and changed at any time.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "firstRetryMaxDelay" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param firstRetryMaxDelay: The max time (in milliseconds) to wait before trying a new connection.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   """
    pass

  def getForcedTransport(self):
    """Inquiry method that gets the value of the forced transport (if any).

   :return: The forced transport or null

   .. seealso:: :meth:`setForcedTransport`
   """
    pass

  def setForcedTransport(self,forcedTransport):
    """Setter method that can be used to disable/enable the Stream-Sense algorithm and to force the client to use a fixed 
   transport or a fixed combination of a transport and a connection type. When a combination is specified the 
   Stream-Sense algorithm is completely disabled. 

   The method can be used to switch between streaming and polling connection types and between 
   HTTP and WebSocket transports. 

   In some cases, the requested status may not be reached, because of connection or environment problems. In that case 
   the client will continuously attempt to reach the configured status. 

   Note that if the Stream-Sense algorithm is disabled, the client may still enter the "CONNECTED:STREAM-SENSING" status; 
   however, in that case, if it eventually finds out that streaming is not possible, no recovery will be tried.
   
   **default** null (full Stream-Sense enabled).
   
   **lifecycle** This method can be called at any time. If called while the client is connecting or connected it will instruct 
   to switch connection type to match the given configuration.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "forcedTransport" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param forcedTransport: can be one of the following: 
   
    * null: the Stream-Sense algorithm is enabled and the client will automatically connect using the most appropriate transport and connection type among those made possible by the environment.
    * "WS": the Stream-Sense algorithm is enabled as in the null case but the client will only use WebSocket based connections. If a connection over WebSocket is not possible because of the environment the client will not connect at all.
    * "HTTP": the Stream-Sense algorithm is enabled as in the null case but the client will only use HTTP based connections. If a connection over HTTP is not possible because of the environment the client will not connect at all.
    * "WS-STREAMING": the Stream-Sense algorithm is disabled and the client will only connect on Streaming over WebSocket. If Streaming over WebSocket is not possible because of the environment the client will not connect at all.
    * "HTTP-STREAMING": the Stream-Sense algorithm is disabled and the client will only connect on Streaming over HTTP. If Streaming over HTTP is not possible because of the browser/environment the client will not connect at all.
    * "WS-POLLING": the Stream-Sense algorithm is disabled and the client will only connect on Polling over WebSocket. If Polling over WebSocket is not possible because of the environment the client will not connect at all.
    * "HTTP-POLLING": the Stream-Sense algorithm is disabled and the client will only connect on Polling over HTTP. If Polling over HTTP is not possible because of the environment the client will not connect at all.
   
   :raises IllegalArgumentException: if the given value is not in the list of the admitted ones.
   """
    pass

  def getHttpExtraHeaders(self):
    """ Inquiry method that gets the Map object containing the extra headers to be sent to the server.

   :return: The Map object containing the extra headers to be sent

   .. seealso:: :meth:`setHttpExtraHeaders`
   .. seealso:: :meth:`setHttpExtraHeadersOnSessionCreationOnly`
   """
    pass

  def setHttpExtraHeaders(self,httpExtraHeaders):
    """Setter method that enables/disables the setting of extra HTTP headers to all the request performed to the Lightstreamer server by the client. 

Note that the Content-Type header is reserved by the client library itself, while other headers might be refused by the environment and others might cause the connection to the server to fail.
   
For instance, you cannot use this method to specify custom cookies to be sent to Lightstreamer Server; leverage :meth:`LightstreamerClient.addCookies` instead.
The use of custom headers might also cause the
client to send an OPTIONS request to the server before opening the actual connection. 
   
**default** null (meaning no extra headers are sent).
   
**lifecycle** This setting should be performed before calling the
:meth:`LightstreamerClient.connect` method. However, the value can be changed
at any time: the supplied value will be used for the next HTTP request or WebSocket establishment.
   
**notification** A change to this setting will be notified through a call to 
:meth:`ClientListener.onPropertyChange` with argument "httpExtraHeaders" on any 
ClientListener listening to the related LightstreamerClient.
   
:param httpExtraHeaders: a Map object containing header-name header-value pairs. Null can be specified to avoid extra headers to be sent.
   """
    pass

  def getIdleTimeout(self):
    """Inquiry method that gets the maximum time the Server is allowed to wait for any data to be sent 
   in response to a polling request, if none has accumulated at request time. The wait time used 
   by the Server, however, may be different, because of server side restrictions.

   :return: The time (in milliseconds) the Server is allowed to wait for data to send upon polling requests.

   .. seealso:: :meth:`setIdleTimeout`
   """
    pass

  def setIdleTimeout(self,idleTimeout):
    """Setter method that sets the maximum time the Server is allowed to wait for any data to be sent in response to a 
   polling request, if none has accumulated at request time. Setting this time to a nonzero value and the polling interval 
   to zero leads to an "asynchronous polling" behavior, which, on low data rates, is very similar to the streaming case.
   Setting this time to zero and the polling interval to a nonzero value, on the other hand, leads to a classical 
   "synchronous polling". 

   Note that the Server may, in some cases, delay the answer for more than the supplied time, to protect itself against
   a high polling rate or because of bandwidth restrictions. Also, the Server may impose an upper limit on the wait time, 
   in order to be able to check for client-side connection drops.
   
   **default**  19000 (19 seconds).
   
   **lifecycle** The idle timeout should be set before calling the 
   :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the supplied value 
   will be used for the next polling request.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "idleTimeout" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param idleTimeout: The time (in milliseconds) the Server is allowed to wait for data to send upon polling requests.
   
   :raises IllegalArgumentException: if a negative value is configured 
   """
    pass

  def getKeepaliveInterval(self):
    """Inquiry method that gets the interval between two keepalive packets sent by Lightstreamer Server 
   on a stream connection when no actual data is being transmitted. If the returned value is 0,
   it means that the interval is to be decided by the Server upon the next connection.
   
   **lifecycle** If the value has just been set and a connection to Lightstreamer Server has not been
   established yet, the returned value is the time that is being requested to the Server.
   Afterwards, the returned value is the time used by the Server, that may be different, because
   of Server side constraints.
   
   :return: The time, expressed in milliseconds, between two keepalive packets sent by the Server, or 0.
   
   .. seealso:: :meth:`setKeepaliveInterval`
   """
    pass

  def setKeepaliveInterval(self,keepaliveInterval):
    """Setter method that sets the interval between two keepalive packets to be sent by Lightstreamer Server on a stream 
   connection when no actual data is being transmitted. The Server may, however, impose a lower limit on the keepalive 
   interval, in order to protect itself. Also, the Server may impose an upper limit on the keepalive interval, in 
   order to be able to check for client-side connection drops.
   If 0 is specified, the interval will be decided by the Server.
   
   **default** 0 (meaning that the Server will send keepalive packets based on its own configuration).
   
   **lifecycle** The keepalive interval should be set before 
   calling the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the supplied 
   value will be used for the next streaming connection (either a bind or a brand new session). Note that, after a connection, the value may be changed to the one imposed by the Server.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "keepaliveInterval" on any 
   ClientListener listening to the related LightstreamerClient.

   :param keepaliveInterval: the keepalive interval time (in milliseconds) to set, or 0.
   
   :raises IllegalArgumentException: if a negative value is configured 
   
   .. seealso:: :meth:`setStalledTimeout`
   .. seealso:: :meth:`setReconnectTimeout`
   """
    pass

  def getRequestedMaxBandwidth(self):
    """Inquiry method that gets the maximum bandwidth that can be consumed for the data coming from 
   Lightstreamer Server, as requested for this session.
   The maximum bandwidth limit really applied by the Server on the session is provided by
   :meth:`getRealMaxBandwidth`
   
   :return:  A decimal number, which represents the maximum bandwidth requested for the streaming or polling connection expressed in kbps (kilobits/sec), or the string "unlimited".

   .. seealso:: :meth:`setRequestedMaxBandwidth`
   """
    pass

  def setRequestedMaxBandwidth(self,maxBandwidth):
    """Setter method that sets the maximum bandwidth expressed in kilobits/s that can be consumed for the data coming from 
   Lightstreamer Server. A limit on bandwidth may already be posed by the Metadata Adapter, but the client can 
   furtherly restrict this limit. The limit applies to the bytes received in each streaming or polling connection.
   
   **general edition note** Bandwidth Control is an optional feature, available depending on Edition and License Type.
   To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
   available at /dashboard).
   
   **default** "unlimited"
   
   **lifecycle** The bandwidth limit can be set and changed at any time. If a connection is currently active, the bandwidth 
   limit for the connection is changed on the fly. Remember that the Server may apply a different limit.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "requestedMaxBandwidth" on any 
   ClientListener listening to the related LightstreamerClient. Moreover, upon any change or attempt to change the limit, the Server will notify the client and such notification will be received through a call to :meth:`ClientListener.onPropertyChange` with argument "realMaxBandwidth" on any ClientListener listening to the related LightstreamerClient.
   
   :param maxBandwidth:  A decimal number, which represents the maximum bandwidth requested for the streaming or polling connection expressed in kbps (kilobits/sec). The string "unlimited" is also allowed, to mean that the maximum bandwidth can be entirely decided on the Server side (the check is case insensitive).
   
   :raises IllegalArgumentException: if a negative, zero, or a not-number value (excluding special values) is passed.
   
   .. seealso:: :meth:`getRealMaxBandwidth`
   """
    pass

  def getRealMaxBandwidth(self):
    """Inquiry method that gets the maximum bandwidth that can be consumed for the data coming from 
   Lightstreamer Server. This is the actual maximum bandwidth, in contrast with the requested
   maximum bandwidth, returned by :meth:`getRequestedMaxBandwidth`. 

   The value may differ from the requested one because of restrictions operated on the server side,
   or because bandwidth management is not supported (in this case it is always "unlimited"),
   but also because of number rounding.
   
   **lifecycle** If a connection to Lightstreamer Server is not currently active, null is returned;
   soon after the connection is established, the value becomes available, as notified
   by a call to :meth:`ClientListener.onPropertyChange` with argument "realMaxBandwidth".
   
   :return:  A decimal number, which represents the maximum bandwidth applied by the Server for the streaming or polling connection expressed in kbps (kilobits/sec), or the string "unlimited", or null.
   
   .. seealso:: :meth:`setRequestedMaxBandwidth`
   """
    pass

  def getPollingInterval(self):
    """Inquiry method that gets the polling interval used for polling connections. 
 
   If the value has just been set and a polling request to Lightstreamer Server has not been performed 
   yet, the returned value is the polling interval that is being requested to the Server. Afterwards, 
   the returned value is the the time between subsequent polling requests that is really allowed by the 
   Server, that may be different, because of Server side constraints.

   :return: The time (in milliseconds) between subsequent polling requests.

   .. seealso:: :meth:`setPollingInterval`
   """
    pass

  def setPollingInterval(self,pollingInterval):
    """Setter method that sets the polling interval used for polling connections. The client switches from the default 
   streaming mode to polling mode when the client network infrastructure does not allow streaming. Also, 
   polling mode can be forced by calling :meth:`setForcedTransport` with "WS-POLLING" or "HTTP-POLLING" 
   as parameter. 

   The polling interval affects the rate at which polling requests are issued. It is the time between the start of a 
   polling request and the start of the next request. However, if the polling interval expires before the first polling 
   request has returned, then the second polling request is delayed. This may happen, for instance, when the Server delays 
   the answer because of the idle timeout setting. In any case, the polling interval allows for setting an upper limit on 
   the polling frequency. 
 
   The Server does not impose a lower limit on the client polling interval. However, in some cases, it may protect itself
   against a high polling rate by delaying its answer. Network limitations and configured bandwidth limits may also lower 
   the polling rate, despite of the client polling interval. 

   The Server may, however, impose an upper limit on the polling interval, in order to be able to promptly detect 
   terminated polling request sequences and discard related session information.
   
   **default** 0 (pure "asynchronous polling" is configured).
   
   **lifecycle** The polling interval should be set before calling 
   the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the supplied value will
   be used for the next polling request. 

   Note that, after each polling request, the value may be changed to the one imposed by the Server.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "pollingInterval" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param pollingInterval: The time (in milliseconds) between subsequent polling requests. Zero is a legal value too, meaning that the client will issue a new polling request as soon as a previous one has returned.
   
   :raises IllegalArgumentException: if a negative value is configured 
   """
    pass

  def getReconnectTimeout(self):
    """Inquiry method that gets the time the client, after entering "STALLED" status,
   is allowed to keep waiting for a keepalive packet or any data on a stream connection,
   before disconnecting and trying to reconnect to the Server.

   :return: The idle time (in milliseconds) admitted in "STALLED" status before trying to reconnect to the Server.

   .. seealso:: :meth:`setReconnectTimeout`
   """
    pass

  def setReconnectTimeout(self,reconnectTimeout):
    """Setter method that sets the time the client, after entering "STALLED" status,
   is allowed to keep waiting for a keepalive packet or any data on a stream connection,
   before disconnecting and trying to reconnect to the Server.
   The new connection may be either the opening of a new session or an attempt to recovery
   the current session, depending on the kind of interruption.
   
   **default** 3000 (3 seconds).
   
   **lifecycle** This value can be set and changed at any time.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "reconnectTimeout" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param reconnectTimeout: The idle time (in milliseconds) allowed in "STALLED" status before trying to reconnect to the Server.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   
   .. seealso:: :meth:`setStalledTimeout`
   .. seealso:: :meth:`setKeepaliveInterval`
   """
    pass

  def getRetryDelay(self):
    """Inquiry method that gets the minimum time to wait before trying a new connection
   to the Server in case the previous one failed for any reason, which is also the maximum time to wait for a response to a request 
   before dropping the connection and trying with a different approach.
   Note that the delay is calculated from the moment the effort to create a connection
   is made, not from the moment the failure is detected or the connection timeout expires.

   :return: The time (in milliseconds) to wait before trying a new connection.

   .. seealso:: :meth:`setRetryDelay`
   """
    pass

  def setRetryDelay(self,retryDelay):
    """Setter method that sets 

    1. the minimum time to wait before trying a new connection to the Server in case the previous one failed for any reason; and
    2. the maximum time to wait for a response to a request before dropping the connection and trying with a different approach.
   

   Enforcing a delay between reconnections prevents strict loops of connection attempts when these attempts
   always fail immediately because of some persisting issue.
   This applies both to reconnections aimed at opening a new session and to reconnections
   aimed at attempting a recovery of the current session.

   Note that the delay is calculated from the moment the effort to create a connection
   is made, not from the moment the failure is detected.
   As a consequence, when a working connection is interrupted, this timeout is usually
   already consumed and the new attempt can be immediate (except that
   :meth:`ConnectionOptions.setFirstRetryMaxDelay` will apply in this case).
   As another consequence, when a connection attempt gets no answer and times out,
   the new attempt will be immediate.

   As a timeout on unresponsive connections, it is applied in these cases:
   
   * *Streaming*: Applied on any attempt to setup the streaming connection. If after the timeout no data has arrived on the stream connection, the client may automatically switch transport or may resort to a polling connection.
   * *Polling and pre-flight requests*: Applied on every connection. If after the timeout no data has arrived on the polling connection, the entire connection process restarts from scratch.
   
   **This setting imposes only a minimum delay. In order to avoid network congestion, the library may use a longer delay if the issue preventing the establishment of a session persists.**
   
   **default** 4000 (4 seconds).
   
   **lifecycle** This value can be set and changed at any time.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "retryDelay" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param retryDelay: The time (in milliseconds) to wait before trying a new connection.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   
   .. seealso:: :meth:`setFirstRetryMaxDelay`
   """
    pass

  def getReverseHeartbeatInterval(self):
    """Inquiry method that gets the reverse-heartbeat interval expressed in milliseconds.
   A 0 value is possible, meaning that the mechanism is disabled.

   :return: The reverse-heartbeat interval, or 0.

   .. seealso:: :meth:`setReverseHeartbeatInterval`
   """
    pass

  def setReverseHeartbeatInterval(self,reverseHeartbeatInterval):
    """Setter method that enables/disables the reverse-heartbeat mechanism by setting the heartbeat interval. If the given value (expressed in milliseconds) equals 0 then the reverse-heartbeat mechanism will be disabled; otherwise if the given value is greater than 0 the mechanism will be enabled with the specified interval. 

When the mechanism is active, the client will ensure that there
is at most the specified interval between a control request and the following one,
by sending empty control requests (the "reverse heartbeats") if necessary.
   
This can serve various purposes:

   * Preventing the communication infrastructure from closing an inactive socket that is ready for reuse for more HTTP control requests, to avoid connection reestablishment overhead. However it is not guaranteed that the connection will be kept open,as the underlying TCP implementation may open a new socket each time a HTTP request needs to be sent. Note that this will be done only when a session is in place.
   * Allowing the Server to detect when a streaming connection or Websocket is interrupted but not closed. In these cases, the client eventually closes the connection, but the Server cannot see that (the connection remains "half-open") and just keeps trying to write. This is done by notifying the timeout to the Server upon each streaming request. For long polling, the :meth:`setIdleTimeout` setting has a similar function.
   * Allowing the Server to detect cases in which the client has closed a connection in HTTP streaming, but the socket is kept open by some intermediate node, which keeps consuming the response. This is also done by notifying the timeout to the Server upon each streaming request,whereas, for long polling, the :meth:`setIdleTimeout` setting has a similar function.
   
**default** 0 (meaning that the mechanism is disabled).
   
**lifecycle** This setting should be performed before calling the
:meth:`LightstreamerClient.connect` method. However, the value can be changed
at any time: the setting will be obeyed immediately, unless a higher heartbeat
frequency was notified to the Server for the current connection. The setting
will always be obeyed upon the next connection (either a bind or a brand new session).
   
**notification** A change to this setting will be notified through a call to 
:meth:`ClientListener.onPropertyChange` with argument "reverseHeartbeatInterval" on any 
ClientListener listening to the related LightstreamerClient.
   
:param reverseHeartbeatInterval: the interval, expressed in milliseconds, between subsequent reverse-heartbeats, or 0.
   
:raises IllegalArgumentException: if a negative value is configured
   """
    pass

  def getSessionRecoveryTimeout(self):
    """Inquiry method that gets the maximum time allowed for attempts to recover
   the current session upon an interruption, after which a new session will be created.
   A 0 value also means that any attempt to recover the current session is prevented
   in the first place.
   
   :return: The maximum time allowed for recovery attempts, possibly 0.

   .. seealso:: :meth:`setSessionRecoveryTimeout`
   """
    pass

  def setSessionRecoveryTimeout(self,sessionRecoveryTimeout):
    """Setter method that sets the maximum time allowed for attempts to recover the current session upon an interruption, after which a new session will be created. If the given value (expressed in milliseconds) equals 0, then any attempt to recover the current session will be prevented in the first place.
   
In fact, in an attempt to recover the current session, the client will
periodically try to access the Server at the address related with the current
session. In some cases, this timeout, by enforcing a fresh connection attempt,
may prevent an infinite sequence of unsuccessful attempts to access the Server.
   
Note that, when the Server is reached, the recovery may fail due to a
Server side timeout on the retention of the session and the updates sent.
In that case, a new session will be created anyway.
A setting smaller than the Server timeouts may prevent such useless failures,
but, if too small, it may also prevent successful recovery in some cases.
   
**default** 15000 (15 seconds).
   
**lifecycle** This value can be set and changed at any time.
   
**notification** A change to this setting will be notified through a
call to :meth:`ClientListener.onPropertyChange` with argument "sessionRecoveryTimeout" on any 
ClientListener listening to the related LightstreamerClient.
   
:param sessionRecoveryTimeout: The maximum time allowed for recovery attempts, expressed in milliseconds, including 0.

:raises IllegalArgumentException: if a negative value is passed.
   """
    pass

  def getStalledTimeout(self):
    """Inquiry method that gets the extra time the client can wait when an expected keepalive packet 
   has not been received on a stream connection (and no actual data has arrived), before entering 
   the "STALLED" status.

   :return: The idle time (in milliseconds) admitted before entering the "STALLED" status.

   .. seealso:: :meth:`setStalledTimeout`
   """
    pass

  def setStalledTimeout(self,stalledTimeout):
    """Setter method that sets the extra time the client is allowed to wait when an expected keepalive packet has not been 
   received on a stream connection (and no actual data has arrived), before entering the "STALLED" status.
   
   **default** 2000 (2 seconds).
   
   **lifecycle**  This value can be set and changed at any time.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "stalledTimeout" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param stalledTimeout: The idle time (in milliseconds) allowed before entering the "STALLED" status.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   
   .. seealso:: :meth:`setReconnectTimeout`
   .. seealso:: :meth:`setKeepaliveInterval`
   """
    pass

  def isHttpExtraHeadersOnSessionCreationOnly(self):
    """ Inquiry method that checks if the restriction on the forwarding of the configured extra http headers 
   applies or not. 

   :return: true/false if the restriction applies or not.

   .. seealso:: :meth:`setHttpExtraHeadersOnSessionCreationOnly`
   .. seealso:: :meth:`setHttpExtraHeaders`
   """
    pass

  def setHttpExtraHeadersOnSessionCreationOnly(self,httpExtraHeadersOnSessionCreationOnly):
    """Setter method that enables/disables a restriction on the forwarding of the extra http headers specified through 
   :meth:`setHttpExtraHeaders`. If true, said headers will only be sent during the session creation 
   process (and thus will still be available to the metadata adapter notifyUser method) but will not be sent on following 
   requests. On the contrary, when set to true, the specified extra headers will be sent to the server on every request.
   
   **default** false
   
   **lifecycle** This setting should be performed before calling the
   :meth:`LightstreamerClient.connect` method. However, the value can be changed
   at any time: the supplied value will be used for the next HTTP request or WebSocket establishment.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "httpExtraHeadersOnSessionCreationOnly" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param httpExtraHeadersOnSessionCreationOnly: true/false to enable/disable the restriction on extra headers forwarding.
   """
    pass

  def isServerInstanceAddressIgnored(self):
    """ Inquiry method that checks if the client is going to ignore the server instance address that 
   will possibly be sent by the server.

   :return: Whether or not to ignore the server instance address sent by the server.

   .. seealso:: :meth:`setServerInstanceAddressIgnored`
   """
    pass

  def setServerInstanceAddressIgnored(self,serverInstanceAddressIgnored):
    """Setter method that can be used to disable/enable the automatic handling of server instance address that may 
   be returned by the Lightstreamer server during session creation. 
 
   In fact, when a Server cluster is in place, the Server address specified through 
   :meth:`ConnectionDetails.setServerAddress` can identify various Server instances; in order to 
   ensure that all requests related to a session are issued to the same Server instance, the Server can answer
   to the session opening request by providing an address which uniquely identifies its own instance. 
 
   Setting this value to true permits to ignore that address and to always connect through the address 
   supplied in setServerAddress. This may be needed in a test environment, if the Server address specified 
   is actually a local address to a specific Server instance in the cluster. 

   
   **general edition note** Server Clustering is an optional feature, available depending on Edition and License Type.
   To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
   available at /dashboard).
   
   **default** false.
   
   **lifecycle** This method can be called at any time. If called while connected, it will be applied when the 
   next session creation request is issued.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "serverInstanceAddressIgnored" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param serverInstanceAddressIgnored: true or false, to ignore or not the server instance address sent by the server.
   
   .. seealso:: :meth:`ConnectionDetails.setServerAddress`
   """
    pass

  def isSlowingEnabled(self):
    """Inquiry method that checks if the slowing algorithm is enabled or not.

   :return: Whether the slowing algorithm is enabled or not.

   .. seealso:: :meth:`setSlowingEnabled`
   """
    pass

  def setSlowingEnabled(self,slowingEnabled):
    """Setter method that turns on or off the slowing algorithm. This heuristic algorithm tries to detect when the client 
   CPU is not able to keep the pace of the events sent by the Server on a streaming connection. In that case, an automatic
   transition to polling is performed. 

   In polling, the client handles all the data before issuing the next poll, hence a slow client would just delay the polls, 
   while the Server accumulates and merges the events and ensures that no obsolete data is sent. 

   Only in very slow clients, the next polling request may be so much delayed that the Server disposes the session first, 
   because of its protection timeouts. In this case, a request for a fresh session will be reissued by the client and this 
   may happen in cycle.
   
   **default** false.
   
   **lifecycle** This setting should be performed before 
   calling the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the supplied value will 
   be used for the next streaming connection (either a bind or a brand new session).
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "slowingEnabled" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param slowingEnabled: true or false, to enable or disable the heuristic algorithm that lowers the item update frequency.
   """
    pass

  def setProxy(self,proxy):
    """Setter method that configures the coordinates to a proxy server to be used to connect to the Lightstreamer Server. 
   
   **default** null (meaning not to pass through a proxy).
   
   **lifecycle** This value can be set and changed at any time. the supplied value will 
   be used for the next connection attempt.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`ClientListener.onPropertyChange` with argument "proxy" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param proxy: The proxy configuration. Specify null to avoid using a proxy.
   """
    pass

class LightstreamerClient:
  """Facade class for the management of the communication to
 Lightstreamer Server. Used to provide configuration settings, event
 handlers, operations for the control of the connection lifecycle,
 :class:`Subscription` handling and to send messages. 

 An instance of LightstreamerClient handles the communication with
 Lightstreamer Server on a specified endpoint. Hence, it hosts one "Session";
 or, more precisely, a sequence of Sessions, since any Session may fail
 and be recovered, or it can be interrupted on purpose.
 So, normally, a single instance of LightstreamerClient is needed. 

 However, multiple instances of LightstreamerClient can be used,
 toward the same or multiple endpoints.

 :ivar connectionOptions: Data object that contains options and policies for the connection to the server. This instance is set up by the LightstreamerClient object at its own creation. Properties of this object can be overwritten by values received from a Lightstreamer Server. 

 :ivar connectionDetails: Data object that contains the details needed to open a connection to a Lightstreamer Server. This instance is set up by the LightstreamerClient object at its own creation. Properties of this object can be overwritten by values received from a Lightstreamer Server. 

 :param serverAddress: the address of the Lightstreamer Server to which this LightstreamerClient will connect to. It is possible to specify it later by using null here. See :meth:`ConnectionDetails.setServerAddress` for details.
 :param adapterSet: the name of the Adapter Set mounted on Lightstreamer Server to be used to handle all requests in the Session associated with this LightstreamerClient. It is possible not to specify it at all or to specify it later by using null here. See :meth:`ConnectionDetails.setAdapterSet` for details.

 :raises IllegalArgumentException: if a not valid address is passed. See :meth:`ConnectionDetails.setServerAddress` for details.
 """

  LIB_NAME = "TODO"
  """
  A constant string representing the name of the library.
  """

  LIB_VERSION = "TODO"
  """
  A constant string representing the version of the library.
  """

  def __init__(self,serverAddress,adapterSet):
    pass

  def addListener(self,listener):
    """Adds a listener that will receive events from the LightstreamerClient instance. 
 
   The same listener can be added to several different LightstreamerClient instances.

   **lifecycle** A listener can be added at any time. A call to add a listener already 
   present will be ignored.
   
   :param listener: An object that will receive the events as documented in the :class:`ClientListener` interface.
   
   .. seealso:: :meth:`removeListener`
    """
    pass

  def removeListener(self,listener):
    """ Removes a listener from the LightstreamerClient instance so that it will not receive events anymore.
   
   **lifecycle** a listener can be removed at any time.
   
   :param listener: The listener to be removed.
   
   .. seealso:: :meth:`addListener`
   """
    pass

  def getListeners(self):
    """Returns a list containing the :class:`ClientListener` instances that were added to this client.

   :return: a list containing the listeners that were added to this client. 

   .. seealso:: :meth:`addListener`
   """
    pass

  def connect(self):
    """Operation method that requests to open a Session against the configured Lightstreamer Server. 

   When connect() is called, unless a single transport was forced through 
   :meth:`ConnectionOptions.setForcedTransport`, the so called "Stream-Sense" mechanism is started: 
   if the client does not receive any answer for some seconds from the streaming connection, then it 
   will automatically open a polling connection. 

   A polling connection may also be opened if the environment is not suitable for a streaming connection. 

   Note that as "polling connection" we mean a loop of polling requests, each of which requires opening a 
   synchronous (i.e. not streaming) connection to Lightstreamer Server.
   
   **lifecycle** Note that the request to connect is accomplished by the client in a separate thread; this means 
   that an invocation to :meth:`getStatus` right after connect() might not reflect the change yet. 
 
   When the request to connect is finally being executed, if the current status
   of the client is not DISCONNECTED, then nothing will be done.
   
   :raises IllegalStateException: if no server address was configured.
   
   .. seealso:: :meth:`getStatus`
   .. seealso:: :meth:`disconnect`
   .. seealso:: :meth:`ClientListener.onStatusChange`
   .. seealso:: :meth:`ConnectionDetails.setServerAddress`
   """
    pass

  def disconnect(self):
    """ Operation method that requests to close the Session opened against the configured Lightstreamer Server 
   (if any). 

   When disconnect() is called, the "Stream-Sense" mechanism is stopped. 

   Note that active Subscription instances, associated with this LightstreamerClient instance, are preserved 
   to be re-subscribed to on future Sessions.
   
   **lifecycle**  Note that the request to disconnect is accomplished by the client in a separate thread; this 
   means that an invocation to :meth:`getStatus` right after disconnect() might not reflect the change yet. 
 
   When the request to disconnect is finally being executed, if the status of the client is "DISCONNECTED", 
   then nothing will be done.
   
   .. seealso:: :meth:`connect`
   """
    pass

  def getStatus(self):
    """Inquiry method that gets the current client status and transport (when applicable).
   
   :return: The current client status. It can be one of the following values:
   
    * "CONNECTING" the client is waiting for a Server's response in order to establish a connection;
    * "CONNECTED:STREAM-SENSING" the client has received a preliminary response from the server and is currently verifying if a streaming connection is possible;
    * "CONNECTED:WS-STREAMING" a streaming connection over WebSocket is active;
    * "CONNECTED:HTTP-STREAMING" a streaming connection over HTTP is active;
    * "CONNECTED:WS-POLLING" a polling connection over WebSocket is in progress;
    * "CONNECTED:HTTP-POLLING" a polling connection over HTTP is in progress;
    * "STALLED" the Server has not been sending data on an active streaming connection for longer than a configured time;
    * "DISCONNECTED:WILL-RETRY" no connection is currently active but one will be opened (possibly after a timeout);
    * "DISCONNECTED:TRYING-RECOVERY" no connection is currently active, but one will be opened as soon as possible, as an attempt to recover the current session after a connection issue; 
    * "DISCONNECTED" no connection is currently active.
   
   .. seealso:: :meth:`ClientListener.onStatusChange`
   """
    pass

  def sendMessage(self,message,sequence = None,delayTimeout = None,listener = None,enqueueWhileDisconnected = None):
    """Operation method that sends a message to the Server. The message is interpreted and handled by 
   the Metadata Adapter associated to the current Session. This operation supports in-order 
   guaranteed message delivery with automatic batching. In other words, messages are guaranteed 
   to arrive exactly once and respecting the original order, whatever is the underlying transport 
   (HTTP or WebSockets). Furthermore, high frequency messages are automatically batched, if necessary,
   to reduce network round trips. 

   Upon subsequent calls to the method, the sequential management of the involved messages is guaranteed. 
   The ordering is determined by the order in which the calls to sendMessage are issued. 

   If a message, for any reason, doesn't reach the Server (this is possible with the HTTP transport),
   it will be resent; however, this may cause the subsequent messages to be delayed.
   For this reason, each message can specify a "delayTimeout", which is the longest time the message, after
   reaching the Server, can be kept waiting if one of more preceding messages haven't been received yet.
   If the "delayTimeout" expires, these preceding messages will be discarded; any discarded message
   will be notified to the listener through :meth:`ClientMessageListener.onDiscarded`.
   Note that, because of the parallel transport of the messages, if a zero or very low timeout is 
   set for a message and the previous message was sent immediately before, it is possible that the
   latter gets discarded even if no communication issues occur.
   The Server may also enforce its own timeout on missing messages, to prevent keeping the subsequent
   messages for long time. 

   Sequence identifiers can also be associated with the messages. In this case, the sequential management is 
   restricted to all subsets of messages with the same sequence identifier associated. 

   Notifications of the operation outcome can be received by supplying a suitable listener. The supplied 
   listener is guaranteed to be eventually invoked; listeners associated with a sequence are guaranteed 
   to be invoked sequentially. 

   The "UNORDERED_MESSAGES" sequence name has a special meaning. For such a sequence, immediate processing 
   is guaranteed, while strict ordering and even sequentialization of the processing is not enforced. 
   Likewise, strict ordering of the notifications is not enforced. However, messages that, for any reason, 
   should fail to reach the Server whereas subsequent messages had succeeded, might still be discarded after 
   a server-side timeout, in order to ensure that the listener eventually gets a notification.

   Moreover, if "UNORDERED_MESSAGES" is used and no listener is supplied, a "fire and forget" scenario
   is assumed. In this case, no checks on missing, duplicated or overtaken messages are performed at all,
   so as to optimize the processing and allow the highest possible throughput.
   
   **lifecycle** Since a message is handled by the Metadata Adapter associated to the current connection, a
   message can be sent only if a connection is currently active. If the special enqueueWhileDisconnected 
   flag is specified it is possible to call the method at any time and the client will take care of sending
   the message as soon as a connection is available, otherwise, if the current status is "DISCONNECTED*", 
   the message will be abandoned and the :meth:`ClientMessageListener.onAbort` event will be fired. 

   Note that, in any case, as soon as the status switches again to "DISCONNECTED*", any message still pending 
   is aborted, including messages that were queued with the enqueueWhileDisconnected flag set to true. 

   Also note that forwarding of the message to the server is made in a separate thread, hence, if a message 
   is sent while the connection is active, it could be aborted because of a subsequent disconnection. 
   In the same way a message sent while the connection is not active might be sent because of a subsequent
   connection.
   
   :param message: a text message, whose interpretation is entirely demanded to the Metadata Adapter associated to the current connection.
   :param sequence: an alphanumeric identifier, used to identify a subset of messages to be managed in sequence; underscore characters are also allowed. If the "UNORDERED_MESSAGES" identifier is supplied, the message will be processed in the special way described above. The parameter is optional; if set to null, "UNORDERED_MESSAGES" is used as the sequence name. 
   :param delayTimeout: a timeout, expressed in milliseconds. If higher than the Server configured timeout on missing messages, the latter will be used instead. The parameter is optional; if a negative value is supplied, the Server configured timeout on missing messages will be applied. This timeout is ignored for the special "UNORDERED_MESSAGES" sequence, although a server-side timeout on missing messages still applies.
   :param listener: an object suitable for receiving notifications about the processing outcome. The parameter is optional; if not supplied, no notification will be available.
   :param enqueueWhileDisconnected: if this flag is set to true, and the client is in a disconnected status when the provided message is handled, then the message is not aborted right away but is queued waiting for a new session. Note that the message can still be aborted later when a new session is established.
   """
    pass

  def subscribe(self,subscription):
    """Operation method that adds a Subscription to the list of "active" Subscriptions. The Subscription cannot already 
   be in the "active" state. 

   Active subscriptions are subscribed to through the server as soon as possible (i.e. as soon as there is a 
   session available). Active Subscription are automatically persisted across different sessions as long as a 
   related unsubscribe call is not issued.
   
   **lifecycle** Subscriptions can be given to the LightstreamerClient at any time. Once done the Subscription 
   immediately enters the "active" state. 

   Once "active", a Subscription instance cannot be provided again to a LightstreamerClient unless it is 
   first removed from the "active" state through a call to :meth:`unsubscribe`. 

   Also note that forwarding of the subscription to the server is made in a separate thread. 

   A successful subscription to the server will be notified through a :meth:`SubscriptionListener.onSubscription`
   event.
   
   :param subscription: A Subscription object, carrying all the information needed to process real-time values.
   
   .. seealso:: :meth:`unsubscribe`
   """
    pass

  def unsubscribe(self,subscription):
    """Operation method that removes a Subscription that is currently in the "active" state. 
 
   By bringing back a Subscription to the "inactive" state, the unsubscription from all its items is 
   requested to Lightstreamer Server.
   
   **lifecycle** Subscription can be unsubscribed from at any time. Once done the Subscription immediately 
   exits the "active" state. 

   Note that forwarding of the unsubscription to the server is made in a separate thread. 

   The unsubscription will be notified through a :meth:`SubscriptionListener.onUnsubscription` event.
   
   :param subscription: An "active" Subscription object that was activated by this LightstreamerClient instance.
   """
    pass

  def getSubscriptions(self):
    """ Inquiry method that returns a list containing all the Subscription instances that are 
   currently "active" on this LightstreamerClient. 

   Internal second-level Subscription are not included.

   :return: A list, containing all the Subscription currently "active" on this LightstreamerClient. 

   The list can be empty.

   .. seealso:: :meth:`subscribe`
   """
    pass

  @staticmethod
  def setLoggerProvider(provider):
    """Static method that permits to configure the logging system used by the library. The logging system must respect the :class:`LoggerProvider` interface. A custom class can be used to wrap any third-party logging system. 

If no logging system is specified, all the generated log is discarded. 

The following categories are available to be consumed:
   
    * lightstreamer.stream: logs socket activity on Lightstreamer Server connections; at INFO level, socket operations are logged; at DEBUG level, read/write data exchange is logged.
    * lightstreamer.protocol: logs requests to Lightstreamer Server and Server answers; at INFO level, requests are logged; at DEBUG level, request details and events from the Server are logged.
    * lightstreamer.session: logs Server Session lifecycle events; at INFO level, lifecycle events are logged; at DEBUG level, lifecycle event details are logged.
    * lightstreamer.subscriptions: logs subscription requests received by the clients and the related updates; at WARN level, alert events from the Server are logged; at INFO level, subscriptions and unsubscriptions are logged; at DEBUG level, requests batching and update details are logged.
    * lightstreamer.actions: logs settings / API calls.
    
:param provider: A :class:`LoggerProvider` instance that will be used to generate log messages by the library classes.
   """
    pass

  @staticmethod
  def addCookies(uri,cookies):
    """Static method that can be used to share cookies between connections to the Server (performed by this library) and connections to other sites that are performed by the application. With this method, cookies received by the application can be added (or replaced if already present) to the cookie set used by the library to access the Server. Obviously, only cookies whose domain is compatible with the Server domain will be used internally.
     
**lifecycle** This method should be invoked before calling the :meth:`LightstreamerClient.connect` method. However it can be invoked at any time; it will affect the internal cookie set immediately and the sending of cookies on the next HTTP request or WebSocket establishment.
   
:param uri: the URI from which the supplied cookies were received. It cannot be null.
   
:param cookies: an instance of http.cookies.SimpleCookie.
   
.. seealso:: :meth:`getCookies`
   """
    pass

  @staticmethod
  def getCookies(uri):
    """Static inquiry method that can be used to share cookies between connections to the Server (performed by this library) and connections to other sites that are performed by the application. With this method, cookies received from the Server can be extracted for sending through other connections, according with the URI to be accessed.
   
See :meth:`addCookies` for clarifications on when cookies are directly stored by the library and when not.

:param uri: the URI to which the cookies should be sent, or null.
   
:return: a list with the various cookies that can be sent in a HTTP request for the specified URI. If a null URI was supplied, all available non-expired cookies will be returned.
:rtype: http.cookies.SimpleCookie
   """
    pass

  @staticmethod
  def setTrustManagerFactory(factory):
    """Provides a mean to control the way TLS certificates are evaluated, with the possibility to accept untrusted ones.
   
**lifecycle** May be called only once before creating any LightstreamerClient instance.
   
:param factory: an instance of ssl.SSLContext
:raises NullPointerException: if the factory is null
:raises IllegalStateException: if a factory is already installed
   """
    pass

class Proxy:
  """Simple class representing a Proxy configuration. 

 An instance of this class can be used through :meth:`ConnectionOptions.setProxy` to
 instruct a LightstreamerClient to connect to the Lightstreamer Server passing through a proxy.

 :param type: the proxy type
 :param host: the proxy host
 :param port: the proxy port
 :param user: the user name to be used to validate against the proxy
 :param password: the password to be used to validate against the proxy
 """

  def __init__(self,_hx_type,host,port,user,password):
    pass

class Subscription:
  """Class representing a Subscription to be submitted to a Lightstreamer Server. It contains subscription details and the listeners needed to process the real-time data. 

After the creation, a Subscription object is in the "inactive" state. When a Subscription object is subscribed to on a LightstreamerClient object, through the :meth:`LightstreamerClient.subscribe` method, its state becomes "active". 
This means that the client activates a subscription to the required items through 
Lightstreamer Server and the Subscription object begins to receive real-time events. 

A Subscription can be configured to use either an Item Group or an Item List to specify the 
items to be subscribed to and using either a Field Schema or Field List to specify the fields. 

"Item Group" and "Item List" are defined as follows:
  
   * "Item Group": an Item Group is a String identifier representing a list of items. Such Item Group has to be expanded into a list of items by the getItems method of the MetadataProvider of the associated Adapter Set. When using an Item Group, items in the subscription are identified by their 1-based index within the group. It is possible to configure the Subscription to use an "Item Group" using the :meth:`setItemGroup` method. 
   * "Item List": an Item List is an array of Strings each one representing an item. For the Item List to be correctly interpreted a LiteralBasedProvider or a MetadataProvider with a compatible implementation of getItems has to be configured in the associated Adapter Set. Note that no item in the list can be empty, can contain spaces or can be a number. When using an Item List, items in the subscription are identified by their name or by their 1-based index within the list. It is possible to configure the Subscription to use an "Item List" using the :meth:`setItems` method or by specifying it in the constructor.
  
"Field Schema" and "Field List" are defined as follows:
  
   * "Field Schema": a Field Schema is a String identifier representing a list of fields. Such Field Schema has to be expanded into a list of fields by the getFields method of the MetadataProvider of the associated Adapter Set. When using a Field Schema, fields in the subscription are identified by their 1-based index within the schema. It is possible to configure the Subscription to use a "Field Schema" using the :meth:`setFieldSchema` method.
   * "Field List": a Field List is an array of Strings each one representing a field. For the Field List to be correctly interpreted a LiteralBasedProvider or a MetadataProvider with a compatible implementation of getFields has to be configured in the associated Adapter Set. Note that no field in the list can be empty or can contain spaces. When using a Field List, fields in the subscription are identified by their name or by their 1-based index within the list. It is possible to configure the Subscription to use a "Field List" using the :meth:`setFields` method or by specifying it in the constructor.
  
A Subscription can be supplied to :meth:`LightstreamerClient.subscribe` and :meth:`LightstreamerClient.unsubscribe`, in order to bring the Subscription to "active" or back to "inactive" state. 

Note that all of the methods used to describe the subscription to the server can only be called while the instance is in the "inactive" state; the only exception is :meth:`setRequestedMaxFrequency`.
    
:param subscriptionMode: the subscription mode for the items, required by Lightstreamer Server. Permitted values are:
    
     * MERGE
     * DISTINCT
     * RAW
     * COMMAND
    
:param items: an array of items to be subscribed to through Lightstreamer server. It is also possible specify the "Item List" or "Item Group" later through :meth:`setItems` and :meth:`setItemGroup`.

:param fields: an array of fields for the items to be subscribed to through Lightstreamer Server. It is also possible to specify the "Field List" or "Field Schema" later through :meth:`setFields` and :meth:`setFieldSchema`.

:raises IllegalArgumentException: If no or invalid subscription mode is passed.
:raises IllegalArgumentException: If either the items or the fields array is left null.
:raises IllegalArgumentException: If the specified "Item List" or "Field List" is not valid; see :meth:`setItems` and :meth:`setFields` for details.
  """

  def __init__(self,mode,items,fields):
    pass

  def addListener(self,listener):
    """Adds a listener that will receive events from the Subscription instance. 
 
    The same listener can be added to several different Subscription instances.
    
    **lifecycle** A listener can be added at any time. A call to add a listener already 
    present will be ignored.
    
    :param listener: An object that will receive the events as documented in the SubscriptionListener interface.
    
    .. seealso:: :meth:`removeListener`
    """
    pass

  def removeListener(self,listener):
    """Removes a listener from the Subscription instance so that it will not receive 
    events anymore.
    
    **lifecycle** a listener can be removed at any time.
    
    :param listener: The listener to be removed.
    
    .. seealso:: :meth:`addListener`
    """
    pass

  def getListeners(self):
    """Returns a list containing the :class:`SubscriptionListener` instances that were 
    added to this client.

    :return: a list containing the listeners that were added to this client. 
    .. seealso:: :meth:`addListener`
    """
    pass

  def isActive(self):
    """Inquiry method that checks if the Subscription is currently "active" or not.Most of the Subscription properties cannot be modified if a Subscription is "active". 

    The status of a Subscription is changed to "active" through the  
    :meth:`LightstreamerClient.subscribe` method and back to 
    "inactive" through the :meth:`LightstreamerClient.unsubscribe` one.
    
    **lifecycle** This method can be called at any time.
    
    :return: true/false if the Subscription is "active" or not.
    
    .. seealso:: :meth:`LightstreamerClient.subscribe`
    .. seealso:: :meth:`LightstreamerClient.unsubscribe`
    """
    pass

  def isSubscribed(self):
    """Inquiry method that checks if the Subscription is currently subscribed to
    through the server or not. 

    This flag is switched to true by server sent Subscription events, and 
    back to false in case of client disconnection, 
    :meth:`LightstreamerClient.unsubscribe` calls and server 
    sent unsubscription events. 
    
    **lifecycle** This method can be called at any time.
    
    :return: true/false if the Subscription is subscribed to through the server or not.
    """
    pass

  def getDataAdapter(self):
    """Inquiry method that can be used to read the name of the Data Adapter specified for this 
    Subscription through :meth:`setDataAdapter`.
    **lifecycle** This method can be called at any time.

    :return: the name of the Data Adapter; returns null if no name has been configured, so that the "DEFAULT" Adapter Set is used.
    """
    pass

  def setDataAdapter(self,dataAdapter):
    """Setter method that sets the name of the Data Adapter
    (within the Adapter Set used by the current session)
    that supplies all the items for this Subscription. 

    The Data Adapter name is configured on the server side through
    the "name" attribute of the "data_provider" element, in the
    "adapters.xml" file that defines the Adapter Set (a missing attribute
    configures the "DEFAULT" name). 

    Note that if more than one Data Adapter is needed to supply all the
    items in a set of items, then it is not possible to group all the
    items of the set in a single Subscription. Multiple Subscriptions
    have to be defined.
    
    **default** The default Data Adapter for the Adapter Set,
    configured as "DEFAULT" on the Server.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param dataAdapter: the name of the Data Adapter. A null value is equivalent to the "DEFAULT" name.
     
    .. seealso:: :meth:`ConnectionDetails.setAdapterSet`
    """
    pass

  def getMode(self):
    """Inquiry method that can be used to read the mode specified for this
    Subscription.
    
    **lifecycle** This method can be called at any time.
    
    :return: the Subscription mode specified in the constructor.
    """
    pass

  def getItems(self):
    """Inquiry method that can be used to read the "Item List" specified for this Subscription. 
    Note that if the single-item-constructor was used, this method will return an array 
    of length 1 containing such item.
    
    **lifecycle** This method can only be called if the Subscription has been initialized 
    with an "Item List".

    :raises IllegalStateException: if the Subscription was initialized with an "Item Group" or was not initialized at all.
    :return: the "Item List" to be subscribed to through the server.
    """
    pass

  def setItems(self,items):
    """Setter method that sets the "Item List" to be subscribed to through 
    Lightstreamer Server. 

    Any call to this method will override any "Item List" or "Item Group"
    previously specified.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalArgumentException: if any of the item names in the "Item List" contains a space or is a number or is empty/null.
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param items: an array of items to be subscribed to through the server. 
    """
    pass

  def getItemGroup(self):
    """Inquiry method that can be used to read the item group specified for this Subscription.
    
    **lifecycle** This method can only be called if the Subscription has been initialized
    using an "Item Group"

    :raises IllegalStateException: if the Subscription was initialized with an "Item List" or was not initialized at all.
    :return: the "Item Group" to be subscribed to through the server.
    """
    pass

  def setItemGroup(self,group):
    """Setter method that sets the "Item Group" to be subscribed to through 
    Lightstreamer Server. 

    Any call to this method will override any "Item List" or "Item Group"
    previously specified.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param groupName: A String to be expanded into an item list by the Metadata Adapter. 
    """
    pass

  def getFields(self):
    """Inquiry method that can be used to read the "Field List" specified for this Subscription.
    
    **lifecycle**  This method can only be called if the Subscription has been initialized 
    using a "Field List".

    :raises IllegalStateException: if the Subscription was initialized with a "Field Schema" or was not initialized at all.
    :return: the "Field List" to be subscribed to through the server.
    """
    pass

  def setFields(self,fields):
    """Setter method that sets the "Field List" to be subscribed to through 
    Lightstreamer Server. 

    Any call to this method will override any "Field List" or "Field Schema"
    previously specified.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalArgumentException: if any of the field names in the list contains a space or is empty/null.
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param fields: an array of fields to be subscribed to through the server. 
    """
    pass

  def getFieldSchema(self):
    """Inquiry method that can be used to read the field schema specified for this Subscription.
    
    **lifecycle** This method can only be called if the Subscription has been initialized 
    using a "Field Schema"

    :raises IllegalStateException: if the Subscription was initialized with a "Field List" or was not initialized at all.
    :return: the "Field Schema" to be subscribed to through the server.
    """
    pass

  def setFieldSchema(self,schema):
    """Setter method that sets the "Field Schema" to be subscribed to through 
    Lightstreamer Server. 

    Any call to this method will override any "Field List" or "Field Schema"
    previously specified.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param schemaName: A String to be expanded into a field list by the Metadata Adapter. 
    """
    pass

  def getRequestedBufferSize(self):
    """Inquiry method that can be used to read the buffer size, configured though
    :meth:`setRequestedBufferSize`, to be requested to the Server for 
    this Subscription.
    
    **lifecycle** This method can be called at any time.
    
    :return:  An integer number, representing the buffer size to be requested to the server, or the string "unlimited", or null.
    """
    pass

  def setRequestedBufferSize(self,size):
    """Setter method that sets the length to be requested to Lightstreamer
    Server for the internal queuing buffers for the items in the Subscription.
    A Queuing buffer is used by the Server to accumulate a burst
    of updates for an item, so that they can all be sent to the client,
    despite of bandwidth or frequency limits. It can be used only when the
    subscription mode is MERGE or DISTINCT and unfiltered dispatching has
    not been requested. Note that the Server may pose an upper limit on the
    size of its internal buffers.
    
    **default** null, meaning to lean on the Server default based on the subscription
    mode. This means that the buffer size will be 1 for MERGE 
    subscriptions and "unlimited" for DISTINCT subscriptions. See 
    the "General Concepts" document for further details.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalArgumentException: if the specified value is not null nor "unlimited" nor a valid positive integer number.
    
    :param size:  An integer number, representing the length of the internal queuing buffers to be used in the Server. If the string "unlimited" is supplied, then no buffer size limit is requested (the check is case insensitive). It is also possible to supply a null value to stick to the Server default (which currently depends on the subscription mode).
    
    .. seealso:: :meth:`Subscription.setRequestedMaxFrequency`
    """
    pass

  def getRequestedSnapshot(self):
    """Inquiry method that can be used to read the snapshot preferences, 
    configured through :meth:`setRequestedSnapshot`, to be requested 
    to the Server for this Subscription.
    
    **lifecycle** This method can be called at any time.
    
    :return:  "yes", "no", null, or an integer number.
    """
    pass

  def setRequestedSnapshot(self,snapshot):
    """Setter method that enables/disables snapshot delivery request for the
    items in the Subscription. The snapshot can be requested only if the
    Subscription mode is MERGE, DISTINCT or COMMAND.
    
    **default** "yes" if the Subscription mode is not "RAW",
    null otherwise.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalArgumentException: if the specified value is not "yes" nor "no" nor null nor a valid integer positive number.
    :raises IllegalArgumentException: if the specified value is not compatible with the mode of the Subscription: 
    
      * In case of a RAW Subscription only null is a valid value;
      * In case of a non-DISTINCT Subscription only null "yes" and "no" are valid values.
    
    
    :param required: "yes"/"no" to request/not request snapshot delivery (the check is case insensitive). If the Subscription mode is DISTINCT, instead of "yes", it is also possible to supply an integer number, to specify the requested length of the snapshot (though the length of the received snapshot may be less than requested, because of insufficient data or server side limits); passing "yes"  means that the snapshot length should be determined only by the Server. Null is also a valid value; if specified, no snapshot preference will be sent to the server that will decide itself whether or not to send any snapshot. 
    
    .. seealso:: :meth:`ItemUpdate.isSnapshot`
    """
    pass

  def getRequestedMaxFrequency(self):
    """Inquiry method that can be used to read the max frequency, configured
    through :meth:`setRequestedMaxFrequency`, to be requested to the 
    Server for this Subscription.
    
    **lifecycle** This method can be called at any time.
    
    :return:  A decimal number, representing the max frequency to be requested to the server (expressed in updates per second), or the strings "unlimited" or "unfiltered", or null.
    """
    pass

  def setRequestedMaxFrequency(self,freq):
    """Setter method that sets the maximum update frequency to be requested to
Lightstreamer Server for all the items in the Subscription. It can
be used only if the Subscription mode is MERGE, DISTINCT or
COMMAND (in the latter case, the frequency limitation applies to the
UPDATE events for each single key). For Subscriptions with two-level behavior
(see :meth:`Subscription.setCommandSecondLevelFields` and :meth:`Subscription.setCommandSecondLevelFieldSchema`)
, the specified frequency limit applies to both first-level and second-level items. 

Note that frequency limits on the items can also be set on the
server side and this request can only be issued in order to furtherly
reduce the frequency, not to rise it beyond these limits. 

This method can also be used to request unfiltered dispatching
for the items in the Subscription. However, unfiltered dispatching
requests may be refused if any frequency limit is posed on the server
side for some item.
    
**general edition note** A further global frequency limit could also be imposed by the Server,
depending on Edition and License Type; this specific limit also applies to RAW mode and
to unfiltered dispatching.
To know what features are enabled by your license, please see the License tab of the
Monitoring Dashboard (by default, available at /dashboard).
    
**default** null, meaning to lean on the Server default based on the subscription
mode. This consists, for all modes, in not applying any frequency 
limit to the subscription (the same as "unlimited"); see the "General Concepts"
document for further details.
    
**lifecycle** This method can can be called at any time with some
differences based on the Subscription status:
    
  * If the Subscription instance is in its "inactive" state then this method can be called at will.
  * If the Subscription instance is in its "active" state then the method can still be called unless the current value is "unfiltered" or the supplied value is "unfiltered" or null. If the Subscription instance is in its "active" state and the connection to the server is currently open, then a request to change the frequency of the Subscription on the fly is sent to the server.
    
:raises IllegalStateException: if the Subscription is currently "active" and the current value of this property is "unfiltered".
:raises IllegalStateException: if the Subscription is currently "active" and the given parameter is null or "unfiltered".
:raises IllegalArgumentException: if the specified value is not null nor one of the special "unlimited" and "unfiltered" values nor a valid positive number.
    
:param freq:  A decimal number, representing the maximum update frequency (expressed in updates per second) for each item in the Subscription; for instance, with a setting of 0.5, for each single item, no more than one update every 2 seconds will be received. If the string "unlimited" is supplied, then no frequency limit is requested. It is also possible to supply the string "unfiltered", to ask for unfiltered dispatching, if it is allowed for the items, or a null value to stick to the Server default (which currently corresponds to "unlimited"). The check for the string constants is case insensitive.
    """
    pass

  def getSelector(self):
    """Inquiry method that can be used to read the selector name  
    specified for this Subscription through :meth:`setSelector`.
    
    **lifecycle** This method can be called at any time.
    
    :return: the name of the selector.
    """
    pass

  def setSelector(self,selector):
    """Setter method that sets the selector name for all the items in the
    Subscription. The selector is a filter on the updates received. It is
    executed on the Server and implemented by the Metadata Adapter.
    
    **default** null (no selector).
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param selector: name of a selector, to be recognized by the Metadata Adapter, or null to unset the selector.
    """
    pass

  def getCommandPosition(self):
    """Returns the position of the "command" field in a COMMAND Subscription. 

    This method can only be used if the Subscription mode is COMMAND and the Subscription 
    was initialized using a "Field Schema".
    
    **lifecycle** This method can be called at any time after the first 
    :meth:`SubscriptionListener.onSubscription` event.

    :raises IllegalStateException: if the Subscription mode is not COMMAND or if the :meth:`SubscriptionListener.onSubscription` event for this Subscription was not yet fired.
    :raises IllegalStateException: if a "Field List" was specified.

    :return: the 1-based position of the "command" field within the "Field Schema".
    """
    pass

  def getKeyPosition(self):
    """Returns the position of the "key" field in a COMMAND Subscription. 

    This method can only be used if the Subscription mode is COMMAND
    and the Subscription was initialized using a "Field Schema".
     
    **lifecycle** This method can be called at any time.
    
    :raises IllegalStateException: if the Subscription mode is not COMMAND or if the :meth:`SubscriptionListener.onSubscription` event for this Subscription was not yet fired.
    
    :return: the 1-based position of the "key" field within the "Field Schema".
    """
    pass

  def getCommandSecondLevelDataAdapter(self):
    """Inquiry method that can be used to read the second-level Data Adapter name configured 
    through :meth:`setCommandSecondLevelDataAdapter`.
    
    **lifecycle** This method can be called at any time.

    :raises IllegalStateException: if the Subscription mode is not COMMAND
    :return: the name of the second-level Data Adapter.
    
    .. seealso:: :meth:`setCommandSecondLevelDataAdapter`
    """
    pass

  def setCommandSecondLevelDataAdapter(self,dataAdapter):
    """Setter method that sets the name of the second-level Data Adapter (within 
    the Adapter Set used by the current session) that supplies all the 
    second-level items. 

    All the possible second-level items should be supplied in "MERGE" mode 
    with snapshot available. 
 
    The Data Adapter name is configured on the server side through the 
    "name" attribute of the <data_provider> element, in the "adapters.xml" 
    file that defines the Adapter Set (a missing attribute configures the 
    "DEFAULT" name).
    
    **default** The default Data Adapter for the Adapter Set,
    configured as "DEFAULT" on the Server.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalStateException: if the Subscription mode is not "COMMAND".
    
    :param dataAdapter: the name of the Data Adapter. A null value is equivalent to the "DEFAULT" name.
     
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFields`
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFieldSchema`
    """
    pass

  def getCommandSecondLevelFields(self):
    """Inquiry method that can be used to read the "Field List" specified for second-level 
    Subscriptions.
    
    **lifecycle** This method can only be called if the second-level of this Subscription 
    has been initialized using a "Field List"

    :raises IllegalStateException: if the Subscription was initialized with a "Field Schema" or was not initialized at all.
    :raises IllegalStateException: if the Subscription mode is not COMMAND
    :return: the list of fields to be subscribed to through the server.
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFields`
    """
    pass

  def setCommandSecondLevelFields(self,fields):
    """Setter method that sets the "Field List" to be subscribed to through 
    Lightstreamer Server for the second-level items. It can only be used on
    COMMAND Subscriptions. 

    Any call to this method will override any "Field List" or "Field Schema"
    previously specified for the second-level. 

    Calling this method enables the two-level behavior:

    in synthesis, each time a new key is received on the COMMAND Subscription, 
    the key value is treated as an Item name and an underlying Subscription for
    this Item is created and subscribed to automatically, to feed fields specified
    by this method. This mono-item Subscription is specified through an "Item List"
    containing only the Item name received. As a consequence, all the conditions
    provided for subscriptions through Item Lists have to be satisfied. The item is 
    subscribed to in "MERGE" mode, with snapshot request and with the same maximum
    frequency setting as for the first-level items (including the "unfiltered" 
    case). All other Subscription properties are left as the default. When the 
    key is deleted by a DELETE command on the first-level Subscription, the 
    associated second-level Subscription is also unsubscribed from. 
 
    Specifying null as parameter will disable the two-level behavior.
          
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalArgumentException: if any of the field names in the "Field List" contains a space or is empty/null.
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalStateException: if the Subscription mode is not "COMMAND".
    
    :param fields: An array of Strings containing a list of fields to be subscribed to through the server. Ensure that no name conflict is generated between first-level and second-level fields. In case of conflict, the second-level field will not be accessible by name, but only by position.
    
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFieldSchema`
    """
    pass

  def getCommandSecondLevelFieldSchema(self):
    """Inquiry method that can be used to read the "Field Schema" specified for second-level 
    Subscriptions.
    
    **lifecycle** This method can only be called if the second-level of this Subscription has 
    been initialized using a "Field Schema".

    :raises IllegalStateException: if the Subscription was initialized with a "Field List" or was not initialized at all.
    :raises IllegalStateException: if the Subscription mode is not COMMAND
    :return: the "Field Schema" to be subscribed to through the server.
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFieldSchema`
    """
    pass

  def setCommandSecondLevelFieldSchema(self,schema):
    """Setter method that sets the "Field Schema" to be subscribed to through 
    Lightstreamer Server for the second-level items. It can only be used on
    COMMAND Subscriptions. 

    Any call to this method will override any "Field List" or "Field Schema"
    previously specified for the second-level. 

    Calling this method enables the two-level behavior:

    in synthesis, each time a new key is received on the COMMAND Subscription, 
    the key value is treated as an Item name and an underlying Subscription for
    this Item is created and subscribed to automatically, to feed fields specified
    by this method. This mono-item Subscription is specified through an "Item List"
    containing only the Item name received. As a consequence, all the conditions
    provided for subscriptions through Item Lists have to be satisfied. The item is 
    subscribed to in "MERGE" mode, with snapshot request and with the same maximum
    frequency setting as for the first-level items (including the "unfiltered" 
    case). All other Subscription properties are left as the default. When the 
    key is deleted by a DELETE command on the first-level Subscription, the 
    associated second-level Subscription is also unsubscribed from. 

    Specify null as parameter will disable the two-level behavior.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalStateException: if the Subscription mode is not "COMMAND".
    
    :param schemaName: A String to be expanded into a field list by the Metadata Adapter. 
    
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFields`
    """
    pass

  def getValue(self,itemNameOrPos,fieldNameOrPos):
    """Returns the latest value received for the specified item/field pair.
     
It is suggested to consume real-time data by implementing and adding
a proper :class:`SubscriptionListener` rather than probing this method.
In case of COMMAND Subscriptions, the value returned by this
method may be misleading, as in COMMAND mode all the keys received, being
part of the same item, will overwrite each other; for COMMAND Subscriptions,
use :meth:`Subscription.getCommandValue` instead.
     
Note that internal data is cleared when the Subscription is 
unsubscribed from. 
     
**lifecycle** This method can be called at any time; if called 
to retrieve a value that has not been received yet, then it will return null. 
          
:raises IllegalArgumentException: if an invalid item name or field name is specified or if the specified item position or field position is out of bounds.
     
:param itemIdentifier: a String representing an item in the configured item list or a Number representing the 1-based position of the item in the specified item group. (In case an item list was specified, passing the item position is also possible).
     
:param fieldIdentifier: a String representing a field in the configured field list or a Number representing the 1-based position of the field in the specified field schema. (In case a field list was specified, passing the field position is also possible).
     
:return: the current value for the specified field of the specified item(possibly null), or null if no value has been received yet.
     """
    pass

  def getCommandValue(self,itemNameOrPos,keyValue,fieldNameOrPos):
    """Returns the latest value received for the specified item/key/field combination. This method can only be used if the Subscription mode is COMMAND. Subscriptions with two-level behavior are also supported, hence the specified field can be either a first-level or a second-level one.
     
It is suggested to consume real-time data by implementing and adding a proper :class:`SubscriptionListener` rather than probing this method.
     
Note that internal data is cleared when the Subscription is unsubscribed from. 
     
**lifecycle** This method can be called at any time; if called to retrieve a value that has not been received yet, then it will return null.
          
:raises IllegalArgumentException: if an invalid item name or field name is specified or if the specified item position or field position is out of bounds.
:raises IllegalStateException: if the Subscription mode is not COMMAND.
     
:param itemIdentifier: a String representing an item in the configured item list or a Number representing the 1-based position of the item in the specified item group. (In case an item list was specified, passing the item position is also possible).
     
:param keyValue: a String containing the value of a key received on the COMMAND subscription.
     
:param fieldIdentifier: a String representing a field in the configured field list or a Number representing the 1-based position of the field in the specified field schema. (In case a field list was specified, passing the field position is also possible).
     
:return: the current value for the specified field of the specified key within the specified item (possibly null), or null if the specified key has not been added yet (note that it might have been added and eventually deleted).
    """
    pass

class ConsoleLoggerProvider(LoggerProvider):
  """This LoggerProvider rests on the standard logging facility provided by the module *logging*. The log events are forwarded to the logger named *lightstreamer*.

  :param level: the threshold of the loggers created by this provider (see :class:`ConsoleLogLevel`)
  """

  def __init__(self,level):
    pass

  def getLogger(self,category):
    pass

class ConsoleLogLevel:
  """The threshold configured for an instance of :class:`ConsoleLoggerProvider`.
  """

  TRACE = 0
  """Trace logging level.
  
  This level enables all logging.
  """
  DEBUG = 10
  """Debug logging level.
  
  This level enables logging for debug, information, warnings, errors and fatal errors.
  """
  INFO = 20
  """Info logging level.
  
  This level enables logging for information, warnings, errors and fatal errors.
  """
  WARN = 30
  """Warn logging level.
  
  This level enables logging for warnings, errors and fatal errors.
  """
  ERROR = 40
  """Error logging level.
  
  This level enables logging for errors and fatal errors.
  """
  FATAL = 50
  """Fatal logging level.
  
  This level enables logging for fatal errors.
  """
