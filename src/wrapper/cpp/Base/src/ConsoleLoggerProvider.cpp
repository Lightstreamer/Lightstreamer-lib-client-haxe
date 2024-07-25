#include "Lightstreamer/ConsoleLoggerProvider.h"
#include <ctime>
#include <iomanip>
#include <iostream>
#include <sstream>

using Lightstreamer::Logger;
using Lightstreamer::ConsoleLoggerProvider;
using Lightstreamer::ConsoleLogLevel;

namespace {

class ConsoleLogger: public Logger {
  ConsoleLogLevel _level;
  std::string _category;
  bool _traceEnabled;
  bool _debugEnabled;
  bool _infoEnabled;
  bool _warnEnabled;
  bool _errorEnabled;
  bool _fatalEnabled;

  void print(const char* level, const std::string& line);
public:
  ConsoleLogger(ConsoleLogLevel level, const std::string& category);

  void trace(const std::string& line);
  void debug(const std::string& line);
  void info(const std::string& line);
  void warn(const std::string& line);
  void error(const std::string& line);
  void fatal(const std::string& line);

  bool isTraceEnabled() {
    return _traceEnabled;
  }
  bool isDebugEnabled() {
    return _debugEnabled;
  }
  bool isInfoEnabled() {
    return _infoEnabled;
  }
  bool isWarnEnabled() {
    return _warnEnabled;
  }
  bool isErrorEnabled() {
    return _errorEnabled;
  }
  bool isFatalEnabled() {
    return _fatalEnabled;
  }
};

ConsoleLogger::ConsoleLogger(ConsoleLogLevel level, const std::string& category) :
  _level(level),
  _category(category),
  _traceEnabled(level <= ConsoleLogLevel::Trace),
  _debugEnabled(level <= ConsoleLogLevel::Debug),
  _infoEnabled (level <= ConsoleLogLevel::Info),
  _warnEnabled (level <= ConsoleLogLevel::Warn),
  _errorEnabled(level <= ConsoleLogLevel::Error),
  _fatalEnabled(level <= ConsoleLogLevel::Fatal)
  {}

void ConsoleLogger::print(const char* level, const std::string& line) {
  std::time_t t = std::time(nullptr);
  // https://stackoverflow.com/a/25618891
  #ifdef _MSC_VER
  std::tm tm = *std::localtime(&t);
  #else
  std::tm tm;
  localtime_r(&t, &tm);
  #endif
  std::stringstream ss;
  ss << std::put_time(&tm, "%F %T") << "|" << level << "|" << _category << "|" << line;
  std::cout << ss.str() << std::endl;
}

void ConsoleLogger::trace(const std::string& line){
  if (_traceEnabled) {
    print("TRACE", line);
  }
}

void ConsoleLogger::debug(const std::string& line){
  if (_debugEnabled) {
    print("DEBUG", line);
  }
}

void ConsoleLogger::info(const std::string& line){
  if (_infoEnabled) {
    print("INFO", line);
  }
}

void ConsoleLogger::warn(const std::string& line){
  if (_warnEnabled) {
    print("WARN", line);
  }
}

void ConsoleLogger::error(const std::string& line){
  if (_errorEnabled) {
    print("ERROR", line);
  }
}

void ConsoleLogger::fatal(const std::string& line){
  if (_fatalEnabled) {
    print("FATAL", line);
  }
}

} // unnamed namespace

Logger* ConsoleLoggerProvider::getLogger(const std::string& category) {
  auto it = _loggers.find(category);
  if (it == _loggers.end()) {
    Logger* p = new ConsoleLogger(_level, category);
    _loggers.emplace(category, p);
    return p;
  }
  return it->second.get();
}