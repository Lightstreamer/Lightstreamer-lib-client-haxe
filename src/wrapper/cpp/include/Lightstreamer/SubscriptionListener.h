#ifndef INCLUDED_Lightstreamer_SubscriptionListener
#define INCLUDED_Lightstreamer_SubscriptionListener

#include "Lightstreamer/ItemUpdate.h"
#include <string>

namespace Lightstreamer {

class SubscriptionListener {
public:
  virtual ~SubscriptionListener() {}
  virtual void onClearSnapshot(const std::string& itemName, int itemPos) {}
  virtual void onCommandSecondLevelItemLostUpdates(int lostUpdates, const std::string& key) {}
  virtual void onCommandSecondLevelSubscriptionError(int code, const std::string& message, const std::string& key) {}
  virtual void onEndOfSnapshot(const std::string& itemName, int itemPos) {}
  virtual void onItemLostUpdates(const std::string& itemName, int itemPos, int lostUpdates) {}
  virtual void onItemUpdate(ItemUpdate& update) {}
  virtual void onListenEnd() {}
  virtual void onListenStart() {}
  virtual void onSubscription() {}
  virtual void onSubscriptionError(int code, const std::string& message) {}
  virtual void onUnsubscription() {}
  virtual void onRealMaxFrequency(const std::string& frequency) {}
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_SubscriptionListener