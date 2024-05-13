#ifndef INCLUDED_Lightstreamer_LoggerProvider
#define INCLUDED_Lightstreamer_LoggerProvider

#include "Lightstreamer/Logger.h"
#include <string>

namespace Lightstreamer {

class LoggerProvider {
public:
  virtual ~LoggerProvider() {};
  virtual Logger* getLogger(const std::string& category) = 0;
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_LoggerProvider