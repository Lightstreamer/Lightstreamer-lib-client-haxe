#ifndef INCLUDED_Lightstreamer_ConsoleLoggerProvider
#define INCLUDED_Lightstreamer_ConsoleLoggerProvider

#include "Lightstreamer/LoggerProvider.h"
#include <map>
#include <memory>

namespace Lightstreamer {

enum class ConsoleLogLevel {
  TRACE = 0,
  DEBUG = 10,
  INFO = 20,
  WARN = 30,
  ERROR = 40,
  FATAL = 50
};

// TODO cpp add macro for visibility
class __attribute__((visibility("default"))) ConsoleLoggerProvider: public LoggerProvider {
  ConsoleLogLevel _level;
  std::map<std::string, std::unique_ptr<Logger>> _loggers;
public:
  ConsoleLoggerProvider(ConsoleLogLevel level) : _level(level) {}

  Logger* getLogger(const std::string& category) override;
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_ConsoleLoggerProvider