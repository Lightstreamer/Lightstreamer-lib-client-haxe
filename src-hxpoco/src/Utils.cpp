#include "Lightstreamer/HxPoco/Utils.h"

bool Lightstreamer::HxPoco::ends_with(std::string_view str, std::string_view suffix)
{
  return str.size() >= suffix.size() && str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

bool Lightstreamer::HxPoco::starts_with(std::string_view str, std::string_view prefix)
{
  return str.size() >= prefix.size() && str.compare(0, prefix.size(), prefix) == 0;
}

std::string Lightstreamer::HxPoco::mid(const std::string& s, size_t pos) {
  if (pos > s.size())
    return "";
  return s.substr(pos);
}

std::string Lightstreamer::HxPoco::left(const std::string& s, size_t n) {
  return s.substr(0, n);
}

size_t Lightstreamer::HxPoco::lastIndexOf(const std::string& s, std::string::value_type c) {
  return s.find_last_of(c);
}

bool Lightstreamer::HxPoco::contains(const std::string& s, const std::string& x) {
  return s.find(x) != -1;
}
