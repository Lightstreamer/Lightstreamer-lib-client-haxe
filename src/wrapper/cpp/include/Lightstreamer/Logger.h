#ifndef INCLUDED_Lightstreamer_Logger
#define INCLUDED_Lightstreamer_Logger

#include <string>

namespace Lightstreamer {

/** 
 * Interface to be implemented to consume log from the library. <BR>
 * Instances of implemented classes are obtained by the library through the LoggerProvider instance set on {@link LightstreamerClient#setLoggerProvider}.
 */
class Logger {
public:
  virtual ~Logger() {};
  /** 
   * Receives log messages at Error level.
   * 
   * @param line The message to be logged.
   */
  virtual void error(const std::string& line) = 0;
  /** 
   * Receives log messages at Warn level.
   * 
   * @param line The message to be logged.
   */
  virtual void warn(const std::string& line) = 0;
  /** 
   * Receives log messages at Info level.
   * 
   * @param line The message to be logged.
   */
  virtual void info(const std::string& line) = 0;
  /** 
   * Receives log messages at Debug level.
   * 
   * @param line The message to be logged.
   */
  virtual void debug(const std::string& line) = 0;
  /** 
   * Receives log messages at Trace level.
   * 
   * @param line The message to be logged.
   */
  virtual void trace(const std::string& line) = 0;
  /** 
   * Receives log messages at Fatal level.
   * 
   * @param line The message to be logged.
   */
  virtual void fatal(const std::string& line) = 0;
  /** 
   * Checks if this logger is enabled for the Trace level. <BR>
   * The property should be true if this logger is enabled for Trace events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Trace statements. Note 
   * that even if the property is false, Trace log lines may be received anyway by the Trace methods.
   * @return true if the Trace logger is enabled
   */
  virtual bool isTraceEnabled() = 0;
  /** 
   * Checks if this logger is enabled for the Debug level. <BR>
   * The property should be true if this logger is enabled for Debug events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Debug statements. Note 
   * that even if the property is false, Debug log lines may be received anyway by the Debug methods.
   * @return true if the Debug logger is enabled
   */
  virtual bool isDebugEnabled() = 0;
  /** 
   * Checks if this logger is enabled for the Info level. <BR>
   * The property should be true if this logger is enabled for Info events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Info statements. Note 
   * that even if the property is false, Info log lines may be received anyway by the Info methods.
   * @return true if the Info logger is enabled
   */
  virtual bool isInfoEnabled() = 0;
  /** 
   * Checks if this logger is enabled for the Warn level. <BR>
   * The property should be true if this logger is enabled for Warn events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Warn statements. Note 
   * that even if the property is false, Warn log lines may be received anyway by the Warn methods.
   * @return true if the Warn logger is enabled
   */
  virtual bool isWarnEnabled() = 0;
  /** 
   * Checks if this logger is enabled for the Error level. <BR>
   * The property should be true if this logger is enabled for Error events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Error statements. Note 
   * that even if the property is false, Error log lines may be received anyway by the Error methods.
   * @return true if the Error logger is enabled
   */
  virtual bool isErrorEnabled() = 0;
  /** 
   * Checks if this logger is enabled for the Fatal level. <BR>
   * The property should be true if this logger is enabled for Fatal events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Fatal statements. Note 
   * that even if the property is false, Fatal log lines may be received anyway by the Fatal methods.
   * @return true if the Fatal logger is enabled
   */
  virtual bool isFatalEnabled() = 0;
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Logger