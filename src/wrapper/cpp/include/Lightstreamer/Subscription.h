#ifndef INCLUDED_Lightstreamer_Subscription
#define INCLUDED_Lightstreamer_Subscription

#include "../Lightstreamer.h"
#include <string>

namespace Lightstreamer {

class Subscription {
  friend class LightstreamerClient;
  HaxeObject _delegate;
public:
  Subscription(const std::string& mode, const std::vector<std::string>& items, const std::vector<std::string>& fields);
  Subscription& operator=(const Subscription&) = delete;
  Subscription(const Subscription&) = delete;
  Subscription() = delete;
  ~Subscription();
  void addListener(SubscriptionListener* listener);
  void removeListener(SubscriptionListener* listener);
  std::vector<SubscriptionListener*> getListeners();
  bool isSubscribed();
  void setDataAdapter(const std::string& dataAdapter);
};

Subscription::Subscription(const std::string& mode, const std::vector<std::string>& items, const std::vector<std::string>& fields) {
  _delegate = Subscription_new(mode.c_str(), &const_cast<std::vector<std::string>&>(items), &const_cast<std::vector<std::string>&>(fields), this);
}

Subscription::~Subscription() {
  Lightstreamer_releaseHaxeObject(_delegate);
}

void Subscription::addListener(SubscriptionListener* listener) {
  Subscription_addListener(_delegate, listener);
}

void Subscription::removeListener(SubscriptionListener* listener) {
  Subscription_removeListener(_delegate, listener);
}

std::vector<SubscriptionListener*> Subscription::getListeners() {
  return Subscription_getListeners(_delegate);
}

bool Subscription::isSubscribed() {
  return Subscription_isSubscribed(_delegate);
}

void Subscription::setDataAdapter(const std::string& dataAdapter) {
  Subscription_setDataAdapter(_delegate, dataAdapter.c_str());
}

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Subscription