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
from .ls_python_client_api import *
from .ls_python_client_haxe import LSConsoleLoggerProvider, LSConsoleLogLevel, LSProxy, LSSubscription, LSConnectionDetails, LSConnectionOptions, LSLightstreamerClient

class ConnectionDetails:
    """Used by LightstreamerClient to provide a basic connection properties data object.
 
 Data object that contains the configuration settings needed
 to connect to a Lightstreamer Server. 

 An instance of this class is attached to every :class:`LightstreamerClient`
 as :attr:`LightstreamerClient.connectionDetails`

 
 .. seealso:: :class:`LightstreamerClient`
    """

    def __init__(self,lsDetails):
      self.delegate = lsDetails

    def getServerAddress(self):
      """Inquiry method that gets the configured address of Lightstreamer Server.
   
   :return: the serverAddress the configured address of Lightstreamer Server.
   """
      return self.delegate.getServerAddress()

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
   :meth:`.ClientListener.onPropertyChange` with argument "serverAddress" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param serverAddress: The full address of Lightstreamer Server. A None value can also be used, to restore the default value. 
   
   An IPv4 or IPv6 can also be used in place of a hostname. Some examples of valid values include: ::
    
    http://push.mycompany.com
    http://push.mycompany.com:8080
    http://79.125.7.252
    http://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]
    http://[2001:0db8:85a3::8a2e:0370:7334]:8080
   
   :raises IllegalArgumentException: if the given address is not valid.
      """
      self.delegate.setServerAddress(serverAddress)

    def getAdapterSet(self):
      """Inquiry method that gets the name of the Adapter Set (which defines the Metadata Adapter and one or several 
   Data Adapters) mounted on Lightstreamer Server that supply all the items used in this application.
   
   :return: the adapterSet the name of the Adapter Set; returns None if no name has been configured, that means that the "DEFAULT" Adapter Set is used.
   
   .. seealso:: :meth:`setAdapterSet`
      """
      return self.delegate.getAdapterSet()

    def setAdapterSet(self,adapterSet):
      """Setter method that sets the name of the Adapter Set mounted on Lightstreamer Server to be used to handle 
   all requests in the session. 
 
   An Adapter Set defines the Metadata Adapter and one or several Data Adapters. It is configured on the 
   server side through an "adapters.xml" file; the name is configured through the "id" attribute in 
   the <adapters_conf> element.
   
   **default** The default Adapter Set, configured as "DEFAULT" on the Server.
   
   **lifecycle** The Adapter Set name should be set on the :attr:`LightstreamerClient.connectionDetails` object 
   before calling the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: 
   the supplied value will be used for the next time a new session is requested to the server. 

   This setting can also be specified in the :class:`LightstreamerClient` constructor.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "adapterSet" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param adapterSet: The name of the Adapter Set to be used. A None value is equivalent to the "DEFAULT" name.
      """
      self.delegate.setAdapterSet(adapterSet)

    def getUser(self):
      """ Inquiry method that gets the username to be used for the authentication on Lightstreamer Server when 
   initiating the session.
   
   :return: the username to be used for the authentication on Lightstreamer Server; returns None if no user name has been configured.
   """
      return self.delegate.getUser()

    def setUser(self,user):
      """Setter method that sets the username to be used for the authentication on Lightstreamer Server when initiating
   the session. The Metadata Adapter is responsible for checking the credentials (username and password).
   
   **default** If no username is supplied, no user information will be sent at session initiation. 
   The Metadata Adapter, however, may still allow the session.
   
   **lifecycle** The username should be set on the :attr:`LightstreamerClient.connectionDetails` object before 
   calling the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the 
   supplied value will be used for the next time a new session is requested to the server.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "user" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param user: The username to be used for the authentication on Lightstreamer Server. The username can be None.
   
   .. seealso:: :meth:`setPassword`
   """
      self.delegate.setUser(user)

    def setPassword(self,password):
      """Setter method that sets the password to be used for the authentication on Lightstreamer Server when initiating 
   the session. The Metadata Adapter is responsible for checking the credentials (username and password).
   
   **default**  If no password is supplied, no password information will be sent at session initiation. 
   The Metadata Adapter, however, may still allow the session.
   
   **lifecycle** The username should be set on the :attr:`LightstreamerClient.connectionDetails` object before calling 
   the :meth:`LightstreamerClient.connect` method. However, the value can be changed at any time: the supplied 
   value will be used for the next time a new session is requested to the server. 

   NOTE: The password string will be stored in the current instance. That is necessary in order to allow 
   automatic reconnection/reauthentication for fail-over. For maximum security, avoid using an actual private 
   password to authenticate on Lightstreamer Server; rather use a session-id originated by your web/application 
   server, that can be checked by your Metadata Adapter.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "password" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param password: The password to be used for the authentication on Lightstreamer Server. 
          The password can be None.
          
   .. seealso:: :meth:`setUser`
      """
      self.delegate.setPassword(password)

    def getSessionId(self):
      """Inquiry method that gets the ID associated by the server to this client session.
   
   **lifecycle** If a session is not currently active, null is returned; soon after a session is established, the value will become available.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "sessionId" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return: ID assigned by the Server to this client session, or None."""
      return self.delegate.getSessionId()

    def getServerInstanceAddress(self):
      """Inquiry method that gets the server address to be used to issue all requests related to the current session. 
   In fact, when a Server cluster is in place, the Server address specified through :meth:`setServerAddress` can 
   identify various Server instances; in order to ensure that all requests related to a session are issued to 
   the same Server instance, the Server can answer to the session opening request by providing an address which 
   uniquely identifies its own instance. When this is the case, this address is returned by the method; otherwise,
   None is returned. 
 
   Note that the addresses will always have the http: or https: scheme. In case WebSockets are used, the specified 
   scheme is internally converted to match the related WebSocket protocol (i.e. http becomes ws while 
   https becomes wss).
   
   **general edition note** Server Clustering is an optional feature, available depending on Edition and License Type.
   To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
   available at /dashboard).
   
   **lifecycle** If a session is not currently active, null is returned; soon after a session is established, the value may become available.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "serverInstanceAddress" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return: address used to issue all requests related to the current session, or None.
   """
      return self.delegate.getServerInstanceAddress()

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
   
   **lifecycle** If a session is not currently active, None is returned;
   soon after a session is established, the value will become available.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "serverSocketName" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return: name configured for the Server instance which is managing the current session, or None.
   """
      return self.delegate.getServerSocketName()

    def getClientIp(self):
      """Inquiry method that gets the IP address of this client as seen by the Server which is serving
   the current session as the client remote address (note that it may not correspond to the client host;
   for instance it may refer to an intermediate proxy). If, upon a new session, this address changes,
   it may be a hint that the intermediary network nodes handling the connection have changed, hence the network
   capabilities may be different. The library uses this information to optimize the connection. 
  
   Note that in case of polling or in case rebind requests are needed, subsequent requests related to the same 
   session may, in principle, expose a different IP address to the Server; these changes would not be reported.
   
   **lifecycle** If a session is not currently active, None is returned;
   soon after a session is established, the value may become available.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "clientIp" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return:  A canonical representation of an IP address (it can be either IPv4 or IPv6), or None.
   """
      return self.delegate.getClientIp()

