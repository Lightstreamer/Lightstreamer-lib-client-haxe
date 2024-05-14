#ifndef INCLUDED_Lightstreamer_LightstreamerError
#define INCLUDED_Lightstreamer_LightstreamerError

#include <string>

namespace Lightstreamer {

class LightstreamerError : public std::runtime_error {
public:
  LightstreamerError(const std::string& message) : runtime_error(message) {}
};

} // namespace Lightstreamer

#endif