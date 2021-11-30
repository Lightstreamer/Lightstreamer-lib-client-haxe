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
import Environment from "./Environment";

export default /*@__PURE__*/(function() {
  var TRIM_REGEXP = new RegExp("^\\s*([\\s\\S]*?)\\s*$");
  var COMMA = new RegExp(",","g");
  var DOT = new RegExp("\\.","g");
  
  /**
   * This module is a motley collection of simple "shortcut" methods
   * @exports Helpers
   */
  var Helpers = {
      
      /**
       * Shortcut for new Date().getTime();
       * 
       * @returns the current timestamp
       */
      getTimeStamp: function() {
        return new Date().getTime();
      },
      
      /**
       * Shortcut for Math.round( Math.random() * max );
       * @param {Number} [max=1000] The max value to be returned
       * @returns the current timestamp
       */
      randomG: function(max) {
        max = max || 1000;
        return Math.round( Math.random() * max );
      },
      
      /**
       * Trims a string
       * @param {String} str the string to be trimmed
       * @returns {String} the trimmed string
       */
      trim: function(str) {
        return str.replace(TRIM_REGEXP,"$1");
      },
      
      /**
       * Gets a string and interpret it as a Number. The given string may contain dots or commas to separate decimals
       * @param {String} val the string to be converted
       * @param {Boolean} [commaAsDecimalSeparator=false] true to interpret the commas as decimal separators, false to interpret dots as decimal separators
       * @returns {Number} the interpreted number
       * @example
       * Helpers.getNumber("3.432.771,201",true) == 3432771.201
       */
      getNumber: function(val, commaAsDecimalSeparator) {
        if (val) {
          if (!val.replace) {
            return val;
          }
          if (commaAsDecimalSeparator) {
            val = val.replace(DOT, "");
            val = val.replace(COMMA, ".");
          } else {
            val = val.replace(COMMA, "");
          }
          return new Number(val);
        }
        return 0;
      },
      
      /**
       * Shortcut for val.join && typeof(val.join) == "function"
       * @param {Object} val the object to be verified 
       * @returns {Boolean} true if val is an array, false otherwise
       */
      isArray: function(val) {
        return val && val.join && typeof(val.join) == "function";
      },
      
      /**
       * Adds a handler for a browser event. The capture flag is set to false.
       * @param {Object} obj the element to be listened to.
       * @param {String} evnt the event to be listened to.
       * @param {Function} handler the function to be called
       * @returns {Boolean} true if the event was registered, false otherwise.
       * @example 
       * Helpers.addEvent(window, "load", function(){});
       */
      addEvent: function(obj, evnt, handler){ 
        if (!Environment.isBrowserDocument()) {
          return false;
        }
        if (typeof obj.addEventListener != "undefined") {
          obj.addEventListener(evnt, handler, false);
          
        } else if (typeof obj.attachEvent != "undefined") { //old IE
          obj.attachEvent("on" + evnt, handler);
        } 
        return true;
      },
      
      /**
       * Removes a handler for a browser event. 
       * @param {Object} obj the element that is listened to.
       * @param {String} evnt the event that is listened to.
       * @param {Function} handler the function that is called
       * @returns {Boolean} true if the event was removed, false otherwise.
       */
      removeEvent: function(obj, evnt, handler){ 
        if (!Environment.isBrowserDocument()) {
          return false;
        }
        if (typeof obj.removeEventListener != "undefined") {
          obj.removeEventListener(evnt, handler, false);
          
        } else if (typeof obj.detachEvent != "undefined") { //old IE
          obj.detachEvent("on" + evnt, handler);
        } 
        return true;
      } 
  };
  
  Helpers["getTimeStamp"] = Helpers.getTimeStamp;
  Helpers["randomG"] = Helpers.randomG;
  Helpers["trim"] = Helpers.trim;
  Helpers["getNumber"] = Helpers.getNumber;
  Helpers["isArray"] = Helpers.isArray;
  Helpers["addEvent"] = Helpers.addEvent;
  Helpers["removeEvent"] = Helpers.removeEvent;
  
  return Helpers;
})();