class ConnectionOptions:
  """Used by LightstreamerClient to provide an extra connection properties data object.

 Data object that contains the policy settings used to connect to a Lightstreamer Server. 

 An instance of this class is attached to every :class:`LightstreamerClient`
 as :attr:`LightstreamerClient.connectionOptions`

 .. seealso:: :class:`LightstreamerClient`
 """

  def __init__(self,lsOptions):
    self.delegate = lsOptions

  def getContentLength(self):
    """Inquiry method that gets the length expressed in bytes to be used by the Server for the response body on a HTTP stream connection.

   :return: The length to be used by the Server for the response body on a HTTP stream connection
   
   .. seealso:: :meth:`setContentLength`
   """
    return self.delegate.getContentLength()

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
   :meth:`.ClientListener.onPropertyChange` with argument "contentLength" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param contentLength: The length to be used by the Server for the response body on a HTTP stream connection.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   """
    self.delegate.setContentLength(contentLength)

  def getFirstRetryMaxDelay(self):
    """Inquiry method that gets the maximum time to wait before trying a new connection to the Server in case the previous one is unexpectedly closed while correctly working.

   :return: The max time (in milliseconds) to wait before trying a new connection.

   .. seealso:: :meth:`setFirstRetryMaxDelay`
   """
    return self.delegate.getFirstRetryMaxDelay()

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
   :meth:`.ClientListener.onPropertyChange` with argument "firstRetryMaxDelay" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param firstRetryMaxDelay: The max time (in milliseconds) to wait before trying a new connection.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   """
    self.delegate.setFirstRetryMaxDelay(firstRetryMaxDelay)

  def getForcedTransport(self):
    """Inquiry method that gets the value of the forced transport (if any).

   :return: The forced transport or None

   .. seealso:: :meth:`setForcedTransport`
   """
    return self.delegate.getForcedTransport()

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
   
   **default** None (full Stream-Sense enabled).
   
   **lifecycle** This method can be called at any time. If called while the client is connecting or connected it will instruct 
   to switch connection type to match the given configuration.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "forcedTransport" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param forcedTransport: can be one of the following: 
   
    * None: the Stream-Sense algorithm is enabled and the client will automatically connect using the most appropriate transport and connection type among those made possible by the environment.
    * "WS": the Stream-Sense algorithm is enabled as in the None case but the client will only use WebSocket based connections. If a connection over WebSocket is not possible because of the environment the client will not connect at all.
    * "HTTP": the Stream-Sense algorithm is enabled as in the None case but the client will only use HTTP based connections. If a connection over HTTP is not possible because of the environment the client will not connect at all.
    * "WS-STREAMING": the Stream-Sense algorithm is disabled and the client will only connect on Streaming over WebSocket. If Streaming over WebSocket is not possible because of the environment the client will not connect at all.
    * "HTTP-STREAMING": the Stream-Sense algorithm is disabled and the client will only connect on Streaming over HTTP. If Streaming over HTTP is not possible because of the browser/environment the client will not connect at all.
    * "WS-POLLING": the Stream-Sense algorithm is disabled and the client will only connect on Polling over WebSocket. If Polling over WebSocket is not possible because of the environment the client will not connect at all.
    * "HTTP-POLLING": the Stream-Sense algorithm is disabled and the client will only connect on Polling over HTTP. If Polling over HTTP is not possible because of the environment the client will not connect at all.
   
   :raises IllegalArgumentException: if the given value is not in the list of the admitted ones.
   """
    self.delegate.setForcedTransport(forcedTransport)

  def getHttpExtraHeaders(self):
    """ Inquiry method that gets the Map object containing the extra headers to be sent to the server.

   :return: The Map object containing the extra headers to be sent

   .. seealso:: :meth:`setHttpExtraHeaders`
   .. seealso:: :meth:`setHttpExtraHeadersOnSessionCreationOnly`
   """
    return self.delegate.getHttpExtraHeaders()

  def setHttpExtraHeaders(self,httpExtraHeaders):
    """Setter method that enables/disables the setting of extra HTTP headers to all the request performed to the Lightstreamer server by the client. 

Note that the Content-Type header is reserved by the client library itself, while other headers might be refused by the environment and others might cause the connection to the server to fail.
   
For instance, you cannot use this method to specify custom cookies to be sent to Lightstreamer Server; leverage :meth:`LightstreamerClient.addCookies` instead.
The use of custom headers might also cause the
client to send an OPTIONS request to the server before opening the actual connection. 
   
**default** None (meaning no extra headers are sent).
   
**lifecycle** This setting should be performed before calling the
:meth:`LightstreamerClient.connect` method. However, the value can be changed
at any time: the supplied value will be used for the next HTTP request or WebSocket establishment.
   
**notification** A change to this setting will be notified through a call to 
:meth:`.ClientListener.onPropertyChange` with argument "httpExtraHeaders" on any 
ClientListener listening to the related LightstreamerClient.
   
