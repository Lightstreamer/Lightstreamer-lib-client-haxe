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

namespace com.lightstreamer.client
{
    /// <summary>
    /// Simple class representing a Proxy configuration. <br/>
    /// 
    /// An instance of this class can be used through <seealso cref="ConnectionOptions.Proxy"/> to
    /// instruct a LightstreamerClient to connect to the Lightstreamer Server passing through a proxy.
    /// </summary>
    public class Proxy
    {
       internal readonly LSProxy _delegate;

        /// <summary>
        /// This constructor will call <seealso cref="Proxy(string, string, int, string, string)"/>
        /// specifying null user and null password. </summary>
        /// <param name="type"> the proxy type. Supported values are HTTP, SOCKS4 and SOCKS5. </param>
        /// <param name="host"> the proxy host </param>
        /// <param name="port"> the proxy port </param>
        public Proxy(string type, string host, int port)
        {
            this._delegate = new LSProxy(type, host, port);
        }

        /// <summary>
        /// This constructor will call <seealso cref="Proxy(string, string, int, string, string)"/>
        /// specifying a null password. </summary>
        /// <param name="type"> the proxy type. Supported values are HTTP, SOCKS4 and SOCKS5. </param>
        /// <param name="host"> the proxy host </param>
        /// <param name="port"> the proxy port </param>
        /// <param name="user"> the user name to be used to validate against the proxy </param>
        public Proxy(string type, string host, int port, string user)
        {
            this._delegate = new LSProxy(type, host, port, user);
        }

        /// <summary>
        /// Creates a Proxy instance containing all the informations required by the <seealso cref="LightstreamerClient"/>
        /// to connect to a Lightstreamer server passing through a proxy. <br/>
        /// Once created the Proxy instance has to be passed to the <seealso cref="LightstreamerClient.connectionOptions"/>
        /// instance using the <seealso cref="ConnectionOptions.Proxy"/> method.
        /// </summary>
        /// <param name="type"> the proxy type. Supported values are HTTP, SOCKS4 and SOCKS5. </param>
        /// <param name="host"> the proxy host </param>
        /// <param name="port"> the proxy port </param>
        /// <param name="user"> the user name to be used to validate against the proxy </param>
        /// <param name="password"> the password to be used to validate against the proxy </param>
        public Proxy(string type, string host, int port, string user, string password)
        {
            this._delegate = new LSProxy(type, host, port, user, password);
        }

        /// <inheritdoc/>
        public override string ToString()
        {
            return _delegate.toString();
        }

        /// <inheritdoc/>
        public override bool Equals(object obj)
        {
            var proxy = obj as Proxy;
            return proxy != null && _delegate.isEqualTo(proxy._delegate);
        }

        /// <inheritdoc/>
        public override int GetHashCode()
        {
            return System.HashCode.Combine(_delegate.type, _delegate.host, _delegate.port, _delegate.user, _delegate.password);
        }
    }
}