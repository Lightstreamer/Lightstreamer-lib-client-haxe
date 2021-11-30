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
   * Constructs an IllegalStateException with the specified detail message.
   * @constructor
   *
   * @param {String} message short description of the error.
   *
   * @exports IllegalStateException
   * @class Thrown to indicate that a method has been invoked at an illegal or 
   * inappropriate time or that the internal state of an object is incompatible 
   * with the call.
   * <BR>Use toString to extract details on the error occurred.
   */
  var IllegalStateException = function(message) {

    /**
     * Name of the error, contains the "IllegalStateException" String.
     * 
     * @type String
     */
    this.name = "IllegalStateException";

    /**
     * Human-readable description of the error.
     * 
     * @type String
     */
    this.message = message;

  };

  IllegalStateException.prototype = {

      toString: function() {
        return ["[",this.name,this.message,"]"].join("|");
      }
      
  };
  
  return IllegalStateException;
})();
  
