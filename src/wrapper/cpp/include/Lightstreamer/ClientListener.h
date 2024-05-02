#ifndef INCLUDED_Lightstreamer_ClientListener
#define INCLUDED_Lightstreamer_ClientListener

#include <string>

namespace Lightstreamer {

class ClientListener {
public:
  virtual ~ClientListener() {}
  virtual void onListenEnd() {}
  virtual void onListenStart() {}
  virtual void onServerError(int errorCode, const std::string& errorMessage) {}
  virtual void onStatusChange(const std::string& status) {}
  virtual void onPropertyChange(const std::string& property) {}
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_ClientListener