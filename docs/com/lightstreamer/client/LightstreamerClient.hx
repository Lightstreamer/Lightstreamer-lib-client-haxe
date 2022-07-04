package com.lightstreamer.client;

import com.lightstreamer.native.NativeTypes;

/**
 * Facade class for the management of the communication to
 * Lightstreamer Server. Used to provide configuration settings, event
 * handlers, operations for the control of the connection lifecycle,
 * `Subscription` handling and to send messages. <BR>
 * An instance of LightstreamerClient handles the communication with
 * Lightstreamer Server on a specified endpoint. Hence, it hosts one "Session";
 * or, more precisely, a sequence of Sessions, since any Session may fail
 * and be recovered, or it can be interrupted on purpose.
 * So, normally, a single instance of LightstreamerClient is needed. <BR>
 * However, multiple instances of LightstreamerClient can be used,
 * toward the same or multiple endpoints.
 */
class LightstreamerClient {
  /**
   * A constant string representing the name of the library.
   */
  public static final LIB_NAME: String = "LIB_NAME";
  /**
   * A constant string representing the version of the library.
   */
  public static final LIB_VERSION: String = "LIB_VERSION";
  /**
   * Data object that contains the details needed to open a connection to 
   * a Lightstreamer Server. This instance is set up by the LightstreamerClient object at 
   * its own creation. <BR>
   * Properties of this object can be overwritten by values received from a 
   * Lightstreamer Server. 
   */
  public final connectionDetails: ConnectionDetails = null;
  /**
   * Data object that contains options and policies for the connection to 
   * the server. This instance is set up by the LightstreamerClient object at 
   * its own creation. <BR>
   * Properties of this object can be overwritten by values received from a 
   * Lightstreamer Server. 
   */
  public final connectionOptions: ConnectionOptions = null;
  /**
   * Static method that permits to configure the logging system used by the library. The logging system 
   * must respect the `LoggerProvider`
   * interface. A custom class can be used to wrap any third-party 
   * logging system. <BR>
   * If no logging system is specified, all the generated log is discarded. <BR>
   * The following categories are available to be consumed:
   * <ul>
   *  <li>lightstreamer.stream:<BR>
   *  logs socket activity on Lightstreamer Server connections;<BR>
   *  at INFO level, socket operations are logged;<BR>
   *  at DEBUG level, read/write data exchange is logged.
   *  </li>
   *  <li>lightstreamer.protocol:<BR>
   *  logs requests to Lightstreamer Server and Server answers;<BR>
   *  at INFO level, requests are logged;<BR>
   *  at DEBUG level, request details and events from the Server are logged.
   *  <li>lightstreamer.session:<BR>
   *  logs Server Session lifecycle events;<BR>
   *  at INFO level, lifecycle events are logged;<BR>
   *  at DEBUG level, lifecycle event details are logged.
   *  </li>
   *  <li>lightstreamer.subscriptions:<BR>
   *  logs subscription requests received by the clients and the related updates;<BR>
   *  at WARN level, alert events from the Server are logged;<BR>
   *  at INFO level, subscriptions and unsubscriptions are logged;<BR>
   *  at DEBUG level, requests batching and update details are logged.
   *  </li>
   *  <li>lightstreamer.actions:<BR>
   *  logs settings / API calls.
   *  </li>
   * </ul>
   *
   * @param provider A `LoggerProvider`
   * instance that will be used to generate log messages by the library classes.
   */
  public static function setLoggerProvider(provider: com.lightstreamer.log.LoggerProvider): Void {}
  #if LS_HAS_COOKIES
  /**
   * Static method that can be used to share cookies between connections to the Server
   * (performed by this library) and connections to other sites that are performed
   * by the application. With this method, cookies received by the application
   * can be added (or replaced if already present) to the cookie set used by the
   * library to access the Server. Obviously, only cookies whose domain is compatible
   * with the Server domain will be used internally.
   *
   * **lifecycle** This method can be called at any time;
   * it will affect the internal cookie set immediately and the sending of cookies
   * on future requests.
   *
   * @param uri the URI from which the supplied
   * cookies were received. It can be null.
   *
   * @param cookies the various
   * cookies to be added. Each cookie should be represented in the text format
   * provided for the Set-Cookie HTTP header by RFC 6265.
   *
   * @see `LightstreamerClient.getCookies`
   */
  public static function addCookies(uri: NativeURI, cookies: NativeCookieCollection): Void {}
  /**
   * Static inquiry method that can be used to share cookies between connections to the Server
   * (performed by this library) and connections to other sites that are performed
   * by the application. With this method, cookies received from the Server can be
   * extracted for sending through other connections, according with the URI to be accessed.
   *
   * @param uri the URI to which the cookies should
   * be sent, or null.
   *
   * @return the various cookies that can
   * be sent in a HTTP request for the specified URI. If a null URI was supplied,
   * the export of all available cookies, including expired ones, will be returned.
   * Each cookie is represented in the text format provided for the Set-Cookie HTTP header
   * by RFC 6265.
   *
   * @see `LightstreamerClient.addCookies`
   */
  public static function getCookies(uri: Null<NativeURI>): NativeCookieCollection return null;
  #end
  #if LS_HAS_TRUST_MANAGER
   /**
   * Provides a mean to control the way TLS certificates are evaluated, with the possibility to accept untrusted ones.
   * 
   * **lifecycle** May be called only once before creating any LightstreamerClient instance.
   * 
   * @param factory trust manager factory
   * @throws NullPointerException if the factory is null
   * @throws IllegalStateException if a factory is already installed
   */
  public static function setTrustManagerFactory(factory: NativeTrustManager) {}
  #end
  /**
   * Creates an object to be configured to connect to a Lightstreamer server
   * and to handle all the communications with it.
   * Each LightstreamerClient is the entry point to connect to a Lightstreamer server, 
   * subscribe to as many items as needed and to send messages. 
   * 
   * @param serverAddress the address of the Lightstreamer Server to
   * which this LightstreamerClient will connect to. It is possible to specify it later
   * by using null here. See `ConnectionDetails.setServerAddress(String)`
   * for details.
   * @param adapterSet the name of the Adapter Set mounted on Lightstreamer Server 
   * to be used to handle all requests in the Session associated with this 
   * LightstreamerClient. It is possible not to specify it at all or to specify 
   * it later by using null here. See `ConnectionDetails.setAdapterSet(String)` 
   * for details.
   *
   * @throws IllegalArgumentException if a not valid address is passed. See
   * `ConnectionDetails.setServerAddress(String)` for details.
   */
  public function new(serverAddress: String, adapterSet: String) {}
  /**
   * Adds a listener that will receive events from the LightstreamerClient instance. <BR> 
   * The same listener can be added to several different LightstreamerClient instances.
   *
   * **lifecycle** A listener can be added at any time. A call to add a listener already 
   * present will be ignored.
   * 
   * @param listener An object that will receive the events as documented in the 
   * ClientListener interface.
   * 
   * @see `this.removeListener(ClientListener)`
   */
  public function addListener(listener: ClientListener): Void {}
  /**
   * Removes a listener from the LightstreamerClient instance so that it will not receive events anymore.
   * 
   * **lifecycle** a listener can be removed at any time.
   * 
   * @param listener The listener to be removed.
   * 
   * @see `this.addListener(ClientListener)`
   */
  public function removeListener(listener: ClientListener): Void {}
  /**
   * Returns a list containing the `ClientListener` instances that were added to this client.
   *
   * @return a list containing the listeners that were added to this client. 
   * @see `this.addListener(ClientListener)`
   */
  public function getListeners(): #if python Array #elseif java java.util.List #end<ClientListener> return null;
  /**
   * Operation method that requests to open a Session against the configured Lightstreamer Server. <BR>
   * When connect() is called, unless a single transport was forced through 
   * `ConnectionOptions.setForcedTransport(String)`, the so called "Stream-Sense" mechanism is started: 
   * if the client does not receive any answer for some seconds from the streaming connection, then it 
   * will automatically open a polling connection. <BR>
   * A polling connection may also be opened if the environment is not suitable for a streaming connection. <BR>
   * Note that as "polling connection" we mean a loop of polling requests, each of which requires opening a 
   * synchronous (i.e. not streaming) connection to Lightstreamer Server.
   * 
   * **lifecycle** Note that the request to connect is accomplished by the client in a separate thread; this means 
   * that an invocation to `this.getStatus` right after connect() might not reflect the change yet. <BR> 
   * When the request to connect is finally being executed, if the current status
   * of the client is not DISCONNECTED, then nothing will be done.
   * 
   * @throws IllegalStateException if no server address was configured.
   * 
   * @see `this.getStatus`
   * @see `this.disconnect`
   * @see `ClientListener.onStatusChange(String)`
   * @see `ConnectionDetails.setServerAddress(String)`
   */
  public function connect(): Void {}
  /**
   * Operation method that requests to close the Session opened against the configured Lightstreamer Server 
   * (if any). <BR>
   * When disconnect() is called, the "Stream-Sense" mechanism is stopped. <BR>
   * Note that active Subscription instances, associated with this LightstreamerClient instance, are preserved 
   * to be re-subscribed to on future Sessions.
   * 
   * **lifecycle**  Note that the request to disconnect is accomplished by the client in a separate thread; this 
   * means that an invocation to `this.getStatus` right after disconnect() might not reflect the change yet. <BR> 
   * When the request to disconnect is finally being executed, if the status of the client is "DISCONNECTED", 
   * then nothing will be done.
   * 
   * @see `this.connect`
   */
  public function disconnect(): Void {}
  /**
   * Inquiry method that gets the current client status and transport (when applicable).
   * 
   * Returns the current client status. It can be one of the following values:
   * <ul>
   *  <li>"CONNECTING" the client is waiting for a Server's response in order to establish a connection;</li>
   *  <li>"CONNECTED:STREAM-SENSING" the client has received a preliminary response from the server and 
   *  is currently verifying if a streaming connection is possible;</li>
   *  <li>"CONNECTED:WS-STREAMING" a streaming connection over WebSocket is active;</li>
   *  <li>"CONNECTED:HTTP-STREAMING" a streaming connection over HTTP is active;</li>
   *  <li>"CONNECTED:WS-POLLING" a polling connection over WebSocket is in progress;</li>
   *  <li>"CONNECTED:HTTP-POLLING" a polling connection over HTTP is in progress;</li>
   *  <li>"STALLED" the Server has not been sending data on an active streaming connection for longer 
   *  than a configured time;</li>
   *  <li>"DISCONNECTED:WILL-RETRY" no connection is currently active but one will be opened (possibly after a timeout);</li>
   *  <li>"DISCONNECTED:TRYING-RECOVERY" no connection is currently active,
   *  but one will be opened as soon as possible, as an attempt to recover
   *  the current session after a connection issue;</li> 
   *  <li>"DISCONNECTED" no connection is currently active.</li>
   * </ul>
   * 
   * @see `ClientListener.onStatusChange(String)`
   */
  public function getStatus(): String return null;
  /**
   * Operation method that sends a message to the Server. The message is interpreted and handled by 
   * the Metadata Adapter associated to the current Session. This operation supports in-order 
   * guaranteed message delivery with automatic batching. In other words, messages are guaranteed 
   * to arrive exactly once and respecting the original order, whatever is the underlying transport 
   * (HTTP or WebSockets). Furthermore, high frequency messages are automatically batched, if necessary,
   * to reduce network round trips. <BR>
   * Upon subsequent calls to the method, the sequential management of the involved messages is guaranteed. 
   * The ordering is determined by the order in which the calls to sendMessage are issued. <BR>
   * If a message, for any reason, doesn't reach the Server (this is possible with the HTTP transport),
   * it will be resent; however, this may cause the subsequent messages to be delayed.
   * For this reason, each message can specify a "delayTimeout", which is the longest time the message, after
   * reaching the Server, can be kept waiting if one of more preceding messages haven't been received yet.
   * If the "delayTimeout" expires, these preceding messages will be discarded; any discarded message
   * will be notified to the listener through `ClientMessageListener.onDiscarded(String)`.
   * Note that, because of the parallel transport of the messages, if a zero or very low timeout is 
   * set for a message and the previous message was sent immediately before, it is possible that the
   * latter gets discarded even if no communication issues occur.
   * The Server may also enforce its own timeout on missing messages, to prevent keeping the subsequent
   * messages for long time. <BR>
   * Sequence identifiers can also be associated with the messages. In this case, the sequential management is 
   * restricted to all subsets of messages with the same sequence identifier associated. <BR>
   * Notifications of the operation outcome can be received by supplying a suitable listener. The supplied 
   * listener is guaranteed to be eventually invoked; listeners associated with a sequence are guaranteed 
   * to be invoked sequentially. <BR>
   * The "UNORDERED_MESSAGES" sequence name has a special meaning. For such a sequence, immediate processing 
   * is guaranteed, while strict ordering and even sequentialization of the processing is not enforced. 
   * Likewise, strict ordering of the notifications is not enforced. However, messages that, for any reason, 
   * should fail to reach the Server whereas subsequent messages had succeeded, might still be discarded after 
   * a server-side timeout, in order to ensure that the listener eventually gets a notification.<BR>
   * Moreover, if "UNORDERED_MESSAGES" is used and no listener is supplied, a "fire and forget" scenario
   * is assumed. In this case, no checks on missing, duplicated or overtaken messages are performed at all,
   * so as to optimize the processing and allow the highest possible throughput.
   * 
   * **lifecycle** Since a message is handled by the Metadata Adapter associated to the current connection, a
   * message can be sent only if a connection is currently active. If the special enqueueWhileDisconnected 
   * flag is specified it is possible to call the method at any time and the client will take care of sending
   * the message as soon as a connection is available, otherwise, if the current status is `DISCONNECTED*`, 
   * the message will be abandoned and the `ClientMessageListener.onAbort` event will be fired. <BR>
   * Note that, in any case, as soon as the status switches again to `DISCONNECTED*`, any message still pending 
   * is aborted, including messages that were queued with the enqueueWhileDisconnected flag set to true. <BR>
   * Also note that forwarding of the message to the server is made in a separate thread, hence, if a message 
   * is sent while the connection is active, it could be aborted because of a subsequent disconnection. 
   * In the same way a message sent while the connection is not active might be sent because of a subsequent
   * connection.
   * 
   * @param message a text message, whose interpretation is entirely demanded to the Metadata Adapter
   * associated to the current connection.
   * @param sequence an alphanumeric identifier, used to identify a subset of messages to be managed in sequence; 
   * underscore characters are also allowed. If the "UNORDERED_MESSAGES" identifier is supplied, the message will 
   * be processed in the special way described above. The parameter is optional; if set to null, "UNORDERED_MESSAGES" 
   * is used as the sequence name. 
   * @param delayTimeout a timeout, expressed in milliseconds. If higher than the Server configured timeout
   * on missing messages, the latter will be used instead. <BR> 
   * The parameter is optional; if a negative value is supplied, the Server configured timeout on missing
   * messages will be applied. <BR>
   * This timeout is ignored for the special "UNORDERED_MESSAGES" sequence, although a server-side timeout
   * on missing messages still applies.
   * @param listener an object suitable for receiving notifications about the processing outcome. The parameter is 
   * optional; if not supplied, no notification will be available.
   * @param enqueueWhileDisconnected if this flag is set to true, and the client is in a disconnected status when
   * the provided message is handled, then the message is not aborted right away but is queued waiting for a new
   * session. Note that the message can still be aborted later when a new session is established.
   */
  #if (java || cs)
  overload public function sendMessage(message: String, sequence: Null<String>, delayTimeout: Int, listener: Null<ClientMessageListener>, enqueueWhileDisconnected: Bool): Void {}
  #else
  public function sendMessage(message: String, sequence: Null<String> = null, delayTimeout: Null<Int> = -1, listener: Null<ClientMessageListener> = null, enqueueWhileDisconnected: Null<Bool> = false): Void {}
  #end
  #if (java || cs)
  /**
   * A simplified version of the `this.sendMessage(String,String,int,ClientMessageListener,boolean)`.
   * The internal implementation will call
   * <code>
   *   sendMessage(message,null,-1,null,false);
   * </code>
   * Note that this invocation involves no sequence and no listener, hence an optimized
   * fire-and-forget behavior will be applied.
   *  
   * @param message a text message, whose interpretation is entirely demanded to the Metadata Adapter
   * associated to the current connection.
   */
  overload public function sendMessage(message: String) {}  
  #end
  /**
   * Operation method that adds a Subscription to the list of "active" Subscriptions. The Subscription cannot already 
   * be in the "active" state. <BR>
   * Active subscriptions are subscribed to through the server as soon as possible (i.e. as soon as there is a 
   * session available). Active Subscription are automatically persisted across different sessions as long as a 
   * related unsubscribe call is not issued.
   * 
   * **lifecycle** Subscriptions can be given to the LightstreamerClient at any time. Once done the Subscription 
   * immediately enters the "active" state. <BR>
   * Once "active", a Subscription instance cannot be provided again to a LightstreamerClient unless it is 
   * first removed from the "active" state through a call to `this.unsubscribe(Subscription)`. <BR>
   * Also note that forwarding of the subscription to the server is made in a separate thread. <BR>
   * A successful subscription to the server will be notified through a `SubscriptionListener.onSubscription`
   * event.
   * 
   * @param subscription A Subscription object, carrying all the information needed to process real-time values.
   * 
   * @see `this.unsubscribe(Subscription)`
   */
  public function subscribe(subscription: Subscription): Void {}
  /**
   * Operation method that removes a Subscription that is currently in the "active" state. <BR> 
   * By bringing back a Subscription to the "inactive" state, the unsubscription from all its items is 
   * requested to Lightstreamer Server.
   * 
   * **lifecycle** Subscription can be unsubscribed from at any time. Once done the Subscription immediately 
   * exits the "active" state. <BR>
   * Note that forwarding of the unsubscription to the server is made in a separate thread. <BR>
   * The unsubscription will be notified through a `SubscriptionListener.onUnsubscription` event.
   * 
   * @param subscription An "active" Subscription object that was activated by this LightstreamerClient 
   * instance.
   */
  public function unsubscribe(subscription: Subscription) {}
  /**
   * Inquiry method that returns a list containing all the Subscription instances that are 
   * currently "active" on this LightstreamerClient. <BR>
   * Internal second-level Subscription are not included.
   *
   * @return A list, containing all the Subscription currently "active" on this LightstreamerClient. <BR>
   * The list can be empty.
   * @see `this.subscribe(Subscription)`
   */
  public function getSubscriptions(): NativeList<Subscription> return null;
}