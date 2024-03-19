#include <utpp/utpp.h>
#include <thread>
#include <chrono>   
#include "Lightstreamer/HxPoco/CookieJar.h"
#include "Lightstreamer/HxPoco/LineAssembler.h"

using Poco::URI;
using Poco::Net::HTTPCookie;
using Lightstreamer::HxPoco::CookieJar;
using Lightstreamer::HxPoco::LineAssembler;

TEST(test_add_cookies) {
  CookieJar jar;
  URI url1("http://acme.com");
  URI url2("http://foo.bar");
  HTTPCookie c1("n1", "v1");
  HTTPCookie c2("n2", "v2");
  jar.setCookiesFromUrl(url1, { c1 });
  jar.setCookiesFromUrl(url2, { c2 });
  {
    auto v = jar.cookiesForUrl(url1);
    CHECK_EQUAL(1, v.size());
    CHECK_EQUAL("n1=v1; domain=acme.com; path=/", v.at(0).toString());
  }
  {
    auto v = jar.cookiesForUrl(url2);
    CHECK_EQUAL(1, v.size());
    CHECK_EQUAL("n2=v2; domain=foo.bar; path=/", v.at(0).toString());
  }
}

TEST(test_delete_cookies) {
  CookieJar jar;
  URI url("http://acme.com");
  HTTPCookie c1("n1", "v1");
  jar.setCookiesFromUrl(url, { c1 });
  {
    auto v = jar.cookiesForUrl(url);
    CHECK_EQUAL(1, v.size());
    CHECK_EQUAL("n1=v1; domain=acme.com; path=/", v.at(0).toString());
  }
  {
    c1.setMaxAge(0); // a cookie is deleted by setting its age to 0
    jar.setCookiesFromUrl(url, { c1 });
    auto v = jar.cookiesForUrl(url);
    CHECK_EQUAL(0, v.size());
  }
}

TEST(test_clear_cookies) {
  CookieJar jar;
  URI url("http://acme.com");
  HTTPCookie c1("n1", "v1");
  jar.setCookiesFromUrl(url, { c1 });
  CHECK_EQUAL(1, jar.cookiesForUrl(url).size());
  jar.clearAllCookies();
  CHECK_EQUAL(0, jar.cookiesForUrl(url).size());
}

TEST(test_secure_cookies) {
  CookieJar jar;
  URI url1("http://acme.com");
  URI url2("https://acme.com");
  HTTPCookie c1("n1", "v1");
  c1.setSecure(false);
  HTTPCookie c2("n2", "v2");
  c2.setSecure(true);
  jar.setCookiesFromUrl(url1, { c1, c2 });
  {
    auto v = jar.cookiesForUrl(url1);
    CHECK_EQUAL(1, v.size());
    CHECK_EQUAL("n1=v1; domain=acme.com; path=/", v.at(0).toString());
  }
  {
    auto v = jar.cookiesForUrl(url2);
    CHECK_EQUAL(2, v.size());
    CHECK_EQUAL("n1=v1; domain=acme.com; path=/", v.at(0).toString());
    CHECK_EQUAL("n2=v2; domain=acme.com; path=/; secure", v.at(1).toString());
  }
}

