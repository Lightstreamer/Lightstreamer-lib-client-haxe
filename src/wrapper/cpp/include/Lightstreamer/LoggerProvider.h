#ifndef INCLUDED_Lightstreamer_LoggerProvider
#define INCLUDED_Lightstreamer_LoggerProvider

#include "Lightstreamer/Logger.h"
#include <string>

namespace Lightstreamer {

/** 
 * Simple interface to be implemented to provide custom log consumers to the library. <BR>
 * An instance of the custom implemented class has to be passed to the library through the 
 * {@link LightstreamerClient#setLoggerProvider}.
 */
class LoggerProvider {
public:
  virtual ~LoggerProvider() {};
  /** 
   * Request for a Logger instance that will be used for logging occurring on the given 
   * category. It is suggested, but not mandatory, that subsequent calls to this method
   * related to the same category return the same Logger instance.
   * 
   * @param category the log category all messages passed to the given Logger instance will pertain to.
   * 
   * @return A Logger instance that will receive log lines related to the given category.
   * 
   */
  virtual Logger* getLogger(const std::string& category) = 0;
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_LoggerProvider