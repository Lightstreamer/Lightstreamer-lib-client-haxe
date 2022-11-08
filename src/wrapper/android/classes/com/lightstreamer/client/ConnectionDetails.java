/*
 * Copyright (c) 2004-2015 Weswit s.r.l., Via Campanini, 6 - 20124 Milano, Italy.
 * All rights reserved.
 * www.lightstreamer.com
 *
 * This software is the confidential and proprietary information of
 * Weswit s.r.l.
 * You shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the license agreement you entered
 * into with Weswit s.r.l.
 */
package com.lightstreamer.client;

import javax.annotation.Nullable;
import com.lightstreamer.client.LSConnectionDetails;
import com.lightstreamer.client.LSLightstreamerClient;

/**
 * Used by LightstreamerClient to provide a basic connection properties data object.
 *
 * Data object that contains the configuration settings needed
 * to connect to a Lightstreamer Server. <BR>
 * An instance of this class is attached to every {@link LightstreamerClient}
 * as {@link LightstreamerClient#connectionDetails}<BR>
 * 
 * @see LightstreamerClient
 */
public class ConnectionDetails {
  final LSConnectionDetails delegate;

  ConnectionDetails(LSLightstreamerClient client) {
    this.delegate = new LSConnectionDetails(client);
  }

  /**
   * Inquiry method that gets the name of the Adapter Set (which defines the Metadata Adapter and one or several 
   * Data Adapters) mounted on Lightstreamer Server that supply all the items used in this application.
   * 
   * @return the adapterSet the name of the Adapter Set; returns null if no name has been configured, that 
   * means that the "DEFAULT" Adapter Set is used.
   * 
   * @see #setAdapterSet
   */
  @Nullable
  public String getAdapterSet() {
    return delegate.getAdapterSet();
  }

  /**
   * Setter method that sets the name of the Adapter Set mounted on Lightstreamer Server to be used to handle 
   * all requests in the session. <BR> 
   * An Adapter Set defines the Metadata Adapter and one or several Data Adapters. It is configured on the 
   * server side through an "adapters.xml" file; the name is configured through the "id" attribute in 
   * the &lt;adapters_conf&gt; element.
   * 
   * @default The default Adapter Set, configured as "DEFAULT" on the Server.
   * 
   * @lifecycle The Adapter Set name should be set on the {@link LightstreamerClient#connectionDetails} object 
   * before calling the {@link LightstreamerClient#connect} method. However, the value can be changed at any time: 
   * the supplied value will be used for the next time a new session is requested to the server. <BR>
   * This setting can also be specified in the {@link LightstreamerClient} constructor.
   * 
   * @notification A change to this setting will be notified through a call to 
   * {@link ClientListener#onPropertyChange} with argument "adapterSet" on any 
   * ClientListener listening to the related LightstreamerClient.
   * 
   * @param adapterSet The name of the Adapter Set to be used. A null value is equivalent to the "DEFAULT" name.
   */
  public void setAdapterSet(@Nullable String adapterSet) {
    delegate.setAdapterSet(adapterSet);
  }

  /**
   * Inquiry method that gets the configured address of Lightstreamer Server.
   *
   * @return the serverAddress the configured address of Lightstreamer Server.
   */
  @Nullable
  public String getServerAddress() {
    return delegate.getServerAddress();
  }

