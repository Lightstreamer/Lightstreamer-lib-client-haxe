#ifndef INCLUDED_Lightstreamer_ForwardDcl
#define INCLUDED_Lightstreamer_ForwardDcl

#include "Poco/URI.h"
#include "Poco/Net/HTTPCookie.h"
#include "Poco/Net/Context.h"
#include <string>
#include <vector>

namespace Lightstreamer {
  class Subscription;
  class SubscriptionListener;
  class ClientListener;
  class ClientMessageListener;
  struct Proxy;
  class LoggerProvider;
}

#endif