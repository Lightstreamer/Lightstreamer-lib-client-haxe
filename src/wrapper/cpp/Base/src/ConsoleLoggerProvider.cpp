#include "Lightstreamer/ConsoleLoggerProvider.h"
#include "Poco/Timestamp.h"
#include "Poco/DateTimeFormat.h"
#include "Poco/DateTimeFormatter.h"
#include "Poco/Thread.h"
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
  _traceEnabled(level <= ConsoleLogLevel::TRACE),
  _debugEnabled(level <= ConsoleLogLevel::DEBUG),
  _infoEnabled (level <= ConsoleLogLevel::INFO),
  _warnEnabled (level <= ConsoleLogLevel::WARN),
  _errorEnabled(level <= ConsoleLogLevel::ERROR),
  _fatalEnabled(level <= ConsoleLogLevel::FATAL)
  {}

void ConsoleLogger::print(const char* level, const std::string& line) {
  std::string now = Poco::DateTimeFormatter::format(Poco::Timestamp(), Poco::DateTimeFormat::SORTABLE_FORMAT);
  std::stringstream ss;
  ss << now << "|" << level << "|" << _category << "|" << Poco::Thread::currentOsTid() << "|" << line;
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