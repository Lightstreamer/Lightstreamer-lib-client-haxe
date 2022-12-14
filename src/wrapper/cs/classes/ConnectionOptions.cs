using System;
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
    /// Used by LightstreamerClient to provide an extra connection properties data object.
    /// 
    /// Data object that contains the policy settings used to connect to a 
    /// Lightstreamer Server. <br/>
    /// An instance of this class is attached to every <seealso cref="LightstreamerClient"/>
    /// as <seealso cref="LightstreamerClient.connectionOptions"/><br/>
    /// </summary>
    /// <seealso cref="LightstreamerClient" />
    public class ConnectionOptions
    {
        readonly LSConnectionOptions _delegate;

        internal ConnectionOptions(LSConnectionOptions options) {
            this._delegate = options;
        }

        /// <value>
        /// Property <c>ContentLength</c> represents the length expressed in bytes to be used
        /// by the Server  for the response body on a stream connection (a minimum length, however,
        /// is ensured by the server). After the content length exhaustion, the connection will be
        /// closed and a new bind connection will be automatically reopened.<br/>
        /// NOTE that this setting only applies to the "HTTP-STREAMING" case (i.e.not to WebSockets).<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The content length should be set before calling the
        /// <seealso cref="LightstreamerClient.connect()"/> method. However, the value can be changed at any
        /// time: the supplied value will be used for the next streaming
        /// connection (either a bind or a brand new session).<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "contentLength" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> A length decided by the library, to ensure the best performance.
        /// It can be of a few MB or much higher, depending on the environment.
        /// </value>
        public virtual long ContentLength
        {
            get
            {
              return _delegate.getContentLength();
            }
            set
            {
              _delegate.setContentLength(value);
            }
        }

        /// <value>
        /// Property <c>FirstRetryMaxDelay</c> represents the maximum time (in milliseconds) to wait
        /// before trying a new connection to the Server in case the previous one is unexpectedly closed
        /// while correctly working.<br/>
        /// The new connection may be either the opening of a new session or an attempt to recovery the
        /// current session, depending on the kind of interruption.
        /// The actual delay is a randomized value between 0 and this value. This randomization might
        /// help avoid a load spike on the cluster due to simultaneous reconnections, should one of
        /// the active servers be stopped. Note that this delay is only applied before the first
        /// reconnection: should such reconnection fail, only the setting of <seealso cref="RetryDelay" />
        /// will be applied.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This value can be set and changed at any time.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "firstRetryMaxDelay" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 100 (0.1 seconds).
        /// </value>
        public virtual long FirstRetryMaxDelay
        {
            get
            {
              return _delegate.getFirstRetryMaxDelay();
            }
            set
            {
              _delegate.setFirstRetryMaxDelay(value);
            }
        }

        /// <value>
        /// Property <c>ForcedTransport</c> can be used to disable/enable the Stream-Sense algorithm
        /// and to force the client to use a fixed transport or a fixed combination of a transport and
        /// a connection type. When a combination is specified the Stream-Sense algorithm is completely
        /// disabled.<br/>
        /// The method can be used to switch between streaming and polling connection types and
        /// between HTTP and WebSocket transports.<br/>
        /// In some cases, the requested status may not be reached, because of connection or environment
        /// problems. In that case the client will continuously attempt to reach the configured status.<br/>
        /// Note that if the Stream-Sense algorithm is disabled, the client may still enter the
        /// "CONNECTED:STREAM-SENSING" status; however, in that case, if it eventually finds out that
        /// streaming is not possible, no recovery will be tried.<br/>
        /// <br/>
        /// Can be one of the following:
        /// <ul>
        /// <li>null: the Stream-Sense algorithm is enabled and the client will automatically connect
        /// using the most appropriate transport and connection type among those made possible by the
        /// environment.</li>
        /// <li>"WS": the Stream-Sense algorithm is enabled as in the null case but the client will
        /// only use WebSocket based connections. If a connection over WebSocket is not possible because
        /// of the environment the client will not connect at all.</li>
        /// <li>"HTTP": the Stream-Sense algorithm is enabled as in the null case but the client will only
        /// use HTTP based connections. If a connection over HTTP is not possible because of the
        /// environment the client will not connect at all.</li>
        /// <li>"WS-STREAMING": the Stream-Sense algorithm is disabled and the client will only connect on
        /// Streaming over WebSocket. If Streaming over WebSocket is not possible because of the
        /// environment the client will not connect at all.</li>
        /// <li>"HTTP-STREAMING": the Stream-Sense algorithm is disabled and the client will only connect
        /// on Streaming over HTTP. If Streaming over HTTP is not possible because of the environment
        /// the client will not connect at all.</li>
        /// <li>"WS-POLLING": the Stream-Sense algorithm is disabled and the client will only connect on
        /// Polling over WebSocket. If Polling over WebSocket is not possible because of the environment
        /// the client will not connect at all.</li>
        /// <li>"HTTP-POLLING": the Stream-Sense algorithm is disabled and the client will only connect
        /// on Polling over HTTP. If Polling over HTTP is not possible because of the environment the
        /// client will not connect at all.</li>
        /// </ul><br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can be called at any time. If called while the client is connecting
        /// or connected it will instruct to switch connection type to match the given configuration.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "forcedTransport" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> null (full Stream-Sense enabled).
        /// </value>
        public virtual string ForcedTransport
        {
            get
            {
              return _delegate.getForcedTransport();
            }
            set
            {
              _delegate.setForcedTransport(value);
            }
        }

        /// <value>
        /// Property <c>HttpExtraHeaders</c> represents a Map object containing header-name
        /// header-value pairs. Null can be specified to avoid extra headers to be sent.
        /// That enables/disables the setting of extra HTTP headers
        /// to all the request performed to the Lightstreamer server by the client.<br/>
        /// Note that the Content-Type header is reserved by the client library itself, while other
        /// headers might be refused by the environment and others might cause the connection to the
        /// server to fail.<br/>
        /// For instance, you cannot use this method to specify custom cookies to be sent to Lightstreamer
        /// Server; leverage <seealso cref="LightstreamerClient.addCookies" /> instead. The use of custom
        /// headers might also cause the client to send an OPTIONS request to the server before opening
        /// the actual connection.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This setting should be performed before calling the 
        /// <seealso cref="LightstreamerClient.connect()"/> method. However, the value can be changed
        /// at any time: the supplied value will be used for the next HTTP request or WebSocket
        /// establishment.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "httpExtraHeaders" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> null (meaning no extra headers are sent).
        /// </value>
        /// <seealso cref="HttpExtraHeadersOnSessionCreationOnly" />
        public virtual IDictionary<string, string> HttpExtraHeaders
        {
            get
            {
              return _delegate.getHttpExtraHeaders();
            }
            set
            {
              _delegate.setHttpExtraHeaders(value);
            }
        }

        /// <value>
        /// Property <c>IdleTimeout</c> represents the maximum time (in milliseconds) the Server is
        /// allowed to wait for any data to be sent in response to a polling request, if none has
        /// accumulated at request time. The wait time used by the Server, however, may be different,
        /// because of server side restrictions.
        /// Setting this time to a nonzero value and the polling interval to zero leads to an
        /// "asynchronous polling" behavior, which, on low data rates, is very similar to the streaming
        /// case. Setting this time to zero and the polling interval to a nonzero value, on the other
        /// hand, leads to a classical "synchronous polling".<br/>
        /// Note that the Server may, in some cases, delay the answer for more than the supplied time,
        /// to protect itself against a high polling rate or because of bandwidth restrictions. Also,
        /// the Server may impose an upper limit on the wait time, in order to be able to check for
        /// client-side connection drops.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The idle timeout should be set before calling the <seealso cref="LightstreamerClient.connect()"/>
        /// method. However, the value can be changed at any time: the supplied value will be used for
        /// the next polling request.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "idleTimeout" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 19000 (19 seconds).
        /// </value>
        public virtual long IdleTimeout
        {
            get
            {
              return _delegate.getIdleTimeout();
            }
            set
            {
              _delegate.setIdleTimeout(value);
            }
        }

        /// <value>
        /// Property <c>KeepaliveInterval</c> represents the interval (in milliseconds) between two
        /// keepalive packets sent by Lightstreamer Server on a stream connection when no actual data
        /// is being transmitted. If the returned value is 0, it means that the interval is to be
        /// decided by the Server upon the next connection.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The idle timeout should be set before calling the <seealso cref="LightstreamerClient.connect()"/>
        /// method. However, the value can be changed at any time: the supplied value will be used for
        /// the next streaming connection (either a bind or a brand new session). Note that, after a
        /// connection, the value may be changed to the one imposed by the Server.<br/> 
        /// If the value has just been set and a connection to Lightstreamer Server
        /// has not been established yet, the returned value is the time that is being requested to the
        /// Server. Afterwards, the returned value is the time used by the Server, that may be different,
        /// because of Server side constraints.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "keepaliveInterval" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 0 (meaning that the Server will send keepalive packets based on its own configuration).
        /// </value>
        public virtual long KeepaliveInterval
        {
            get
            {
              return _delegate.getKeepaliveInterval();
            }
            set
            {
              _delegate.setKeepaliveInterval(value);
            }
        }

        /// <value>
        /// Property <c>RequestedMaxBandwidth</c> represents the maximum bandwidth requested for the streaming
        /// or polling connection expressed in kbps (kilobits/sec). The string "unlimited" is also
        /// allowed, to mean that the maximum bandwidth can be entirely decided on the Server side
        /// (the check is case insensitive).<br/>
        /// A limit on bandwidth may already be posed by the Metadata Adapter, but the client can furtherly
        /// restrict this limit. The limit applies to the bytes received in each streaming or polling
        /// connection.<br/>
        /// See also: <seealso cref="RealMaxBandwidth"/><br/>
        /// <br/>
        /// <b>Edition Note:</b> Bandwidth Control is an optional feature, available depending on Edition and License
        /// Type. To know what features are enabled by your license, please see the License tab of the Monitoring
        /// Dashboard(by default, available at /dashboard).<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The bandwidth limit can be set and changed at any time. If a connection
        /// is currently active, the bandwidth limit for the connection is changed on the fly.
        /// Remember that the Server may apply a different limit.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "requestedMaxBandwidth" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// Moreover, upon any change or attempt to change the limit, the Server will notify the
        /// client and such notification will be received through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "realMaxBandwidth" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> "unlimited"
        /// </value>
        public virtual string RequestedMaxBandwidth
        {
            get
            {
              return _delegate.getRequestedMaxBandwidth();
            }
            set
            {
              _delegate.setRequestedMaxBandwidth(value);
            }
        }

        /// <value>
        /// Read-only property <c>RealMaxBandwidth</c> represents the maximum bandwidth that can be
        /// consumed for the data coming from Lightstreamer Server. This is the actual maximum bandwidth,
        /// in contrast with the requested maximum bandwidth, returned by <seealso cref="RequestedMaxBandwidth"/>.
        /// The value may differ from the requested one because of restrictions operated on the server
        /// side, or because bandwidth management is not supported(in this case it is always "unlimited"),
        /// but also because of number rounding.<br/>
        /// The return value is a decimal number, which represents the maximum bandwidth applied by
        /// the Server for the streaming or polling connection expressed in kbps (kilobits/sec), or
        /// the string "unlimited", or null.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> If a connection to Lightstreamer Server is not currently active, null is returned;
        /// soon after the connection is established, the value becomes available, as notified
        /// by a call to <seealso cref="ClientListener.onPropertyChange"/> with argument "realMaxBandwidth".
        /// </value>
        public virtual string RealMaxBandwidth
        {
            get
            {
              return _delegate.getRealMaxBandwidth();
            }
        }

        /// <value>
        /// Property <c>PollingInterval</c> represents the polling interval (in milliseconds) used for
        /// polling connections. The client switches from the default streaming mode to polling mode
        /// when the client network infrastructure does not allow streaming. Also, polling mode can be
        /// forced by set <seealso cref="ForcedTransport"/> to "WS-POLLING" or "HTTP-POLLING" as
        /// parameter.<br/>
        /// The polling interval affects the rate at which polling requests are issued. It is the time
        /// between the start of a polling request and the start of the next request. However, if the
        /// polling interval expires before the first polling request has returned, then the second
        /// polling request is delayed. This may happen, for instance, when the Server delays the
        /// answer because of the idle timeout setting. In any case, the polling interval allows for
        /// setting an upper limit on the polling frequency.<br/>
        /// The Server does not impose a lower limit on the client polling interval. However, in some
        /// cases, it may protect itself against a high polling rate by delaying its answer. Network
        /// limitations and configured bandwidth limits may also lower the polling rate, despite of
        /// the client polling interval.<br/>
        /// The Server may, however, impose an upper limit on the polling interval, in order to be able
        /// to promptly detect terminated polling request sequences and discard related session
        /// information.<br/>
        /// Zero is a legal value too, meaning that the client will issue a new polling request as soon
        /// as a previous one has returned.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The polling interval should be set before calling the
        /// <seealso cref="LightstreamerClient.connect"/> method. However, the value can be changed at any
        /// time: the supplied value will be used for the next polling request.
        /// Note that, after each polling request, the value may be changed to the one imposed by
        /// the Server.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "pollingInterval" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 0 (pure "asynchronous polling" is configured).
        /// </value>
        public virtual long PollingInterval
        {
            get
            {
              return _delegate.getPollingInterval();
            }
            set
            {
              _delegate.setPollingInterval(value);
            }
        }

        /// <value>
        /// Property <c>ReconnectTimeout</c> represents the time (in milliseconds) the client, after
        /// entering "STALLED" status, is allowed to keep waiting for a keepalive packet or any data
        /// on a stream connection, before disconnecting and trying to reconnect to the Server.
        /// The new connection may be either the opening of a new session or an attempt to recovery
        /// the current session, depending on the kind of interruption.<br/>
        /// See also: <seealso cref="StalledTimeout"/>, <seealso cref="KeepaliveInterval"/>.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This value can be set and changed at any time.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "reconnectTimeout" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 3000 (3 seconds).
        /// </value>
        public virtual long ReconnectTimeout
        {
            get
            {
              return _delegate.getReconnectTimeout();
            }
            set
            {
              _delegate.setReconnectTimeout(value);
            }
        }

        /// <value>
        /// Property <c>RetryDelay</c> represents the time (in milliseconds) to wait before trying
        /// a new connection, and specifically determines:
        /// <ul>
        /// <li>the minimum time to wait before trying a new connection to the Server in case the previous one failed for any reason; and</li>
        /// <li>the maximum time to wait for a response to a request before dropping the connection and trying with a different approach.</li>
        /// </ul><br/>
        /// Enforcing a delay between reconnections prevents strict loops of connection attempts when
        /// these attempts always fail immediately because of some persisting issue. This applies both
        /// to reconnections aimed at opening a new session and to reconnections aimed at attempting a
        /// recovery of the current session.<br/>
        /// Note that the delay is calculated from the moment the effort to create a connection is made,
        /// not from the moment the failure is detected. As a consequence, when a working connection is
        /// interrupted, this timeout is usually already consumed and the new attempt can be immediate
        /// (except that <seealso cref="FirstRetryMaxDelay"/> will apply in this case). As another
        /// consequence, when a connection attempt gets no answer and times out, the new attempt will
        /// be immediate.<br/>
        /// <br/>
        /// As a timeout on unresponsive connections, it is applied in these cases:
        /// <ul>
        /// <li>Streaming: Applied on any attempt to setup the streaming connection. If after the timeout no
        /// data has arrived on the stream connection, the client may automatically switch transport
        /// or may resort to a polling connection.</li>
        /// <li>Polling and pre-flight requests: Applied on every connection. If after the timeout no
        /// data has arrived on the polling connection, the entire connection process restarts from
        /// scratch.</li>
        /// </ul><br/>
        /// <b>This setting imposes only a minimum delay. In order to avoid network congestion, the
        /// library may use a longer delay if the issue preventing the establishment of a session
        /// persists.</b><br/>
        /// See also: <seealso cref="FirstRetryMaxDelay"/>, <seealso cref="CurrentConnectTimeout"/>.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This value can be set and changed at any time.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "retryDelay" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 4000 (4 seconds).
        /// </value>
        public virtual long RetryDelay
        {
            get
            {
              return _delegate.getRetryDelay();
            }
            set
            {
              _delegate.setRetryDelay(value);
            }
        }

        /// <value>
        /// Property <c>ReverseHeartbeatInterval</c> represents the interval, expressed in milliseconds, between subsequent reverse-heartbeats, or 0.
        /// Enables/disables the reverse-heartbeat mechanism by setting the heartbeat interval. If the
        /// given value (expressed in milliseconds) equals 0 then the reverse-heartbeat mechanism will
        /// be disabled; otherwise if the given value is greater than 0 the mechanism will be enabled
        /// with the specified interval.<br/>
        /// When the mechanism is active, the client will ensure that there is at most the specified
        /// interval between a control request and the following one, by sending empty control requests 
        /// (the "reverse heartbeats") if necessary.<br/>
        /// This can serve various purposes:
        /// <ul>
        /// <li>Preventing the communication infrastructure from closing an inactive socket that is
        /// ready for reuse for more HTTP control requests, to avoid connection reestablishment
        /// overhead. However it is not guaranteed that the connection will be kept open, as the
        /// underlying TCP implementation may open a new socket each time a HTTP request needs to be
        /// sent.<br/>
        /// Note that this will be done only when a session is in place.</li>
        /// <li>Allowing the Server to detect when a streaming connection or Websocket is interrupted but not closed. In these cases, the client eventually closes the connection, but the Server cannot see that (the connection remains "half-open") and just keeps trying to write.This is done by notifying the timeout to the Server upon each streaming request. For long polling, the setIdleTimeout(long) setting has a similar function.</li>
        /// <li>Allowing the Server to detect cases in which the client has closed a connection in HTTP streaming, but the socket is kept open by some intermediate node, which keeps consuming the response.This is also done by notifying the timeout to the Server upon each streaming request, whereas, for long polling, the setIdleTimeout(long) setting has a similar function.</li>
        /// </ul><br/>
        /// <br/>
        /// <b>Lifecycle:</b> This setting should be performed before calling the
        /// <seealso cref="LightstreamerClient.connect"/> method. However, the value can be changed at
        /// any time: the setting will be obeyed immediately, unless a higher heartbeat frequency was
        /// notified to the Server for the current connection. The setting will always be obeyed upon
        /// the next connection (either a bind or a brand new session).<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "reverseHeartbeatInterval" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 0 (meaning that the mechanism is disabled).
        /// </value>
        public virtual long ReverseHeartbeatInterval
        {
            get
            {
              return _delegate.getReverseHeartbeatInterval();
            }
            set
            {
              _delegate.setReverseHeartbeatInterval(value);
            }
        }

        /// <value>
        /// Property <c>StalledTimeout</c> represents the extra time (in milliseconds) the client is
        /// allowed to wait when an expected keepalive packet has not been received on a stream
        /// connection (and no actual data has arrived), before entering the "STALLED" status.<br/>
        /// See also: <seealso cref="ReconnectTimeout"/>, <seealso cref="KeepaliveInterval"/>.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This value can be set and changed at any time.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "stalledTimeout" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 2000 (2 seconds).
        /// </value>
        public virtual long StalledTimeout
        {
            get
            {
              return _delegate.getStalledTimeout();
            }
            set
            {
              _delegate.setStalledTimeout(value);
            }
        }

        /// <value>
        /// Property <c>SessionRecoveryTimeout</c> represents the maximum time allowed for attempts to
        /// recover the current session upon an interruption, after which a new session will be created.
        /// If the given value (expressed in milliseconds) equals 0, then any attempt to recover the
        /// current session will be prevented in the first place.<br/>
        /// In fact, in an attempt to recover the current session, the client will periodically try to
        /// access the Server at the address related with the current session. In some cases, this
        /// timeout, by enforcing a fresh connection attempt, may prevent an infinite sequence of
        /// unsuccessful attempts to access the Server.<br/>
        /// Note that, when the Server is reached, the recovery may fail due to a Server side timeout
        /// on the retention of the session and the updates sent. In that case, a new session will be
        /// created anyway. A setting smaller than the Server timeouts may prevent such useless failures,
        /// but, if too small, it may also prevent successful recovery in some cases.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This value can be set and changed at any time.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "sessionRecoveryTimeout" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> 15000 (15 seconds).
        /// </value>
        public virtual long SessionRecoveryTimeout
        {
            get
            {
              return _delegate.getSessionRecoveryTimeout();
            }
            set
            {
              _delegate.setSessionRecoveryTimeout(value);
            }
        }

        /// <value>
        /// Property <c>HttpExtraHeadersOnSessionCreationOnly</c> enables/disables a restriction on
        /// the forwarding of the extra http headers specified through <seealso cref="HttpExtraHeaders"/>.
        /// If true, said headers will only be sent during the session creation process (and thus will
        /// still be available to the metadata adapter notifyUser method) but will not be sent on
        /// following requests. On the contrary, when set to true, the specified extra headers will
        /// be sent to the server on every request.<br/>
        /// Values can be true/false to enable/disable the restriction on extra headers forwarding.<br/>
        /// See also: <seealso cref="HttpExtraHeaders"/>.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This setting should be performed before calling the 
        /// <seealso cref="LightstreamerClient.connect"/> method. However, the value can be changed at
        /// any time: the supplied value will be used for the next HTTP request or WebSocket establishment.<br/>
        /// <br/>
        /// <b>Related notifications:</b>A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "httpExtraHeadersOnSessionCreationOnly"
        /// on any ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> false
        /// </value>
        public virtual bool HttpExtraHeadersOnSessionCreationOnly
        {
            get
            {
              return _delegate.isHttpExtraHeadersOnSessionCreationOnly();
            }
            set
            {
              _delegate.setHttpExtraHeadersOnSessionCreationOnly(value);
            }
        }

        /// <value>
        /// Property <c>ServerInstanceAddressIgnored</c> disable/enable the automatic handling of
        /// server instance address that may be returned by the Lightstreamer server during session
        /// creation.<br/>
        /// In fact, when a Server cluster is in place, the Server address specified through
        /// <seealso cref="ConnectionDetails.ServerAddress"/> can identify various Server instances;
        /// in order to ensure that all requests related to a session are issued to the same Server
        /// instance, the Server can answer to the session opening request by providing an address
        /// which uniquely identifies its own instance.<br/>
        /// Setting this value to true permits to ignore that address and to always connect through
        /// the address supplied in setServerAddress. This may be needed in a test environment, if the
        /// Server address specified is actually a local address to a specific Server instance in the
        /// cluster.<br/>
        /// Values can be true or false, to ignore or not the server instance address sent by the server.<br/>
        /// See also: <seealso cref="ConnectionDetails.ServerAddress"/>.<br/>
        /// <br/>
        /// <b>Edition Note:</b> Server Clustering is an optional feature, available depending on Edition and License
        /// Type. To know what features are enabled by your license, please see the License tab of the Monitoring
        /// Dashboard(by default, available at /dashboard).<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can be called at any time. If called while connected, it will be applied
        /// when the next session creation request is issued.<br/>
        /// <br/>
        /// <b>Related notifications:</b>A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "serverInstanceAddressIgnored" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> false
        /// </value>
        public virtual bool ServerInstanceAddressIgnored
        {
            get
            {
              return _delegate.isServerInstanceAddressIgnored();
            }
            set
            {
               _delegate.setServerInstanceAddressIgnored(value);
            }
        }

        /// <value>
        /// Property <c>SlowingEnabled</c> turns on or off the slowing algorithm. This heuristic
        /// algorithm tries to detect when the client CPU is not able to keep the pace of the events
        /// sent by the Server on a streaming connection. In that case, an automatic transition to
        /// polling is performed.<br/>
        /// In polling, the client handles all the data before issuing the next poll, hence a slow
        /// client would just delay the polls, while the Server accumulates and merges the events and
        /// ensures that no obsolete data is sent.<br/>
        /// Only in very slow clients, the next polling request may be so much delayed that the Server
        /// disposes the session first, because of its protection timeouts. In this case, a request for
        /// a fresh session will be reissued by the client and this may happen in cycle.<br/>
        /// Values can be true or false, to enable or disable the heuristic algorithm that lowers the
        /// item update frequency.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This setting should be performed before calling the 
        /// <seealso cref="LightstreamerClient.connect"/> method. However, the value can be changed at
        /// any time: the supplied value will be used for the next streaming connection (either a
        /// bind or a brand new session).<br/>
        /// <br/>
        /// <b>Related notifications:</b>A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "slowingEnabled"
        /// on any ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b> false
        /// </value>
        public virtual bool SlowingEnabled
        {
            get
            {
              return _delegate.isSlowingEnabled();
            }
            set
            {
              _delegate.setSlowingEnabled(value);
            }
        }

        /// <value>
        /// Setter method that configures the coordinates to a proxy server to be used to connect
        /// to the Lightstreamer Server.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This value can be set and changed at any time. The supplied value will
        /// be used for the next connection attempt.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "proxy" on any
        /// ClientListener listening to the related LightstreamerClient.<br/>
        /// <br/>
        /// <b>Default value:</b>  null (meaning not to pass through a proxy).
        ///  </value>
        public virtual Proxy Proxy
        {
            set
            {
              _delegate.setProxy(value._delegate);
            }
        }
    }
}