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
// #ifndef START_NODE_JSDOC_EXCLUDE
   * <BR>A ClientListener implementation is distributed together with the library:
   * {@link StatusWidget}.
// #endif
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
// #ifndef START_NODE_JSDOC_EXCLUDE
     * on a different browser window
// #endif
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
// #ifndef START_NODE_JSDOC_EXCLUDE
     * <li>In case the local LightstreamerClient is exploiting the connection of a
     * different LightstreamerClient (see {@link ConnectionSharing}) and such
     * LightstreamerClient or its container window is disposed, the status will
     * switch to "DISCONNECTED:WILL-RETRY" unless the current status is "DISCONNECTED".
     * In the latter case it will remain "DISCONNECTED".</li>
// #endif
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
// #ifndef START_NODE_JSDOC_EXCLUDE
     * <BR>Properties of these objects can be modified by direct calls to them, but
     * also by calls performed on other LightstreamerClient instances sharing the
     * same connection and by server sent events.
// #endif
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

// #ifndef START_NODE_JSDOC_EXCLUDE
    /**
     * Event handler that receives a notification in case a connection
     * sharing is aborted.
     * A connection sharing can only be aborted if one of the policies specified
     * in the {@link ConnectionSharing} instance supplied to the
     * {@link LightstreamerClient#enableSharing} method is "ABORT".
     * <BR>If this event is fired the client will never be able to connect to
     * the server unless a new call to enableSharing is issued.
     */
// #endif
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

// #ifndef START_NODE_JSDOC_EXCLUDE
    /**
     * Notifies that the Server has sent a keepalive message because a streaming connection
     * is in place and no update had been sent for the configured time
     * (see {@link ConnectionOptions#setKeepaliveInterval}).
     * However, note that the lack of both updates and keepalives is already managed by the library
     * (see {@link ConnectionOptions#setReconnectTimeout} and {@link ConnectionOptions#setStalledTimeout}).
     */
// #endif
    onServerKeepalive: function() {

    }

};
