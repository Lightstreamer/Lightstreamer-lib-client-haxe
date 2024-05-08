#ifndef INCLUDED_Lightstreamer_Value
#define INCLUDED_Lightstreamer_Value

#include <string>

namespace Lightstreamer {

class Value: public std::string {
  bool _null = false;
public:
  Value() = delete;
  Value(const Value&) = delete;
  Value& operator=(const Value&) = delete;

  Value(const char* s) : std::string(s) {}
  Value(std::nullptr_t) : _null(true) {}
  bool null() const { return _null; }
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Value