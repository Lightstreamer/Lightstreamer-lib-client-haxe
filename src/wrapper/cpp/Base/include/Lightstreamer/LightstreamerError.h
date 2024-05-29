#ifndef INCLUDED_Lightstreamer_LightstreamerError
#define INCLUDED_Lightstreamer_LightstreamerError

#include <string>

namespace Lightstreamer {

/**
 * The LightstreamerError class provides a base class for exceptions thrown by the library.
 */
class LightstreamerError : public std::runtime_error {
public:
  /**
   * Constructs a LightstreamerError object carrying the given message.
   */
  LightstreamerError(const std::string& message) : runtime_error(message) {}
};

} // namespace Lightstreamer

#endif