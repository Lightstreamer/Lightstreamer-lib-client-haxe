#ifndef INCLUDED_Lightstreamer_LightstreamerClient
#define INCLUDED_Lightstreamer_LightstreamerClient

#include "../Lightstreamer.h"
#include "Lightstreamer/LoggerProvider.h"
#include "Lightstreamer/Subscription.h"

namespace Lightstreamer {

class LightstreamerClient {
  HaxeObject _client;
public:
  static std::string libName();
  static std::string libVersion();
  LightstreamerClient& operator=(const LightstreamerClient&) = delete;
  LightstreamerClient(const LightstreamerClient&) = delete;
  LightstreamerClient() = delete;
  LightstreamerClient(const std::string& serverAddress, const std::string& adapterSet);
  ~LightstreamerClient();
  void addListener(ClientListener* listener);
  void removeListener(ClientListener* listener);
  std::vector<ClientListener*> getListeners();
  std::string getStatus();
  void connect();
  void disconnect();
  void subscribe(Subscription* subscription);
  void unsubscribe(Subscription* subscription);
  std::vector<Subscription*> getSubscriptions();
};

inline std::string LightstreamerClient::libName() {
  return LightstreamerClient_getLibName();
}

inline std::string LightstreamerClient::libVersion() {
  return LightstreamerClient_getLibVersion();
}

inline LightstreamerClient::LightstreamerClient(const std::string& serverAddress, const std::string& adapterSet) {
  _client = LightstreamerClient_new(serverAddress.c_str(), adapterSet.c_str());
}

inline LightstreamerClient::~LightstreamerClient() {
  LightstreamerClient_disconnect(_client);
  Lightstreamer_releaseHaxeObject(_client);
}

inline void LightstreamerClient::addListener(ClientListener* listener) {
  LightstreamerClient_addListener(_client, listener);
}

inline void LightstreamerClient::removeListener(ClientListener* listener) {
  LightstreamerClient_removeListener(_client, listener);
}

inline std::vector<ClientListener*> LightstreamerClient::getListeners() {
  return LightstreamerClient_getListeners(_client);
}

inline std::string LightstreamerClient::getStatus() {
  HaxeString status = LightstreamerClient_getStatus(_client);
  std::string res(status);
  Lightstreamer_releaseHaxeString(status);
  return res;
}

inline void LightstreamerClient::connect() {
  LightstreamerClient_connect(_client);
}

inline void LightstreamerClient::disconnect() {
  LightstreamerClient_disconnect(_client);
}

inline void LightstreamerClient::subscribe(Subscription* subscription) {
  LightstreamerClient_subscribe(_client, subscription->_delegate);
}

inline void LightstreamerClient::unsubscribe(Subscription* subscription) {
  LightstreamerClient_unsubscribe(_client, subscription->_delegate);
}

inline std::vector<Subscription*> LightstreamerClient::getSubscriptions() {
  return LightstreamerClient_getSubscriptions(_client);
}

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_LightstreamerClient