:param httpExtraHeaders: a Map object containing header-name header-value pairs. None can be specified to avoid extra headers to be sent.
   """
    self.delegate.setHttpExtraHeaders(httpExtraHeaders)

  def getIdleTimeout(self):
    """Inquiry method that gets the maximum time the Server is allowed to wait for any data to be sent 
   in response to a polling request, if none has accumulated at request time. The wait time used 
   by the Server, however, may be different, because of server side restrictions.

   :return: The time (in milliseconds) the Server is allowed to wait for data to send upon polling requests.

   .. seealso:: :meth:`setIdleTimeout`
   """
    return self.delegate.getIdleTimeout()

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
   :meth:`.ClientListener.onPropertyChange` with argument "idleTimeout" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param idleTimeout: The time (in milliseconds) the Server is allowed to wait for data to send upon polling requests.
   
   :raises IllegalArgumentException: if a negative value is configured 
   """
    self.delegate.setIdleTimeout(idleTimeout)

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
    return self.delegate.getKeepaliveInterval()

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
   :meth:`.ClientListener.onPropertyChange` with argument "keepaliveInterval" on any 
   ClientListener listening to the related LightstreamerClient.

   :param keepaliveInterval: the keepalive interval time (in milliseconds) to set, or 0.
   
   :raises IllegalArgumentException: if a negative value is configured 
   
   .. seealso:: :meth:`setStalledTimeout`
   .. seealso:: :meth:`setReconnectTimeout`
   """
    self.delegate.setKeepaliveInterval(keepaliveInterval)

  def getRequestedMaxBandwidth(self):
    """Inquiry method that gets the maximum bandwidth that can be consumed for the data coming from 
   Lightstreamer Server, as requested for this session.
   The maximum bandwidth limit really applied by the Server on the session is provided by
   :meth:`getRealMaxBandwidth`
   
   :return:  A decimal number, which represents the maximum bandwidth requested for the streaming or polling connection expressed in kbps (kilobits/sec), or the string "unlimited".

   .. seealso:: :meth:`setRequestedMaxBandwidth`
   """
    return self.delegate.getRequestedMaxBandwidth()

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
   :meth:`.ClientListener.onPropertyChange` with argument "requestedMaxBandwidth" on any 
   ClientListener listening to the related LightstreamerClient. Moreover, upon any change or attempt to change the limit, the Server will notify the client and such notification will be received through a call to :meth:`.ClientListener.onPropertyChange` with argument "realMaxBandwidth" on any ClientListener listening to the related LightstreamerClient.
   
   :param maxBandwidth:  A decimal number, which represents the maximum bandwidth requested for the streaming or polling connection expressed in kbps (kilobits/sec). The string "unlimited" is also allowed, to mean that the maximum bandwidth can be entirely decided on the Server side (the check is case insensitive).
   
   :raises IllegalArgumentException: if a negative, zero, or a not-number value (excluding special values) is passed.
   
   .. seealso:: :meth:`getRealMaxBandwidth`
   """
    self.delegate.setRequestedMaxBandwidth(maxBandwidth)

  def getRealMaxBandwidth(self):
    """Inquiry method that gets the maximum bandwidth that can be consumed for the data coming from 
   Lightstreamer Server. This is the actual maximum bandwidth, in contrast with the requested
   maximum bandwidth, returned by :meth:`getRequestedMaxBandwidth`. 

   The value may differ from the requested one because of restrictions operated on the server side,
   or because bandwidth management is not supported (in this case it is always "unlimited"),
   but also because of number rounding.
   
   **lifecycle** If a connection to Lightstreamer Server is not currently active, null is returned; soon after the connection is established, the value will become available.

   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "realMaxBandwidth" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :return:  A decimal number, which represents the maximum bandwidth applied by the Server for the streaming or polling connection expressed in kbps (kilobits/sec), or the string "unlimited", or None.
   
   .. seealso:: :meth:`setRequestedMaxBandwidth`
   """
    return self.delegate.getRealMaxBandwidth()

  def getPollingInterval(self):
    """Inquiry method that gets the polling interval used for polling connections. 
 
   If the value has just been set and a polling request to Lightstreamer Server has not been performed 
   yet, the returned value is the polling interval that is being requested to the Server. Afterwards, 
   the returned value is the the time between subsequent polling requests that is really allowed by the 
   Server, that may be different, because of Server side constraints.

   :return: The time (in milliseconds) between subsequent polling requests.

   .. seealso:: :meth:`setPollingInterval`
   """
    return self.delegate.getPollingInterval()

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
   :meth:`.ClientListener.onPropertyChange` with argument "pollingInterval" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param pollingInterval: The time (in milliseconds) between subsequent polling requests. Zero is a legal value too, meaning that the client will issue a new polling request as soon as a previous one has returned.
   
   :raises IllegalArgumentException: if a negative value is configured 
   """
    self.delegate.setPollingInterval(pollingInterval)

  def getReconnectTimeout(self):
    """Inquiry method that gets the time the client, after entering "STALLED" status,
   is allowed to keep waiting for a keepalive packet or any data on a stream connection,
   before disconnecting and trying to reconnect to the Server.

   :return: The idle time (in milliseconds) admitted in "STALLED" status before trying to reconnect to the Server.

   .. seealso:: :meth:`setReconnectTimeout`
   """
    return self.delegate.getReconnectTimeout()

  def setReconnectTimeout(self,reconnectTimeout):
    """Setter method that sets the time the client, after entering "STALLED" status,
   is allowed to keep waiting for a keepalive packet or any data on a stream connection,
   before disconnecting and trying to reconnect to the Server.
   The new connection may be either the opening of a new session or an attempt to recovery
   the current session, depending on the kind of interruption.
   
   **default** 3000 (3 seconds).
   
   **lifecycle** This value can be set and changed at any time.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "reconnectTimeout" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param reconnectTimeout: The idle time (in milliseconds) allowed in "STALLED" status before trying to reconnect to the Server.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   
   .. seealso:: :meth:`setStalledTimeout`
   .. seealso:: :meth:`setKeepaliveInterval`
   """
    self.delegate.setReconnectTimeout(reconnectTimeout)

  def getRetryDelay(self):
    """Inquiry method that gets the minimum time to wait before trying a new connection
   to the Server in case the previous one failed for any reason, which is also the maximum time to wait for a response to a request 
   before dropping the connection and trying with a different approach.
   Note that the delay is calculated from the moment the effort to create a connection
   is made, not from the moment the failure is detected or the connection timeout expires.

   :return: The time (in milliseconds) to wait before trying a new connection.

   .. seealso:: :meth:`setRetryDelay`
   """
    return self.delegate.getRetryDelay()

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
   :meth:`.ClientListener.onPropertyChange` with argument "retryDelay" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param retryDelay: The time (in milliseconds) to wait before trying a new connection.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   
   .. seealso:: :meth:`setFirstRetryMaxDelay`
   """
    self.delegate.setRetryDelay(retryDelay)

  def getReverseHeartbeatInterval(self):
    """Inquiry method that gets the reverse-heartbeat interval expressed in milliseconds.
   A 0 value is possible, meaning that the mechanism is disabled.

   :return: The reverse-heartbeat interval, or 0.

   .. seealso:: :meth:`setReverseHeartbeatInterval`
   """
    return self.delegate.getReverseHeartbeatInterval()

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
:meth:`.ClientListener.onPropertyChange` with argument "reverseHeartbeatInterval" on any 
ClientListener listening to the related LightstreamerClient.
   
:param reverseHeartbeatInterval: the interval, expressed in milliseconds, between subsequent reverse-heartbeats, or 0.
   
