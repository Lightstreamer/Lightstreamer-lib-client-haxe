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
export default /*@__PURE__*/(function() {
  /**
   * @private
   */
  var logLevel = {
    "FATAL": 5,
    "ERROR": 4,
    "WARN": 3,
    "INFO": 2,
    "DEBUG": 1
  };
  
  /*
  bring around numbers instead of names?
  var logNames = {
      5: "FATAL",
      4: "ERROR",
      3: "WARN",
      2: "INFO",
      1: "DEBUG"
  }*/

  /**
   * @exports SimpleLogLevels
   */
  var SimpleLogLevels = {
    /**
     * Coupling log level names with priority.
     * @static
     *
     * @param {String} level the level to be converted into priority. Admitted values are 
     * "FATAL" (5), "ERROR" (4),  "WARN" (3), "INFO" (2), "DEBUG" (1). 
     * @returns {Number} a numeric level representing the priority of the specified log level.
     * if an invalid level is specified 0 is returned.
     */
    priority: function(level) {
      return logLevel[level] || 0;
    }
    /*
    name: function(level) {
      logNames[level];
    }  
    */
  };
  
  SimpleLogLevels["priority"] = SimpleLogLevels.priority;
  //SimpleLogLevels["name"] = SimpleLogLevels.name;
  
  return SimpleLogLevels;
})();
    
  
  