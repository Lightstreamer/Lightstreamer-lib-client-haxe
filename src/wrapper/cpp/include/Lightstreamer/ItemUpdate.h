#ifndef INCLUDED_Lightstreamer_ItemUpdate
#define INCLUDED_Lightstreamer_ItemUpdate

#include "../Lightstreamer.h"

namespace Lightstreamer {

class ItemUpdate {
  HaxeObject _delegate;
public:
  ItemUpdate() = delete;
  ItemUpdate(const ItemUpdate&) = delete;
  ItemUpdate& operator=(const ItemUpdate&) = delete;

  explicit ItemUpdate(HaxeObject hxObj) : _delegate(hxObj) {}

  ~ItemUpdate() {
    Lightstreamer_releaseHaxeObject(_delegate);
  }

  std::string getItemName() {
    return ItemUpdate_getItemName(_delegate);
  }

  int getItemPos() {
    return ItemUpdate_getItemPos(_delegate);
  }

  std::string getValue(const std::string& fieldName) {
    return ItemUpdate_getValueByName(_delegate, &fieldName);
  }

  std::string getValue(int fieldPos) {
    return ItemUpdate_getValueByPos(_delegate, fieldPos);
  }

  bool isNull(const std::string& fieldName) {
    return ItemUpdate_isNullByName(_delegate, &fieldName);
  }

  bool isNull(int fieldPos) {
    return ItemUpdate_isNullByPos(_delegate, fieldPos);
  }

  bool isSnapshot() {
    return ItemUpdate_isSnapshot(_delegate);
  }

  bool isValueChanged(const std::string& fieldName) {
    return ItemUpdate_isValueChangedByName(_delegate, &fieldName);
  }

  bool isValueChanged(int fieldPos) {
    return ItemUpdate_isValueChangedByPos(_delegate, fieldPos);
  }

  std::map<std::string, std::string> getChangedFields() {
    return ItemUpdate_getChangedFields(_delegate);
  }

  std::map<int, std::string> getChangedFieldsByPosition() {
    return ItemUpdate_getChangedFieldsByPosition(_delegate);
  }

  std::map<std::string, std::string> getFields() {
    return ItemUpdate_getFields(_delegate);
  }

  std::map<int, std::string> getFieldsByPosition() {
    return ItemUpdate_getFieldsByPosition(_delegate);
  }
};

} // namespace Lightstreamer


#endif // INCLUDED_Lightstreamer_ItemUpdate