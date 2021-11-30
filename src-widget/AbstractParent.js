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
  var AbstractParent = function(){};
  
  /**
   * @private
   */
  AbstractParent.prototype = {
    /**
     * common ancestor for VisibleParent (oneMap = true) and 
     * invisibleParent (oneMap = false)
     */
    init: function() {
      this.length = 0;
      this.hashMap = {};
      if (!this.oneMap) {
        this.map = {};
      }
    }    
  };
  
  return AbstractParent;
})();
  
