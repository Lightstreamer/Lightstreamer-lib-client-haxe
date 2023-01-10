 /**
    Creates an instace of the concrete system console logger.
    @constructor
     
    @param level The desired logging level. See {@link ConsoleLogLevel}.

    @exports ConsoleLoggerProvider
    @class Simple concrete logging provider that logs on the system console.
    
    To be used, an instance of this class has to be passed to the library through the {@link LightstreamerClient#setLoggerProvider}.
  */
  var ConsoleLoggerProvider = function(level) {
    this.delegate = new LSConsoleLoggerProvider(level);
  };

  ConsoleLoggerProvider.prototype.getLogger = function(category) {
    return this.delegate.getLogger(category);
  };

  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports ConsoleLogLevel
   * @class  Logging level.
   */
var ConsoleLogLevel = function() {
};

/**
  Trace logging level.
 
  This level enables all logging.
 */
  ConsoleLogLevel.TRACE = LSConsoleLogLevel.TRACE;
  /**
    Debug logging level.
     
    This level enables all logging except tracing.
   */
  ConsoleLogLevel.DEBUG = LSConsoleLogLevel.DEBUG;
  /**
    Info logging level.
     
    This level enables logging for information, warnings, errors and fatal errors.
   */
  ConsoleLogLevel.INFO = LSConsoleLogLevel.INFO;
  /**
    Warn logging level.
     
    This level enables logging for warnings, errors and fatal errors.
   */
  ConsoleLogLevel.WARN = LSConsoleLogLevel.WARN;
  /**
    Error logging level.
     
    This level enables logging for errors and fatal errors.
   */
  ConsoleLogLevel.ERROR = LSConsoleLogLevel.ERROR;
  /**
    Fatal logging level.
     
    This level enables logging for fatal errors only.
   */
  ConsoleLogLevel.FATAL = LSConsoleLogLevel.FATAL;

  /**
   * Used by LightstreamerClient to provide a basic connection properties data object.
   * @constructor
   *
   * @exports ConnectionDetails
   * @class Data object that contains the configuration settings needed
   * to connect to a Lightstreamer Server.
   * <BR/>The class constructor, its prototype and any other properties should never
   * be used directly; the library will create ConnectionDetails instances when needed.
   * <BR>Note that all the settings are applied asynchronously; this means that if a
   * CPU consuming task is performed right after the call, the effect of the setting 
   * will be delayed.
   * 
   * @see LightstreamerClient
   */
var ConnectionDetails = function(details){
  this.delegate = details;
};

ConnectionDetails.prototype = {
   
 /**
  * Setter method that sets the address of Lightstreamer Server.
START_NODE_JSDOC_EXCLUDE
  * Setting Lightstreamer Server address is not required when the front-end
  * pages are supplied by Lightstreamer Server itself (although this
  * scenario is advised only for demo purpose).
  * On the other hand, the setting should be configured if the front-end pages are
  * served by an external Web server or loaded directly from the file system or
  * the library is not running inside a browser. 
  * <BR>When the client application is downloaded from a web server, the configured
  * server address should have the same protocol as the client page itself. If this
  * requirement is not respected, the client, depending on the browser in use, 
  * may be unable to open a streaming connection and will try to resort
  * to polling. 
END_NODE_JSDOC_EXCLUDE
  * <BR>Note that the addresses specified must always have the http: or https: scheme.
  * In case WebSockets are used, the specified scheme is 
  * internally converted to match the related WebSocket protocol
  * (i.e. http becomes ws while https becomes wss).
  * 
  * <p class="edition-note"><B>Edition Note:</B> HTTPS is an optional
* feature, available depending on Edition and License Type.
* To know what features are enabled by your license, please see the License tab of the
* Monitoring Dashboard (by default, available at /dashboard).</p>
  * 
START_NODE_JSDOC_EXCLUDE
  * <p class="default-value"><b>Default value:</b> the address of the server
  * that supplies the library pages if any, null otherwise.</p>
END_NODE_JSDOC_EXCLUDE
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>This method can be called at any time. If called while connected, 
  * it will be applied when the next session creation request is issued.
  * <BR>This setting can also be specified in the {@link LightstreamerClient} 
  * constructor.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "serverAddress" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionDetails upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if the given address is not valid.
  *
  * @param {String} serverAddress The full address of Lightstreamer Server.
  * A null value can also be used, to restore the default value.
  * An IPv4 or IPv6 can also be used in place of a hostname, if compatible with
  * the environment in use (see the notes in the summary of this documentation).
  * Some examples of valid values include:
  * <BR>http://push.mycompany.com
  * <BR>http://push.mycompany.com:8080
  * <BR>http://79.125.7.252
  * <BR>http://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]
  * <BR>http://[2001:0db8:85a3::8a2e:0370:7334]:8080
  * 
  */
 setServerAddress: function(serverAddress) {
  this.delegate.setServerAddress(serverAddress);
 },  
 
 /**
  * Inquiry method that gets the configured address of Lightstreamer Server.
  * 
  * @return {String} the configured address of Lightstreamer Server.
  */
 getServerAddress: function() {
  return this.delegate.getServerAddress();
 },

 /** 
  * Setter method that sets the name of the Adapter Set mounted on 
  * Lightstreamer Server to be used to handle all requests in the session.
  * <BR>An Adapter Set defines the Metadata Adapter and one or several
  * Data Adapters. It is configured on the server side through an
  * "adapters.xml" file; the name is configured through the "id" attribute
  * in the &lt;adapters_conf&gt; element.
  *
  * <p class="default-value"><b>Default value:</b> The default Adapter Set, configured as
  * "DEFAULT" on the Server.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> The Adapter Set name should be set on the
  * {@link LightstreamerClient#connectionDetails} object before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next time a new session is 
  * requested to the server.
  * <BR>This setting can also be specified in the {@link LightstreamerClient} 
  * constructor.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "adapterSet" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionDetails upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @param {String} adapterSet The name of the Adapter Set to be used. A null value 
  * is equivalent to the "DEFAULT" name.
  */
 setAdapterSet: function(adapterSet) {
  this.delegate.setAdapterSet(adapterSet);
 },
 
 /**  
  * Inquiry method that gets the name of the Adapter Set (which defines
  * the Metadata Adapter and one or several Data Adapters) mounted on
  * Lightstreamer Server that supply all the items used in this application.
  *
  * @return {String} the name of the Adapter Set; returns null if no name
  * has been configured, so that the "DEFAULT" Adapter Set is used.
  *
  * @see ConnectionDetails#setAdapterSet
  */
 getAdapterSet: function() {
  return this.delegate.getAdapterSet();
 },
     
 
 /**
  * Setter method that sets the username to be used for the authentication
  * on Lightstreamer Server when initiating the push session.
  * The Metadata Adapter is responsible for checking the credentials
  * (username and password).
  * 
  * <p class="default-value"><b>Default value:</b> If no username is supplied, no user
  * information will be sent at session initiation. The Metadata Adapter,
  * however, may still allow the session.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> The username should be set on the
  * {@link LightstreamerClient#connectionDetails} object before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next time a new session is 
  * requested to the server.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "user" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionDetails upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @param {String} user The username to be used for the authentication
  * on Lightstreamer Server. The username can be null.
  *
  * @see ConnectionDetails#setPassword
  */
 setUser: function(user) {
  this.delegate.setUser(user);
 },
 
 /**  
  * Inquiry method that gets the username to be used for the authentication
  * on Lightstreamer Server when initiating the push session.
  * 
  * @return {String} the username to be used for the authentication
  * on Lightstreamer Server; returns null if no user name
  * has been configured.
  *
  * @see ConnectionDetails#setUser
  */
 getUser: function() {
  return this.delegate.getUser();
 },
 
 /**
  * Setter method that sets the password to be used for the authentication
  * on Lightstreamer Server when initiating the push session.
  * The Metadata Adapter is responsible for checking the credentials
  * (username and password).
  * 
  * <p class="default-value"><b>Default value:</b> If no password is supplied, no password
  * information will be sent at session initiation. The Metadata Adapter,
  * however, may still allow the session.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> The username should be set on the
  * {@link LightstreamerClient#connectionDetails} object before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next time a new session is 
  * requested to the server.
  * <BR><b>NOTE:</b> The password string will be stored as a JavaScript
  * variable.
  * That is necessary in order to allow automatic reconnection/reauthentication
  * for fail-over. For maximum security, avoid using an actual private
  * password to authenticate on Lightstreamer Server; rather use
  * a session-id originated by your web/application server, that can be
  * checked by your Metadata Adapter.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "password" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionDetails upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @param {String} password The password to be used for the authentication
  * on Lightstreamer Server. The password can be null.
  *
  * @see ConnectionDetails#setUser
  */
 setPassword: function(password) {
  this.delegate.setPassword(password);
 },
 
 /**
  * Inquiry method that gets the server address to be used to issue all requests
  * related to the current session. In fact, when a Server cluster is in
  * place, the Server address specified through 
  * {@link ConnectionDetails#setServerAddress} can identify various Server 
  * instances; in order to ensure that all requests related to a session are 
  * issued to the same Server instance, the Server can answer to the session 
  * opening request by providing an address which uniquely identifies its own 
  * instance.
  * When this is the case, this address is returned by the method;
  * otherwise, null is returned.
  * <BR>Note that the addresses will always have the http: or https: scheme.
  * In case WebSockets are used, the specified scheme is 
  * internally converted to match the related WebSocket protocol
  * (i.e. http becomes ws while https becomes wss).
  *
  * <p class="edition-note"><B>Edition Note:</B> Server Clustering is
* an optional feature, available depending on Edition and License Type.
* To know what features are enabled by your license, please see the License tab of the
* Monitoring Dashboard (by default, available at /dashboard).</p>
  *
  * <p class="lifecycle"><b>Lifecycle:</b> The method gives a meaningful answer only when
  * a session is currently active.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "serverInstanceAddress" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient that received the setting from the
  * server
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @return {String} address used to issue all requests related to the current
  * session.
  */
 getServerInstanceAddress: function() { 
  return this.delegate.getServerInstanceAddress();
 },
 
 /**
  * Inquiry method that gets the instance name of the Server which is
  * serving the current session. To be more precise, each answering port
  * configured on a Server instance (through a &lt;http_server&gt; or
  * &lt;https_server&gt; element in the Server configuration file) can be given
  * a different name; the name related to the port to which the session
  * opening request has been issued is returned.
  * <BR>Note that in case of polling or in case rebind requests are needed,
  * subsequent requests related to the same session may be issued to a port
  * different than the one used for the first request; the names configured
  * for those ports would not be reported. This, however, can only happen
  * when a Server cluster is in place and particular configurations for the
  * load balancer are used.
  *
  * <p class="edition-note"><B>Edition Note:</B> Server Clustering is
  * an optional feature, available depending on Edition and License Type.
* To know what features are enabled by your license, please see the License tab of the
* Monitoring Dashboard (by default, available at /dashboard).</p>
  *
  * <p class="lifecycle"><b>Lifecycle:</b> The method gives a meaningful answer only when
  * a session is currently active.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "serverSocketName" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient that received the setting from the
  * server
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @return {String} name configured for the Server instance which is managing the
  * current session.
  */
 getServerSocketName: function() { 
  return this.delegate.getServerSocketName();
 },

 /**
  * Inquiry method that gets the ID associated by the server
  * to this client session.
  *
  * <p class="lifecycle"><b>Lifecycle:</b> The method gives a meaningful answer only when
  * a session is currently active.</p>
  *
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "sessionId" on any
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same
  * connection with the LightstreamerClient that received the setting from the
  * server
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @return {String} ID assigned by the Server to this client session.
  */
 getSessionId: function() {
  return this.delegate.getSessionId();
 },
 
 /**
  * Inquiry method that gets the IP address of this client as seen by the Server which is serving
  * the current session as the client remote address (note that it may not correspond to the client host;
  * for instance it may refer to an intermediate proxy). If, upon a new session, this address changes,
  * it may be a hint that the intermediary network nodes handling the connection have changed, hence the network
  * capabilities may be different. The library uses this information to optimize the connection. <BR>  
  * Note that in case of polling or in case rebind requests are needed, subsequent requests related to the same 
  * session may, in principle, expose a different IP address to the Server; these changes would not be reported.
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> If a session is not currently active, null is returned;
  * soon after a session is established, the value may become available; but it is possible
  * that this information is not provided by the Server and that it will never be available.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a call to 
  * {@link ClientListener#onPropertyChange} with argument "clientIp" on any 
  * ClientListener listening to the related LightstreamerClient.</p>
  * 
  * @return {String} A canonical representation of an IP address (it can be either IPv4 or IPv6), or null.
  */
 getClientIp: function() {
  return this.delegate.getClientIp();
 }
 
};

  /**
   * Used by LightstreamerClient to provide an extra connection properties data object.
   * @constructor
   *
   * @exports ConnectionOptions
   * @class Data object that contains the policy settings 
   * used to connect to a Lightstreamer Server.
   * <BR/>The class constructor, its prototype and any other properties should never
   * be used directly; the library will create ConnectionOptions instances when needed.
   * <BR>Note that all the settings are applied asynchronously; this means that if a
   * CPU consuming task is performed right after the call the effect of the setting 
   * will be delayed.
   * 
   * @see LightstreamerClient
   */
