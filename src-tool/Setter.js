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
import IllegalArgumentException from "./IllegalArgumentException";

export default /*@__PURE__*/(function() {
  //This is an abstract class; it could have been a module with a couple of static methods but I find it handier this way.
  
  /**
   * @private
   * @constant
   * @static
   */
  var VALUE_NOT_VALID = "The given value is not valid. ";
  /**
   * @private
   * @constant
   * @static
   */
  var USE_NUMBER = "Use a number";
  /**
   * @private
   * @constant
   * @static
   */
  var USE_INTEGER = "Use an integer";
  /**
   * @private
   * @constant
   * @static
   */
  var USE_POSITIVE = "Use a positive number";
  /**
   * @private
   * @constant
   * @static
   */
  var OR_ZERO = " or 0";
  /**
   * @private
   * @constant
   * @static
   */
  var USE_TRUE_OR_FALSE = "Use true or false";
  
  /**
   * Fake constructor. This abstract class is supposed to be extended using {@link module:Inheritance}
   * light extension.
   * @constructor
   *
   * @exports Setter
   * @abstract
   * @class Abstract class to be  extended to gain input validation for a class' setter methods.
   * 
   * @example
   * define(["Inheritance","Setter"],function(Inheritance,Setter) {
   *   
   *   var MyClass = function() {
   *     this.exampleProperty = 1;
   *     //do stuff
   *   }
   *   
   *   MyClass.prototype = {
   *     setExampleProperty: function(newVal) {
   *       this.exampleProperty = this.checkPositiveNumber(newVal,false,false);
   *     },
   *   
   *     //declare more stuff
   *   };
   *   
   *   Inheritance(MyClass,Setter,true);
   *   return MyClass;
   * });
   * 
   */
  var Setter = function() {
    
  };

  /**
   * Checks the given value to be a valid number. The input value is first explicitly converted into 
   * a Number (e.g. null would become 0) then is checked to be a valid number and finally it is verified
   * against the input configurations.    
   * 
   * @throws {IllegalArgumentException} if the input value is not a number or does not respect one of the given constraint.
   * 
   * @param newVal {Number|String|Object} the value to be verified.
   * @param canBeZero {Boolean} specifies if the given value can be 0 or not.
   * @param canBeDecimal {Boolean} specifies if the given value can be a decimal number or not.
   * @returns {Number} The explicitly converted Number is returned. 
   * 
   * @protected
   * @memberof Setter.prototype
   */
  function checkPositiveNumber(newVal,canBeZero,canBeDecimal) {
    var tmp = new Number(newVal);
    
    if (isNaN(tmp)) {
      throw new IllegalArgumentException(VALUE_NOT_VALID+USE_NUMBER);
    } 

    if(!canBeDecimal && tmp != Math.round(tmp)) {
      throw new IllegalArgumentException(VALUE_NOT_VALID+USE_INTEGER);  
      
    } 
      
    if (canBeZero) {
      if (newVal < 0) {
        throw new IllegalArgumentException(VALUE_NOT_VALID+USE_POSITIVE+OR_ZERO);
      }
    } else if(newVal <= 0) {
      throw new IllegalArgumentException(VALUE_NOT_VALID+USE_POSITIVE);
    } 
    return tmp;
    
  }
  
  /**
   * Checks the given value to be a boolean. The check is performed with the strict equal operactor (i.e.: ===)<br/>
   * If specified, empty strings, nulls, NaN, 0s, negative numbers 
   * and undefineds are also admitted values and are interpreted as false.
   *  
   * @param newVal the value to be verified.
   * @param notStrictFalse if true anything that would not-strictly equal (==) false is considered as
   * a valid false. 
   * @returns {Boolean} 
   * 
   * @throws {IllegalArgumentException} if the input value is not a valid boolean.  
   * 
   * @protected
   * @memberof Setter.prototype
   */
  function checkBool(newVal,notStrictFalse) {
    if (newVal === true || newVal === false || (notStrictFalse && !newVal)) {
      return newVal === true;
    }
    
    throw new IllegalArgumentException(VALUE_NOT_VALID+USE_TRUE_OR_FALSE);
  }
  
  
  Setter.prototype.checkPositiveNumber = checkPositiveNumber;
  Setter.prototype.checkBool = checkBool;
  Setter.prototype["checkPositiveNumber"] = checkPositiveNumber;
  Setter.prototype["checkBool"] = checkBool;
  
  
  return Setter;
})();