:raises IllegalArgumentException: if a negative value is configured
   """
    self.delegate.setReverseHeartbeatInterval(reverseHeartbeatInterval)

  def getSessionRecoveryTimeout(self):
    """Inquiry method that gets the maximum time allowed for attempts to recover
   the current session upon an interruption, after which a new session will be created.
   A 0 value also means that any attempt to recover the current session is prevented
   in the first place.
   
   :return: The maximum time allowed for recovery attempts, possibly 0.

   .. seealso:: :meth:`setSessionRecoveryTimeout`
   """
    return self.delegate.getSessionRecoveryTimeout()

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
call to :meth:`.ClientListener.onPropertyChange` with argument "sessionRecoveryTimeout" on any 
ClientListener listening to the related LightstreamerClient.
   
:param sessionRecoveryTimeout: The maximum time allowed for recovery attempts, expressed in milliseconds, including 0.

:raises IllegalArgumentException: if a negative value is passed.
   """
    self.delegate.setSessionRecoveryTimeout(sessionRecoveryTimeout)

  def getStalledTimeout(self):
    """Inquiry method that gets the extra time the client can wait when an expected keepalive packet 
   has not been received on a stream connection (and no actual data has arrived), before entering 
   the "STALLED" status.

   :return: The idle time (in milliseconds) admitted before entering the "STALLED" status.

   .. seealso:: :meth:`setStalledTimeout`
   """
    return self.delegate.getStalledTimeout()

  def setStalledTimeout(self,stalledTimeout):
    """Setter method that sets the extra time the client is allowed to wait when an expected keepalive packet has not been 
   received on a stream connection (and no actual data has arrived), before entering the "STALLED" status.
   
   **default** 2000 (2 seconds).
   
   **lifecycle**  This value can be set and changed at any time.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "stalledTimeout" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param stalledTimeout: The idle time (in milliseconds) allowed before entering the "STALLED" status.
   
   :raises IllegalArgumentException: if a negative or zero value is configured 
   
   .. seealso:: :meth:`setReconnectTimeout`
   .. seealso:: :meth:`setKeepaliveInterval`
   """
    self.delegate.setStalledTimeout(stalledTimeout)

  def isHttpExtraHeadersOnSessionCreationOnly(self):
    """ Inquiry method that checks if the restriction on the forwarding of the configured extra http headers 
   applies or not. 

   :return: true/false if the restriction applies or not.

   .. seealso:: :meth:`setHttpExtraHeadersOnSessionCreationOnly`
   .. seealso:: :meth:`setHttpExtraHeaders`
   """
    return self.delegate.isHttpExtraHeadersOnSessionCreationOnly()

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
   :meth:`.ClientListener.onPropertyChange` with argument "httpExtraHeadersOnSessionCreationOnly" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param httpExtraHeadersOnSessionCreationOnly: true/false to enable/disable the restriction on extra headers forwarding.
   """
    self.delegate.setHttpExtraHeadersOnSessionCreationOnly(httpExtraHeadersOnSessionCreationOnly)

  def isServerInstanceAddressIgnored(self):
    """ Inquiry method that checks if the client is going to ignore the server instance address that 
   will possibly be sent by the server.

   :return: Whether or not to ignore the server instance address sent by the server.

   .. seealso:: :meth:`setServerInstanceAddressIgnored`
   """
    return self.delegate.isServerInstanceAddressIgnored()

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
   :meth:`.ClientListener.onPropertyChange` with argument "serverInstanceAddressIgnored" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param serverInstanceAddressIgnored: true or false, to ignore or not the server instance address sent by the server.
   
   .. seealso:: :meth:`ConnectionDetails.setServerAddress`
   """
    self.delegate.setServerInstanceAddressIgnored(serverInstanceAddressIgnored)

  def isSlowingEnabled(self):
    """Inquiry method that checks if the slowing algorithm is enabled or not.

   :return: Whether the slowing algorithm is enabled or not.

   .. seealso:: :meth:`setSlowingEnabled`
   """
    return self.delegate.isSlowingEnabled()

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
   :meth:`.ClientListener.onPropertyChange` with argument "slowingEnabled" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param slowingEnabled: true or false, to enable or disable the heuristic algorithm that lowers the item update frequency.
   """
    self.delegate.setSlowingEnabled(slowingEnabled)

  def setProxy(self,proxy):
    """Setter method that configures the coordinates to a proxy server to be used to connect to the Lightstreamer Server. 
   
   **default** None (meaning not to pass through a proxy).
   
   **lifecycle** This value can be set and changed at any time. The supplied value will 
   be used for the next connection attempt.
   
   **notification** A change to this setting will be notified through a call to 
   :meth:`.ClientListener.onPropertyChange` with argument "proxy" on any 
   ClientListener listening to the related LightstreamerClient.
   
   :param proxy: The proxy configuration. Specify None to avoid using a proxy.
   """
    self.delegate.setProxy(proxy.delegate)

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

 You can listen to the events generated by a session by registering an event listener, such as :class:`.ClientListener` or :class:`.SubscriptionListener`. 
 These listeners allow you to handle various events, such as session creation, connection status, subscription updates, and server messages. 
 However, you should be aware that the event notifications are dispatched by a single thread, the so-called event thread. 
 This means that if the operations of a listener are slow or blocking, they will delay the processing of the other listeners and 
 affect the performance of your application. 
 Therefore, you should delegate any slow or blocking operations to a dedicated thread, and keep the listener methods as fast and simple as possible.
 Note that even if you create multiple instances of LightstreamerClient, they will all use a single event thread, that is shared among them.

 :param serverAddress: the address of the Lightstreamer Server to which this LightstreamerClient will connect to. It is possible to specify it later by using None here. See :meth:`ConnectionDetails.setServerAddress` for details.
 :param adapterSet: the name of the Adapter Set mounted on Lightstreamer Server to be used to handle all requests in the Session associated with this LightstreamerClient. It is possible not to specify it at all or to specify it later by using None here. See :meth:`ConnectionDetails.setAdapterSet` for details.

 :raises IllegalArgumentException: if a not valid address is passed. See :meth:`ConnectionDetails.setServerAddress` for details.
 """

  LIB_NAME = LSLightstreamerClient.LIB_NAME
  """
  A constant string representing the name of the library.
  """

  LIB_VERSION = LSLightstreamerClient.LIB_VERSION
  """
  A constant string representing the version of the library.
  """

  def __init__(self,serverAddress,adapterSet):
    self.delegate = LSLightstreamerClient(serverAddress, adapterSet)
    #: Data object that contains options and policies for the connection to the server. This instance is set up by the LightstreamerClient object at its own creation. Properties of this object can be overwritten by values received from a Lightstreamer Server. 
    self.connectionOptions = ConnectionOptions(self.delegate.connectionOptions)
    #: Data object that contains the details needed to open a connection to a Lightstreamer Server. This instance is set up by the LightstreamerClient object at its own creation. Properties of this object can be overwritten by values received from a Lightstreamer Server. 
    self.connectionDetails = ConnectionDetails(self.delegate.connectionDetails)

  def addListener(self,listener):
    """Adds a listener that will receive events from the LightstreamerClient instance. 
 
   The same listener can be added to several different LightstreamerClient instances.

   **lifecycle** A listener can be added at any time. A call to add a listener already 
   present will be ignored.
   
   :param listener: An object that will receive the events as documented in the :class:`.ClientListener` interface.
   
   .. seealso:: :meth:`removeListener`
    """
    self.delegate.addListener(listener)

  def removeListener(self,listener):
    """ Removes a listener from the LightstreamerClient instance so that it will not receive events anymore.
   
   **lifecycle** a listener can be removed at any time.
   
   :param listener: The listener to be removed.
   
   .. seealso:: :meth:`addListener`
   """
    self.delegate.removeListener(listener)

  def getListeners(self):
    """Returns a list containing the :class:`.ClientListener` instances that were added to this client.

   :return: a list containing the listeners that were added to this client. 

   .. seealso:: :meth:`addListener`
   """
    return self.delegate.getListeners()

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
   .. seealso:: :meth:`.ClientListener.onStatusChange`
   .. seealso:: :meth:`ConnectionDetails.setServerAddress`
   """
    self.delegate.connect()

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
    self.delegate.disconnect()

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
   
   .. seealso:: :meth:`.ClientListener.onStatusChange`
   """
    return self.delegate.getStatus()

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
   will be notified to the listener through :meth:`.ClientMessageListener.onDiscarded`.
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
   the message will be abandoned and the :meth:`.ClientMessageListener.onAbort` event will be fired. 

   Note that, in any case, as soon as the status switches again to "DISCONNECTED*", any message still pending 
   is aborted, including messages that were queued with the enqueueWhileDisconnected flag set to true. 

   Also note that forwarding of the message to the server is made in a separate thread, hence, if a message 
   is sent while the connection is active, it could be aborted because of a subsequent disconnection. 
   In the same way a message sent while the connection is not active might be sent because of a subsequent
   connection.
   
   :param message: a text message, whose interpretation is entirely demanded to the Metadata Adapter associated to the current connection.
   :param sequence: an alphanumeric identifier, used to identify a subset of messages to be managed in sequence; underscore characters are also allowed. If the "UNORDERED_MESSAGES" identifier is supplied, the message will be processed in the special way described above. The parameter is optional; if set to None, "UNORDERED_MESSAGES" is used as the sequence name. 
   :param delayTimeout: a timeout, expressed in milliseconds. If higher than the Server configured timeout on missing messages, the latter will be used instead. The parameter is optional; if a negative value is supplied, the Server configured timeout on missing messages will be applied. This timeout is ignored for the special "UNORDERED_MESSAGES" sequence, although a server-side timeout on missing messages still applies.
   :param listener: an object suitable for receiving notifications about the processing outcome. The parameter is optional; if not supplied, no notification will be available.
   :param enqueueWhileDisconnected: if this flag is set to true, and the client is in a disconnected status when the provided message is handled, then the message is not aborted right away but is queued waiting for a new session. Note that the message can still be aborted later when a new session is established.
   """
    self.delegate.sendMessage(message, sequence, delayTimeout, listener, enqueueWhileDisconnected)

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

   A successful subscription to the server will be notified through a :meth:`.SubscriptionListener.onSubscription`
   event.
   
   :param subscription: A Subscription object, carrying all the information needed to process real-time values.
   
   .. seealso:: :meth:`unsubscribe`
   """
    self.delegate.subscribe(subscription.delegate)

  def unsubscribe(self,subscription):
    """Operation method that removes a Subscription that is currently in the "active" state. 
 
   By bringing back a Subscription to the "inactive" state, the unsubscription from all its items is 
   requested to Lightstreamer Server.
   
   **lifecycle** Subscription can be unsubscribed from at any time. Once done the Subscription immediately 
   exits the "active" state. 

   Note that forwarding of the unsubscription to the server is made in a separate thread. 

   The unsubscription will be notified through a :meth:`.SubscriptionListener.onUnsubscription` event.
   
   :param subscription: An "active" Subscription object that was activated by this LightstreamerClient instance.
   """
    self.delegate.unsubscribe(subscription.delegate)

  def getSubscriptions(self):
    """ Inquiry method that returns a list containing all the Subscription instances that are 
   currently "active" on this LightstreamerClient. 

   Internal second-level Subscription are not included.

   :return: A list, containing all the Subscription currently "active" on this LightstreamerClient. 

   The list can be empty.

   .. seealso:: :meth:`subscribe`
   """
    return self.delegate.getSubscriptionWrappers()

  @staticmethod
  def setLoggerProvider(provider):
    """Static method that permits to configure the logging system used by the library. The logging system must respect the :class:`.LoggerProvider` interface. A custom class can be used to wrap any third-party logging system. 

If no logging system is specified, all the generated log is discarded. 

The following categories are available to be consumed:
   
    * lightstreamer.stream: logs socket activity on Lightstreamer Server connections; at INFO level, socket operations are logged; at DEBUG level, read/write data exchange is logged.
    * lightstreamer.protocol: logs requests to Lightstreamer Server and Server answers; at INFO level, requests are logged; at DEBUG level, request details and events from the Server are logged.
    * lightstreamer.session: logs Server Session lifecycle events; at INFO level, lifecycle events are logged; at DEBUG level, lifecycle event details are logged.
    * lightstreamer.subscriptions: logs subscription requests received by the clients and the related updates; at WARN level, alert events from the Server are logged; at INFO level, subscriptions and unsubscriptions are logged; at DEBUG level, requests batching and update details are logged.
    * lightstreamer.actions: logs settings / API calls.
    
:param provider: A :class:`.LoggerProvider` instance that will be used to generate log messages by the library classes.
   """
    LSLightstreamerClient.setLoggerProvider(provider)

  @staticmethod
  def addCookies(uri,cookies):
    """Static method that can be used to share cookies between connections to the Server (performed by this library) and connections to other sites that are performed by the application. With this method, cookies received by the application can be added (or replaced if already present) to the cookie set used by the library to access the Server. Obviously, only cookies whose domain is compatible with the Server domain will be used internally.
     
**lifecycle** This method should be invoked before calling the :meth:`LightstreamerClient.connect` method. However it can be invoked at any time; it will affect the internal cookie set immediately and the sending of cookies on the next HTTP request or WebSocket establishment.
   
:param uri: the URI from which the supplied cookies were received. It cannot be None.
   
:param cookies: an instance of http.cookies.SimpleCookie.
   
.. seealso:: :meth:`getCookies`
   """
    LSLightstreamerClient.addCookies(uri, cookies)

  @staticmethod
  def getCookies(uri):
    """Static inquiry method that can be used to share cookies between connections to the Server (performed by this library) and connections to other sites that are performed by the application. With this method, cookies received from the Server can be extracted for sending through other connections, according with the URI to be accessed.
   
See :meth:`addCookies` for clarifications on when cookies are directly stored by the library and when not.

:param uri: the URI to which the cookies should be sent, or None.
   
:return: a list with the various cookies that can be sent in a HTTP request for the specified URI. If a None URI was supplied, all available non-expired cookies will be returned.
:rtype: http.cookies.SimpleCookie
   """
    return LSLightstreamerClient.getCookies(uri)

  @staticmethod
  def setTrustManagerFactory(factory):
    """Provides a mean to control the way TLS certificates are evaluated, with the possibility to accept untrusted ones.
   
**lifecycle** May be called only once before creating any LightstreamerClient instance.
   
:param factory: an instance of ssl.SSLContext
:raises IllegalArgumentException: if the factory is None
:raises IllegalStateException: if a factory is already installed
   """
    LSLightstreamerClient.setTrustManagerFactory(factory)

