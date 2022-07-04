package com.lightstreamer.client;

#if (java || cs || python)
/**
 * Simple class representing a Proxy configuration. <BR>
 * 
 * An instance of this class can be used through `ConnectionOptions.setProxy(Proxy)` to
 * instruct a LightstreamerClient to connect to the Lightstreamer Server passing through a proxy.
 */
class Proxy {
  #if (java || cs)
  /**
   * This constructor will call `this.Proxy(String, String, int, String, String)`
   * specifying null user and null password.
   * @param type the proxy type
   * @param host the proxy host
   * @param port the proxy port
   */
  overload public function new(type: String, host: String, port: Int) {}
  /**
   * This constructor will call `this.Proxy(String, String, int, String, String)`
   * specifying a null null password.
   * @param type the proxy type
   * @param host the proxy host
   * @param port the proxy port
   * @param user the user name to be used to validate against the proxy
   */
  overload public function new(type: String, host: String, port: Int, user: String) {}

  #if android
  /**
   * Creates a Proxy instance containing all the information required by the `LightstreamerClient`
   * to connect to a Lightstreamer server passing through a proxy. <BR>
   * Once created the Proxy instance has to be passed to the `LightstreamerClient.connectionOptions`
   * instance using the `ConnectionOptions.setProxy(Proxy)` method.
   * 
   * <BR><BR>
   * Note: user and password are ignored. If authentication is required by the proxy in use
   * it is necessary to replace the default java `java.net.Authenticator` with a custom one containing 
   * the necessary logic to authenticate the user against the proxy.  
   *
   * @param type the proxy type
   * @param host the proxy host
   * @param port the proxy port
   * @param user the user name to be used to validate against the proxy
   * @param password the password to be used to validate against the proxy
   */
  #else
  /**
   * Creates a Proxy instance containing all the information required by the `LightstreamerClient`
   * to connect to a Lightstreamer server passing through a proxy. <BR>
   * Once created the Proxy instance has to be passed to the `LightstreamerClient.connectionOptions`
   * instance using the `ConnectionOptions.setProxy(Proxy)` method.
   * 
   * @param type the proxy type
   * @param host the proxy host
   * @param port the proxy port
   * @param user the user name to be used to validate against the proxy
   * @param password the password to be used to validate against the proxy
   */
  #end
  overload public function new(type: String, host: String, port: Int, user: String, password: String) {}
  #end

  #if python
  /**
   * Creates a Proxy instance containing all the information required by the `LightstreamerClient`
   * to connect to a Lightstreamer server passing through a proxy. <BR>
   * Once created the Proxy instance has to be passed to the `LightstreamerClient.connectionOptions`
   * instance using the `ConnectionOptions.setProxy(Proxy)` method.
   * 
   * @param type the proxy type
   * @param host the proxy host
   * @param port the proxy port
   * @param user the user name to be used to validate against the proxy
   * @param password the password to be used to validate against the proxy
   */
  public function new(type: String, host: String, port: Int, user: Null<String>, password: Null<String>) {}
  #end
}
#end