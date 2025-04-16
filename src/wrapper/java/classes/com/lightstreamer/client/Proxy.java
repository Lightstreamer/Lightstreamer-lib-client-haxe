/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.client;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;
import com.lightstreamer.client.LSProxy;

/**
 * Simple class representing a Proxy configuration. <BR>
 * 
 * An instance of this class can be used through {@link ConnectionOptions#setProxy(Proxy)} to
 * instruct a LightstreamerClient to connect to the Lightstreamer Server passing through a proxy.
 */
public class Proxy {
  final LSProxy delegate;

  /**
   * This constructor will call {@link #Proxy(String, String, int, String, String)}
   * specifying null user and null password.
   * @param type the proxy type. Supported values are HTTP, SOCKS4 and SOCKS5.
   * @param host the proxy host
   * @param port the proxy port
   */
  public Proxy(@Nonnull String type, @Nonnull String host, int port) {
    this.delegate = new LSProxy(type, host, port);
  }
  
  /**
   * This constructor will call {@link #Proxy(String, String, int, String, String)}
   * specifying a null null password.
   * @param type the proxy type. Supported values are HTTP, SOCKS4 and SOCKS5.
   * @param host the proxy host
   * @param port the proxy port
   * @param user the user name to be used to validate against the proxy
   */
  public Proxy(@Nonnull String type, @Nonnull String host, int port, @Nullable String user) {
    this.delegate = new LSProxy(type, host, port, user);
  }
  
  /**
   * Creates a Proxy instance containing all the information required by the {@link LightstreamerClient}
   * to connect to a Lightstreamer server passing through a proxy. <BR>
   * Once created the Proxy instance has to be passed to the {@link LightstreamerClient#connectionOptions}
   * instance using the {@link ConnectionOptions#setProxy(Proxy)} method.
   * 
   * @param type the proxy type. Supported values are HTTP, SOCKS4 and SOCKS5.
   * @param host the proxy host
   * @param port the proxy port
   * @param user the user name to be used to validate against the proxy
   * @param password the password to be used to validate against the proxy
   */
  public Proxy(@Nonnull String type, @Nonnull String host, int port, @Nullable String user, @Nullable String password) {
    this.delegate = new LSProxy(type, host, port, user, password);
  }
  
  @Override
  public String toString() {
    return delegate.toString();
  }
  
  @Override
  public boolean equals(Object obj) {
    if (obj != null && obj instanceof Proxy) {
      Proxy _obj = (Proxy)obj;
      return delegate.isEqualTo(_obj.delegate);
    }
    return false;
  }
  
  @Override 
  public int hashCode() {
    return java.util.Objects.hash(delegate.host, delegate.type, delegate.port, delegate.user, delegate.password);
  }
}
