#ifndef INCLUDED_Lightstreamer_LightstreamerClient
#define INCLUDED_Lightstreamer_LightstreamerClient

#include "../Lightstreamer.h"
#include "Lightstreamer/LoggerProvider.h"
#include "Lightstreamer/Subscription.h"
#include <string>

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

std::string LightstreamerClient::libName() {
  return LightstreamerClient_getLibName();
}

std::string LightstreamerClient::libVersion() {
  return LightstreamerClient_getLibVersion();
}

LightstreamerClient::LightstreamerClient(const std::string& serverAddress, const std::string& adapterSet) {
  _client = LightstreamerClient_new(serverAddress.c_str(), adapterSet.c_str());
}

LightstreamerClient::~LightstreamerClient() {
  LightstreamerClient_disconnect(_client);
  Lightstreamer_releaseHaxeObject(_client);
}

void LightstreamerClient::addListener(ClientListener* listener) {
  LightstreamerClient_addListener(_client, listener);
}

void LightstreamerClient::removeListener(ClientListener* listener) {
  LightstreamerClient_removeListener(_client, listener);
}

std::vector<ClientListener*> LightstreamerClient::getListeners() {
  return LightstreamerClient_getListeners(_client);
}

std::string LightstreamerClient::getStatus() {
  HaxeString status = LightstreamerClient_getStatus(_client);
  std::string res(status);
  Lightstreamer_releaseHaxeString(status);
  return res;
}

void LightstreamerClient::connect() {
  LightstreamerClient_connect(_client);
}

void LightstreamerClient::disconnect() {
  LightstreamerClient_disconnect(_client);
}

void LightstreamerClient::subscribe(Subscription* subscription) {
  LightstreamerClient_subscribe(_client, subscription->_delegate);
}

void LightstreamerClient::unsubscribe(Subscription* subscription) {
  LightstreamerClient_unsubscribe(_client, subscription->_delegate);
}

std::vector<Subscription*> LightstreamerClient::getSubscriptions() {
  auto xs = LightstreamerClient_getSubscriptions(_client);
  std::vector<Subscription*> res;
  // TODO 1 avoid cast
  for (auto s : xs) {
    res.push_back(static_cast<Subscription*>(s));
  }
  return res;
}

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_LightstreamerClient