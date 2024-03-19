#ifndef INCLUDED_Lightstreamer_HxPoco_LineAssembler
#define INCLUDED_Lightstreamer_HxPoco_LineAssembler

#include "Poco/Buffer.h"
#include "Poco/Bugcheck.h"

namespace Lightstreamer {
namespace HxPoco {

class LineAssembler
{
public:
  using ByteBuf = Poco::Buffer<char>;

  void readBytes(const ByteBuf& buf, std::function<void(std::string_view)> callback);

private:
  std::string linePart;
};

}}
#endif