var ConnectionOptions = function(options) {
  this.delegate = options;
};

ConnectionOptions.prototype = {
 /** 
  * Setter method that sets the length in bytes to be used by the Server for the 
  * response body on a stream connection (a minimum length, however, is ensured 
  * by the server). After the content length exhaustion, the connection will be 
  * closed and a new bind connection will be automatically reopened.
  * <BR>NOTE that this setting only applies to the "HTTP-STREAMING" case (i.e. not to WebSockets).
  *  
  * <p class="default-value"><b>Default value:</b> A length decided by the library, to ensure
  * the best performance. It can be of a few MB or much higher, depending on the environment.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> The content length should be set before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next streaming connection (either a bind
  * or a brand new session).</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "contentLength" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if a negative, zero, decimal
  * or a not-number value is passed.
  * 
  * @param {Number} contentLength The length to be used by the Server for the 
  * response body on a HTTP stream connection.
  */
 setContentLength: function(contentLength) {
  this.delegate.setContentLength(contentLength);
 },
 
 /**
  * Inquiry method that gets the length expressed in bytes to be used by the Server
  * for the response body on a HTTP stream connection.
  * 
  * @return {Number} the length to be used by the Server
  * for the response body on a HTTP stream connection
  */
 getContentLength: function() {
  return this.delegate.getContentLength();
 },
 
 /**
  * Setter method that sets the maximum time the Server is allowed to wait
  * for any data to be sent in response to a polling request, if none has
  * accumulated at request time. Setting this time to a nonzero value and
  * the polling interval to zero leads to an "asynchronous polling"
  * behaviour, which, on low data rates, is very similar to the streaming
  * case. Setting this time to zero and the polling interval to a nonzero
  * value, on the other hand, leads to a classical "synchronous polling".
  * <BR>Note that the Server may, in some cases, delay the answer for more
  * than the supplied time, to protect itself against a high polling rate or
  * because of bandwidth restrictions. Also, the Server may impose an upper
  * limit on the wait time, in order to be able to check for client-side
  * connection drops.
  *
  * <p class="default-value"><b>Default value:</b> 19000 (19 seconds).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> The idle timeout should be set before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next polling request.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "idleTimeout" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if a negative or a decimal
  * or a not-number value is passed.
  *
  * @param {Number} idleTimeout The time (in milliseconds) the Server is
  * allowed to wait for data to send upon polling requests.
  * 
  * @see ConnectionOptions#setPollingInterval
  */
 setIdleTimeout: function(idleTimeout) {
  this.delegate.setIdleTimeout(idleTimeout);
 },
 
 /**  
  * Inquiry method that gets the maximum time the Server is allowed to wait
  * for any data to be sent in response to a polling request, if none has
  * accumulated at request time. The wait time used by the Server, however,
  * may be different, because of server side restrictions.
  *
  * @return {Number} The time (in milliseconds) the Server is allowed to wait for
  * data to send upon polling requests.
  *
  * @see ConnectionOptions#setIdleTimeout
  */
 getIdleTimeout: function() {
  return this.delegate.getIdleTimeout();
 },
 
 /**
  * Setter method that sets the interval between two keepalive packets
  * to be sent by Lightstreamer Server on a stream connection when
  * no actual data is being transmitted. The Server may, however, impose
  * a lower limit on the keepalive interval, in order to protect itself.
  * Also, the Server may impose an upper limit on the keepalive interval,
  * in order to be able to check for client-side connection drops.
  * If 0 is specified, the interval will be decided by the Server.
  * 
  * <p class="default-value"><b>Default value:</b> 0 (meaning that the Server
  * will send keepalive packets based on its own configuration).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> The keepalive interval should be set before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next streaming connection (either a bind
  * or a brand new session).
  * <BR>Note that, after a connection,
  * the value may be changed to the one imposed by the Server.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "keepaliveInterval" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called or that received the setting from the
  * server
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if a negative or a decimal
  * or a not-number value is passed.
  *
  * @param {Number} keepaliveInterval The time, expressed in milliseconds,
  * between two keepalive packets, or 0.
  */
 setKeepaliveInterval: function(keepaliveInterval) {
  this.delegate.setKeepaliveInterval(keepaliveInterval);
 },
 
 /**  
  * Inquiry method that gets the interval between two keepalive packets
  * sent by Lightstreamer Server on a stream connection when no actual data
  * is being transmitted.
  * <BR>If the value has just been set and a connection to Lightstreamer
  * Server has not been established yet, the returned value is the time that
  * is being requested to the Server. Afterwards, the returned value is the time
  * used by the Server, that may be different, because of Server side constraints.
  * If the returned value is 0, it means that the interval is to be decided
  * by the Server upon the next connection.
  *
  * @return {Number} The time, expressed in milliseconds, between two keepalive
  * packets sent by the Server, or 0.
  * 
  * @see ConnectionOptions#setKeepaliveInterval
  */
 getKeepaliveInterval: function() {
  return this.delegate.getKeepaliveInterval();
 },
 
 /**
  * Setter method that sets the maximum bandwidth expressed in kilobits/s that can be consumed for the data coming from 
  * Lightstreamer Server. A limit on bandwidth may already be posed by the Metadata Adapter, but the client can 
  * furtherly restrict this limit. The limit applies to the bytes received in each streaming or polling connection.
  *
  * <p class="edition-note"><B>Edition Note:</B> Bandwidth Control is
* an optional feature, available depending on Edition and License Type.
* To know what features are enabled by your license, please see the License tab of the
* Monitoring Dashboard (by default, available at /dashboard).</p>
  *
  * <p class="default-value"><b>Default value:</b> "unlimited".</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> The bandwidth limit can be set and changed at any time. If a connection is currently active, the bandwidth 
  * limit for the connection is changed on the fly. Remember that the Server may apply a different limit.
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a call to 
  * {@link ClientListener#onPropertyChange} with argument "requestedMaxBandwidth" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called or that received the setting from the
  * server
END_NODE_JSDOC_EXCLUDE
  * .
  * <BR>
  * Moreover, upon any change or attempt to change the limit, the Server will notify the client
  * and such notification will be received through a call to 
  * {@link ClientListener#onPropertyChange} with argument "realMaxBandwidth" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called or that received the setting from the
  * server
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @param {Number} maxBandwidth A decimal number, which represents the maximum bandwidth requested for the streaming
  * or polling connection expressed in kbps (kilobits/sec). The string "unlimited" is also allowed, to mean that
  * the maximum bandwidth can be entirely decided on the Server side (the check is case insensitive).
  * 
  * @throws {IllegalArgumentException} if a negative, zero, or a not-number value (excluding special values) is passed.
  * 
  * @see ConnectionOptions#getRealMaxBandwidth
  */
 setRequestedMaxBandwidth: function(maxBandwidth) {
  this.delegate.setRequestedMaxBandwidth(maxBandwidth);
 },

 /**
  * Inquiry method that gets the maximum bandwidth that can be consumed for the data coming from 
  * Lightstreamer Server, as requested for this session.
  * The maximum bandwidth limit really applied by the Server on the session is provided by
  * {@link ConnectionOptions#getRealMaxBandwidth}
  * 
  * @return {Number|String} A decimal number, which represents the maximum bandwidth requested for the streaming
  * or polling connection expressed in kbps (kilobits/sec), or the string "unlimited".
  * 
  * @see ConnectionOptions#setRequestedMaxBandwidth
  */
 getRequestedMaxBandwidth: function() {
  return this.delegate.getRequestedMaxBandwidth();
 },
 
 /**
  * Inquiry method that gets the maximum bandwidth that can be consumed for the data coming from 
  * Lightstreamer Server. This is the actual maximum bandwidth, in contrast with the requested
  * maximum bandwidth, returned by {@link ConnectionOptions#getRequestedMaxBandwidth}. <BR>
  * The value may differ from the requested one because of restrictions operated on the server side,
  * or because bandwidth management is not supported (in this case it is always "unlimited"),
  * but also because of number rounding.
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>If a connection to Lightstreamer Server is not currently active, null is returned;
  * soon after the connection is established, the value becomes available, as notified
  * by a call to {@link ClientListener#onPropertyChange} with argument "realMaxBandwidth".</p>
  * 
  * @return {Number|String} A decimal number, which represents the maximum bandwidth applied by the Server for the
  * streaming or polling connection expressed in kbps (kilobits/sec), or the string "unlimited", or null.
  * 
  * @see ConnectionOptions#setRequestedMaxBandwidth
  */
 getRealMaxBandwidth: function() {
  return this.delegate.getRealMaxBandwidth();
 },
 
 /**
  * Setter method that sets the polling interval used for polling
  * connections. The client switches from the default streaming mode
  * to polling mode when the client network infrastructure does not allow
  * streaming. Also, polling mode can be forced
  * by calling {@link ConnectionOptions#setForcedTransport} with 
  * "WS-POLLING" or "HTTP-POLLING" as parameter.
  * <BR>The polling interval affects the rate at which polling requests
  * are issued. It is the time between the start of a polling request and
  * the start of the next request. However, if the polling interval expires
  * before the first polling request has returned, then the second polling
  * request is delayed. This may happen, for instance, when the Server
  * delays the answer because of the idle timeout setting.
  * In any case, the polling interval allows for setting an upper limit
  * on the polling frequency.
  * <BR>The Server does not impose a lower limit on the client polling
  * interval.
  * However, in some cases, it may protect itself against a high polling
  * rate by delaying its answer. Network limitations and configured
  * bandwidth limits may also lower the polling rate, despite of the
  * client polling interval.
  * <BR>The Server may, however, impose an upper limit on the polling
  * interval, in order to be able to promptly detect terminated polling
  * request sequences and discard related session information.
  * 
  * 
  * <p class="default-value"><b>Default value:</b> 0 (pure "asynchronous polling" is configured).
  * </p>
  *
  * <p class="lifecycle"><b>Lifecycle:</b>The polling interval should be set before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next polling request. 
  * <BR>Note that, after each polling request, the value may be
  * changed to the one imposed by the Server.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "pollingInterval" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called or that received the setting from the
  * server.
END_NODE_JSDOC_EXCLUDE
  * </p>
  * 
  * @throws {IllegalArgumentException} if a negative or a decimal
  * or a not-number value is passed.
  *
  * @param {Number} pollingInterval The time (in milliseconds) between
  * subsequent polling requests. Zero is a legal value too, meaning that
  * the client will issue a new polling request as soon as
  * a previous one has returned.
  * 
  * @see ConnectionOptions#setIdleTimeout
  */
 setPollingInterval: function(pollingInterval) {
  this.delegate.setPollingInterval(pollingInterval);
 },
 
 /**  
  * Inquiry method that gets the polling interval used for polling
  * connections.
  * <BR>If the value has just been set and a polling request to Lightstreamer
  * Server has not been performed yet, the returned value is the polling interval that is being requested
  * to the Server. Afterwards, the returned value is the the time between
  * subsequent polling requests that is really allowed by the Server, that may be
  * different, because of Server side constraints.
  *
  * @return {Number} The time (in milliseconds) between subsequent polling requests.
  * 
  * @see ConnectionOptions#setPollingInterval
  */
 getPollingInterval: function() {
  return this.delegate.getPollingInterval();
 },
 
 /**
  * Setter method that sets the time the client, after entering "STALLED" status,
  * is allowed to keep waiting for a keepalive packet or any data on a stream connection,
  * before disconnecting and trying to reconnect to the Server.
  * The new connection may be either the opening of a new session or an attempt to recovery
  * the current session, depending on the kind of interruption.
  *
  * <p class="default-value"><b>Default value:</b> 3000 (3 seconds).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> This value can be set and changed at any time.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "reconnectTimeout" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if a negative, zero, or a not-number 
  * value is passed.
  *
  * @param {Number} reconnectTimeout The idle time (in milliseconds)
  * allowed in "STALLED" status before trying to reconnect to the
  * Server.
  *
  * @see ConnectionOptions#setStalledTimeout
  */
 setReconnectTimeout: function(reconnectTimeout) {
  this.delegate.setReconnectTimeout(reconnectTimeout);
 },
 
 /**  
  * Inquiry method that gets the time the client, after entering "STALLED" status,
  * is allowed to keep waiting for a keepalive packet or any data on a stream connection,
  * before disconnecting and trying to reconnect to the Server.
  *
  * @return {Number} The idle time (in milliseconds) admitted in "STALLED"
  * status before trying to reconnect to the Server.
  *
  * @see ConnectionOptions#setReconnectTimeout
  */
 getReconnectTimeout: function() {
  return this.delegate.getReconnectTimeout();
 },
 
 /**
  * Setter method that sets the extra time the client is allowed
  * to wait when an expected keepalive packet has not been received on
  * a stream connection (and no actual data has arrived), before entering
  * the "STALLED" status.
  *
  * <p class="default-value"><b>Default value:</b> 2000 (2 seconds).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> This value can be set and changed at any time.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "stalledTimeout" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if a negative, zero, or a not-number 
  * value is passed.
  *
  * @param {Number} stalledTimeout The idle time (in milliseconds)
  * allowed before entering the "STALLED" status.
  *
  * @see ConnectionOptions#setReconnectTimeout
  */
 setStalledTimeout: function(stalledTimeout) {
  this.delegate.setStalledTimeout(stalledTimeout);
 },

 /**  
  * Inquiry method that gets the extra time the client can wait
  * when an expected keepalive packet has not been received on a stream
  * connection (and no actual data has arrived), before entering the
  * "STALLED" status.
  *
  * @return {Number} The idle time (in milliseconds) admitted before entering the
  * "STALLED" status.
  *
  * @see ConnectionOptions#setStalledTimeout
  */
 getStalledTimeout: function() {
  return this.delegate.getStalledTimeout();
 },
 
 /**
  * Does nothing.
  * <p>
  * <b>The method is deprecated and it has no effect.
  * To act on connection timeouts use {@link ConnectionOptions#setRetryDelay}.</b>
  */
 setConnectTimeout: function(connectTimeout) {
     // ignore: see setRetryDelay
 },


 /**
  * Returns the same value as {@link ConnectionOptions#getRetryDelay}.
  * <p>
  * <b>The method is deprecated: use {@link ConnectionOptions#getRetryDelay} instead.</b>
  */
 getConnectTimeout: function() {
  return this.delegate.getConnectTimeout();
 },


 /**
  * Does nothing.
  * <p>
  * <b>The method is deprecated and it has no effect.
  * To act on connection timeouts, only {@link ConnectionOptions#setRetryDelay} is available.</b>
  */
 setCurrentConnectTimeout: function(currentConnectTimeout) {
     // ignore: see setRetryDelay
 },


 /**
  * Inquiry method that gets the maximum time to wait for a response to a request.
  * 
  * <p>
  * This value corresponds to the retry delay, but, in case of multiple failed attempts
  * on unresponsive connections, it can be changed dynamically by the library to higher values.
  * When this happens, the current value cannot be altered, but by issuing
  * {@link LightstreamerClient#disconnect} and {@link LightstreamerClient#connect}
  * it will restart from the retry delay.
  *
  * @return {Number} The time (in milliseconds) allowed to wait before trying a new connection.
  * 
  * @see ConnectionOptions#setRetryDelay
  */
 getCurrentConnectTimeout: function() {
  return this.delegate.getCurrentConnectTimeout();
 },

 
 /**
  * Setter method that sets 
  * <ol>
  * <li>the minimum time to wait before trying a new connection
  * to the Server in case the previous one failed for any reason; and</li>
  * <li>the maximum time to wait for a response to a request 
  * before dropping the connection and trying with a different approach.</li>
  * </ol>
  * 
  * <p>
  * Enforcing a delay between reconnections prevents strict loops of connection attempts when these attempts
  * always fail immediately because of some persisting issue.
  * This applies both to reconnections aimed at opening a new session and to reconnections
  * aimed at attempting a recovery of the current session.<BR>
  * Note that the delay is calculated from the moment the effort to create a connection
  * is made, not from the moment the failure is detected.
  * As a consequence, when a working connection is interrupted, this timeout is usually
  * already consumed and the new attempt can be immediate (except that
  * {@link ConnectionOptions#setFirstRetryMaxDelay} will apply in this case).
  * As another consequence, when a connection attempt gets no answer and times out,
  * the new attempt will be immediate.
  * 
  * <p>
  * As a timeout on unresponsive connections, it is applied in these cases:
  * <ul>
  * <li><i>Streaming</i>: Applied on any attempt to setup the streaming connection. If after the 
  * timeout no data has arrived on the stream connection, the client may automatically switch transport 
  * or may resort to a polling connection.</li>
  * <li>Polling and pre-flight requests</i>: Applied on every connection. If after the timeout 
  * no data has arrived on the polling connection, the entire connection process restarts from scratch.</li>
  * </ul>
  * 
  * <p>
  * <b>This setting imposes only a minimum delay. In order to avoid network congestion, the library may use a longer delay if the issue preventing the
  * establishment of a session persists.</b>
  *    
  * <p class="default-value"><b>Default value:</b> 4000 (4 seconds).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> This value can be set and changed at any time.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "retryDelay" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if a negative, zero, or a not-number 
  * value is passed.
  * 
  * @param {Number} retryDelay The time (in milliseconds)
  * to wait before trying a new connection.
  *
  * @see ConnectionOptions#setFirstRetryMaxDelay
  * @see ConnectionOptions#getCurrentConnectTimeout
  */
 setRetryDelay: function(retryDelay) {
  this.delegate.setRetryDelay(retryDelay);
 },
 
 /**  
  * Inquiry method that gets the minimum time to wait before trying a new connection
  * to the Server in case the previous one failed for any reason, which is also the maximum time to wait for a response to a request 
  * before dropping the connection and trying with a different approach.
  * Note that the delay is calculated from the moment the effort to create a connection
  * is made, not from the moment the failure is detected or the connection timeout expires.
  *
  * @return {Number} The time (in milliseconds) to wait before trying a new connection.
  *
  * @see ConnectionOptions#setRetryDelay
  */
 getRetryDelay: function() {
  return this.delegate.getRetryDelay();
 },
 
 
 /**
  * Setter method that sets the maximum time to wait before trying a new connection to the Server
  * in case the previous one is unexpectedly closed while correctly working.
  * The new connection may be either the opening of a new session or an attempt to recovery
  * the current session, depending on the kind of interruption.
  * <BR/>The actual delay is a randomized value between 0 and this value. 
  * This randomization might help avoid a load spike on the cluster due to simultaneous reconnections, should one of 
  * the active servers be stopped. Note that this delay is only applied before the first reconnection: should such 
  * reconnection fail, only the setting of {@link ConnectionOptions#setRetryDelay} will be applied.
  *    
  * <p class="default-value"><b>Default value:</b> 100 (0.1 seconds).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> This value can be set and changed at any time.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "firstRetryMaxDelay" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if a negative, zero, or a not-number 
  * value is passed.
  * 
  * @param {Number} firstRetryMaxDelay The max time (in milliseconds)
  * to wait before trying a new connection. 
  */
 setFirstRetryMaxDelay: function(firstRetryMaxDelay) {
  this.delegate.setFirstRetryMaxDelay(firstRetryMaxDelay);
 },
 
 /**  
  * Inquiry method that gets the maximum time to wait before trying a new connection to the Server
  * in case the previous one is unexpectedly closed while correctly working.
  *
  * @return {Number} The max time (in milliseconds)
  * to wait before trying a new connection.
  * 
  * @see ConnectionOptions#setFirstRetryMaxDelay
  */
 getFirstRetryMaxDelay: function() {
  return this.delegate.getFirstRetryMaxDelay();
 },
 
 /**
  * Setter method that turns on or off the slowing algorithm. This heuristic
  * algorithm tries to detect when the client CPU is not able to keep the pace
  * of the events sent by the Server on a streaming connection. In that case,
  * an automatic transition to polling is performed.
  * <BR/>In polling, the client handles all the data before issuing the
  * next poll, hence a slow client would just delay the polls, while the Server
  * accumulates and merges the events and ensures that no obsolete data is sent.
  * <BR/>Only in very slow clients, the next polling request may be so much
  * delayed that the Server disposes the session first, because of its protection
  * timeouts. In this case, a request for a fresh session will be reissued
  * by the client and this may happen in cycle.
  *
  * <p class="default-value"><b>Default value:</b> false.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>This setting should be performed before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next streaming connection (either a bind
  * or a brand new session).</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "slowingEnabled" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if a not boolean value is given.
  *
  * @param {boolean} slowingEnabled true or false, to enable or disable
  * the heuristic algorithm that lowers the item update frequency. 
  */
 setSlowingEnabled: function(slowingEnabled) {
  this.delegate.setSlowingEnabled(slowingEnabled);
 },
 
 /**  
  * Inquiry method that checks if the slowing algorithm is enabled or not.
  *
  * @return {boolean} Whether the slowing algorithm is enabled or not.
  *
  * @see ConnectionOptions#setSlowingEnabled
  */
 isSlowingEnabled: function() {
  return this.delegate.isSlowingEnabled();
 },
 
 /**
  * Setter method that can be used to disable/enable the 
  * Stream-Sense algorithm and to force the client to use a fixed transport or a
  * fixed combination of a transport and a connection type. When a combination is specified the
  * Stream-Sense algorithm is completely disabled.
  * <BR>The method can be used to switch between streaming and polling connection 
  * types and between HTTP and WebSocket transports.
  * <BR>In some cases, the requested status may not be reached, because of 
  * connection or environment problems. In that case the client will continuously
  * attempt to reach the configured status.
  * <BR>Note that if the Stream-Sense algorithm is disabled, the client may still
  * enter the "CONNECTED:STREAM-SENSING" status; however, in that case,
  * if it eventually finds out that streaming is not possible, no recovery will
  * be tried.
  * 
  * <p class="default-value"><b>Default value:</b> null (full Stream-Sense enabled).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>This method can be called at any time. If called while 
  * the client is connecting or connected it will instruct to switch connection 
  * type to match the given configuration.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "forcedTransport" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @throws {IllegalArgumentException} if the given value is not in the list
  * of the admitted ones.
  * 
  * @param {String} forcedTransport can be one of the following:
  * <BR>
  * <ul>
  *    <li>null: the Stream-Sense algorithm is enabled and
  *    the client will automatically connect using the most appropriate
  *    transport and connection type among those made possible by the
  *    browser/environment.</li>
  *    <li>"WS": the Stream-Sense algorithm is enabled as in the null case but
  *    the client will only use WebSocket based connections. If a connection
  *    over WebSocket is not possible because of the browser/environment
  *    the client will not connect at all.</li>
  *    <li>"HTTP": the Stream-Sense algorithm is enabled as in the null case but
  *    the client will only use HTTP based connections. If a connection
  *    over HTTP is not possible because of the browser/environment
  *    the client will not connect at all.</li>
  *    <li>"WS-STREAMING": the Stream-Sense algorithm is disabled and
  *    the client will only connect on Streaming over WebSocket. If 
  *    Streaming over WebSocket is not possible because of the browser/environment
  *    the client will not connect at all.</li>
  *    <li>"HTTP-STREAMING": the Stream-Sense algorithm is disabled and
  *    the client will only connect on Streaming over HTTP. If 
  *    Streaming over HTTP is not possible because of the browser/environment
  *    the client will not connect at all.</li> 
  *    <li>"WS-POLLING": the Stream-Sense algorithm is disabled and
  *    the client will only connect on Polling over WebSocket. If 
  *    Polling over WebSocket is not possible because of the browser/environment
  *    the client will not connect at all.</li>
  *    <li>"HTTP-POLLING": the Stream-Sense algorithm is disabled and
  *    the client will only connect on Polling over HTTP. If 
  *    Polling over HTTP is not possible because of the browser/environment
  *    the client will not connect at all.</li>
  *  </ul>
  */
 setForcedTransport: function(forcedTransport) {
  this.delegate.setForcedTransport(forcedTransport);
 },
 
 /**  
  * Inquiry method that gets the value of the forced transport (if any).
  *
  * @return {String} The forced transport or null
  *
  * @see ConnectionOptions#setForcedTransport
  */
 getForcedTransport: function() {
  return this.delegate.getForcedTransport();
 },


 /**
  * Setter method that can be used to disable/enable the automatic handling of 
  * server instance address that may be returned by the Lightstreamer server 
  * during session creation.
  * <BR>In fact, when a Server cluster is in place, the Server address specified 
  * through {@link ConnectionDetails#setServerAddress} can identify various Server 
  * instances; in order to ensure that all requests related to a session are 
  * issued to the same Server instance, the Server can answer to the session 
  * opening request by providing an address which uniquely identifies its own 
  * instance.
  * <BR>Setting this value to true permits to ignore that address and to always connect
  * through the address supplied in setServerAddress. This may be needed in a test
  * environment, if the Server address specified is actually a local address
  * to a specific Server instance in the cluster.
  *
  * <p class="edition-note"><B>Edition Note:</B> Server Clustering is
* an optional feature, available depending on Edition and License Type.
* To know what features are enabled by your license, please see the License tab of the
* Monitoring Dashboard (by default, available at /dashboard).</p>
  *
  * <p class="default-value"><b>Default value:</b> false.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>This method can be called at any time. If called while connected, 
  * it will be applied when the next session creation request is issued.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "serverInstanceAddressIgnored" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @throws {IllegalArgumentException} if a not boolean value is given.
  *
  * @param {boolean} serverInstanceAddressIgnored true or false, to ignore
  * or not the server instance address sent by the server.
  * 
  * @see ConnectionDetails#setServerAddress
  */
 setServerInstanceAddressIgnored: function(serverInstanceAddressIgnored) {
  this.delegate.setServerInstanceAddressIgnored(serverInstanceAddressIgnored);
 },
 
 /**  
  * Inquiry method that checks if the client is going to ignore the server
  * instance address that will possibly be sent by the server.
  *
  * @return {boolean} Whether or not to ignore the server instance address sent by the 
  * server.
  * 
  * @see ConnectionOptions#setServerInstanceAddressIgnored
  */
 isServerInstanceAddressIgnored: function() {
  return this.delegate.isServerInstanceAddressIgnored();
 },
 
 /**
  * Setter method that enables/disables the cookies-are-required policy on the 
  * client side.
  * Enabling this policy will guarantee that cookies pertaining to the 
  * Lightstreamer Server will be sent with each request.
START_NODE_JSDOC_EXCLUDE
  * <BR>This holds for both cookies returned by the Server (possibly affinity cookies
  * inserted by a Load Balancer standing in between) and for cookies set by
  * other sites (for instance on the front-end page) and with a domain
  * specification which includes Lightstreamer Server host.
  * Likewise, cookies set by Lightstreamer Server and with a domain
  * specification which includes other sites will be forwarded to them.
END_NODE_JSDOC_EXCLUDE
START_WEB_JSDOC_EXCLUDE
  * <BR>This holds only for cookies returned by the Server (possibly affinity cookies
  * inserted by a Load Balancer standing in between). If other cookies received
  * by the application also pertain to Lightstreamer Server host, they must be
  * manually set through the static {@link LightstreamerClient.addCookies} method.
  * Likewise, cookies set by Lightstreamer Server and also pertaining to other hosts
  * accessed by the application must be manually extracted through the static
  * {@link LightstreamerClient.getCookies} method and handled properly.
END_WEB_JSDOC_EXCLUDE
  * <BR>On the other hand enabling this setting may prevent the client from
  * opening a streaming connection or even to connect at all depending on the
  * browser/environment.
  * 
  * <p class="default-value"><b>Default value:</b> false.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>This setting should be performed before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next HTTP request or WebSocket establishment.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "cookieHandlingRequired" on any 
  * {@link ClientListener} listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called.</p>
  *
  * @throws {IllegalArgumentException} if a not boolean value is given.
  * 
  * @param {boolean} cookieHandlingRequired true/false to enable/disable the 
  * cookies-are-required policy.
  */
 setCookieHandlingRequired: function(cookieHandlingRequired) {
  this.delegate.setCookieHandlingRequired(cookieHandlingRequired);
 },
 
 /**  
  * Inquiry method that checks if the client is going to connect only if it
  * can guarantee that cookies pertaining to the server will be sent.
  *
  * @return {boolean} true/false if the cookies-are-required policy is enabled or not.
  * 
  * @see ConnectionOptions#setCookieHandlingRequired
  */
 isCookieHandlingRequired: function() {
  return this.delegate.isCookieHandlingRequired();
 },
 
 /**
  * Setter method that enables/disables the "early-open" of the WebSocket 
  * connection.<BR/>
  * When enabled a WebSocket is open to the address specified through
  * {@link ConnectionDetails#setServerAddress} before a potential server instance 
  * address is received during session creation. In this case if a server instance 
  * address is received, the previously open WebSocket is closed and a new one is open 
  * to the received server instance address.<br/> 
  * If disabled, the session creation is completed to verify if such
  * a server instance address is configured in the server before opening the
  * WebSocket.<BR/>
  * For these reasons this setting should be set to false if the server 
  * configuration specifies a &lt;control_link_address&gt; and/or a
  * &lt;control_link_machine_name&gt; element in its configuration;
  * viceversa it should be set to true if such elements are not set on
  * the target server(s) configuration.
  * 
  * <p class="edition-note"><B>Edition Note:</B> Server Clustering is
* an optional feature, available depending on Edition and License Type.
* To know what features are enabled by your license, please see the License tab of the
* Monitoring Dashboard (by default, available at /dashboard).</p>
  *
  * <p class="default-value"><b>Default value:</b> false.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>This method can be called at any time. If called while 
  * the client already owns a session it will be applied the next time a session 
  * is requested to a server.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "earlyWSOpenEnabled" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @throws {IllegalArgumentException} if a not boolean value is given.
  * 
  * @param {boolean} earlyWSOpenEnabled true/false to enable/disable the 
  * early-open of the WebSocket connection.
  * 
  * @see ConnectionOptions#setServerInstanceAddressIgnored
  */
 setEarlyWSOpenEnabled: function(earlyWSOpenEnabled) {
  this.delegate.setEarlyWSOpenEnabled(earlyWSOpenEnabled);
 },
 
 /**  
  * Inquiry method that checks if the client is going to early-open the
  * WebSocket connection to the address specified in 
  * {@link ConnectionDetails#setServerAddress}.
  *
  * @return {boolean} true/false if the early-open of the WebSocket connection is 
  * enabled or not.
  * 
  * @see ConnectionOptions#setEarlyWSOpenEnabled
  */
 isEarlyWSOpenEnabled: function() {
  return this.delegate.isEarlyWSOpenEnabled();
 },
 
 /**
  * Setter method that enables/disables the reverse-heartbeat mechanism
  * by setting the heartbeat interval. If the given value 
  * (expressed in milliseconds) equals 0 then the reverse-heartbeat mechanism will
  * be disabled; otherwise if the given value is greater than 0 the mechanism  
  * will be enabled with the specified interval.
  * <BR>When the mechanism is active, the client will ensure that there is at most
  * the specified interval between a control request and the following one,
  * by sending empty control requests (the "reverse heartbeats") if necessary.
  * <BR>This can serve various purposes:<ul>
  * <li>Preventing the communication infrastructure from closing an inactive socket
  * that is ready for reuse for more HTTP control requests, to avoid
  * connection reestablishment overhead. However it is not 
  * guaranteed that the connection will be kept open, as the underlying TCP 
  * implementation may open a new socket each time a HTTP request needs to be sent.<BR>
  * Note that this will be done only when a session is in place.</li>
  * <li>Allowing the Server to detect when a streaming connection or Websocket
  * is interrupted but not closed. In these cases, the client eventually closes
  * the connection, but the Server cannot see that (the connection remains "half-open")
  * and just keeps trying to write.
  * This is done by notifying the timeout to the Server upon each streaming request.
  * For long polling, the {@link ConnectionOptions#setIdleTimeout} setting has a similar function.</li>
  * <li>Allowing the Server to detect cases in which the client has closed a connection
  * in HTTP streaming, but the socket is kept open by some intermediate node,
  * which keeps consuming the response.
  * This is also done by notifying the timeout to the Server upon each streaming request,
  * whereas, for long polling, the {@link ConnectionOptions#setIdleTimeout} setting has a similar function.</li>
  * </ul>
  * 
  * <p class="default-value"><b>Default value:</b> 0 (meaning that the mechanism is disabled).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> This setting should be performed before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the setting will be obeyed immediately, unless a higher heartbeat
  * frequency was notified to the Server for the current connection. The setting
  * will always be obeyed upon the next connection (either a bind or a brand new session).</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "reverseHeartbeatInterval" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @throws {IllegalArgumentException} if a negative, decimal
  * or a not-number value is passed.
  * 
  * @param {Number} reverseHeartbeatInterval the interval, expressed in milliseconds,
  * between subsequent reverse-heartbeats, or 0.
  */
 setReverseHeartbeatInterval: function(reverseHeartbeatInterval) {
  this.delegate.setReverseHeartbeatInterval(reverseHeartbeatInterval);
 },
 
 /**
  * Inquiry method that gets the reverse-heartbeat interval expressed in 
  * milliseconds.
  * A 0 value is possible, meaning that the mechanism is disabled.
  * 
  * @return {Number} the reverse-heartbeat interval, or 0.
  * 
  * @see ConnectionOptions#setReverseHeartbeatInterval
  */
 getReverseHeartbeatInterval: function() {
  return this.delegate.getReverseHeartbeatInterval();
 },
 
 /**
  * Setter method that enables/disables the setting of extra HTTP headers to all the 
  * request performed to the Lightstreamer server by the client.
  * Note that when the value is set WebSockets are disabled
START_NODE_JSDOC_EXCLUDE
  * (as the current browser client API does not support the setting of custom HTTP headers)
END_NODE_JSDOC_EXCLUDE
  * unless {@link ConnectionOptions#setHttpExtraHeadersOnSessionCreationOnly}
  * is set to true. <BR> Also note that
  * if the browser/environment does not have the possibility to send extra headers while 
  * some are specified through this method it will fail to connect.
  * Also note that the Content-Type header is reserved by the client library itself,
  * while other headers might be refused by the browser/environment and others might cause the
  * connection to the server to fail.
START_WEB_JSDOC_EXCLUDE
  * <BR>For instance, you cannot use this method to specify custom cookies to be sent to
  * Lightstreamer Server. Use the static {@link LightstreamerClient.addCookies} instead
  * (and {@link LightstreamerClient.getCookies} for inquiries). <BR>
END_WEB_JSDOC_EXCLUDE
START_NODE_JSDOC_EXCLUDE
  * <BR>For instance, you cannot use this method to specify custom cookies to be sent to
  * Lightstreamer Server. They can only be set and inquired through the browser's
  * document.cookie object. <BR>
END_NODE_JSDOC_EXCLUDE
  * The use of custom headers might also cause the
  * browser/environment to send an OPTIONS request to the server before opening the actual connection.
START_NODE_JSDOC_EXCLUDE
  * Finally, note that, in case of cross-origin requests, extra headers have to be authorized
  * on the server configuration file, in the cross_domain_policy element.
END_NODE_JSDOC_EXCLUDE
  * 
  * <p class="default-value"><b>Default value:</b> null (meaning no extra headers are sent).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>This setting should be performed before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next HTTP request or WebSocket establishment.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "httpExtraHeaders" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  * 
  * @param {Object} headersObj a JSON object containing header-name header-value pairs. 
  * Null can be specified to avoid extra headers to be sent.
  */
 setHttpExtraHeaders: function(headersObj) {
  this.delegate.setHttpExtraHeaders(headersObj);
 },
 
 /**
  * Inquiry method that gets the JSON object containing the extra headers
  * to be sent to the server.
  * 
  * @return {Object} the JSON object containing the extra headers
  * to be sent
  * 
  * @see ConnectionOptions#setHttpExtraHeaders
  */
 getHttpExtraHeaders: function() {
  return this.delegate.getHttpExtraHeaders();
 },
 
 /**
  * Setter method that enables/disables a restriction on the forwarding of the extra http headers 
  * specified through {@link ConnectionOptions#setHttpExtraHeaders}.
  * If true, said headers will only be sent during the session creation process (and thus
  * will still be available to the Metadata Adapter notifyUser method) but will not
  * be sent on following requests. On the contrary, when set to true, the specified extra
  * headers will be sent to the server on every request: as a consequence, if any 
  * extra header is actually specified, WebSockets will be disabled (as the current browser
  * client API does not support the setting of custom HTTP headers).
  * 
  * <p class="default-value"><b>Default value:</b> false.</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b>This setting should be performed before calling the
  * {@link LightstreamerClient#connect} method. However, the value can be changed
  * at any time: the supplied value will be used for the next HTTP request or WebSocket establishment.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "httpExtraHeadersOnSessionCreationOnly" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @throws {IllegalArgumentException} if a not boolean value is given.
  * 
  * @param {boolean} httpExtraHeadersOnSessionCreationOnly true/false to enable/disable the 
  * restriction on extra headers forwarding.
  */
 setHttpExtraHeadersOnSessionCreationOnly: function(httpExtraHeadersOnSessionCreationOnly) {
  this.delegate.setHttpExtraHeadersOnSessionCreationOnly(httpExtraHeadersOnSessionCreationOnly);
 },
 
 /**  
  * Inquiry method that checks if the restriction on the forwarding of the 
  * configured extra http headers applies or not.
  *
  * @return {boolean} true/false if the restriction applies or not.
  * 
  * @see ConnectionOptions#setHttpExtraHeadersOnSessionCreationOnly
  */
 isHttpExtraHeadersOnSessionCreationOnly: function() {
  return this.delegate.isHttpExtraHeadersOnSessionCreationOnly();
 },
 
 /**
  * Setter method that sets the maximum time allowed for attempts to recover
  * the current session upon an interruption, after which a new session will be created.
  * If the given value (expressed in milliseconds) equals 0, then any attempt
  * to recover the current session will be prevented in the first place.
  * <BR>In fact, in an attempt to recover the current session, the client will
  * periodically try to access the Server at the address related with the current
  * session. In some cases, this timeout, by enforcing a fresh connection attempt,
  * may prevent an infinite sequence of unsuccessful attempts to access the Server.
  * <BR>Note that, when the Server is reached, the recovery may fail due to a
  * Server side timeout on the retention of the session and the updates sent.
  * In that case, a new session will be created anyway.
  * A setting smaller than the Server timeouts may prevent such useless failures,
  * but, if too small, it may also prevent successful recovery in some cases.</p>
  * 
  * <p class="default-value"><b>Default value:</b> 15000 (15 seconds).</p>
  * 
  * <p class="lifecycle"><b>Lifecycle:</b> This value can be set and changed at any time.</p>
  * 
  * <p class="notification"><b>Notification:</b> A change to this setting will be notified through a
  * call to {@link ClientListener#onPropertyChange} with argument "sessionRecoveryTimeout" on any 
  * {@link ClientListener}
START_NODE_JSDOC_EXCLUDE
  * listening to any LightstreamerClient sharing the same 
  * connection with the LightstreamerClient owning the ConnectionOptions upon 
  * which the setter was called
END_NODE_JSDOC_EXCLUDE
  * .</p>
  *
  * @throws {IllegalArgumentException} if a negative, decimal
  * or a not-number value is passed.
  * 
  * @param {Number} sessionRecoveryTimeout the maximum time allowed
  * for recovery attempts, expressed in milliseconds, including 0.
  */
 setSessionRecoveryTimeout: function(sessionRecoveryTimeout) {
  this.delegate.setSessionRecoveryTimeout(sessionRecoveryTimeout);
 },
 
 /**
  * Inquiry method that gets the maximum time allowed for attempts to recover
  * the current session upon an interruption, after which a new session will be created.
  * A 0 value also means that any attempt to recover the current session is prevented
  * in the first place.
  * 
  * @return {Number} the maximum time allowed for recovery attempts, possibly 0.
  * 
  * @see ConnectionOptions#setSessionRecoveryTimeout
  */
 getSessionRecoveryTimeout: function() {
  return this.delegate.getSessionRecoveryTimeout();
 },
};

  /**
   * Creates an object to be configured to connect to a Lightstreamer server
   * and to handle all the communications with it.
   * It is possible to instantiate as many LightstreamerClient as needed.
   * Each LightstreamerClient is the entry point to connect to a Lightstreamer server,
   * subscribe to as many items as needed and to send messages.
START_NODE_JSDOC_EXCLUDE
   * Multiple LightstreamerClient instances may share the same connection if
   * configured to behave that way through {@link LightstreamerClient#enableSharing}.
END_NODE_JSDOC_EXCLUDE
   * @constructor
   *
   * @exports LightstreamerClient
   *
   * @throws {IllegalArgumentException} if a not valid address is passed. See
   * {@link ConnectionDetails#setServerAddress} for details.
   *
   * @param {String} [serverAddress] the address of the Lightstreamer Server to
   * which this LightstreamerClient will connect to. It is possible not to specify
   * it at all or to specify it later. See  {@link ConnectionDetails#setServerAddress}
   * for details.
   * @param {String} [adapterSet] the name of the Adapter Set mounted on Lightstreamer Server
   * to be used to handle all requests in the Session associated with this LightstreamerClient.
   * It is possible not to specify it at all or to specify it later. See
   * {@link ConnectionDetails#setAdapterSet} for details.
   *
   * @class Facade class for the management of the communication to
   * Lightstreamer Server. Used to provide configuration settings, event
   * handlers, operations for the control of the connection lifecycle,
   * {@link Subscription} handling and to send messages.
START_NODE_JSDOC_EXCLUDE
   * <BR>It can be configured to share its connection with other LightstreamerClient
   * instances (even if on different html pages) through
   * {@link LightstreamerClient#enableSharing} calls.
END_NODE_JSDOC_EXCLUDE
   */
