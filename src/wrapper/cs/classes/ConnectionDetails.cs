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
    /// Used by LightstreamerClient to provide a basic connection properties data object.
    /// Data object that contains the configuration settings needed
    /// to connect to a Lightstreamer Server. <br/>
    /// An instance of this class is attached to every <seealso cref="LightstreamerClient"/>
    /// as <seealso cref="LightstreamerClient.connectionDetails"/><br/>
    /// </summary>
    /// <seealso cref="LightstreamerClient" />
    public class ConnectionDetails
    {
        readonly LSConnectionDetails _delegate;

        internal ConnectionDetails(LSConnectionDetails details)
        {
            this._delegate = details;
        }

        /// <value>
        /// Property <c>AdapterSet</c> represents the name of the Adapter Set (which defines the Metadata Adapter and one or several 
        /// Data Adapters) mounted on Lightstreamer Server that supply all the items used in this application.
        /// The name of the Adapter Set can be null if no name has been configured; that 
        /// means that the "DEFAULT" Adapter Set name is used.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The Adapter Set name should be set on the <seealso cref="LightstreamerClient.connectionDetails" /> object before calling the 
        /// <seealso cref="LightstreamerClient.connect()"/> method. However, the value can be changed at any time: the supplied value will be used for the
        /// next time a new session is requested to the server. This setting can also be specified in the <seealso cref="LightstreamerClient"/> constructor.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "adapterSet" on any ClientListener listening to the related LightstreamerClient.
        /// </value>
        public virtual string AdapterSet
        {
            get
            {
                return _delegate.getAdapterSet();
            }
            set
            {
                _delegate.setAdapterSet(value);
            }
        }


        /// <value>
        /// Property <c>ServerAddress</c> represents the configured address of Lightstreamer Server.
        /// Note that the addresses specified must always have the http: or https: scheme. In case WebSockets
        /// are used, the specified scheme is internally converted to match the related WebSocket protocol
        /// (i.e. http becomes ws while https becomes wss).
        /// 
        /// A null value can also be used, to restore the default value. An IPv4 or IPv6 can also be used 
        /// in place of a hostname. Some examples of valid values include: 
        /// <ul><li>http://push.mycompany.com</li>
        /// <li>http://push.mycompany.com:8080</li>
        /// <li>http://79.125.7.252</li>
        /// <li>http://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]</li>
        /// <li>http://[2001:0db8:85a3::8a2e:0370:7334]:8080</li>
        /// </ul>
        /// <br/>
        /// <b>Edition Note:</b> WSS/HTTPS is an optional feature, available depending on Edition and License
        /// Type. To know what features are enabled by your license, please see the License tab of the Monitoring
        /// Dashboard (by default, available at /dashboard).<br/>
        /// <br/>
        /// <b>Lifecycle:</b> This method can be called at any time. If called while connected, it will be
        /// applied when the next session creation request is issued. This setting can also be specified in the <seealso cref="LightstreamerClient"/> constructor.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "serverAddress" on any ClientListener listening to the related LightstreamerClient.
        /// </value>
        public virtual string ServerAddress
        {
            get
            {
                return _delegate.getServerAddress();
            }
            set
            {
                _delegate.setServerAddress(value);
            }
        }


        /// <value>
        /// Property <c>User</c> represents the username to be used for the authentication on Lightstreamer Server when 
        /// initiating the session. The Metadata Adapter is responsible for checking the credentials (username and password).
        /// The User can be null if no user name has been configured. If no username is supplied, no user information will
        /// be sent at session initiation. The Metadata Adapter, however, may still allow the session.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The username should be set on the <seealso cref="LightstreamerClient.connectionDetails" /> object before
        /// calling the <seealso cref="LightstreamerClient.connect()"/> method. However, the value can be changed at 
        /// any time: the supplied value will be used for the next time a new session is requested to the server.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to 
        /// <seealso cref="ClientListener.onPropertyChange" /> with argument "user" on any ClientListener listening to the related LightstreamerClient.
        /// </value>
        public virtual string User
        {
            get
            {
                return _delegate.getUser();
            }
            set
            {
                _delegate.setUser(value);
            }
        }


        /// <value>
        /// Read-only property <c>ServerInstanceAddress</c> represents the server address to be used to issue all requests related to the current session.
        /// In fact, when a Server cluster is in place, the Server address specified through <seealso cref="ServerAddress"/> can 
        /// identify various Server instances; in order to ensure that all requests related to a session are issued to 
        /// the same Server instance, the Server can answer to the session opening request by providing an address which 
        /// uniquely identifies its own instance. When this is the case, this address is returned by the method; otherwise,
        /// null is returned. <br/> 
        /// Note that the addresses will always have the http: or https: scheme. In case WebSockets are used, the specified 
        /// scheme is internally converted to match the related WebSocket protocol (i.e. http becomes ws while 
        /// https becomes wss).<br/>
        /// <br/>
        /// <b>Edition Note:</b> Server Clustering is an optional feature, available depending on Edition and License Type.
        /// To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
        /// available at /dashboard).<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The method gives a meaningful answer only when a session is currently active.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to 
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "serverInstanceAddress" on any 
        /// ClientListener listening to the related LightstreamerClient.
        /// </value>
        public virtual string ServerInstanceAddress
        {
            get
            {
                return _delegate.getServerInstanceAddress();
            }
        }

        /// <value>
        /// Read-only property <c>ServerSocketName</c> represents the instance name of the Server which is serving the current session. To be more precise, 
        /// each answering port configured on a Server instance (through a &lt;http_server&gt; or &lt;https_server&gt; element in the 
        /// Server configuration file) can be given a different name; the name related to the port to which the session 
        /// opening request has been issued is returned. <br/> 
        /// Note that each rebind to the same session can, potentially, reach the Server on a port different than the one
        /// used for the previous request, depending on the behavior of intermediate nodes. However, the only meaningful case
        /// is when a Server cluster is in place and it is configured in such a way that the port used for all bind_session requests
        /// differs from the port used for the initial create_session request.<br/>
        /// <br/>
        /// <b>Edition Note:</b> Server Clustering is an optional feature, available depending on Edition and License Type.
        /// To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).<br/>
        /// <br/>
        /// <b>Lifecycle:</b> If a session is not currently active, null is returned;
        /// soon after a session is established, the value will become available.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to 
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "serverSocketName" on any 
        /// ClientListener listening to the related LightstreamerClient.
        /// </value>
        public virtual string ServerSocketName
        {
            get
            {
                return _delegate.getServerSocketName();
            }
        }

        /// <value>
        /// Read-only property <c>ClientIp</c> represents the IP address of this client as seen by the Server which is serving
        /// the current session as the client remote address (note that it may not correspond to the client host;
        /// for instance it may refer to an intermediate proxy). If, upon a new session, this address changes,
        /// it may be a hint that the intermediary network nodes handling the connection have changed, hence the network
        /// capabilities may be different. The library uses this information to optimize the connection. <br/>  
        /// Note that in case of polling or in case rebind requests are needed, subsequent requests related to the same 
        /// session may, in principle, expose a different IP address to the Server; these changes would not be reported.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> If a session is not currently active, null is returned;
        /// soon after a session is established, the value may become available; but it is possible
        /// that this information is not provided by the Server and that it will never be available.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to 
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "clientIp" on any 
        /// ClientListener listening to the related LightstreamerClient.
        /// </value>
        public virtual string ClientIp
        {
            get
            {
                return _delegate.getClientIp();
            }
        }

        /// <value>
        /// Read-only property <c>SessionId</c> represents the ID associated by the server to this client session.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The method gives a meaningful answer only when a session is currently active.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to 
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "sessionId" on any 
        /// ClientListener listening to the related LightstreamerClient.
        /// </value>
        public virtual string SessionId
        {
            get
            {
                return _delegate.getSessionId();
            }
        }

        /// <value>
        /// Write-only property <c>Password</c> represents the password to be used for the authentication on Lightstreamer Server when initiating 
        /// the session. The Metadata Adapter is responsible for checking the credentials (username and password).
        /// If no password is supplied, no password information will be sent at session initiation. 
        /// The Metadata Adapter, however, may still allow the session.<br/>
        /// <br/>
        /// <b>Lifecycle:</b> The password should be set on the <seealso cref="LightstreamerClient.connectionDetails"/> object before calling 
        /// the <seealso cref="LightstreamerClient.connect"/> method. However, the value can be changed at any time: the supplied 
        /// value will be used for the next time a new session is requested to the server. <br/>
        /// NOTE: The password string will be stored in the current instance. That is necessary in order to allow 
        /// automatic reconnection/reauthentication for fail-over. For maximum security, avoid using an actual private 
        /// password to authenticate on Lightstreamer Server; rather use a session-id originated by your web/application 
        /// server, that can be checked by your Metadata Adapter.<br/>
        /// <br/>
        /// <b>Related notifications:</b> A change to this setting will be notified through a call to 
        /// <seealso cref="ClientListener.onPropertyChange"/> with argument "password" on any 
        /// ClientListener listening to the related LightstreamerClient.
        /// </value>
        /// <seealso cref="User" />
        public virtual string Password
        {
            set
            {
                _delegate.setPassword(value);
            }
        }
    }
}