  /**
   * Setter method that sets the address of Lightstreamer Server. <BR> 
   * Note that the addresses specified must always have the http: or https: scheme. In case WebSockets are used, 
   * the specified scheme is internally converted to match the related WebSocket protocol (i.e. http becomes ws 
   * while https becomes wss).
   *
   * @general_edition_note WSS/HTTPS is an optional feature, available depending on Edition and License Type.
   * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
   * available at /dashboard).
   * 
   * @default if no server address is supplied the client will be unable to connect.
   * 
   * @lifecycle This method can be called at any time. If called while connected, it will be applied when the next 
   * session creation request is issued. This setting can also be specified in the {@link LightstreamerClient}
   * constructor.
   * 
   * @notification A change to this setting will be notified through a call to 
   * {@link ClientListener#onPropertyChange} with argument "serverAddress" on any 
   * ClientListener listening to the related LightstreamerClient.
   * 
   * @param serverAddress The full address of Lightstreamer Server. A null value can also be used, to restore the default value. 
   * An IPv4 or IPv6 can also be used in place of a hostname. Some examples of valid values include:
   * http://push.mycompany.com<BR> 
   * http://push.mycompany.com:8080<BR>
   * http://79.125.7.252<BR>
   * http://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]<BR>
   * http://[2001:0db8:85a3::8a2e:0370:7334]:8080
   * 
   * @throws IllegalArgumentException if the given address is not valid.
   */
  public void setServerAddress(@Nullable String serverAddress) {
    delegate.setServerAddress(serverAddress);
  }

  /**
   * Inquiry method that gets the username to be used for the authentication on Lightstreamer Server when 
   * initiating the session.
   * 
   * @return the username to be used for the authentication on Lightstreamer Server; returns null if no 
   * user name has been configured.
   */
  @Nullable
  public String getUser() {
    return delegate.getUser();
  }

  /**
   * Setter method that sets the username to be used for the authentication on Lightstreamer Server when initiating
   * the session. The Metadata Adapter is responsible for checking the credentials (username and password).
   * 
   * @default If no username is supplied, no user information will be sent at session initiation. 
   * The Metadata Adapter, however, may still allow the session.
   * 
   * @lifecycle The username should be set on the {@link LightstreamerClient#connectionDetails} object before 
   * calling the {@link LightstreamerClient#connect} method. However, the value can be changed at any time: the 
   * supplied value will be used for the next time a new session is requested to the server.
   * 
   * @notification A change to this setting will be notified through a call to 
   * {@link ClientListener#onPropertyChange} with argument "user" on any 
   * ClientListener listening to the related LightstreamerClient.
   * 
   * @param user The username to be used for the authentication on Lightstreamer Server. The username can be null.
   * 
   * @see #setPassword(String)
   */
  public void setUser(@Nullable String user) {
    delegate.setUser(user);
  }

  /**
   * Inquiry method that gets the server address to be used to issue all requests related to the current session. 
   * In fact, when a Server cluster is in place, the Server address specified through {@link #setServerAddress} can 
   * identify various Server instances; in order to ensure that all requests related to a session are issued to 
   * the same Server instance, the Server can answer to the session opening request by providing an address which 
   * uniquely identifies its own instance. When this is the case, this address is returned by the method; otherwise,
   * null is returned. <BR> 
   * Note that the addresses will always have the http: or https: scheme. In case WebSockets are used, the specified 
   * scheme is internally converted to match the related WebSocket protocol (i.e. http becomes ws while 
   * https becomes wss).
   * 
   * @general_edition_note Server Clustering is an optional feature, available depending on Edition and License Type.
   * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default,
   * available at /dashboard).
   * 
   * @lifecycle The method gives a meaningful answer only when a session is currently active.
   * 
   * @notification A change to this setting will be notified through a call to 
   * {@link ClientListener#onPropertyChange} with argument "serverInstanceAddress" on any 
   * ClientListener listening to the related LightstreamerClient.
   * 
   * @return address used to issue all requests related to the current session.
   */
  @Nullable
  public String getServerInstanceAddress() {
    return delegate.getServerInstanceAddress();
  }
  
