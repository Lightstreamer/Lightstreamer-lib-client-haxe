#ifndef INCLUDED_Lightstreamer_ConsoleLoggerProvider
#define INCLUDED_Lightstreamer_ConsoleLoggerProvider

#include "Lightstreamer/LoggerProvider.h"
#include <map>
#include <memory>

/** @file */

// TODO cpp use HXCPP_EXTERN_CLASS_ATTRIBUTES?
#ifdef _MSC_VER
#define LS_PUBLIC_API
#else
#define LS_PUBLIC_API __attribute__((visibility("default")))
#endif

namespace Lightstreamer {

/**
 Logging level.
 */
enum class ConsoleLogLevel {
  /**
    Trace logging level.
   
    This level enables all logging.
   */
  Trace = 0,
  /**
    Debug logging level.
     
    This level enables all logging except tracing.
   */
  Debug = 10,
  /**
    Info logging level.
     
    This level enables logging for information, warnings, errors and fatal errors.
   */
  Info = 20,
  /**
    Warn logging level.
     
    This level enables logging for warnings, errors and fatal errors.
   */
  Warn = 30,
  /**
    Error logging level.
     
    This level enables logging for errors and fatal errors.
   */
  Error = 40,
  /**
    Fatal logging level.
     
    This level enables logging for fatal errors only.
   */
  Fatal = 50
};

/**
  Simple concrete logging provider that logs on the system console.
 
  To be used, an instance of this class has to be passed to the library through the {@link LightstreamerClient#setLoggerProvider()}.
 */
class LS_PUBLIC_API ConsoleLoggerProvider: public LoggerProvider {
  ConsoleLogLevel _level;
  std::map<std::string, std::unique_ptr<Logger>> _loggers;
public:
  /**
    Creates an instance of the concrete system console logger.
     
    @param level The desired logging level. See {@link ConsoleLogLevel}.
  */
  ConsoleLoggerProvider(ConsoleLogLevel level) : _level(level) {}

  Logger* getLogger(const std::string& category) override;
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_ConsoleLoggerProvider