#ifndef INCLUDED_Lightstreamer_ConsoleLoggerProvider
#define INCLUDED_Lightstreamer_ConsoleLoggerProvider

#include "../Lightstreamer.h"
#include "Lightstreamer/LoggerProvider.h"

namespace Lightstreamer {

class ConsoleLoggerProvider: public LoggerProvider {
  HaxeObject _delegate;
public:
  ConsoleLoggerProvider(int level) {
    _delegate = ConsoleLoggerProvider_new(level);
  }
  virtual ~ConsoleLoggerProvider() {
    Lightstreamer_releaseHaxeObject(_delegate);
  }
  virtual Logger* getLogger(const std::string& category) {
    // TODO
  }
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_ConsoleLoggerProvider