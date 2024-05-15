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

  std::string getDataAdapter() {
    return Subscription_getDataAdapter(_delegate);
  }

  void setDataAdapter(const std::string& dataAdapter) {
    Subscription_setDataAdapter(_delegate, &dataAdapter);
  }

  std::string getMode() {
    return Subscription_getMode(_delegate);
  }

  std::vector<std::string> getItems() {
    return Subscription_getItems(_delegate);
  }

  void setItems(const std::vector<std::string>& items) {
    Subscription_setItems(_delegate, &items);
  }

  std::string getItemGroup() {
    return Subscription_getItemGroup(_delegate);
  }

  void setItemGroup(const std::string& group) {
    Subscription_setItemGroup(_delegate, &group);
  }

  std::vector<std::string> getFields() {
    return Subscription_getFields(_delegate);
  }

  void setFields(const std::vector<std::string>& fields) {
    Subscription_setFields(_delegate, &fields);
  }

  std::string getFieldSchema() {
    return Subscription_getFieldSchema(_delegate);
  }

  void setFieldSchema(const std::string& schema) {
    Subscription_setFieldSchema(_delegate, &schema);
  }

  std::string getRequestedBufferSize() {
    return Subscription_getRequestedBufferSize(_delegate);
  }

  void setRequestedBufferSize(const std::string& size) {
    Subscription_setRequestedBufferSize(_delegate, &size);
  }

  std::string getRequestedSnapshot() {
    return Subscription_getRequestedSnapshot(_delegate);
  }

  void setRequestedSnapshot(const std::string& snapshot) {
    Subscription_setRequestedSnapshot(_delegate, &snapshot);
  }

  std::string getRequestedMaxFrequency() {
    return Subscription_getRequestedMaxFrequency(_delegate);
  }

  void setRequestedMaxFrequency(const std::string& frequency) {
    Subscription_setRequestedMaxFrequency(_delegate, &frequency);
  }

  std::string getSelector() {
    return Subscription_getSelector(_delegate);
  }

  void setSelector(const std::string& selector) {
    Subscription_setSelector(_delegate, &selector);
  }
  
  int getCommandPosition() {
    return Subscription_getCommandPosition(_delegate);
  }

  int getKeyPosition() {
    return Subscription_getKeyPosition(_delegate);
  }

  std::string getCommandSecondLevelDataAdapter() {
    return Subscription_getCommandSecondLevelAdapter(_delegate);
  }
  
  void setCommandSecondLevelDataAdapter(const std::string& dataAdapter) {
    Subscription_setCommandSecondLevelDataAdapter(_delegate, &dataAdapter);
  }

  std::vector<std::string> getCommandSecondLevelFields() {
    return Subscription_getCommandSecondLevelFields(_delegate);
  }

  void setCommandSecondLevelFields(const std::vector<std::string>& fields) {
    Subscription_setCommandSecondLevelFields(_delegate, &fields);
  }

  std::string getCommandSecondLevelFieldSchema() {
    return Subscription_getCommandSecondLevelFieldSchema(_delegate);
  }

  void setCommandSecondLevelFieldSchema(const std::string& schema) {
    Subscription_setCommandSecondLevelFieldSchema(_delegate, &schema);
  }

  std::string getValue(const std::string& itemName, const std::string& fieldName) {
    return Subscription_getValueSS(_delegate, &itemName, &fieldName);
  }

  std::string getValue(int itemPos, int fieldPos) {
    return Subscription_getValueII(_delegate, itemPos, fieldPos);
  }

  std::string getValue(const std::string& itemName, int fieldPos) {
    return Subscription_getValueSI(_delegate, &itemName, fieldPos);
  }

  std::string getValue(int itemPos, const std::string& fieldName) {
    return Subscription_getValueIS(_delegate, itemPos, &fieldName);
  }

  std::string getCommandValue(const std::string& itemName, const std::string& keyValue, const std::string& fieldName) {
    return Subscription_getCommandValueSS(_delegate, &itemName, &keyValue, &fieldName);
  }

  std::string getCommandValue(int itemPos, const std::string& keyValue, int fieldPos) {
    return Subscription_getCommandValueII(_delegate, itemPos, &keyValue, fieldPos);
  }

  std::string getCommandValue(const std::string& itemName, const std::string& keyValue, int fieldPos) {
    return Subscription_getCommandValueSI(_delegate, &itemName, &keyValue, fieldPos);
  }

  std::string getCommandValue(int itemPos, const std::string& keyValue, const std::string& fieldName) {
    return Subscription_getCommandValueIS(_delegate, itemPos, &keyValue, &fieldName);
  }
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Subscription