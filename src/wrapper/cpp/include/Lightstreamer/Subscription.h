#ifndef INCLUDED_Lightstreamer_Subscription
#define INCLUDED_Lightstreamer_Subscription

#include "../Lightstreamer.h"

namespace Lightstreamer {

class Subscription {
  friend class LightstreamerClient;
  HaxeObject _delegate;
public:
  Subscription() = delete;
  Subscription(const Subscription&) = delete;
  Subscription& operator=(const Subscription&) = delete;

  Subscription(const std::string& mode, const std::vector<std::string>& items, const std::vector<std::string>& fields) {
    _delegate = Subscription_new(&mode, &items, &fields, this);
  }

  ~Subscription() {
    Lightstreamer_releaseHaxeObject(_delegate);
  }

  void addListener(SubscriptionListener* listener) {
    Subscription_addListener(_delegate, listener);
  }

  void removeListener(SubscriptionListener* listener) {
    Subscription_removeListener(_delegate, listener);
  }

  std::vector<SubscriptionListener*> getListeners() {
    return Subscription_getListeners(_delegate);
  }

  bool isActive() {
    return Subscription_isActive(_delegate);
  }

  bool isSubscribed() {
    return Subscription_isSubscribed(_delegate);
  }

  // std::string getDataAdapter();
  void setDataAdapter(const std::string& dataAdapter) {
    Subscription_setDataAdapter(_delegate, &dataAdapter);
  }
  // std::string getMode();
  // std::vector<std::string> getItems();
  // void setItems(const std::vector<std::string>& items);
  // std::string getItemGroup();
  // void setItemGroup(const std::string& group);
  // std::vector<std::string> getFields();
  // void setFields(const std::vector<std::string>& fields);
  // std::string getFieldSchema();
  // void setFieldSchema(const std::string& schema);
  // std::string getRequestedBufferSize();
  // void setRequestedBufferSize(const std::string& size);
  // std::string getRequestedSnapshot();
  // void setRequestedSnapshot(const std::string& required);
  // std::string getRequestedMaxFrequency();
  // void setRequestedMaxFrequency(const std::string& frequency);
  // std::string getSelector();
  // void setSelector(const std::string& selector);
  
  int getCommandPosition() {
    return Subscription_getCommandPosition(_delegate);
  }

  int getKeyPosition() {
    return Subscription_getKeyPosition(_delegate);
  }

  // std::string getCommandSecondLevelAdapter();
  
  void setCommandSecondLevelDataAdapter(const std::string& dataAdapter) {
    Subscription_setCommandSecondLevelDataAdapter(_delegate, &dataAdapter);
  }

  // std::vector<std::string> getCommandSecondLevelFields();

  void setCommandSecondLevelFields(const std::vector<std::string>& fields) {
    Subscription_setCommandSecondLevelFields(_delegate, &fields);
  }

  // std::string getCommandSecondLevelFieldSchema();
  // void setCommandSecondLevelFieldSchema(const std::string& schema);
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Subscription