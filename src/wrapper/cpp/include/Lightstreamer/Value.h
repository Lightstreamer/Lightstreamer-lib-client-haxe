#ifndef INCLUDED_Lightstreamer_Value
#define INCLUDED_Lightstreamer_Value

#include <string>

namespace Lightstreamer {

class Value: public std::string {
  bool _null = false;
public:
  Value() = delete;

  Value(const char* s) : std::string(s) {}
  Value(std::nullptr_t) : _null(true) {}
  Value(const Value& other) : std::string(other), _null(other._null) {}
  Value& operator=(const Value& other) {
    if (&other == this) { 
      return *this; 
    }
    std::string::operator=(other);
    _null = other._null;
    return *this;
  }
  bool null() const { return _null; }
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Value