class Proxy:
  """Simple class representing a Proxy configuration. 

 An instance of this class can be used through :meth:`ConnectionOptions.setProxy` to
 instruct a LightstreamerClient to connect to the Lightstreamer Server passing through a proxy.

 :param type: the proxy type. Supported values are HTTP, SOCKS4 and SOCKS5.
 :param host: the proxy host
 :param port: the proxy port
 :param user: the user name to be used to validate against the proxy. Optional.
 :param password: the password to be used to validate against the proxy. Optional.
 """

  def __init__(self,_hx_type,host,port,user=None,password=None):
    self.delegate = LSProxy(_hx_type, host, port, user, password)

  def __str__(self):
    return self.delegate.toString()

  def __eq__(self, other):
    if other is not None and isinstance(other, Proxy):
      return self.delegate.isEqualTo(other.delegate)
    return False

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
:raises IllegalArgumentException: If either the items or the fields array is left None.
:raises IllegalArgumentException: If the specified "Item List" or "Field List" is not valid; see :meth:`setItems` and :meth:`setFields` for details.
  """

  def __init__(self,mode,items,fields):
    self.delegate = LSSubscription(mode, items, fields, self)

  def addListener(self,listener):
    """Adds a listener that will receive events from the Subscription instance. 
 
    The same listener can be added to several different Subscription instances.
    
    **lifecycle** A listener can be added at any time. A call to add a listener already 
    present will be ignored.
    
    :param listener: An object that will receive the events as documented in the SubscriptionListener interface.
    
    .. seealso:: :meth:`removeListener`
    """
    self.delegate.addListener(listener)

  def removeListener(self,listener):
    """Removes a listener from the Subscription instance so that it will not receive 
    events anymore.
    
    **lifecycle** a listener can be removed at any time.
    
    :param listener: The listener to be removed.
    
    .. seealso:: :meth:`addListener`
    """
    self.delegate.removeListener(listener)

  def getListeners(self):
    """Returns a list containing the :class:`.SubscriptionListener` instances that were 
    added to this client.

    :return: a list containing the listeners that were added to this client. 

    .. seealso:: :meth:`addListener`
    """
    return self.delegate.getListeners()

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
    return self.delegate.isActive()

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
    return self.delegate.isSubscribed()

  def getDataAdapter(self):
    """Inquiry method that can be used to read the name of the Data Adapter specified for this 
    Subscription through :meth:`setDataAdapter`.
    **lifecycle** This method can be called at any time.

    :return: the name of the Data Adapter; returns None if no name has been configured, so that the "DEFAULT" Adapter Set is used.
    """
    return self.delegate.getDataAdapter()

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
    
    :param dataAdapter: the name of the Data Adapter. A None value is equivalent to the "DEFAULT" name.
     
    .. seealso:: :meth:`ConnectionDetails.setAdapterSet`
    """
    self.delegate.setDataAdapter(dataAdapter)

  def getMode(self):
    """Inquiry method that can be used to read the mode specified for this
    Subscription.
    
    **lifecycle** This method can be called at any time.
    
    :return: the Subscription mode specified in the constructor.
    """
    return self.delegate.getMode()

  def getItems(self):
    """Inquiry method that can be used to read the "Item List" specified for this Subscription. 
    Note that if the single-item-constructor was used, this method will return an array 
    of length 1 containing such item.
    
    **lifecycle** This method can only be called if the Subscription has been initialized 
    with an "Item List".

    :return: the "Item List" to be subscribed to through the server, or None if the Subscription was initialized with an "Item Group" or was not initialized at all.
    """
    return self.delegate.getItems()

  def setItems(self,items):
    """Setter method that sets the "Item List" to be subscribed to through 
    Lightstreamer Server. 

    Any call to this method will override any "Item List" or "Item Group"
    previously specified.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalArgumentException: if any of the item names in the "Item List" contains a space or is a number or is empty/None.
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param items: an array of items to be subscribed to through the server. 
    """
    self.delegate.setItems(items)

  def getItemGroup(self):
    """Inquiry method that can be used to read the item group specified for this Subscription.
    
    **lifecycle** This method can only be called if the Subscription has been initialized
    using an "Item Group"

    :return: the "Item Group" to be subscribed to through the server, or None if the Subscription was initialized with an "Item List" or was not initialized at all.
    """
    return self.delegate.getItemGroup()

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
    self.delegate.setItemGroup(group)

  def getFields(self):
    """Inquiry method that can be used to read the "Field List" specified for this Subscription.
    
    **lifecycle**  This method can only be called if the Subscription has been initialized 
    using a "Field List".

    :return: the "Field List" to be subscribed to through the server, or None if the Subscription was initialized with a "Field Schema" or was not initialized at all.
    """
    return self.delegate.getFields()

  def setFields(self,fields):
    """Setter method that sets the "Field List" to be subscribed to through 
    Lightstreamer Server. 

    Any call to this method will override any "Field List" or "Field Schema"
    previously specified.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalArgumentException: if any of the field names in the list contains a space or is empty/None.
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param fields: an array of fields to be subscribed to through the server. 
    """
    self.delegate.setFields(fields)

  def getFieldSchema(self):
    """Inquiry method that can be used to read the field schema specified for this Subscription.
    
    **lifecycle** This method can only be called if the Subscription has been initialized 
    using a "Field Schema"

    :return: the "Field Schema" to be subscribed to through the server, or None if the Subscription was initialized with a "Field List" or was not initialized at all.
    """
    return self.delegate.getFieldSchema()

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
    self.delegate.setFieldSchema(schema)

  def getRequestedBufferSize(self):
    """Inquiry method that can be used to read the buffer size, configured though
    :meth:`setRequestedBufferSize`, to be requested to the Server for 
    this Subscription.
    
    **lifecycle** This method can be called at any time.
    
    :return:  An integer number, representing the buffer size to be requested to the server, or the string "unlimited", or None.
    """
    return self.delegate.getRequestedBufferSize()

  def setRequestedBufferSize(self,size):
    """Setter method that sets the length to be requested to Lightstreamer
    Server for the internal queuing buffers for the items in the Subscription.
    A Queuing buffer is used by the Server to accumulate a burst
    of updates for an item, so that they can all be sent to the client,
    despite of bandwidth or frequency limits. It can be used only when the
    subscription mode is MERGE or DISTINCT and unfiltered dispatching has
    not been requested. Note that the Server may pose an upper limit on the
    size of its internal buffers.
    
    **default** None, meaning to lean on the Server default based on the subscription
    mode. This means that the buffer size will be 1 for MERGE 
    subscriptions and "unlimited" for DISTINCT subscriptions. See 
    the "General Concepts" document for further details.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalArgumentException: if the specified value is not None nor "unlimited" nor a valid positive integer number.
    
    :param size:  An integer number, representing the length of the internal queuing buffers to be used in the Server. If the string "unlimited" is supplied, then no buffer size limit is requested (the check is case insensitive). It is also possible to supply a None value to stick to the Server default (which currently depends on the subscription mode).
    
    .. seealso:: :meth:`Subscription.setRequestedMaxFrequency`
    """
    self.delegate.setRequestedBufferSize(size)

  def getRequestedSnapshot(self):
    """Inquiry method that can be used to read the snapshot preferences, 
    configured through :meth:`setRequestedSnapshot`, to be requested 
    to the Server for this Subscription.
    
    **lifecycle** This method can be called at any time.
    
    :return:  "yes", "no", None, or an integer number.
    """
    return self.delegate.getRequestedSnapshot()

  def setRequestedSnapshot(self,snapshot):
    """Setter method that enables/disables snapshot delivery request for the
    items in the Subscription. The snapshot can be requested only if the
    Subscription mode is MERGE, DISTINCT or COMMAND.
    
    **default** "yes" if the Subscription mode is not "RAW",
    None otherwise.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalArgumentException: if the specified value is not "yes" nor "no" nor None nor a valid integer positive number.
    :raises IllegalArgumentException: if the specified value is not compatible with the mode of the Subscription: 
    
      * In case of a RAW Subscription only None is a valid value;
      * In case of a non-DISTINCT Subscription only None "yes" and "no" are valid values.
    
    
    :param required: "yes"/"no" to request/not request snapshot delivery (the check is case insensitive). If the Subscription mode is DISTINCT, instead of "yes", it is also possible to supply an integer number, to specify the requested length of the snapshot (though the length of the received snapshot may be less than requested, because of insufficient data or server side limits); passing "yes"  means that the snapshot length should be determined only by the Server. None is also a valid value; if specified, no snapshot preference will be sent to the server that will decide itself whether or not to send any snapshot. 
    
    .. seealso:: :meth:`.ItemUpdate.isSnapshot`
    """
    self.delegate.setRequestedSnapshot(snapshot)

  def getRequestedMaxFrequency(self):
    """Inquiry method that can be used to read the max frequency, configured
    through :meth:`setRequestedMaxFrequency`, to be requested to the 
    Server for this Subscription.
    
    **lifecycle** This method can be called at any time.
    
    :return:  A decimal number, representing the max frequency to be requested to the server (expressed in updates per second), or the strings "unlimited" or "unfiltered", or None.
    """
    return self.delegate.getRequestedMaxFrequency()

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
    