TEST(test_cookie_domain) {
  CookieJar jar;
  URI url1("http://acme.com");
  URI url2("http://sub.acme.com");
  URI url3("http://www.sub.acme.com");
  HTTPCookie c1("n1", "v1");
  c1.setDomain("acme.com");
  HTTPCookie c2("n2", "v2");
  c2.setDomain("sub.acme.com");
  jar.setCookiesFromUrl(url2, { c1, c2 });
  {
    auto v = jar.cookiesForUrl(url1);
    CHECK_EQUAL(1, v.size());
    CHECK_EQUAL("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
  }
  {
    auto v = jar.cookiesForUrl(url2);
    CHECK_EQUAL(2, v.size());
    CHECK_EQUAL("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
    CHECK_EQUAL("n2=v2; domain=.sub.acme.com; path=/", v.at(1).toString());
  }
  {
    auto v = jar.cookiesForUrl(url3);
    CHECK_EQUAL(2, v.size());
    CHECK_EQUAL("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
    CHECK_EQUAL("n2=v2; domain=.sub.acme.com; path=/", v.at(1).toString());
  }
}

TEST(test_cookie_path) {
  CookieJar jar;
  URI url1("http://acme.com");
  URI url2("http://acme.com/foo");
  URI url3("http://acme.com/foo/bar");
  HTTPCookie c1("n1", "v1");
  c1.setPath("/");
  HTTPCookie c2("n2", "v2");
  c2.setPath("/foo");
  jar.setCookiesFromUrl(url2, { c1, c2 });
  {
    auto v = jar.cookiesForUrl(url1);
    CHECK_EQUAL(1, v.size());
    CHECK_EQUAL("n1=v1; domain=acme.com; path=/", v.at(0).toString());
  }
  {
    auto v = jar.cookiesForUrl(url2);
    CHECK_EQUAL(2, v.size());
    CHECK_EQUAL("n2=v2; domain=acme.com; path=/foo", v.at(0).toString());
    CHECK_EQUAL("n1=v1; domain=acme.com; path=/", v.at(1).toString());
  }
  {
    auto v = jar.cookiesForUrl(url3);
    CHECK_EQUAL(2, v.size());
    CHECK_EQUAL("n2=v2; domain=acme.com; path=/foo", v.at(0).toString());
    CHECK_EQUAL("n1=v1; domain=acme.com; path=/", v.at(1).toString());
  }
}

TEST(test_cookie_expiration_date) {
  CookieJar jar;
  URI url("http://acme.com");
  HTTPCookie c1("n1", "v1");
  c1.setMaxAge(0); // expired
  HTTPCookie c2("n2", "v2");
  c2.setMaxAge(1); // expiring after 1 second
  HTTPCookie c3("n3", "v3");
  c3.setMaxAge(-1); // session cookie
  jar.setCookiesFromUrl(url, { c1, c2, c3 });
  {
    auto v = jar.cookiesForUrl(url);
    CHECK_EQUAL(2, v.size());
    CHECK_EQUAL("n2", v.at(0).getName());
    CHECK_EQUAL("n3", v.at(1).getName());
  }
  {
    std::this_thread::sleep_for (std::chrono::seconds(1));
    auto v = jar.cookiesForUrl(url);
    CHECK_EQUAL(1, v.size());
    CHECK_EQUAL("n3", v.at(0).getName());
  }
}

LineAssembler::ByteBuf fromString(std::string_view s) {
  return LineAssembler::ByteBuf(s.data(), s.size());
}

TEST(test_buffer) {
  LineAssembler la;
  LineAssembler::ByteBuf buf(0);
  std::vector<std::string> v;
  auto cb = [&v](std::string_view s) { v.push_back(std::string(s)); };

  buf = fromString("a whole line\r\n");
  la.readBytes(buf, cb);
  CHECK_EQUAL("a whole line", v.back());

  buf = fromString("another whole line\r\na partial");
  la.readBytes(buf, cb);
  CHECK_EQUAL("another whole line", v.back());

  buf = fromString(" line\r\nanother");
  la.readBytes(buf, cb);
  CHECK_EQUAL("a partial line", v.back());

  buf = fromString(" partial");
  la.readBytes(buf, cb);

  buf = fromString(" line\r\n");
  la.readBytes(buf, cb);
  CHECK_EQUAL("another partial line", v.back());

  buf = fromString("a tricky line\r");
  la.readBytes(buf, cb);

  buf = fromString("\n");
  la.readBytes(buf, cb);
  CHECK_EQUAL("a tricky line", v.back());

  buf = fromString("");
  la.readBytes(buf, cb);

  buf = fromString("\r\n");
  la.readBytes(buf, cb);
  CHECK_EQUAL("", v.back());

  CHECK_EQUAL(6, v.size());
}

int main() {
  return UnitTest::RunAllTests();
}