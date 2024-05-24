#ifndef INCLUDED_Lightstreamer_Proxy
#define INCLUDED_Lightstreamer_Proxy

#include <string>

namespace Lightstreamer {

/**
 * Simple class representing a Proxy configuration. <BR>
 * 
 * An instance of this class can be used through {@link ConnectionOptions#setProxy()} to
 * instruct a LightstreamerClient to connect to the Lightstreamer Server passing through a proxy.
 */
struct Proxy {
  /// @brief the proxy type
  std::string type;
  /// @brief the proxy host
  std::string host;
  /// @brief the proxy port
  int port;
  /// @brief the proxy user name
  std::string user;
  /// @brief the proxy password
  std::string password;

  /**
   * Creates a Proxy instance containing all the information required by the {@link LightstreamerClient}
   * to connect to a Lightstreamer server passing through a proxy. <BR>
   * Once created the Proxy instance has to be passed to the {@link LightstreamerClient#connectionOptions}
   * instance using the {@link ConnectionOptions#setProxy()} method.
   * 
   * @param type the proxy type. The only supported value is HTTP.
   * @param host the proxy host
   * @param port the proxy port
   * @param user the user name to be used to validate against the proxy
   * @param password the password to be used to validate against the proxy
   */
  Proxy(const std::string& type, const std::string& host, int port, const std::string& user = "", const std::string& password = "") :
    type(type), host(host), port(port), user(user), password(password) {}
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Proxy