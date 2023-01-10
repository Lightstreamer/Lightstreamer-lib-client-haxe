  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports Logger
   * @class Simple Interface to be implemented to produce log.
   */
var Logger = function() {
};


Logger.prototype = {
    
    /**
     * Receives log messages at FATAL level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     * 
     * @see LoggerProvider
     */
    fatal: function(message,exception) {
      
    },
    
    /**
     * Checks if this Logger is enabled for the FATAL level. 
     * The method should return true if this Logger is enabled for FATAL events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log FATAL statements. However, even if the method returns false, FATAL log 
     * lines may still be received by the {@link Logger#fatal} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if FATAL logging is enabled, false otherwise
     */
    isFatalEnabled: function() {
      
    },
    
    /**
     * Receives log messages at ERROR level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    error: function(message,exception) {
      
    },
    
    /**
     * Checks if this Logger is enabled for the ERROR level. 
     * The method should return true if this Logger is enabled for ERROR events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log ERROR statements. However, even if the method returns false, ERROR log 
     * lines may still be received by the {@link Logger#error} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if ERROR logging is enabled, false otherwise
     */
    isErrorEnabled: function() {
      
    },
    
    /**
     * Receives log messages at WARN level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    warn: function(message,exception) {
      
    },
    
    /**
     * Checks if this Logger is enabled for the WARN level. 
     * The method should return true if this Logger is enabled for WARN events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log WARN statements. However, even if the method returns false, WARN log 
     * lines may still be received by the {@link Logger#warn} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if WARN logging is enabled, false otherwise
     */
    isWarnEnabled: function() {
      
    },
    
    /**
     * Receives log messages at INFO level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    info: function(message,exception) {
      
    },

    /**
     * Checks if this Logger is enabled for the INFO level. 
     * The method should return true if this Logger is enabled for INFO events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log INFO statements. However, even if the method returns false, INFO log 
     * lines may still be received by the {@link Logger#info} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if INFO logging is enabled, false otherwise
     */
    isInfoEnabled: function() {
      
    },
    
    /**
     * Receives log messages at DEBUG level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    debug: function(message,exception) {
      
    },

    /**
     * Checks if this Logger is enabled for the DEBUG level. 
     * The method should return true if this Logger is enabled for DEBUG events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log DEBUG statements. However, even if the method returns false, DEBUG log 
     * lines may still be received by the {@link Logger#debug} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if DEBUG logging is enabled, false otherwise
     */
    isDebugEnabled: function() {
      
    },

    /**
     * Receives log messages at TRACE level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    trace: function(message,exception) {
      
    },

    /**
     * Checks if this Logger is enabled for the TRACE level. 
     * The method should return true if this Logger is enabled for TRACE events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log TRACE statements. However, even if the method returns false, TRACE log 
     * lines may still be received by the {@link Logger#trace} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if TRACE logging is enabled, false otherwise
     */
    isTraceEnabled: function() {
      
    }
};

  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports LoggerProvider
   * @class Simple interface to be implemented to provide custom log producers
   * through {@link module:LoggerManager.setLoggerProvider}.
   * 
   * <BR>A simple implementation of this interface is included with this library: 
   * {@link SimpleLoggerProvider}.
   */
var LoggerProvider = function() {
    
};

