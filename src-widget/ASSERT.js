/*
  Copyright (c) Lightstreamer Srl

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
import LoggerManager from "../src-log/LoggerManager";

export default /*@__PURE__*/(function() {
  var logger = LoggerManager.getLoggerProxy("weswit.test");
  
  var failures = 0;
  
  var VOID = {};
  
  /**
   * you can use method of ASSERT to verify conditions
   * If a conditions is not met ASSERT.failures is increased
   * and an error log line is printed on the ASSERT category
   * @exports ASSERT
   */
  var ASSERT = {
    /**
     * The VOID property to be used in various calls
     */
    "VOID": VOID,
    
    /**
     * Gets the number of failures. A failure is added
     * each time any of the other methods return false.
     * @returns {Number}
     */
    getFailures: function() {
      return failures;
    },
    
    /**
     * Checks that two arrays contain the same elements
     * the sameOrder flag can be used to specify if the
     * elements must be in the same order in both arrays.
     * 
     * @param {Array} arr1 the first array to be compared
     * @param {Array} expected the second array to be compared
     * @param {Boolean} sameOrder true if the elements in the 
     * arrays must be placed in the same order, false otherwise.
     * In the latter case duplicated entries will be considered
     * as one.
     * 
     * @return true if the test pass, false otherwise.
     */
    compareArrays: function(arr1,expected,sameOrder) {
      if (arr1.length != expected.length) {
        this.failInternal();
        logger.logError("Wong length!",arr1,expected);
        return false;
      }
      
      if (!sameOrder) {
        var genMap = {};
        for (var i=0; i<arr1.length; i++) {
          genMap[arr1[i]] = 1;
        }
        
        for (var i=0; i<expected.length; i++) {
          if (!genMap[expected[i]]) {
            logger.logError("Missing from first array",expected[i]);
            this.failInternal();
            return false;
          } else {
            genMap[expected[i]]++;
          }
        }
        
        for (var i in genMap) {
          if (genMap[i] == 1) {
            logger.logError("Missing from second array",genMap[i]);
            this.failInternal();
            return false;
          }
        }
        
      } else {
        for (var i=0; i<arr1.length; i++) {
          if(arr1[i] != expected[i]) {
            logger.logError("Wrong  element", arr1[i], expected[i]);
            this.failInternal();
            return false;
          }
        }
      }
      
      return true;
    },
    
    /**
     * Calls the function method (passed as a string) of the
     * obj instance using param (that is an array of parameters) 
     * as parameters and verifies that the result is equal to res.
     * Specify ASSERT.VOID as param to not pass any input parameter.
     * Specify ASSERT.VOID as res to avoid checks on the return value.
     * Pass a function as compareFun if the check between res and 
     * the return value can't be done with a simple comparison (==) 
     * and must be done by such compareFun method, specify true as
     * compareFun if the check must be performed using the strict 
     * equal operator (===). The tested function is expected to not
     * throw any exception.
     * 
     * @param {Object} obj the object upon which the function method will 
     * be called
     * @param {String} method the name of the function to be called
     * @param {Array} param an array of parameters to be passed to the
     * function call or ASSERT.VOID if no parameters have to be passed.
     * @param {*} res the expected value or ASSERT.VOID if no value is
     * expected.
     * @param {Boolean|Function} [compareFun] if not specified the return 
     * value will be compared with the res parameter using the equal 
     * operator (==). If true is specified the strict equal operator 
     * (===) is used. If a function is passed the return value will 
     * be compared by such function with the res parameter.
     * 
     * @returns true if the function executes without exception 
     * and returns with the expected value, false otherwise.
     */
    verifySuccess: function(obj,method,param,res,compareFun) {
      return this.verify(obj,method,param,res,false,compareFun);
    },
    
    /**
     * Calls the function method (passed as a string) of the
     * obj instance using param (that is an array of parameters) 
     * as parameters and verifies that the method exits with an
     * exception.
     * Specify ASSERT.VOID as param to not pass any input parameter.
     * 
     * @param {Object} obj the object upon which the function method will 
     * be called
     * @param {String} method the name of the function to be called
     * @param {Array} param an array of parameters to be passed to the
     * function call or ASSERT.VOID if no parameters have to be passed.
     * 
     * @returns true if the function throws an exception, false otherwise.
     */
    verifyException: function (obj,method,param) {
      return this.verify(obj,method,param,null,true);
    },
    
    /**
     * Verifies that the given value is not null (strict check)
     * @param {*} val1 the value to be checked.
     * @returns {Boolean}
     */
    verifyNotNull: function(val1) {
      if (val1 === null) {
        this.failInternal();
        logger.logError("Not expecting a NULL",val1);
        return false;
      }
      return true;
    },
    
    /**
     * Compares two values.
     * 
     * @param {*} val1 the first value to be compared.
     * @param {*} val2 the second value to be compared.
     * @param {Boolean|Function} [compareFun] if not specified the return 
     * value will be compared with the res parameter using the equal 
     * operator (==). If true is specified the strict equal operator 
     * (===) is used. If a function is passed the return value will 
     * be compared by such function with the res parameter.
     * 
     * @returns true if the two values are the same, false otherwise.
     */
    verifyValue: function(val1,val2,compareFun) {
      var ok = false;
      if (compareFun === true) {
        ok = val1===val2;
      } else if (compareFun) {
        ok = compareFun(val1,val2);
      } else if (!isNaN(val1)) {
        
        var c1 = val1 && val1.charAt ? val1.charAt(0) : null;
        var c2 = val2 && val2.charAt ? val2.charAt(0) : null;
        
        if (c1 == "." || c1 == " " || c1 == "0" || c2 == "." || c2 == " " || c2 == "0") {
          ok = String(val1)==String(val2);
        } else {
          ok = val1==val2;
        }
        
        
      } else {
        ok = val1==val2;
      }
       
      if (!ok) {
        this.failInternal();
        logger.logError("Expecting a different value",val1,val2);
        return false;
      }
      return true;
    },
    
    /**
     * Compares two values expecting'em to be different.
     * 
     * @param {*} val1 the first value to be compared.
     * @param {*} val2 the second value to be compared.
     * @param {Boolean} [strict] if true a strict comparison
     * is performed.
     * 
     * @returns true if the two values are different, false otherwise.
     */
    verifyDiffValue: function(val1,val2,strict) {
      var ok = false;
      if (strict) {
        ok = val1 !== val2;
      } else {
        ok = val1 != val2;
      }
      
      if (!ok) {
        this.failInternal();
        logger.logError("Expecting 2 different values",val1,val2);
        return false;
      }
      return true;
    },
    
    /**
     * Simple check for a valid value 
     * (0, "", NaN etc do not pass this test)
     * 
     * @param {*} val the value to be checked.
     * @returns {Boolean} true if a valid value is passed, false otherwise.
     */
    verifyOk: function(val) {
      if (!val) {
        this.failInternal();
        logger.logError("Expecting a valid value");
        return false;
      }
      return true;
    },
    
    /**
     * Simple check for a not valid value 
     * (0, "", NaN etc pass this test)
     * 
     * @param {*} val the value to be checked.
     * @returns {Boolean} true if a not valid value is passed, false otherwise.
     */
    verifyNotOk: function(val) {
      if (val) {
        this.failInternal();
        logger.logError("Expecting a not valid value");
        return false;
      }
      return true;
    },
    
    /**
     * Fails in any case
     * @returns {Boolean} false is always returned.
     */
    fail: function() {
      logger.logError("ASSERT failed");
      this.failInternal();
      return false;
    },
    
    /**
     * @private
     */
    failInternal: function() {
      failures++;
    },
    
    /**
     * @private
     */
    verify: function(obj,method,param,res,expectingException,compareFun) {
      var flag = false;
      var ret = null;
      var exc = null;
      try {
        if (param !== VOID) {
          ret = obj[method].apply(obj,param);
        } else {
          ret = obj[method]();  
        }
        
      } catch(_e) {
        flag = true;
        exc = _e;
      }
      
      var what = expectingException ? "succes" : "failure";
      var ok = expectingException == flag;
      if (!ok) {
        this.failInternal();
        logger.logError("Unexpected",what,"for",method,param,res,exc);
        return false;
      }
      
      
      if (!expectingException && res !== VOID) {
        return this.verifyValue(ret,res,compareFun);
      }
      return true;
    }
    
  };
  
  //closure exports
  ASSERT["getFailures"] = ASSERT.getFailures;
  ASSERT["fail"] = ASSERT.fail;
  ASSERT["verifyNotOk"] = ASSERT.verifyNotOk;
  ASSERT["verifyOk"] = ASSERT.verifyOk;
  ASSERT["verifyDiffValue"] = ASSERT.verifyDiffValue;
  ASSERT["verifyNotNull"] = ASSERT.verifyNotNull;
  ASSERT["verifyValue"] = ASSERT.verifyValue;
  ASSERT["verifyException"] = ASSERT.verifyException;
  ASSERT["verifySuccess"] = ASSERT.verifySuccess;
  ASSERT["compareArrays"] = ASSERT.compareArrays;
  
  
  return ASSERT;
})();
  
