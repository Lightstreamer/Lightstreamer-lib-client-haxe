#ifndef INCLUDED_utest
#define INCLUDED_utest

#include "Poco/Semaphore.h"
#include <vector>
#include <sstream>
#include <iostream>
#include <regex>
#include <thread>
#include <chrono>

#define EXPECT_EQ(expected, actual) check_eq((expected), (actual), __FILE__, __LINE__)
#define EXPECT_NE(expected, actual) check_ne((expected), (actual), __FILE__, __LINE__)
#define EXPECT_TRUE(cond) check((cond), #cond, __FILE__, __LINE__)
#define EXPECT_FALSE(cond) check_false((cond), #cond, __FILE__, __LINE__)
#define EXPECT_THROW(expr, except) \
  do                                                                          \
  {                                                                           \
    bool caught_ = false;                                                     \
    try { (expr); }                                                           \
    catch (const except& ) { caught_ = true; }                                \
    catch (...) {                                                             \
      utest::_reporter.onError(                                               \
        name, "Unexpected exception in EXPECT_THROW", __FILE__, __LINE__);    \
    }                                                                         \
    if (!caught_)                                                             \
      utest::_reporter.onFailure(                                             \
        name, "Exception '" #except "' not thrown", __FILE__, __LINE__);      \
  } while(0)

#define TEST(name)                            \
struct name: public utest::Test {             \
  name(const std::string& param1 = ""): utest::Test(#name, __FILE__, __LINE__, param1) {}  \
  void run() override;                        \
};                                            \
void name::run()

#define TEST_FIXTURE(fixture, name)           \
struct name: public fixture {                 \
  name(const std::string& param1 = ""): fixture(#name, __FILE__, __LINE__, param1) {}  \
  void run() override;                        \
};                                            \
void name::run()

namespace utest {

struct Reporter {
  int n_run = 0;
  std::vector<std::string> _errors;
  std::vector<std::string> _failures;

  void onTestStart(const std::string& test, const std::string& filename, int line) {
    n_run++;
    std::stringstream ss;
    ss << "\n********** '" << test << "' (" << filename << ":" << line << ") **********\n";
    std::cout << ss.str() << "\n";
  }

  void onError(const std::string& test, const std::string& msg, const std::string& filename, int line) {
    std::stringstream ss;
    ss << "Error in '" << test << "' (" << filename << ":" << line << "): " << msg;
    _errors.push_back(ss.str());
    std::cout << ">>>>>>>>>> " << ss.str() << "\n";
  }

  void onFailure(const std::string& test, const std::string& msg, const std::string& filename, int line) {
    std::stringstream ss;
    ss << "Failure in '" << test << "' (" << filename << ":" << line << "): " << msg;
    _failures.push_back(ss.str());
    std::cout << ">>>>>>>>>> " << ss.str() << "\n";
  }

  void onCompletion() {
    int n_errors = _errors.size();
    int n_failures = _failures.size();
    if (n_run == 0) {
      std::cout << "\nFAIL: no test to run\n";
    } else if (n_errors + n_failures == 0) {
      std::cout << "\nSUCCESS: " << n_run << " tests passed\n";
    } else {
      std::cout << "\n***** TEST RESULTS *****\n";
      int i = 1;
      for (auto& s : _errors) {
        std::cout << i++ << ". " << s << "\n";
      }
      for (auto& s : _failures) {
        std::cout << i++ << ". " << s << "\n";
      }
      std::cout << "FAIL: " << n_run << " tests run (" << n_errors << " errors, " << n_failures << " assertions failed)\n";
    }
  }

  int exit_code() {
    return n_run > 0 ? _errors.size() + _failures.size() : 1;
  }
};

inline Reporter _reporter;

struct Test {
  std::string name;
  std::string filename;
  int line;
  Poco::Semaphore _sem{0, std::numeric_limits<int>::max()}; // simulate an unbound semaphore
  std::string _param1;

  Test() = delete;
  Test(const std::string& name, const std::string& filename, int line, const std::string& param1 = "")
    : name(name), filename(filename), line(line), _param1(param1) 
  {
    if (!param1.empty()) {
      std::stringstream ss;
      ss << name << "[" << param1 << "]";
      this->name = ss.str();
    }
  }

  virtual ~Test() {}
  virtual void setup() {}
  virtual void tear_down() {}
  virtual void run() = 0;
  
  void start() {
    try {
      _reporter.onTestStart(name, filename, line);
      setup();
      run();
    } catch(const std::exception& ex) {
      _reporter.onError(name, ex.what(), filename, line);
    } catch(...) {
      _reporter.onError(name, "Unknown exception", filename, line);
    }
    try {
      tear_down();
    } catch(const std::exception& ex) {
      _reporter.onError(name, ex.what(), filename, line);
    } catch(...) {
      _reporter.onError(name, "Unknown exception", filename, line);
    }
  }

  template<typename P, typename Q>
  void check_eq(const P& expected, const Q& actual, const std::string& filename, int line) {
    try {
      if (expected != actual) {
        std::stringstream ss;
        ss << "Expected `" << expected << "` but was `" << actual << "`";
        _reporter.onFailure(name, ss.str(), filename, line);
      }
    } catch(const std::exception& ex) {
      _reporter.onError(name, ex.what(), filename, line);
    } catch(...) {
      _reporter.onError(name, "Unknown exception", filename, line);
    }
  }

  template<typename P, typename Q>
  void check_ne(const P& expected, const Q& actual, const std::string& filename, int line) {
    try {
      if (expected == actual) {
        std::stringstream ss;
        ss << "Expected different values but found `" << actual << "`";
        _reporter.onFailure(name, ss.str(), filename, line);
      }
    } catch(const std::exception& ex) {
      _reporter.onError(name, ex.what(), filename, line);
    } catch(...) {
      _reporter.onError(name, "Unknown exception", filename, line);
    }
  }

  void check(bool cond, const char* expr, const std::string& filename, int line) {
    try {
      if (!cond) {
        std::stringstream ss;
        ss << "Condition `" << expr << "` is not true";
        _reporter.onFailure(name, ss.str(), filename, line);
      }
    } catch(const std::exception& ex) {
      _reporter.onError(name, ex.what(), filename, line);
    } catch(...) {
      _reporter.onError(name, "Unknown exception", filename, line);
    }
  }

  void check_false(bool cond, const char* expr, const std::string& filename, int line) {
    try {
      if (cond) {
        std::stringstream ss;
        ss << "Condition `" << expr << "` is not false";
        _reporter.onFailure(name, ss.str(), filename, line);
      }
    } catch(const std::exception& ex) {
      _reporter.onError(name, ex.what(), filename, line);
    } catch(...) {
      _reporter.onError(name, "Unknown exception", filename, line);
    }
  }

  void resume() {
    _sem.set();
  }

  void wait(long ms, int expectedResumes = 1) {
    if (expectedResumes == 1) {
      _sem.wait(ms);
    } else {
      using std::chrono::high_resolution_clock;
      using std::chrono::duration_cast;
      using std::chrono::milliseconds;

      auto t0 = high_resolution_clock::now();
      auto left = ms;
      while (expectedResumes-- > 0) {
        if (left <= 0) {
          throw std::runtime_error("Timeout");
        }
        _sem.wait(left);
        left = ms - duration_cast<milliseconds>(high_resolution_clock::now() - t0).count();
      }
    }
  }

  void sleep(int ms) {
    std::this_thread::sleep_for(std::chrono::milliseconds(ms));
  }
};

struct Runner {
  std::vector<Test*> _tests;

  void add(Test* tt) {
    _tests.push_back(tt);
  }

  int start(const std::string& pattern = "") {
    std::regex _pattern;
    if (pattern != "") {
      _pattern = ".*" + pattern + ".*";
    }
    bool no_regex = pattern == "";
    for (auto tt : _tests) {
      if (no_regex || std::regex_match(tt->name, _pattern)) {
        tt->start();
      }
    }
    _reporter.onCompletion();
    return _reporter.exit_code();
  }
};

inline Runner runner;

} // namespace utest

#endif