var LightstreamerClient = function(serverAddress, adapterSet) {
  this.delegate = new LSLightstreamerClient(serverAddress, adapterSet);
  /**
   * Data object that contains options and policies for the connection to
   * the server. This instance is set up by the LightstreamerClient object at
   * its own creation.
   * <BR>Properties of this object can be overwritten by values received from a
   * Lightstreamer Server. Such changes will be notified through a
   * {@link ClientListener#onPropertyChange} event on listeners of this instance.
START_NODE_JSDOC_EXCLUDE
   * <BR>In case of a shared connection the involved LightstreamerClient instances
   * will keep this data object synchronized so that a change on a property of an object
   * of one of the instances will be reflected on all the others. Any change will
   * be notified through a {@link ClientListener#onPropertyChange} event on
   * listeners of this instance.
END_NODE_JSDOC_EXCLUDE
   *
   * @type ConnectionOptions
   *
   * @see ClientListener#onPropertyChange
   */
  this.connectionOptions = new ConnectionOptions(delegate.connectionOptions);

  /**
   * Data object that contains the details needed to open a connection to
   * a Lightstreamer Server. This instance is set up by the LightstreamerClient object at
   * its own creation.
   * <BR>Properties of this object can be overwritten by values received from a
   * Lightstreamer Server. Such changes will be notified through a
   * {@link ClientListener#onPropertyChange} event on listeners of this instance.
START_NODE_JSDOC_EXCLUDE
   * <BR>In case of a shared connection the involved LightstreamerClient instances
   * will keep this data object synchronized so that a change on a property of an object
   * of one of the instances will be reflected on all the others. Any change will
   * be notified through a {@link ClientListener#onPropertyChange} event on
   * listeners of this instance.
END_NODE_JSDOC_EXCLUDE
   *
   * @type ConnectionDetails
   *
   * @see ClientListener#onPropertyChange
   */
  this.connectionDetails = new ConnectionDetails(delegate.connectionDetails);
};