LoggerProvider.prototype = {
  
    /**
     * Invoked by the {@link module:LoggerManager} to request a {@link Logger} instance that will be used for logging occurring 
     * on the given category. It is suggested, but not mandatory, that subsequent 
     * calls to this method related to the same category return the same {@link Logger}
     * instance.
     * 
     * @param {String} category the log category all messages passed to the given 
     * Logger instance will pertain to. 
     * 
     * @return {Logger} A Logger instance that will receive log lines related to 
     * the given category.
     */
    getLogger: function(category) {
      
    }
    
};

  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   *
   * @exports ClientListener
   * @class Interface to be implemented to listen to {@link LightstreamerClient} events
   * comprehending notifications of connection activity and errors.
   * <BR>Events for these listeners are executed asynchronously with respect to the code
   * that generates them. This means that, upon reception of an event, it is possible that
   * the current state of the client has changed furtherly.
   * <BR>Note that it is not necessary to implement all of the interface methods for
   * the listener to be successfully passed to the {@link LightstreamerClient#addListener}
   * method.
START_NODE_JSDOC_EXCLUDE
   * <BR>A ClientListener implementation is distributed together with the library:
   * {@link StatusWidget}.
END_NODE_JSDOC_EXCLUDE
   */
function ClientListener() {

};

ClientListener.prototype = {
    /**
     * Event handler that is called when the Server notifies a refusal on the
     * client attempt to open a new connection or the interruption of a
     * streaming connection. In both cases, the {@link ClientListener#onStatusChange}
     * event handler has already been invoked with a "DISCONNECTED" status and
     * no recovery attempt has been performed. By setting a custom handler, however,
     * it is possible to override this and perform custom recovery actions.
     *
     * @param {Number} errorCode The error code. It can be one of the
     * following:
     * <ul>
     * <li>1 - user/password check failed</li>
     * <li>2 - requested Adapter Set not available</li>
     * <li>7 - licensed maximum number of sessions reached
     * (this can only happen with some licenses)</li>
     * <li>8 - configured maximum number of sessions reached</li>
     * <li>9 - configured maximum server load reached</li>
     * <li>10 - new sessions temporarily blocked</li>
     * <li>11 - streaming is not available because of Server license
     * restrictions (this can only happen with special licenses)</li>
     * <li>21 - a bind request has unexpectedly reached a wrong Server instance, which suggests that a routing issue may be in place</li>
     * <li>30-41 - the current connection or the whole session has been closed
     * by external agents; the possible cause may be:
     * <ul>
     * <li>The session was closed on the Server side (via software or by
     * the administrator) (32) or through a client "destroy" request (31);</li>
     * <li>The Metadata Adapter imposes limits on the overall open sessions
     * for the current user and has requested the closure of the current session
     * upon opening of a new session for the same user
START_NODE_JSDOC_EXCLUDE
     * on a different browser window
END_NODE_JSDOC_EXCLUDE
     * (35);</li>
     * <li>An unexpected error occurred on the Server while the session was in
     * activity (33, 34);</li>
     * <li>An unknown or unexpected cause; any code different from the ones
     * identified in the above cases could be issued.</li>
     * </ul>
     * A detailed description for the specific cause is currently not supplied
     * (i.e. errorMessage is null in this case).</li>
     * <li>60 - this version of the client is not allowed by the current license terms.</li>
     * <li>61 - there was an error in the parsing of the server response thus the client cannot continue with the current session.</li>
     * <li>66 - an unexpected exception was thrown by the Metadata Adapter while authorizing the connection.</li>
     * <li>68 - the Server could not open or continue with the session because of an internal error.</li>
     * <li>70 - an unusable port was configured on the server address.</li>
     * <li>71 - this kind of client is not allowed by the current license terms.</li>
     * <li>&lt;= 0 - the Metadata Adapter has refused the user connection;
     * the code value is dependent on the specific Metadata Adapter
     * implementation</li>
     * </ul>
     * @param {String} errorMessage The description of the error as sent
     * by the Server.
     *
     * @see ConnectionDetails#setAdapterSet
     * @see ClientListener#onStatusChange
     */
    onServerError: function(errorCode, errorMessage) {

    },

    /**
     * Event handler that receives a notification each time the LightstreamerClient
     * status has changed. The status changes may be originated either by custom
     * actions (e.g. by calling {@link LightstreamerClient#disconnect}) or by
     * internal actions.
     * <BR/><BR/>The normal cases are the following:
     * <ul>
     * <li>After issuing connect(), if the current status is "DISCONNECTED*", the
     * client will switch to "CONNECTING" first and
     * to "CONNECTED:STREAM-SENSING" as soon as the pre-flight request receives its
     * answer.
     * <BR>As soon as the new session is established, it will switch to
     * "CONNECTED:WS-STREAMING" if the browser/environment permits WebSockets;
     * otherwise it will switch to "CONNECTED:HTTP-STREAMING" if the
     * browser/environment permits streaming or to "CONNECTED:HTTP-POLLING"
     * as a last resort.
     * <BR>On the other hand if the status is already "CONNECTED:*" a
     * switch to "CONNECTING" is usually not needed.</li>
     * <li>After issuing disconnect(), the status will switch to "DISCONNECTED".</li>
     * <li>In case of a server connection refusal, the status may switch from
     * "CONNECTING" directly to "DISCONNECTED". After that, the
     * {@link ClientListener#onServerError} event handler will be invoked.</li>
     * </ul>
     * <BR/>Possible special cases are the following:
     * <ul>
     * <li>In case of Server unavailability during streaming, the status may
     * switch from "CONNECTED:*-STREAMING" to "STALLED" (see
     * {@link ConnectionOptions#setStalledTimeout}).
     * If the unavailability ceases, the status will switch back to
     * ""CONNECTED:*-STREAMING"";
     * otherwise, if the unavailability persists (see
     * {@link ConnectionOptions#setReconnectTimeout}),
     * the status will switch to "DISCONNECTED:TRYING-RECOVERY" and eventually to
     * "CONNECTED:*-STREAMING".</li>
     * <li>In case the connection or the whole session is forcibly closed
     * by the Server, the status may switch from "CONNECTED:*-STREAMING"
     * or "CONNECTED:*-POLLING" directly to "DISCONNECTED". After that, the
     * {@link ClientListener#onServerError} event handler will be invoked.</li>
     * <li>Depending on the setting in {@link ConnectionOptions#setSlowingEnabled},
     * in case of slow update processing, the status may switch from
     * "CONNECTED:WS-STREAMING" to "CONNECTED:WS-POLLING" or from
     * "CONNECTED:HTTP-STREAMING" to "CONNECTED:HTTP-POLLING".</li>
     * <li>If the status is "CONNECTED:*-POLLING" and any problem during an
     * intermediate poll occurs, the status may switch to "CONNECTING" and
     * eventually to "CONNECTED:*-POLLING". The same may hold for the
     * "CONNECTED:*-STREAMING" case, when a rebind is needed.</li>
     * <li>In case a forced transport was set through
     * {@link ConnectionOptions#setForcedTransport}, only the related final
     * status or statuses are possible. Note that if the transport is forced
     * while a Session is active and this requires a reconnection, the status
     * may do a preliminary switch to CONNECTED:STREAM-SENSING.</li>
     * <li>In case of connection problems, the status may switch from any value
     * to "DISCONNECTED:WILL-RETRY" (see {@link ConnectionOptions#setRetryDelay}),
     * then to "CONNECTING" and a new attempt will start.
     * However, in most cases, the client will try to recover the current session;
     * hence, the "DISCONNECTED:TRYING-RECOVERY" status will be entered
     * and the recovery attempt will start.</li>
     * <li>In case of connection problems during a recovery attempt, the status may stay
     * in "DISCONNECTED:TRYING-RECOVERY" for long time, while further attempts are made.
     * On the other hand, if the connection is successful, the status will do
     * a preliminary switch to CONNECTED:STREAM-SENSING. If the recovery is finally
     * unsuccessful, the current session will be abandoned and the status
     * will switch to "DISCONNECTED:WILL-RETRY" before the next attempts.</li>
START_NODE_JSDOC_EXCLUDE
     * <li>In case the local LightstreamerClient is exploiting the connection of a
     * different LightstreamerClient (see {@link ConnectionSharing}) and such
     * LightstreamerClient or its container window is disposed, the status will
     * switch to "DISCONNECTED:WILL-RETRY" unless the current status is "DISCONNECTED".
     * In the latter case it will remain "DISCONNECTED".</li>
END_NODE_JSDOC_EXCLUDE
     * </ul>
     *
     * <BR>By setting a custom handler it is possible to perform
     * actions related to connection and disconnection occurrences. Note that
     * {@link LightstreamerClient#connect} and {@link LightstreamerClient#disconnect},
     * as any other method, can be issued directly from within a handler.
     *
     * @param {String} chngStatus The new status. It can be one of the
     * following values:
     * <ul>
     * <li>"CONNECTING" the client has started a connection attempt and is
     * waiting for a Server answer.</li>
     * <li>"CONNECTED:STREAM-SENSING" the client received a first response from
     * the server and is now evaluating if a streaming connection is fully
     * functional. </li>
     * <li>"CONNECTED:WS-STREAMING" a streaming connection over WebSocket has
     * been established.</li>
     * <li>"CONNECTED:HTTP-STREAMING" a streaming connection over HTTP has
     * been established.</li>
     * <li>"CONNECTED:WS-POLLING" a polling connection over WebSocket has
     * been started. Note that, unlike polling over HTTP, in this case only one
     * connection is actually opened (see {@link ConnectionOptions#setSlowingEnabled}).
     * </li>
     * <li>"CONNECTED:HTTP-POLLING" a polling connection over HTTP has
     * been started.</li>
     * <li>"STALLED" a streaming session has been silent for a while,
     * the status will eventually return to its previous CONNECTED:*-STREAMING
     * status or will switch to "DISCONNECTED:WILL-RETRY" / "DISCONNECTED:TRYING-RECOVERY".</li>
     * <li>"DISCONNECTED:WILL-RETRY" a connection or connection attempt has been
     * closed; a new attempt will be performed (possibly after a timeout).</li>
     * <li>"DISCONNECTED:TRYING-RECOVERY" a connection has been closed and
     * the client has started a connection attempt and is waiting for a Server answer;
     * if successful, the underlying session will be kept.</li>
     * <li>"DISCONNECTED" a connection or connection attempt has been closed. The
     * client will not connect anymore until a new {@link LightstreamerClient#connect}
     * call is issued.</li>
     * </ul>
     *
     * @see LightstreamerClient#connect
     * @see LightstreamerClient#disconnect
     * @see LightstreamerClient#getStatus
     */
    onStatusChange: function(chngStatus) {
    },

    /**
     * Event handler that receives a notification each time  the value of a property of
     * {@link LightstreamerClient#connectionDetails} or {@link LightstreamerClient#connectionOptions}
     * is changed.
START_NODE_JSDOC_EXCLUDE
     * <BR>Properties of these objects can be modified by direct calls to them, but
     * also by calls performed on other LightstreamerClient instances sharing the
     * same connection and by server sent events.
END_NODE_JSDOC_EXCLUDE
     *
     * @param {String} the name of the changed property.
     * <BR>Possible values are:
     * <ul>
     * <li>adapterSet</li>
     * <li>serverAddress</li>
     * <li>user</li>
     * <li>password</li>
     * <li>serverInstanceAddress</li>
     * <li>serverSocketName</li>
     * <li>sessionId</li>
     * <li>contentLength</li>
     * <li>idleTimeout</li>
     * <li>keepaliveInterval</li>
     * <li>maxBandwidth</li>
     * <li>pollingInterval</li>
     * <li>reconnectTimeout</li>
     * <li>stalledTimeout</li>
     * <li>retryDelay</li>
     * <li>firstRetryMaxDelay</li>
     * <li>slowingEnabled</li>
     * <li>forcedTransport</li>
     * <li>serverInstanceAddressIgnored</li>
     * <li>cookieHandlingRequired</li>
     * <li>reverseHeartbeatInterval</li>
     * <li>earlyWSOpenEnabled</li>
     * <li>httpExtraHeaders</li>
     * <li>httpExtraHeadersOnSessionCreationOnly</li>
     *
     * </ul>
     *
     * @see LightstreamerClient#connectionDetails
     * @see LightstreamerClient#connectionOptions
     */
    onPropertyChange: function(propertyName) {
    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Event handler that receives a notification in case a connection
     * sharing is aborted.
     * A connection sharing can only be aborted if one of the policies specified
     * in the {@link ConnectionSharing} instance supplied to the
     * {@link LightstreamerClient#enableSharing} method is "ABORT".
     * <BR>If this event is fired the client will never be able to connect to
     * the server unless a new call to enableSharing is issued.
     */
// END_NODE_JSDOC_EXCLUDE
    onShareAbort: function() {

    },

    /**
     * Event handler that receives a notification when the ClientListener instance
     * is added to a LightstreamerClient through
     * {@link LightstreamerClient#addListener}.
     * This is the first event to be fired on the listener.
     *
     * @param {LightstreamerClient} lsClient the LightstreamerClient this
     * instance was added to.
     */
    onListenStart: function(lsClient) {

    },

    /**
     * Event handler that receives a notification when the ClientListener instance
     * is removed from a LightstreamerClient through
     * {@link LightstreamerClient#removeListener}.
     * This is the last event to be fired on the listener.
     *
     * @param {LightstreamerClient} lsClient the LightstreamerClient this
     * instance was removed from.
     */
    onListenEnd: function(lsClient) {

    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Notifies that the Server has sent a keepalive message because a streaming connection
     * is in place and no update had been sent for the configured time
     * (see {@link ConnectionOptions#setKeepaliveInterval}).
     * However, note that the lack of both updates and keepalives is already managed by the library
     * (see {@link ConnectionOptions#setReconnectTimeout} and {@link ConnectionOptions#setStalledTimeout}).
     */
// END_NODE_JSDOC_EXCLUDE
    onServerKeepalive: function() {

    }

};

  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   *
   * @exports ClientMessageListener
   * @class Interface to be implemented to listen to {@link LightstreamerClient#sendMessage}
   * events reporting a message processing outcome.
   * <BR>Events for these listeners are executed asynchronously with respect to the code
   * that generates them.
   * <BR>Note that it is not necessary to implement all of the interface methods for
   * the listener to be successfully passed to the {@link LightstreamerClient#sendMessage}
   * method. On the other hand, if all of the handlers are implemented the library will
   * ensure to call one and only one of them per message.
   */
function ClientMessageListener() {

};

ClientMessageListener.prototype = {
  /**
   * Event handler that is called by Lightstreamer when any notifications
   * of the processing outcome of the related message haven't been received
   * yet and can no longer be received.
   * Typically, this happens after the session has been closed.
   * In this case, the client has no way of knowing the processing outcome
   * and any outcome is possible.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   * @param {boolean} sentOnNetwork true if the message was probably sent on the
   * network, false otherwise.
   * <BR>Event if the flag is true, it is not possible to infer whether the message
   * actually reached the Lightstreamer Server or not.
   */
  onAbort: function(originalMessage,sentOnNetwork) {
    return;
  },

  /**
   * Event handler that is called by Lightstreamer when the related message
   * has been processed by the Server but the processing has failed for any
   * reason. The level of completion of the processing by the Metadata Adapter
   * cannot be determined.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   */
  onError: function(originalMessage) {
    return;
  },

  /**
   * Event handler that is called by Lightstreamer to notify that the related
   * message has been discarded by the Server. This means that the message
   * has not reached the Metadata Adapter and the message next in the sequence
   * is considered enabled for processing.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   */
  onDiscarded: function(originalMessage) {
    return;
  },

  /**
   * Event handler that is called by Lightstreamer when the related message
   * has been processed by the Server but the expected processing outcome
   * could not be achieved for any reason.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   * @param {Number} code the error code sent by the Server. It can be one
   * of the following:
   * <ul>
   * <li>&lt;= 0 - the Metadata Adapter has refused the message; the code
   * value is dependent on the specific Metadata Adapter implementation.</li>
   * </ul>
   * @param {String} message the description of the error sent by the Server.
   */
  onDeny: function(originalMessage,code, message) {
    return;
  },

  /**
   * Event handler that is called by Lightstreamer when the related message
   * has been processed by the Server with success.
   *
   * @param {String} originalMessage the message to which this notification
   * is related.
   */
  onProcessed: function(originalMessage) {
    return;
  }
};

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
     * Receives an iterator function and invokes it once per each field 
     * changed with the last server update. 
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
START_NODE_JSDOC_EXCLUDE
   * <BR>The {@link AbstractWidget} and its subclasses, distributed together 
   * with the library, implement this interface.
   * 
   * @see DynaGrid
   * @see StaticGrid
   * @see Chart
END_NODE_JSDOC_EXCLUDE
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
     *
     * @param {Subscription} subscription the Subscription this
     * instance was added to.
     */
    onListenStart: function(subscription) {
      
    },
    
    /**
     * Event handler that receives a notification when the SubscriptionListener instance 
     * is removed from a Subscription through 
     * {@link Subscription#removeListener}.
     * This is the last event to be fired on the listener.
     *
     * @param {Subscription} subscription the Subscription this
     * instance was removed from.
     */
    onListenEnd: function(subscription) {
      
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
