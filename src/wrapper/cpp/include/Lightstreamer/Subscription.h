#ifndef INCLUDED_Lightstreamer_Subscription
#define INCLUDED_Lightstreamer_Subscription

#include "../Lightstreamer.h"

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
  void setCommandSecondLevelDataAdapter(const std::string& dataAdapter);
  void setCommandSecondLevelFields(const std::vector<std::string>& fields);
  int getKeyPosition();
  int getCommandPosition();
};

inline Subscription::Subscription(const std::string& mode, const std::vector<std::string>& items, const std::vector<std::string>& fields) {
  _delegate = Subscription_new(mode.c_str(), &const_cast<std::vector<std::string>&>(items), &const_cast<std::vector<std::string>&>(fields), this);
}

inline Subscription::~Subscription() {
  Lightstreamer_releaseHaxeObject(_delegate);
}

inline void Subscription::addListener(SubscriptionListener* listener) {
  Subscription_addListener(_delegate, listener);
}

inline void Subscription::removeListener(SubscriptionListener* listener) {
  Subscription_removeListener(_delegate, listener);
}

inline std::vector<SubscriptionListener*> Subscription::getListeners() {
  return Subscription_getListeners(_delegate);
}

inline bool Subscription::isSubscribed() {
  return Subscription_isSubscribed(_delegate);
}

inline void Subscription::setDataAdapter(const std::string& dataAdapter) {
  Subscription_setDataAdapter(_delegate, dataAdapter.c_str());
}

inline void Subscription::setCommandSecondLevelDataAdapter(const std::string& dataAdapter) {
  Subscription_setCommandSecondLevelDataAdapter(_delegate, dataAdapter.c_str());
}

inline void Subscription::setCommandSecondLevelFields(const std::vector<std::string>& fields) {
  Subscription_setCommandSecondLevelFields(_delegate, &fields);
}

inline int Subscription::getKeyPosition() {
  return Subscription_getKeyPosition(_delegate);
}

inline int Subscription::getCommandPosition() {
  return Subscription_getCommandPosition(_delegate);
}

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Subscription