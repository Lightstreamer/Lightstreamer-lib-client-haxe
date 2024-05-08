#ifndef INCLUDED_Lightstreamer_ItemUpdate
#define INCLUDED_Lightstreamer_ItemUpdate

#include "../Lightstreamer.h"
#include "Lightstreamer/Value.h"

namespace Lightstreamer {

class ItemUpdate {
  HaxeObject _delegate;
public:
  ItemUpdate& operator=(const ItemUpdate&) = delete;
  ItemUpdate(const ItemUpdate&) = delete;
  ItemUpdate() = delete;
  explicit ItemUpdate(void* hxObj);
  ~ItemUpdate();
  int getItemPos();
  Value getValue(const std::string& fieldName);
};

inline ItemUpdate::ItemUpdate(HaxeObject hxObj) : _delegate(hxObj) {}

inline ItemUpdate::~ItemUpdate() {
  Lightstreamer_releaseHaxeObject(_delegate);
}

inline int ItemUpdate::getItemPos() {
  return ItemUpdate_getItemPos(_delegate);
}

inline Value ItemUpdate::getValue(const std::string& fieldName) {
  HaxeString v = ItemUpdate_getValueByName(_delegate, fieldName.c_str());
  if (v == nullptr) {
    return Value(nullptr);
  } else {
    Value res(v);
    Lightstreamer_releaseHaxeString(v);
    return res;
  }
}

} // namespace Lightstreamer


#endif // INCLUDED_Lightstreamer_ItemUpdate