#ifndef INCLUDED_Lightstreamer_Utils
#define INCLUDED_Lightstreamer_Utils

#include "Lightstreamer/ClientListener.h"
#include <vector>

namespace Lightstreamer {

struct ClientListenerVector {
  std::vector<ClientListener*> v;
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_Utils