package utest;

import haxe.rtti.CType.MetaData;
import haxe.rtti.Rtti;
import haxe.Exception;
import haxe.macro.Compiler;

using Lambda;
using StringTools;

typedef TestCase = {
  clazz: Class<Test>, 
  methodName: String, 
  isAsync: Bool, 
  timeout: Null<Int>
}

enum State {
  Init; NoTest; FirstTest; TestPassed; TestFailed;
}

@:access(utest.Test)
@:build(utils.Macros.synchronizeClass())
class Runner {
  final classes: Array<Class<Test>> = [];
  final tests: Array<Test> = [];
  final ignoredTests: Array<String> = [];
  var globalPattern: EReg;
  public var numFailures(default, null) = 0;
  
  var state = Init;
  var current: Int = 0;
  var currentTest: Test = null;
  var currentTimer: hx.concurrent.executor.Executor.TaskFuture<Void> = null;
  final testCases: Array<TestCase> = [];

  final sem = new hx.concurrent.lock.Semaphore(0);

  public function new() {
    var envPattern = Compiler.getDefine('UTEST_PATTERN');
    if (envPattern != null) {
      globalPattern = new EReg(envPattern, '');
    }
  }

  @:unsynchronized
  public function await() {
    sem.acquire();
  }

  public function addCase(clazz: Class<Test>) {
    classes.push(clazz);
  }

  public function run() {
    loadTestCases();
    evtRun();
  }

  public function evtRun() {
    trace('evtRun: state=$state current=$current');
    if (testCases.length == 0) {
      gotoNoTest();
    } else {
      gotoFirstTest();
    }
  }

  public function evtCompleted(testIndex: Int) {
    trace('evtCompleted: state=$state current=$current testIndex=$testIndex');
    if (testIndex != current) {
      return;
    }
    gotoTestPassed();
  }

  public function evtTimeout(testIndex: Int) {
    trace('evtTimeout: state=$state current=$current testIndex=$testIndex');
    if (testIndex != current) {
      return;
    }
    gotoTestFailed();
  }

  function gotoNoTest() {
    state = NoTest;
    trace('goto: state=$state');
    printReport();
  }

  function gotoFirstTest() {
    state = FirstTest;
    trace('goto: state=$state');
    runCurrent();
  }

  function gotoTestPassed() {
    state = TestPassed;
    trace('goto: state=$state');
    teardownCurrent();
    current += 1;
    if (current < testCases.length) {
      runCurrent();
    } else {
      printReport();
    }
  }

  function gotoTestFailed() {
    state = TestFailed;
    trace('goto: state=$state');
    teardownCurrent();
    current += 1;
    if (current < testCases.length) {
      runCurrent();
    } else {
      printReport();
    }
  }
  
  function runCurrent() {
    var testIndex = current;
    var testCase = testCases[testIndex];
    var clazz = testCase.clazz;
    var methodName = testCase.methodName;
    var isAsync = testCase.isAsync;
    var timeout = testCase.timeout;
    var testName = getClassName(clazz) + "." + methodName;
    trace('********** $testName **********');
    var test: Test;
    try {
      test = currentTest = Type.createInstance(clazz, []);
    } catch(ex) {
      var test = currentTest = new Test();
      test.name = testName;
      test.addException(ex);
      tests.push(test);
      evtCompleted(testIndex);
      return;
    }
    test.name = testName;
    var async = isAsync ? new Async(this, testIndex) : null;
    try {
      var setup = Reflect.field(test, "setup");
      if (setup != null) Reflect.callMethod(test, setup, []);
      var body = Reflect.field(test, methodName);
      if (isAsync) {
        test._async = async;
        Reflect.callMethod(test, body, [async]);
        currentTimer = test.delay(() -> evtTimeout(testIndex), timeout ?? 250);
      } else {
        Reflect.callMethod(test, body, []);
        evtCompleted(testIndex);
      }
    } catch(ex) {
      test.addException(ex);
      evtCompleted(testIndex);
    }
  }

  function teardownCurrent() {
    var test = currentTest;
    var async = test._async;
    var isAsync = async != null;
    if (isAsync) {
      currentTimer.cancel();
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
  }

  function loadTestCases() {
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
        if (isAsync) {
          var methodTimeout = getTimeout(field);
          var timeout = if (methodTimeout != null) methodTimeout
            else if (classTimeout != null) classTimeout
            else null;
          testCases.push({clazz: clazz, methodName: field.name, isAsync: true, timeout: timeout});
        } else {
          testCases.push({clazz: clazz, methodName: field.name, isAsync: false, timeout: null});
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
    var failed = 0;
    var total = tests.length;
    trace("********** Results **********");
    for (test in tests) {
      var passed = test.passed();
      failed += passed ? 0 : 1;
      trace(test.name, passed ? "OK" : "FAILED");
    }
    if (failed > 0) {
      trace("********** Errors **********");
      for (test in tests) {
        if (!test.passed()) {
          trace(test.name, "FAILED");
          for (error in test.errors) {
            trace("  " + error.message);
          }
        }
      }
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

    sem.release();
  }

  function getClassName(clazz: Class<Any>) {
    var comps = Type.getClassName(clazz).split(".");
    return comps[comps.length - 1];
  }
}