  /**
   * Inquiry method that gets the instance name of the Server which is serving the current session. To be more precise, 
   * each answering port configured on a Server instance (through a &lt;http_server&gt; or &lt;https_server&gt; element in the 
   * Server configuration file) can be given a different name; the name related to the port to which the session 
   * opening request has been issued is returned. <BR> 
   * Note that each rebind to the same session can, potentially, reach the Server on a port different than the one
   * used for the previous request, depending on the behavior of intermediate nodes. However, the only meaningful case
   * is when a Server cluster is in place and it is configured in such a way that the port used for all bind_session requests
   * differs from the port used for the initial create_session request.
   * 
   * @general_edition_note Server Clustering is an optional feature, available depending on Edition and License Type.
   * To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).
   * 
   * @lifecycle If a session is not currently active, null is returned;
   * soon after a session is established, the value will become available.
   * 
   * @notification A change to this setting will be notified through a call to 
   * {@link ClientListener#onPropertyChange} with argument "serverSocketName" on any 
   * ClientListener listening to the related LightstreamerClient.
   * 
   * @return name configured for the Server instance which is managing the current session, or null.
   */
  @Nullable
  public String getServerSocketName() {
    return delegate.getServerSocketName();
  }
  
  /**
   * Inquiry method that gets the IP address of this client as seen by the Server which is serving
   * the current session as the client remote address (note that it may not correspond to the client host;
   * for instance it may refer to an intermediate proxy). If, upon a new session, this address changes,
   * it may be a hint that the intermediary network nodes handling the connection have changed, hence the network
   * capabilities may be different. The library uses this information to optimize the connection. <BR>  
   * Note that in case of polling or in case rebind requests are needed, subsequent requests related to the same 
   * session may, in principle, expose a different IP address to the Server; these changes would not be reported.
   * 
   * @lifecycle If a session is not currently active, null is returned;
   * soon after a session is established, the value may become available; but it is possible
   * that this information is not provided by the Server and that it will never be available.
   * 
   * @notification A change to this setting will be notified through a call to 
   * {@link ClientListener#onPropertyChange} with argument "clientIp" on any 
   * ClientListener listening to the related LightstreamerClient.
   * 
   * @return  A canonical representation of an IP address (it can be either IPv4 or IPv6), or null.
   */
  @Nullable
  public String getClientIp() {
    return delegate.getClientIp();
  }
  
  /**
   * Inquiry method that gets the ID associated by the server to this client session.
   * 
   * @lifecycle The method gives a meaningful answer only when a session is currently active.
   * 
   * @notification A change to this setting will be notified through a call to 
   * {@link ClientListener#onPropertyChange} with argument "sessionId" on any 
   * ClientListener listening to the related LightstreamerClient.
   * 
   * @return ID assigned by the Server to this client session.
   */
  @Nullable
  public String getSessionId() {
    return delegate.getSessionId();
  }

  /**
   * Setter method that sets the password to be used for the authentication on Lightstreamer Server when initiating 
   * the session. The Metadata Adapter is responsible for checking the credentials (username and password).
   * 
   * @default  If no password is supplied, no password information will be sent at session initiation. 
   * The Metadata Adapter, however, may still allow the session.
   * 
   * @lifecycle The username should be set on the {@link LightstreamerClient#connectionDetails} object before calling 
   * the {@link LightstreamerClient#connect} method. However, the value can be changed at any time: the supplied 
   * value will be used for the next time a new session is requested to the server. <BR>
   * NOTE: The password string will be stored in the current instance. That is necessary in order to allow 
   * automatic reconnection/reauthentication for fail-over. For maximum security, avoid using an actual private 
   * password to authenticate on Lightstreamer Server; rather use a session-id originated by your web/application 
   * server, that can be checked by your Metadata Adapter.
   * 
   * @notification A change to this setting will be notified through a call to 
   * {@link ClientListener#onPropertyChange} with argument "password" on any 
   * ClientListener listening to the related LightstreamerClient.
   * 
   * @param password The password to be used for the authentication on Lightstreamer Server. 
   *        The password can be null.
   *        
   * @see #setUser(String)
   */
  public void setPassword(@Nullable String password) {
    delegate.setPassword(password);
  }
}