**default** None, meaning to lean on the Server default based on the subscription
mode. This consists, for all modes, in not applying any frequency 
limit to the subscription (the same as "unlimited"); see the "General Concepts"
document for further details.
    
**lifecycle** This method can can be called at any time with some
differences based on the Subscription status:
    
  * If the Subscription instance is in its "inactive" state then this method can be called at will.
  * If the Subscription instance is in its "active" state then the method can still be called unless the current value is "unfiltered" or the supplied value is "unfiltered" or None. If the Subscription instance is in its "active" state and the connection to the server is currently open, then a request to change the frequency of the Subscription on the fly is sent to the server.
    
:raises IllegalStateException: if the Subscription is currently "active" and the current value of this property is "unfiltered".
:raises IllegalStateException: if the Subscription is currently "active" and the given parameter is None or "unfiltered".
:raises IllegalArgumentException: if the specified value is not None nor one of the special "unlimited" and "unfiltered" values nor a valid positive number.
    
:param freq:  A decimal number, representing the maximum update frequency (expressed in updates per second) for each item in the Subscription; for instance, with a setting of 0.5, for each single item, no more than one update every 2 seconds will be received. If the string "unlimited" is supplied, then no frequency limit is requested. It is also possible to supply the string "unfiltered", to ask for unfiltered dispatching, if it is allowed for the items, or a None value to stick to the Server default (which currently corresponds to "unlimited"). The check for the string constants is case insensitive.
    """
    self.delegate.setRequestedMaxFrequency(freq)

  def getSelector(self):
    """Inquiry method that can be used to read the selector name  
    specified for this Subscription through :meth:`setSelector`.
    
    **lifecycle** This method can be called at any time.
    
    :return: the name of the selector.
    """
    return self.delegate.getSelector()

  def setSelector(self,selector):
    """Setter method that sets the selector name for all the items in the
    Subscription. The selector is a filter on the updates received. It is
    executed on the Server and implemented by the Metadata Adapter.
    
    **default** None (no selector).
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    
    :param selector: name of a selector, to be recognized by the Metadata Adapter, or None to unset the selector.
    """
    self.delegate.setSelector(selector)

  def getCommandPosition(self):
    """Returns the position of the "command" field in a COMMAND Subscription. 

    This method can only be used if the Subscription mode is COMMAND and the Subscription 
    was initialized using a "Field Schema".
    
    **lifecycle** This method can be called at any time after the first 
    :meth:`.SubscriptionListener.onSubscription` event.

    :raises IllegalStateException: if the Subscription mode is not COMMAND or if the :meth:`.SubscriptionListener.onSubscription` event for this Subscription was not yet fired.
    :raises IllegalStateException: if a "Field List" was specified.

    :return: the 1-based position of the "command" field within the "Field Schema".
    """
    return self.delegate.getCommandPosition()

  def getKeyPosition(self):
    """Returns the position of the "key" field in a COMMAND Subscription. 

    This method can only be used if the Subscription mode is COMMAND
    and the Subscription was initialized using a "Field Schema".
     
    **lifecycle** This method can be called at any time.
    
    :raises IllegalStateException: if the Subscription mode is not COMMAND or if the :meth:`.SubscriptionListener.onSubscription` event for this Subscription was not yet fired.
    
    :return: the 1-based position of the "key" field within the "Field Schema".
    """
    return self.delegate.getKeyPosition()

  def getCommandSecondLevelDataAdapter(self):
    """Inquiry method that can be used to read the second-level Data Adapter name configured 
    through :meth:`setCommandSecondLevelDataAdapter`.
    
    **lifecycle** This method can be called at any time.

    :raises IllegalStateException: if the Subscription mode is not COMMAND
    :return: the name of the second-level Data Adapter.
    
    .. seealso:: :meth:`setCommandSecondLevelDataAdapter`
    """
    return self.delegate.getCommandSecondLevelDataAdapter()

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
    
    :param dataAdapter: the name of the Data Adapter. A None value is equivalent to the "DEFAULT" name.
     
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFields`
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFieldSchema`
    """
    self.delegate.setCommandSecondLevelDataAdapter(dataAdapter)

  def getCommandSecondLevelFields(self):
    """Inquiry method that can be used to read the "Field List" specified for second-level 
    Subscriptions.
    
    **lifecycle** This method can only be called if the second-level of this Subscription 
    has been initialized using a "Field List"

    :raises IllegalStateException: if the Subscription mode is not COMMAND
    :return: the list of fields to be subscribed to through the server, or None if the Subscription was initialized with a "Field Schema" or was not initialized at all.

    .. seealso:: :meth:`Subscription.setCommandSecondLevelFields`
    """
    return self.delegate.getCommandSecondLevelFields()

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
 
    Specifying None as parameter will disable the two-level behavior.
          
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalArgumentException: if any of the field names in the "Field List" contains a space or is empty/None.
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalStateException: if the Subscription mode is not "COMMAND".
    
    :param fields: An array of Strings containing a list of fields to be subscribed to through the server. Ensure that no name conflict is generated between first-level and second-level fields. In case of conflict, the second-level field will not be accessible by name, but only by position.
    
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFieldSchema`
    """
    self.delegate.setCommandSecondLevelFields(fields)

  def getCommandSecondLevelFieldSchema(self):
    """Inquiry method that can be used to read the "Field Schema" specified for second-level 
    Subscriptions.
    
    **lifecycle** This method can only be called if the second-level of this Subscription has 
    been initialized using a "Field Schema".

    :raises IllegalStateException: if the Subscription mode is not COMMAND
    :return: the "Field Schema" to be subscribed to through the server, or None if the Subscription was initialized with a "Field List" or was not initialized at all.

    .. seealso:: :meth:`Subscription.setCommandSecondLevelFieldSchema`
    """
    return self.delegate.getCommandSecondLevelFieldSchema()

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

    Specify None as parameter will disable the two-level behavior.
    
    **lifecycle** This method can only be called while the Subscription
    instance is in its "inactive" state.
    
    :raises IllegalStateException: if the Subscription is currently "active".
    :raises IllegalStateException: if the Subscription mode is not "COMMAND".
    
    :param schemaName: A String to be expanded into a field list by the Metadata Adapter. 
    
    .. seealso:: :meth:`Subscription.setCommandSecondLevelFields`
    """
    return self.delegate.setCommandSecondLevelFieldSchema(schema)

  def getValue(self,itemNameOrPos,fieldNameOrPos):
    """Returns the latest value received for the specified item/field pair.
     
It is suggested to consume real-time data by implementing and adding
a proper :class:`.SubscriptionListener` rather than probing this method.
In case of COMMAND Subscriptions, the value returned by this
method may be misleading, as in COMMAND mode all the keys received, being
part of the same item, will overwrite each other; for COMMAND Subscriptions,
use :meth:`Subscription.getCommandValue` instead.
     
Note that internal data is cleared when the Subscription is 
unsubscribed from. 
     
**lifecycle** This method can be called at any time; if called 
to retrieve a value that has not been received yet, then it will return None. 
          
:raises IllegalArgumentException: if an invalid item name or field name is specified or if the specified item position or field position is out of bounds.
     
:param itemNameOrPos: a String representing an item in the configured item list or a Number representing the 1-based position of the item in the specified item group. (In case an item list was specified, passing the item position is also possible).
     
:param fieldNameOrPos: a String representing a field in the configured field list or a Number representing the 1-based position of the field in the specified field schema. (In case a field list was specified, passing the field position is also possible).
     
:return: the current value for the specified field of the specified item(possibly None), or None if no value has been received yet.
     """
    return self.delegate.getValue(itemNameOrPos,fieldNameOrPos)

  def getCommandValue(self,itemNameOrPos,keyValue,fieldNameOrPos):
    """Returns the latest value received for the specified item/key/field combination. This method can only be used if the Subscription mode is COMMAND. Subscriptions with two-level behavior are also supported, hence the specified field can be either a first-level or a second-level one.
     
It is suggested to consume real-time data by implementing and adding a proper :class:`.SubscriptionListener` rather than probing this method.
     
Note that internal data is cleared when the Subscription is unsubscribed from. 
     
**lifecycle** This method can be called at any time; if called to retrieve a value that has not been received yet, then it will return None.
          
:raises IllegalArgumentException: if an invalid item name or field name is specified or if the specified item position or field position is out of bounds.
:raises IllegalStateException: if the Subscription mode is not COMMAND.
     
:param itemIdentifier: a String representing an item in the configured item list or a Number representing the 1-based position of the item in the specified item group. (In case an item list was specified, passing the item position is also possible).
     
:param keyValue: a String containing the value of a key received on the COMMAND subscription.
     
:param fieldIdentifier: a String representing a field in the configured field list or a Number representing the 1-based position of the field in the specified field schema. (In case a field list was specified, passing the field position is also possible).
     
:return: the current value for the specified field of the specified key within the specified item (possibly None), or None if the specified key has not been added yet (note that it might have been added and eventually deleted).
    """
    return self.delegate.getCommandValue(itemNameOrPos,keyValue,fieldNameOrPos)

class ConsoleLoggerProvider(LoggerProvider):
  """This LoggerProvider rests on the logging facility provided by the standard module *logging*. The log events are forwarded to the logger named *lightstreamer*.

  If you need further customizations, you can leverage the features of module *logging* through, for example, *logging.basicConfig*::

    logging.basicConfig(level=logging.DEBUG, format="%(message)s", stream=sys.stdout)

  :param level: the threshold of the loggers created by this provider (see :class:`ConsoleLogLevel`)
  """

  def __init__(self,level):
    self.delegate = LSConsoleLoggerProvider(level)

  def getLogger(self,category):
    return self.delegate.getLogger(category)

class ConsoleLogLevel:
  """The threshold configured for an instance of :class:`ConsoleLoggerProvider`.
  """

  TRACE = LSConsoleLogLevel.TRACE
  """Trace logging level.
  
  This level enables all logging.
  """
  DEBUG = LSConsoleLogLevel.DEBUG
  """Debug logging level.
  
  This level enables logging for debug, information, warnings, errors and fatal errors.
  """
  INFO = LSConsoleLogLevel.INFO
  """Info logging level.
  
  This level enables logging for information, warnings, errors and fatal errors.
  """
  WARN = LSConsoleLogLevel.WARN
  """Warn logging level.
  
  This level enables logging for warnings, errors and fatal errors.
  """
  ERROR = LSConsoleLogLevel.ERROR
  """Error logging level.
  
  This level enables logging for errors and fatal errors.
  """
  FATAL = LSConsoleLogLevel.FATAL
  """Fatal logging level.
  
  This level enables logging for fatal errors.
  """
