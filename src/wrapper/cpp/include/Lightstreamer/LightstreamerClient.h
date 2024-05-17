#ifndef INCLUDED_Lightstreamer_LightstreamerClient
#define INCLUDED_Lightstreamer_LightstreamerClient

#include "../Lightstreamer.h"
#include "Lightstreamer/LoggerProvider.h"
#include "Lightstreamer/Subscription.h"
#include "Lightstreamer/ConnectionDetails.h"

namespace Lightstreamer {

class LightstreamerClient {
  HaxeObject _client;
public:
  LightstreamerClient() = delete;
  LightstreamerClient(const LightstreamerClient&) = delete;
  LightstreamerClient& operator=(const LightstreamerClient&) = delete;

  ConnectionDetails connectionDetails;

  static std::string libName() {
    return LightstreamerClient_getLibName();
  }

  static std::string libVersion() {
    return LightstreamerClient_getLibVersion();
  }

  LightstreamerClient(const std::string& serverAddress, const std::string& adapterSet) {
    _client = LightstreamerClient_new(&serverAddress, &adapterSet);
    connectionDetails.initDelegate(_client);
  }

  ~LightstreamerClient() {
    LightstreamerClient_disconnect(_client);
    Lightstreamer_releaseHaxeObject(_client);
  }

  void addListener(ClientListener* listener) {
    LightstreamerClient_addListener(_client, listener);
  }

  void removeListener(ClientListener* listener) {
    LightstreamerClient_removeListener(_client, listener);
  }

  std::vector<ClientListener*> getListeners() {
    return LightstreamerClient_getListeners(_client);
  }

  std::string getStatus() {
    return LightstreamerClient_getStatus(_client);
  }

  void connect() {
    LightstreamerClient_connect(_client);
  }

  void disconnect() {
    LightstreamerClient_disconnect(_client);
  }

  void subscribe(Subscription* subscription) {
    LightstreamerClient_subscribe(_client, subscription->_delegate);
  }

  void unsubscribe(Subscription* subscription) {
    LightstreamerClient_unsubscribe(_client, subscription->_delegate);
  }

  std::vector<Subscription*> getSubscriptions() {
    return LightstreamerClient_getSubscriptions(_client);
  }

  void sendMessage(const std::string& message, const std::string& sequence = "", int delayTimeout = -1, ClientMessageListener* listener = nullptr, bool enqueueWhileDisconnected = false) {
    LightstreamerClient_sendMessage(_client, &message, &sequence, delayTimeout, listener, enqueueWhileDisconnected);
  }
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_LightstreamerClient