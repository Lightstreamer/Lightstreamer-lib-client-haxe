#ifndef INCLUDED_Lightstreamer_Proxy
#define INCLUDED_Lightstreamer_Proxy

#include <string>

namespace Lightstreamer {

struct Proxy {
  std::string type;
  std::string host;
  int port;
  std::string user;
  std::string password;

  Proxy(const std::string& type, const std::string& host, int port, const std::string& user = "", const std::string& password = "") :
    type(type), host(host), port(port), user(user), password(password) {}
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Proxy