#include "utest.h"
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
    EXPECT_EQ(1, v.size());
    EXPECT_EQ("n1=v1; domain=acme.com; path=/", v.at(0).toString());
  }
  {
    auto v = jar.cookiesForUrl(url2);
    EXPECT_EQ(1, v.size());
    EXPECT_EQ("n2=v2; domain=foo.bar; path=/", v.at(0).toString());
  }
}

TEST(test_delete_cookies) {
  CookieJar jar;
  URI url("http://acme.com");
  HTTPCookie c1("n1", "v1");
  jar.setCookiesFromUrl(url, { c1 });
  {
    auto v = jar.cookiesForUrl(url);
    EXPECT_EQ(1, v.size());
    EXPECT_EQ("n1=v1; domain=acme.com; path=/", v.at(0).toString());
  }
  {
    c1.setMaxAge(0); // a cookie is deleted by setting its age to 0
    jar.setCookiesFromUrl(url, { c1 });
    auto v = jar.cookiesForUrl(url);
    EXPECT_EQ(0, v.size());
  }
}

TEST(test_clear_cookies) {
  CookieJar jar;
  URI url("http://acme.com");
  HTTPCookie c1("n1", "v1");
  jar.setCookiesFromUrl(url, { c1 });
  EXPECT_EQ(1, jar.cookiesForUrl(url).size());
  jar.clearAllCookies();
  EXPECT_EQ(0, jar.cookiesForUrl(url).size());
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
    EXPECT_EQ(1, v.size());
    EXPECT_EQ("n1=v1; domain=acme.com; path=/", v.at(0).toString());
  }
  {
    auto v = jar.cookiesForUrl(url2);
    EXPECT_EQ(2, v.size());
    EXPECT_EQ("n1=v1; domain=acme.com; path=/", v.at(0).toString());
    EXPECT_EQ("n2=v2; domain=acme.com; path=/; secure", v.at(1).toString());
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
    EXPECT_EQ(1, v.size());
    EXPECT_EQ("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
  }
  {
    auto v = jar.cookiesForUrl(url2);
    EXPECT_EQ(2, v.size());
    EXPECT_EQ("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
    EXPECT_EQ("n2=v2; domain=.sub.acme.com; path=/", v.at(1).toString());
  }
  {
    auto v = jar.cookiesForUrl(url3);
    EXPECT_EQ(2, v.size());
    EXPECT_EQ("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
    EXPECT_EQ("n2=v2; domain=.sub.acme.com; path=/", v.at(1).toString());
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
    EXPECT_EQ(1, v.size());
    EXPECT_EQ("n1=v1; domain=acme.com; path=/", v.at(0).toString());
  }
  {
    auto v = jar.cookiesForUrl(url2);
    EXPECT_EQ(2, v.size());
    EXPECT_EQ("n2=v2; domain=acme.com; path=/foo", v.at(0).toString());
    EXPECT_EQ("n1=v1; domain=acme.com; path=/", v.at(1).toString());
  }
  {
    auto v = jar.cookiesForUrl(url3);
    EXPECT_EQ(2, v.size());
    EXPECT_EQ("n2=v2; domain=acme.com; path=/foo", v.at(0).toString());
    EXPECT_EQ("n1=v1; domain=acme.com; path=/", v.at(1).toString());
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
    EXPECT_EQ(2, v.size());
    EXPECT_EQ("n2", v.at(0).getName());
    EXPECT_EQ("n3", v.at(1).getName());
  }
  {
    std::this_thread::sleep_for (std::chrono::seconds(1));
    auto v = jar.cookiesForUrl(url);
    EXPECT_EQ(1, v.size());
    EXPECT_EQ("n3", v.at(0).getName());
  }
}

LineAssembler::ByteBuf fromString(std::string_view s) {
  return LineAssembler::ByteBuf(s.data(), s.size());
}

TEST(test_line_assembler) {
  LineAssembler la;
  LineAssembler::ByteBuf buf(0);
  std::vector<std::string> v;
  auto cb = [&v](std::string_view s) { v.push_back(std::string(s)); };

  buf = fromString("a whole line\r\n");
  la.readBytes(buf, cb);
  EXPECT_EQ("a whole line", v.back());

  buf = fromString("another whole line\r\na partial");
  la.readBytes(buf, cb);
  EXPECT_EQ("another whole line", v.back());

  buf = fromString(" line\r\nanother");
  la.readBytes(buf, cb);
  EXPECT_EQ("a partial line", v.back());

  buf = fromString(" partial");
  la.readBytes(buf, cb);

  buf = fromString(" line\r\n");
  la.readBytes(buf, cb);
  EXPECT_EQ("another partial line", v.back());

  buf = fromString("a tricky line\r");
  la.readBytes(buf, cb);

  buf = fromString("\n");
  la.readBytes(buf, cb);
  EXPECT_EQ("a tricky line", v.back());

  buf = fromString("");
  la.readBytes(buf, cb);

  buf = fromString("\r\n");
  la.readBytes(buf, cb);
  EXPECT_EQ("", v.back());

  EXPECT_EQ(6, v.size());
}

TEST(test_extract_lines_from_frames) {
  LineAssembler la;
  LineAssembler::ByteBuf buf(0);
  std::vector<std::string> v;
  auto cb = [&v](std::string_view s) { v.push_back(std::string(s)); };

  buf = fromString("SERVNAME,Lightstreamer HTTP Server\r\nCLIENTIP,127.0.0.1\r\nCONS,40.0\r\nSUBOK");
  la.readBytes(buf, cb);
  EXPECT_EQ(3, v.size());
  EXPECT_EQ("SERVNAME,Lightstreamer HTTP Server", v.at(0));
  EXPECT_EQ("CLIENTIP,127.0.0.1", v.at(1));
  EXPECT_EQ("CONS,40.0", v.at(2));

  buf = fromString(",1,1,1\r\nCONF,1,unlimited,filtered\r\n");
  la.readBytes(buf, cb);
  EXPECT_EQ(5, v.size());
  EXPECT_EQ("SUBOK,1,1,1", v.at(3));
  EXPECT_EQ("CONF,1,unlimited,filtered", v.at(4));
}

int main(int argc, char** argv) {
  using utest::runner;

  runner.add(new test_add_cookies());
  runner.add(new test_delete_cookies());
  runner.add(new test_clear_cookies());
  runner.add(new test_secure_cookies());
  runner.add(new test_cookie_domain());
  runner.add(new test_cookie_path());
  runner.add(new test_cookie_expiration_date());
  runner.add(new test_line_assembler());
  runner.add(new test_extract_lines_from_frames());

  return runner.start(argc > 1 ? argv[1]: "");
}