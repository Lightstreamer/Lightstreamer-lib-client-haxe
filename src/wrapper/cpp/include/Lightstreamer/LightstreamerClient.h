#ifndef INCLUDED_Lightstreamer_LightstreamerClient
#define INCLUDED_Lightstreamer_LightstreamerClient

#include "../Lightstreamer.h"
#include <string>

namespace Lightstreamer {

class LightstreamerClient {
  HaxeObject _client;
public:
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
};

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
  auto ls = LightstreamerClient_getListeners(_client);
  return ls.v;
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

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_LightstreamerClient