//START_WEB_JSDOC_EXCLUDE
/**
 * Static method that can be used to share cookies between connections to the Server
 * (performed by this library) and connections to other sites that are performed
 * by the application. With this method, cookies received by the application
 * can be added (or replaced if already present) to the cookie set used by the
 * library to access the Server. Obviously, only cookies whose domain is compatible
 * with the Server domain will be used internally.
 *
 * <p class="lifecycle"><b>Lifecycle:</b>This method can be called at any time;
 * it will affect the internal cookie set immediately and the sending of cookies
 * on future requests.</p>
 *
 * @param {String} uri String representation of the URI from which the supplied
 * cookies were received. It can be null.
 *
 * @param {String[]} cookies An array of String representations of the various
 * cookies to be added. Each cookie should be represented in the text format
 * provided for the Set-Cookie HTTP header by RFC 6265.
 *
 * @see LightstreamerClient.getCookies
 *
 * @static
 */
//END_WEB_JSDOC_EXCLUDE
LightstreamerClient.addCookies = function(uri, cookieList) {
    LSLightstreamerClient.addCookies(uri, cookieList);
};

//START_WEB_JSDOC_EXCLUDE
/**
 * Static inquiry method that can be used to share cookies between connections to the Server
 * (performed by this library) and connections to other sites that are performed
 * by the application. With this method, cookies received from the Server can be
 * extracted for sending through other connections, according with the URI to be accessed.
 *
 * @param {String} uri String representation of the URI to which the cookies should
 * be sent, or null.
 *
 * @return {String[]} An array of String representations of the various cookies that can
 * be sent in a HTTP request for the specified URI. If a null URI was supplied,
 * the export of all available cookies, including expired ones, will be returned.
 * Each cookie is represented in the text format provided for the Set-Cookie HTTP header
 * by RFC 6265.
 *
 * @see LightstreamerClient.addCookies
 *
 * @static
 */
