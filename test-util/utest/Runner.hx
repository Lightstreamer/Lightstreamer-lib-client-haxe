package utest;

import haxe.rtti.CType.MetaData;
import haxe.rtti.Rtti;
import haxe.Exception;
import haxe.macro.Compiler;

using Lambda;
using StringTools;

@:access(utest.Test)
class Runner {
  final classes: Array<Class<Test>> = [];
  final tests: Array<Test> = [];
  final ignoredTests: Array<String> = [];
  var globalPattern: EReg;
  public var numFailures(default, null) = 0;

  public function new() {
    var envPattern = Compiler.getDefine('UTEST_PATTERN');
    if (envPattern != null) {
      globalPattern = new EReg(envPattern, '');
    }
  }

  public function addCase(clazz: Class<Test>) {
    classes.push(clazz);
  }

  public function run() {
    runTests();
    printReport();
  }

  function runTests() {
    forEachTestCase((clazz, methodName, isAsync, timeout) -> {
      var testName = getClassName(clazz) + "." + methodName;
      trace('********** $testName **********');
      var test: Test;
      try {
        test = Type.createInstance(clazz, []);
      } catch(ex) {
        var test = new Test();
        test.name = testName;
        test.addException(ex);
        tests.push(test);
        return;
      }
      test.name = testName;
      var async = isAsync ? new Async() : null;
      try {
        var setup = Reflect.field(test, "setup");
        if (setup != null) Reflect.callMethod(test, setup, []);
        var body = Reflect.field(test, methodName);
        if (isAsync) {
          test._async = async;
          Reflect.callMethod(test, body, [async]);
          async.tryAcquire(timeout ?? 250);
        } else {
          Reflect.callMethod(test, body, []);
        }
      } catch(ex) {
        test.addException(ex);
      }
      try {
        var teardown = Reflect.field(test, "teardown");
        if (teardown != null) Reflect.callMethod(test, teardown, []);
      } catch(ex) {
        test.addException(ex);
      }
      if (isAsync && !async.isCompleted) {
        test.addError("missed async call");
      } else if (test.passed() && test.numAssertions == 0) {
        test.addError("no assertion");
      }
      tests.push(test);
    });
  }

  function forEachTestCase(func: (clazz: Class<Test>, methodName: String, isAsync: Bool, timeout: Null<Int>)->Void) {
    for (clazz in classes) {
      var rtti = Rtti.getRtti(clazz);
      var classTimeout = getTimeout(rtti);
      for (field in rtti.fields) {
        // a test case has the following properties:
        // 1) it's a function
        // 2) its name starts with "test"
        // 3) it has no argument or only one having type "utest.Async"
        // 4) it's not annotated with "Ignored"
        var methodArgs;
        switch field.type {
        case CFunction(args, _):
          methodArgs = args;
        case _:
          continue;
        }
        if (!field.name.startsWith("test")) {
          continue;
        }
        if (methodArgs.length > 1) {
          continue;
        }
        var isAsync = false; // when methodArgs.length == 0
        if (methodArgs.length == 1) {
          switch methodArgs[0].t {
          case CClass(name, _) if (name == "utest.Async"):
            isAsync = true;
          case _:
            continue;
          }
        }
        var testName = getClassName(clazz) + "." + field.name;
        if (globalPattern != null && !globalPattern.match(testName)) {
          continue;
        }
        if (isIgnored(field)) {
          ignoredTests.push(testName);
          continue;
        }
        // process test
        if (isAsync) {
          var methodTimeout = getTimeout(field);
          var timeout = if (methodTimeout != null) methodTimeout
            else if (classTimeout != null) classTimeout
            else null;
          func(clazz, field.name, true, timeout);
        } else {
          func(clazz, field.name, false, null);
        }
      }
    }
  }

  function getTimeout(elem: {meta: MetaData}): Null<Int> {
    var timeoutMeta = elem.meta.find(m -> m.name == "timeout" || m.name == ":timeout");
    if (timeoutMeta != null) {
      var timeoutArg = timeoutMeta.params[0];
      return timeoutArg != null ? Std.parseInt(timeoutArg) : null;
    }
    return null;
  }

  function isIgnored(elem: {meta: MetaData}): Bool {
    return elem.meta.find(m -> m.name == "Ignored" || m.name == ":Ignored") != null;
  }

  function printReport() {
    if (tests.length == 0) {
      trace("No test to run");
      return;
    }
    for (test in tests) {
      if (test.passed()) {
        continue;
      }
      trace('********** ${test.name} **********');
      for (error in test.errors) {
        trace(error.message + error.stack);
      }
    }
    var failed = 0;
    var total = tests.length;
    trace("********** Results **********");
    for (test in tests) {
      var passed = test.passed();
      failed += passed ? 0 : 1;
      trace(test.name, passed ? "OK" : "FAILED");
      if (!passed) {
        for (error in test.errors) {
          trace("  " + error.message);
        }
      }
    }
    if (failed > 0) {
      trace('FAILED [$failed/$total]');
    } else {
      trace('All tests passed [$total/$total]');
    }
    if (ignoredTests.length > 0) {
      trace('WARN Ignored ${ignoredTests.length} tests:');
      for (testName in ignoredTests) {
        trace("  " + testName);
      }
    }
    numFailures = failed;
  }

  function getClassName(clazz: Class<Any>) {
    var comps = Type.getClassName(clazz).split(".");
    return comps[comps.length - 1];
  }
}