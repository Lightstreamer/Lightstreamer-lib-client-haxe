#ifndef INCLUDED_Lightstreamer_HxPoco_Utils
#define INCLUDED_Lightstreamer_HxPoco_Utils

#include <string>
#include <string_view>

namespace Lightstreamer {
namespace HxPoco {

bool ends_with(std::string_view str, std::string_view suffix);
bool starts_with(std::string_view str, std::string_view prefix);
std::string mid(const std::string& s, size_t pos);
std::string left(const std::string& s, size_t n);
size_t lastIndexOf(const std::string& s, std::string::value_type c);
bool contains(const std::string& s, const std::string& x);

}} // END NAMESPACE

#endif