//END_WEB_JSDOC_EXCLUDE
LightstreamerClient.getCookies = function(uri) {
    return LSLightstreamerClient.getCookies(uri);
};

/**
 * Static method that permits to configure the logging system used by the library.
 * The logging system must respect the {@link LoggerProvider} interface. A custom
 * class can be used to wrap any third-party JavaScript logging system.
 * <BR>A ready-made LoggerProvider implementation is available within the
 * library in the form of the {@link SimpleLoggerProvider} class.
 * <BR>If no logging system is specified, all the generated log is discarded.
 * <BR>The following categories are available to be consumed:
 * <ul>
 * <li>
 * lightstreamer.stream:
 * <BR>logs socket activity on Lightstreamer Server connections;
 * <BR>at DEBUG level, read data is logged, write preparations are logged.
 * </li><li>
 * lightstreamer.protocol:
 * <BR>logs requests to Lightstreamer Server and Server answers;
 * <BR>at DEBUG level, request details and events from the Server are logged.
 * </li><li>
 * lightstreamer.session:
 * <BR>logs Server Session lifecycle events;
 * <BR>at INFO level, lifecycle events are logged;
 * <BR>at DEBUG level, lifecycle event details are logged.
 * </li><li>
 * lightstreamer.requests:
 * <BR>logs submission of control requests to the Server;
 * <BR>at WARN level, alert events from the Server are logged;
 * <BR>at INFO level, submission of control requests is logged;
 * <BR>at DEBUG level, requests batching and handling details are logged.
 * </li><li>
 * lightstreamer.subscriptions:
 * <BR>logs subscription requests and the related updates;
 * <BR>at INFO level, subscriptions and unsubscriptions are logged;
 * <BR>at DEBUG level, requests handling details are logged.
 * </li><li>
 * lightstreamer.messages:
 * <BR>logs sendMessage requests and the related updates;
 * <BR>at INFO level, sendMessage operations are logged;
 * <BR>at DEBUG level, request handling details are logged.
 * </li><li>
 * lightstreamer.actions:
 * <BR>logs settings / API calls.
 * </li>
START_NODE_JSDOC_EXCLUDE
 * <li>
 * lightstreamer.grids:
 * <BR>logs grid-related code.
 * </li><li>
 * lightstreamer.sharing:
 * <BR>logs creation / sharing / election of the Master and Slave
 * {@link LightstreamerClient};
 * <BR>at WARN level, problems getting a connection up and ready are logged;
 * <BR>at INFO level, found/lost events are logged;
 * <BR>at DEBUG level, connection management details and regular checks on the current connection are logged.
 * </li>
END_NODE_JSDOC_EXCLUDE
 * </ul>
 *
 * @param {LoggerProvider} provider A LoggerProvider instance that will be used
 * to generate log messages by the library classes.
 *
 * @static
 */
