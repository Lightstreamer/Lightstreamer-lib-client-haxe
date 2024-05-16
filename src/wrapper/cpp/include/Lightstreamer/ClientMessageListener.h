#ifndef INCLUDED_Lightstreamer_ClientMessageListener
#define INCLUDED_Lightstreamer_ClientMessageListener

#include <string>

namespace Lightstreamer {

class ClientMessageListener {
public:
  virtual ~ClientMessageListener() {}
  virtual void onAbort(const std::string& originalMessage, bool sentOnNetwork) {}
  virtual void onDeny(const std::string& originalMessage, int code, const std::string& error) {}
  virtual void onDiscarded(const std::string& originalMessage) {}
  virtual void onError(const std::string& originalMessage) {}
  virtual void onProcessed(const std::string& originalMessage, const std::string& response) {}
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_ClientMessageListener