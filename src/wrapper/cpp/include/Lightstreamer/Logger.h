#ifndef INCLUDED_Lightstreamer_Logger
#define INCLUDED_Lightstreamer_Logger

#include <string>

namespace Lightstreamer {

class Logger {
public:
  virtual ~Logger() {};
  virtual void error(const std::string& line) = 0;
  virtual void warn(const std::string& line) = 0;
  virtual void info(const std::string& line) = 0;
  virtual void debug(const std::string& line) = 0;
  virtual void trace(const std::string& line) = 0;
  virtual void fatal(const std::string& line) = 0;
  virtual bool isTraceEnabled() = 0;
  virtual bool isDebugEnabled() = 0;
  virtual bool isInfoEnabled() = 0;
  virtual bool isWarnEnabled() = 0;
  virtual bool isErrorEnabled() = 0;
  virtual bool isFatalEnabled() = 0;
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Logger