LightstreamerClient.setLoggerProvider = function(provider) {
    LSLightstreamerClient.setLoggerProvider(provider);
};

/**
 * A constant string representing the name of the library.
 *
 * @type String
 */
LightstreamerClient.LIB_NAME = LSLightstreamerClient.LIB_NAME;

/**
 * A constant string representing the version of the library.
 *
 * @type String
 */
LightstreamerClient.LIB_VERSION = LSLightstreamerClient.LIB_VERSION;

LightstreamerClient.prototype = {

// START_NODE_JSDOC_EXCLUDE
    /**
     * Configures the client to share its connection and/or attach to a shared connection.
     * Different windows trying to share the connection to Lightstreamer Server must share the
     * exact same origin. Depending on the browser in use, connection sharing might not work.
     * Specify null to prevent any kind of sharing (this is also the default). In case
     * a connection is not currently required (i.e. the client is in DISCONNECTED status)
     * specifying null will also have the effect to dismiss resources currently held by the
     * client: failing to do that when a LightstreamerClient instance is not needed anymore
     * might prevent the VM from collecting all the allocated resources. Note that in this case
     * required resources will be prepared again once a call to {@link LightstreamerClient#connect}
     * is performed.
     *
     * <p class="default-value"><b>Default value:</b> by default no sharing is configured.</p>
     *
     * <p class="lifecycle"><b>Lifecycle:</b> this method can be called at any time.
     * <BR>Note that if multiple calls to this method are performed, the last one will
     * override the previous ones. Also if a call to enableSharing is made on a
     * Master client, the current connection (if any) will be dropped and the
     * remaining clients will enter the election algorithm.</p>
     *
     * @param {ConnectionSharing} sharing The sharing parameters or null to prevent any sharing
     */
// END_NODE_JSDOC_EXCLUDE
    enableSharing: function(sharing) {
        // TODO remove
    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Inquiry method that checks if the LightstreamerClient has its own connection or if it is using
     * a connection shared by another LightstreamerClient.
     * This LightstreamerClient is not a Master if:
     * <ul>
     * <li>it is attached to another LightstreamerClient connection</li>
     * <li>no call to {@link LightstreamerClient#connect} or {@link LightstreamerClient#enableSharing}
     * was performed on it.</li>
     * <li>the {@link ClientListener#onShareAbort} event has been fired and no following
     * {@link LightstreamerClient#enableSharing} has been performed.</li>
     * <li>a call to {@link LightstreamerClient#enableSharing} has been performed and the client is currently
     * searching for a shared connection</li>
     * <li>a call to {@link LightstreamerClient#enableSharing} has been performed with null as parameter and no
     * subsequent call to connect has been performed</li>
     *
     * @return {boolean} Whenever the LightstreamerClient owning this instance is a Master or not.
     *
     * @see ConnectionSharing
     */
// END_NODE_JSDOC_EXCLUDE
    isMaster: function() {
        // TODO remove
    },


    /**
     * Operation method that requests to open a Session against the configured
     * Lightstreamer Server.
     * <BR>When connect() is called, unless a single transport was forced through
     * {@link ConnectionOptions#setForcedTransport},
     * the so called "Stream-Sense" mechanism is started: if the client does not
     * receive any answer for some seconds from the streaming connection, then it
     * will automatically open a polling connection.
     * <BR>A polling connection may also be opened if the environment is not suitable
     * for a streaming connection.
START_NODE_JSDOC_EXCLUDE
     * <BR>When connect() is used to activate the Lightstreamer
     * Session on page start up, it is suggested to make this call as the
     * latest action of the scripts in the page. Otherwise, if the stream
     * connection is opened but third-party scripts are consuming most of the
     * CPU for page initialization (initial rendering, etc.), the parsing
     * of the streaming response could be delayed to the point that the Client
     * switches to polling mode. This is usually not the case nowadays but may
     * still happen if the client is used on old machines.
     * <BR>In case of a shared connection the connect call will apply to such
     * shared connection regardless of which LightstreamerClient is calling it.
     * <BR>If {@link LightstreamerClient#enableSharing} has not been called before the
     * first call to connect, then a default call will be performed with the
     * following parameter:
     * <BR><CODE>new ConnectionSharing("randomstring","IGNORE", "CREATE", true, null);</CODE>
END_NODE_JSDOC_EXCLUDE
     * <BR>Note that as "polling connection" we mean a loop of polling
     * requests, each of which requires opening a synchronous (i.e. not
     * streaming) connection to Lightstreamer Server.
     *
     * <p class="lifecycle"><b>Lifecycle:</b>
     * Note that the request to connect is accomplished by the client
     * asynchronously; this means that an invocation to {@link LightstreamerClient#getStatus}
     * right after connect() might not reflect the change yet. Also if a
     * CPU consuming task is performed right after the call the connection will
     * be delayed.
     * <BR>When the request to connect is finally being executed, if the current status
     * of the client is not DISCONNECTED, then nothing will be done.</p>
     *
START_NODE_JSDOC_EXCLUDE
     * @throws {IllegalStateException} if the LightstreamerClient cannot
     * connect to the server due to the sharing policies configured in the
     * {@link ConnectionSharing} object.
     * @see ConnectionSharing
     *
END_NODE_JSDOC_EXCLUDE
     * @throws {IllegalStateException} if no server address was configured
     * and there is no suitable default address to be used.
     *
     * @see LightstreamerClient#getStatus
     * @see LightstreamerClient#disconnect
     * @see ClientListener#onStatusChange
     * @see ConnectionDetails#setServerAddress
     */
    connect: function() {
        this.delegate.connect();
    },

    /**
     * Operation method that requests to close the Session opened against the
     * configured Lightstreamer Server (if any).
     * <BR>When disconnect() is called, the "Stream-Sense" mechanism is stopped.
     * <BR>Note that active {@link Subscription} instances, associated with this
     * LightstreamerClient instance, are preserved to be re-subscribed to on future
     * Sessions.
START_NODE_JSDOC_EXCLUDE
     * <BR>In case of a shared connection, the disconnect() call will apply to such
     * shared connection regardless of which LightstreamerClient is calling it.
END_NODE_JSDOC_EXCLUDE
     *
     * <p class="lifecycle"><b>Lifecycle:</b>
     * Note that the request to disconnect is accomplished by the client
     * asynchronously; this means that an invocation to {@link LightstreamerClient#getStatus}
     * right after disconnect() might not reflect the change yet. Also if a
     * CPU consuming task is performed right after the call the disconnection will
     * be delayed.
     * <BR>When the request to disconnect is finally being executed, if the status of the client is
     * "DISCONNECTED", then nothing will be done.</p>
     */
    disconnect: function() {
        this.delegate.disconnect();
    },

    /**
     * Inquiry method that gets the current client status and transport
     * (when applicable).
     *
     * @return {String} The current client status. It can be one of the following
     * values:
     * <ul>
     * <li>"CONNECTING" the client is waiting for a Server's response in order
     * to establish a connection;</li>
     * <li>"CONNECTED:STREAM-SENSING" the client has received a preliminary
     * response from the server and is currently verifying if a streaming connection
     * is possible;</li>
     * <li>"CONNECTED:WS-STREAMING" a streaming connection over WebSocket is active;</li>
     * <li>"CONNECTED:HTTP-STREAMING" a streaming connection over HTTP is active;</li>
     * <li>"CONNECTED:WS-POLLING" a polling connection over WebSocket is in progress;</li>
     * <li>"CONNECTED:HTTP-POLLING" a polling connection over HTTP is in progress;</li>
     * <li>"STALLED" the Server has not been sending data on an active
     * streaming connection for longer than a configured time;</li>
     * <li>"DISCONNECTED:WILL-RETRY" no connection is currently active but one will
     * be opened (possibly after a timeout).</li>
     * <li>"DISCONNECTED:TRYING-RECOVERY" no connection is currently active,
     * but one will be opened as soon as possible, as an attempt to recover
     * the current session after a connection issue;</li>
     * <li>"DISCONNECTED" no connection is currently active;</li>
     * </ul>
     *
     * @see ClientListener#onStatusChange
     */
    getStatus: function() {
        return this.delegate.getStatus();
    },

    /**
     * Operation method that sends a message to the Server. The message is
     * interpreted and handled by the Metadata Adapter associated to the
     * current Session. This operation supports in-order guaranteed message
     * delivery with automatic batching. In other words, messages are
     * guaranteed to arrive exactly once and respecting the original order,
     * whatever is the underlying transport (HTTP or WebSockets). Furthermore,
     * high frequency messages are automatically batched, if necessary,
     * to reduce network round trips.
     * <BR>Upon subsequent calls to the method, the sequential management of
     * the involved messages is guaranteed. The ordering is determined by the
     * order in which the calls to sendMessage are issued
START_NODE_JSDOC_EXCLUDE
     * ; in case of calls
     * issued from different LightstreamerClient instances on different html pages
     * sharing the same connection, the relative order is determined by the client
     * owning the shared connection. Anyway two messages sent through the same
     * LightstreamerClient instance will never surpass each other
END_NODE_JSDOC_EXCLUDE
     * .
     * <BR>If a message, for any reason, doesn't reach the Server (this is possible with the HTTP transport),
     * it will be resent; however, this may cause the subsequent messages to be delayed.
     * For this reason, each message can specify a "delayTimeout", which is the longest time the message, after
     * reaching the Server, can be kept waiting if one of more preceding messages haven't been received yet.
     * If the "delayTimeout" expires, these preceding messages will be discarded; any discarded message
     * will be notified to the listener through {@link ClientMessageListener#onDiscarded}.
     * Note that, because of the parallel transport of the messages, if a zero or very low timeout is 
     * set for a message and the previous message was sent immediately before, it is possible that the
     * latter gets discarded even if no communication issues occur.
     * The Server may also enforce its own timeout on missing messages, to prevent keeping the subsequent
     * messages for long time.
     * <BR>Sequence identifiers can also be associated with the messages.
     * In this case, the sequential management is restricted to all subsets
     * of messages with the same sequence identifier associated.
     * <BR>Notifications of the operation outcome can be received by supplying
     * a suitable listener. The supplied listener is guaranteed to be eventually
     * invoked; listeners associated with a sequence are guaranteed to be invoked
     * sequentially.
     * <BR>The "UNORDERED_MESSAGES" sequence name has a special meaning.
     * For such a sequence, immediate processing is guaranteed, while strict
     * ordering and even sequentialization of the processing is not enforced.
     * Likewise, strict ordering of the notifications is not enforced.
     * However, messages that, for any reason, should fail to reach the Server
     * whereas subsequent messages had succeeded, might still be discarded after
     * a server-side timeout, in order to ensure that the listener eventually gets a notification.
     * <BR>Moreover, if "UNORDERED_MESSAGES" is used and no listener is supplied,
     * a "fire and forget" scenario is assumed. In this case, no checks on
     * missing, duplicated or overtaken messages are performed at all, so as to
     * optimize the processing and allow the highest possible throughput.
     *
     * <p class="lifecycle"><b>Lifecycle:</b> Since a message is handled by the Metadata
     * Adapter associated to the current connection, a message can be sent
     * only if a connection is currently active.
     * If the special enqueueWhileDisconnected flag is specified it is possible to
     * call the method at any time and the client will take care of sending the
     * message as soon as a connection is available, otherwise, if the current status
     * is "DISCONNECTED*", the message will be abandoned and the
     * {@link ClientMessageListener#onAbort} event will be fired.
     * <BR>Note that, in any case, as soon as the status switches again to
     * "DISCONNECTED*", any message still pending is aborted, including messages
     * that were queued with the enqueueWhileDisconnected flag set to true.
     * <BR>Also note that forwarding of the message to the server is made
     * asynchronously; this means that if a CPU consuming task is
     * performed right after the call, the message will be delayed. Hence,
     * if a message is sent while the connection is active, it could be aborted
     * because of a subsequent disconnection. In the same way a message sent
     * while the connection is not active might be sent because of a subsequent
     * connection.</p>
     *
     * @throws: {IllegalArgumentException} if the given sequence name is
     * invalid.
     * @throws: {IllegalArgumentException} if NaN or a negative value is
     * given as delayTimeout.
     *
     * @param {String} msg a text message, whose interpretation is entirely
     * demanded to the Metadata Adapter associated to the current connection.
     * @param {String} [sequence="UNORDERED_MESSAGES"] an alphanumeric identifier, used to
     * identify a subset of messages to be managed in sequence; underscore
     * characters are also allowed. If the "UNORDERED_MESSAGES" identifier is
     * supplied, the message will be processed in the special way described
     * above.
     * <BR>The parameter is optional; if not supplied, "UNORDERED_MESSAGES" is used
     * as the sequence name.
     * @param {Number} [delayTimeout] a timeout, expressed in milliseconds.
     * If higher than the Server configured timeout on missing messages,
     * the latter will be used instead. <BR>
     * The parameter is optional; if not supplied, the Server configured timeout on missing
     * messages will be applied.
     * <BR>This timeout is ignored for the special "UNORDERED_MESSAGES" sequence,
     * although a server-side timeout on missing messages still applies.
     * @param {ClientMessageListener} [listener] an
     * object suitable for receiving notifications about the processing outcome.
     * <BR>The parameter is optional; if not supplied, no notification will be
     * available.
     * @param {boolean} [enqueueWhileDisconnected=false] if this flag is set to true, and
     * the client is in a disconnected status when the provided message
     * is handled, then the message is not aborted right away but is queued waiting
     * for a new session. Note that the message can still be aborted later when a new
     * session is established.
     */
    sendMessage: function(msg,sequence,delayTimeout,listener,enqueueWhileDisconnected) {
        this.delegate.sendMessage(msg, sequence, delayTimeout, listener, enqueueWhileDisconnected);
    },

    /**
     * Inquiry method that returns an array containing all the {@link Subscription}
     * instances that are currently "active" on this LightstreamerClient.
     * <BR/>Internal second-level Subscription are not included.
     *
     * @return {String[]} An array, containing all the {@link Subscription} currently
     * "active" on this LightstreamerClient.
     * <BR>The array can be empty.
     */
    getSubscriptions: function() {
        return this.delegate.getSubscriptionWrappers();
    },

    /**
     * Operation method that adds a {@link Subscription} to the list of "active"
     * Subscriptions.
     * The Subscription cannot already be in the "active" state.
     * <BR>Active subscriptions are subscribed to through the server as soon as possible
     * (i.e. as soon as there is a session available). Active Subscription are
     * automatically persisted across different sessions as long as a related
     * unsubscribe call is not issued.
     *
     * <p class="lifecycle"><b>Lifecycle:</b> Subscriptions can be given to the LightstreamerClient at
     * any time. Once done the Subscription immediately enters the "active" state.
     * <BR>Once "active", a {@link Subscription} instance cannot be provided again
     * to a LightstreamerClient unless it is first removed from the "active" state
     * through a call to {@link LightstreamerClient#unsubscribe}.
     * <BR>Also note that forwarding of the subscription to the server is made
     * asynchronously; this means that if a CPU consuming task is
     * performed right after the call the subscription will be delayed.
     * <BR>A successful subscription to the server will be notified through a
     * {@link SubscriptionListener#onSubscription} event.</p>
     *
     * @throws {IllegalArgumentException} if the given Subscription does
     * not contain a field list/field schema.
     * @throws {IllegalArgumentException} if the given Subscription does
     * not contain a item list/item group.
     * @throws {IllegalStateException}  if the given Subscription is already "active".
     *
     * @param {Subscription} subscription A {@link Subscription} object, carrying
     * all the information needed to process its pushed values.
     *
     * @see SubscriptionListener#onSubscription
     */
    subscribe: function(subscription) {
        this.delegate.subscribe(subscription);
    },

    /**
     * Operation method that removes a {@link Subscription} that is currently in
     * the "active" state.
     * <BR>By bringing back a Subscription to the "inactive" state, the unsubscription
     * from all its items is requested to Lightstreamer Server.
     *
     * <p class="lifecycle"><b>Lifecycle:</b> Subscription can be unsubscribed from at
     * any time. Once done the Subscription immediately exits the "active" state.
     * <BR>Note that forwarding of the unsubscription to the server is made
     * asynchronously; this means that if a CPU consuming task is
     * performed right after the call the unsubscription will be delayed.
     * <BR>The unsubscription will be notified through a
     * {@link SubscriptionListener#onUnsubscription} event.</p>
     *
     * @throws {IllegalStateException} if the given Subscription is not
     * currently "active".
     *
     * @param {Subscription} subscription An "active" {@link Subscription} object
     * that was activated by this LightstreamerClient instance.
     *
     * @see SubscriptionListener#onUnsubscription
     */
    unsubscribe: function(subscription) {
        this.delegate.unsubscribe(subscription);
    },

    /**
     * Adds a listener that will receive events from the LightstreamerClient
     * instance.
     * <BR>The same listener can be added to several different LightstreamerClient
     * instances.
     *
     * <p class="lifecycle"><b>Lifecycle:</b> a listener can be added at any time.</p>
     *
     * @param {ClientListener} listener An object that will receive the events
     * as shown in the {@link ClientListener} interface.
     * <BR>Note that the given instance does not have to implement all of the
     * methods of the ClientListener interface. In fact it may also
     * implement none of the interface methods and still be considered a valid
     * listener. In the latter case it will obviously receive no events.
     */
    addListener: function(listener) {
        this.delegate.addListener(listener);
    },

    /**
     * Removes a listener from the LightstreamerClient instance so that it
     * will not receive events anymore.
     *
     * <p class="lifecycle"><b>Lifecycle:</b> a listener can be removed at any time.</p>
     *
     * @param {ClientListener} listener The listener to be removed.
     */
    removeListener: function(listener) {
        this.delegate.removeListener(listener);
    },

    /**
     * Returns an array containing the {@link ClientListener} instances that
     * were added to this client.
     *
     * @return {ClientListener[]} an array containing the listeners that were added to this client.
     * Listeners added multiple times are included multiple times in the array.
     */
    getListeners: function() {
        return this.delegate.getListeners();
    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Operation method that registers the MPN device on the server's MPN Module.<BR>
     * By registering an MPN device, the client enables MPN functionalities such as {@link LightstreamerClient#subscribeMpn}.
     *
     * <p class="edition-note"><B>Edition Note:</B> MPN is an optional feature, available depending on Edition and License Type.
     * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
     * available at /dashboard).</p>
     *
     * <p class="lifecycle"><b>Lifecycle:</b> An {@link MpnDevice} can be registered at any time. The registration will be notified through a {@link MpnDeviceListener#onRegistered} event.</p>
     *
     * @param device An {@link MpnDevice} instance, carrying all the information about the MPN device.
     * @throws IllegalArgumentException if the specified device is null.
     *
     * @see #subscribeMpn
     */
// END_NODE_JSDOC_EXCLUDE
    registerForMpn: function(device) {
        this.delegate.registerForMpn(device);
    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Operation method that subscribes an MpnSubscription on server's MPN Module.<BR>
     * This operation adds the {@link MpnSubscription} to the list of "active" subscriptions. MPN subscriptions are activated on the server as soon as possible
     * (i.e. as soon as there is a session available and subsequently as soon as the MPN device registration succeeds). Differently than real-time subscriptions,
     * MPN subscriptions are persisted on the server's MPN Module database and survive the session they were created on.<BR>
     * If the <code>coalescing</code> flag is <i>set</i>, the activation of two MPN subscriptions with the same Adapter Set, Data Adapter, Group, Schema and trigger expression will be
     * considered the same MPN subscription. Activating two such subscriptions will result in the second activation modifying the first MpnSubscription (that
     * could have been issued within a previous session). If the <code>coalescing</code> flag is <i>not set</i>, two activations are always considered different MPN subscriptions,
     * whatever the Adapter Set, Data Adapter, Group, Schema and trigger expression are set.<BR>
     * The rationale behind the <code>coalescing</code> flag is to allow simple apps to always activate their MPN subscriptions when the app starts, without worrying if
     * the same subscriptions have been activated before or not. In fact, since MPN subscriptions are persistent, if they are activated every time the app starts and
     * the <code>coalescing</code> flag is not set, every activation is a <i>new</i> MPN subscription, leading to multiple push notifications for the same event.
     *
     * <p class="edition-note"><B>Edition Note:</B> MPN is an optional feature, available depending on Edition and License Type.
     * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
     * available at /dashboard).</p>
     *
     * <p class="lifecycle"><b>Lifecycle:</b> An MpnSubscription can be given to the LightstreamerClient once an MpnDevice registration has been requested. The MpnSubscription
     * immediately enters the "active" state.<BR>
     * Once "active", an MpnSubscription instance cannot be provided again to an LightstreamerClient unless it is first removed from the "active" state through
     * a call to {@link #unsubscribeMpn}.<BR>
     * A successful subscription to the server will be notified through an {@link MpnSubscriptionListener#onSubscription} event.</p>
     *
     * @param subscription An MpnSubscription object, carrying all the information to route real-time data via push notifications.
     * @param coalescing A flag that specifies if the MPN subscription must coalesce with any pre-existing MPN subscription with the same Adapter Set, Data Adapter,
     * Group, Schema and trigger expression.
     * @throws IllegalStateException if the given MPN subscription does not contain a field list/field schema.
     * @throws IllegalStateException if the given MPN subscription does not contain a item list/item group.
     * @throws IllegalStateException if there is no MPN device registered.
     * @throws IllegalStateException if the given MPN subscription is already active.
     *
     * @see #unsubscribeMpn
     * @see #unsubscribeMpnSubscriptions
     */
// END_NODE_JSDOC_EXCLUDE
    subscribeMpn: function(subscription, coalescing) {
        this.delegate.subscribeMpn(subscription, coalescing);
    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Operation method that unsubscribes an MpnSubscription from the server's MPN Module.<BR>
     * This operation removes the MpnSubscription from the list of "active" subscriptions.
     *
     * <p class="edition-note"><B>Edition Note:</B> MPN is an optional feature, available depending on Edition and License Type.
     * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
     * available at /dashboard).</p>
     *
     * <p class="lifecycle"><b>Lifecycle:</b> An MpnSubscription can be unsubscribed from at any time. Once done the MpnSubscription immediately exits the "active" state.<BR>
     * The unsubscription will be notified through an {@link MpnSubscriptionListener#onUnsubscription} event.</p>
     *
     * @param subscription An "active" MpnSubscription object.
     * @throws IllegalStateException if the given MPN subscription is not active.
     * @throws IllegalStateException if there is no MPN device registered.
     *
     * @see #subscribeMpn
     * @see #unsubscribeMpnSubscriptions
     */
// END_NODE_JSDOC_EXCLUDE
    unsubscribeMpn: function(/*MpnSubscription*/ subscription) {
        this.delegate.unsubscribeMpn(subscription);
    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Operation method that unsubscribes all the MPN subscriptions with a specified status from the server's MPN Module.<BR>
     * By specifying a status filter it is possible to unsubscribe multiple MPN subscriptions at once. E.g. by passing <code>TRIGGERED</code> it is possible
     * to unsubscribe all triggered MPN subscriptions. This operation removes the involved MPN subscriptions from the list of "active" subscriptions.
     *
     * <p class="edition-note"><B>Edition Note:</B> MPN is an optional feature, available depending on Edition and License Type.
     * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
     * available at /dashboard).</p>
     *
     * <p class="lifecycle"><b>Lifecycle:</b> Multiple unsubscription can be requested at any time. Once done the involved MPN subscriptions immediately exit the "active" state.<BR>
     * The unsubscription will be notified through an {@link MpnSubscriptionListener#onUnsubscription} event to all involved MPN subscriptions.</p>
     *
     * @param filter A status name to be used to select the MPN subscriptions to unsubscribe. If null all existing MPN subscriptions
     * are unsubscribed. Possible filter values are:<ul>
     * <li><code>ALL</code> or null</li>
     * <li><code>TRIGGERED</code></li>
     * <li><code>SUBSCRIBED</code></li>
     * </ul>
     * @throws IllegalArgumentException if the given filter is not valid.
     * @throws IllegalStateException if there is no MPN device registered.
     *
     * @see #subscribeMpn
     * @see #unsubscribeMpn
     */
// END_NODE_JSDOC_EXCLUDE
    unsubscribeMpnSubscriptions: function(filter) {
        this.delegate.unsubscribeMpnSubscriptions(filter);
    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Inquiry method that returns a collection of the existing MPN subscription with a specified status.<BR>
     * Can return both objects created by the user, via {@link MpnSubscription} constructors, and objects created by the client, to represent pre-existing MPN subscriptions.<BR>
     * Note that objects in the collection may be substituted at any time with equivalent ones: do not rely on pointer matching, instead rely on the
     * {@link MpnSubscription#getSubscriptionId} value to verify the equivalence of two MpnSubscription objects. Substitutions may happen
     * when an MPN subscription is modified, or when it is coalesced with a pre-existing subscription.
     *
     * <p class="edition-note"><B>Edition Note:</B> MPN is an optional feature, available depending on Edition and License Type.
     * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
     * available at /dashboard).</p>
     *
     * <p class="lifecycle"><b>Lifecycle:</b> The collection is available once an MpnDevice registration has been requested, but reflects the actual server's collection only
     * after an {@link MpnDeviceListener#onSubscriptionsUpdated} event has been notified.</p>
     *
     * @param {String} filter An MPN subscription status name to be used to select the MPN subscriptions to return. If null all existing MPN subscriptions
     * are returned. Possible filter values are:<ul>
     * <li><code>ALL</code> or null</li>
     * <li><code>TRIGGERED</code></li>
     * <li><code>SUBSCRIBED</code></li>
     * </ul>
     * @return {MpnSubscription[]} the collection of {@link MpnSubscription} with the specified status.
     * @throws IllegalArgumentException if the given filter is not valid.
     * @throws IllegalStateException if there is no MPN device registered.
     *
     * @see #findMpnSubscription
     */
// END_NODE_JSDOC_EXCLUDE
    getMpnSubscriptions: function(filter) {
        return this.delegate.getMpnSubscriptionWrappers();
    },

// START_NODE_JSDOC_EXCLUDE
    /**
     * Inquiry method that returns the MpnSubscription with the specified subscription ID, or null if not found.<BR>
     * The object returned by this method can be an object created by the user, via MpnSubscription constructors, or an object created by the client,
     * to represent pre-existing MPN subscriptions.<BR>
     * Note that objects returned by this method may be substitutued at any time with equivalent ones: do not rely on pointer matching, instead rely on the
     * {@link MpnSubscription#getSubscriptionId} value to verify the equivalence of two MpnSubscription objects. Substitutions may happen
     * when an MPN subscription is modified, or when it is coalesced with a pre-existing subscription.
     *
     * <p class="edition-note"><B>Edition Note:</B> MPN is an optional feature, available depending on Edition and License Type.
     * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
     * available at /dashboard).</p>
     *
     * @param {String} subscriptionId The subscription ID to search for.
     * @return {MpnSubscription} the MpnSubscription with the specified ID, or null if not found.
     * @throws IllegalArgumentException if the given subscription ID is null.
     * @throws IllegalStateException if there is no MPN device registered.
     *
     * @see #getMpnSubscriptions
     */
// END_NODE_JSDOC_EXCLUDE
    findMpnSubscription: function(subscriptionId) {
        return this.delegate.findMpnSubscriptionWrapper(subscriptionId);
    },
};

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
  this.delegate = new LSSubscription(subscriptionMode, items, fields, this);
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
    return this.delegate.isActive();
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
    return this.delegate.isSubscribed();
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
    this.delegate.setItems(items);
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
    return this.delegate.getItems();
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
    this.delegate.setItemGroup(groupName);
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
    return this.delegate.getItemGroup();
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
    this.delegate.setFields(fields);
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
    return this.delegate.getFields();
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
    this.delegate.setFieldSchema(schemaName);
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
    return this.delegate.getFieldSchema();
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
    return this.delegate.getMode();
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
    this.delegate.setDataAdapter(dataAdapter);
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
    return this.delegate.getDataAdapter();
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
    this.delegate.setSelector(selector);
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
    return this.delegate.getSelector();
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
    this.delegate.setRequestedMaxFrequency(freq);
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
    return this.delegate.getRequestedMaxFrequency();
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
    this.delegate.setRequestedBufferSize(size);
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
    return this.delegate.getRequestedBufferSize();
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
    this.delegate.setRequestedSnapshot(required);
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
    return this.delegate.getRequestedSnapshot();
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
    this.delegate.setCommandSecondLevelFields(fields);
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
    return this.delegate.getCommandSecondLevelFields();
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
    this.delegate.setCommandSecondLevelFieldSchema(schemaName);
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
    return this.delegate.getCommandSecondLevelFieldSchema();
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
    this.delegate.setCommandSecondLevelDataAdapter(dataAdapter);
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
    return this.delegate.getCommandSecondLevelDataAdapter();
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
    return this.delegate.getValue(itemIdentifier, fieldIdentifier);
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
    return this.delegate.getCommandValue(itemIdentifier, keyValue, fieldIdentifier);
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
    return this.delegate.getKeyPosition();
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
    return this.delegate.getCommandPosition();
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
    this.delegate.addListener(listener);
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
    this.delegate.removeListener(listener);
  },
  
  /**
   * Returns an array containing the {@link SubscriptionListener} instances that
   * were added to this client.
   * 
   * @return {SubscriptionListener[]} an Array containing the listeners that were added to this client.
   * Listeners added multiple times are included multiple times in the array.
   */
  getListeners: function() {
    return this.delegate.getListeners();
  },
};
