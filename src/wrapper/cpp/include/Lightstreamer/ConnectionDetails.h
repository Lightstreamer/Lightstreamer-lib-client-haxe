#ifndef INCLUDED_Lightstreamer_ConnectionDetails
#define INCLUDED_Lightstreamer_ConnectionDetails

#include "../Lightstreamer.h"

namespace Lightstreamer {

class ConnectionDetails {
  HaxeObject _delegate = nullptr;

  void initDelegate(HaxeObject client) {
    _delegate = LightstreamerClient_getConnectionDetails(client);
  }

  friend class LightstreamerClient;
public:
  ConnectionDetails(const ConnectionDetails&) = delete;
  ConnectionDetails& operator=(const ConnectionDetails&) = delete;

  ConnectionDetails() {}

  ~ConnectionDetails() {
    Lightstreamer_releaseHaxeObject(_delegate);
  }

  std::string getAdapterSet() {
    return ConnectionDetails_getAdapterSet(_delegate);
  }

  void setAdapterSet(const std::string& adapterSet) {
    ConnectionDetails_setAdapterSet(_delegate, &adapterSet);
  }

  std::string getServerAddress() {
    return ConnectionDetails_getServerAddress(_delegate);
  }

  void setServerAddress(const std::string& serverAddress) {
    ConnectionDetails_setServerAddress(_delegate, &serverAddress);
  }

  std::string getUser() {
    return ConnectionDetails_getUser(_delegate);
  }

  void setUser(const std::string& user) {
    ConnectionDetails_setUser(_delegate, &user);
  }

  std::string getServerInstanceAddress() {
    return ConnectionDetails_getServerInstanceAddress(_delegate);
  }

  std::string getServerSocketName() {
    return ConnectionDetails_getServerSocketName(_delegate);
  }

  std::string getClientIp() {
    return ConnectionDetails_getClientIp(_delegate);
  }

  std::string getSessionId() {
    return ConnectionDetails_getSessionId(_delegate);
  }

  void setPassword(const std::string& password) {
    ConnectionDetails_setPassword(_delegate, &password);
  }
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_ConnectionDetails