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
import Executor from "./Executor";

export default /*@__PURE__*/(function() {
  var TOUCH_TIMEOUT = 5000;
  /**
   * This constructor simply calls the {@link Dismissable#initTouches initTouches} method. This abstract class is supposed 
   * to be extended using {@link module:Inheritance} extension.
   * It can be either light extended or fully extended. When light extension is performed
   * the {@link Dismissable#initTouches initTouches} method should be called in the extended class constructor.
   * <br/>For this class to properly work the {@link Dismissable#clean clean} method that releases the resources needs to be implemented.
   * @constructor
   * 
   * @exports Dismissable
   * @class Abstract class. Instances of extended classes can be used to keep track of the uses of a certain resources that can then be trashed 
   * after a timeout once it is no more used by anyone.
   */
  var Dismissable = function() {
    this.initTouches();
  };
  
  Dismissable.prototype = {
    
      /**
       * Abstract method that needs to be implemented to clean the used resources. This method is called internally after
       * a timeout when all of the uses ( i.e. calls to {@link Dismissable#touch touch} ) were dismissed (using {@link Dismissable#dismiss dismiss}).
       * @abstract
       */
      clean: function() {}, 
      
      /**
       * Method to be called to initialize the use of the Dismissable features.
       * If not called {@link Dismissable#touch touch} and {@link Dismissable#dismiss dismiss} calls will fail. Ideally this method
       * should be called in the constructor.
       * @protected
       *
       * @param {Number} timeout the time in ms to wait after all the uses were dismissed before actually clean the resources.
       * If a new call to {@link Dismissable#touch touch} is performed before the timeout is expired the clean is postponed until the 
       * touches count is back to 0 again. If not specified 5000 (5 seconds) is used.
       */
      initTouches: function(timeout) {
        this.inUse = 0;
        this.touchPhase = 0;
        this.timeout = timeout || TOUCH_TIMEOUT;
      },
      
      /**
       * @private
       */
      verifyTouches: function(ph) {
        if (ph == this.touchPhase && this.inUse <= 0) {
          this.clean();
        }
      },
      
      /**
       * Method to be called to declare that this instance is not in use anymore by some component. 
       * This method should only be called once per each previous {@link Dismissable#touch touch} call or the resource may be 
       * dismissed while some piece of code still needs it.
       */
      dismiss: function() {
        this.inUse--;
        
        if (this.inUse <= 0) {
          Executor.addTimedTask(this.verifyTouches,this.timeout,this,[this.touchPhase]);
        }
      },
      
      /**
       * Method to be called to declare that this instance is in use by some component. Per each
       * touch call a {@link Dismissable#dismiss dismiss} call should be called at some point or the resources will 
       * never be released.
       */
      touch: function() {
        this.touchPhase++;
        if (this.inUse < 0){
          this.inUse=0;
        }
        this.inUse++;
      }
      
      
  };
  
  //closure compiler exports
  Dismissable.prototype["touch"] = Dismissable.prototype.touch;
  Dismissable.prototype["dismiss"] = Dismissable.prototype.dismiss;
  Dismissable.prototype["clean"] = Dismissable.prototype.clean;
  Dismissable.prototype["initTouches"] = Dismissable.prototype.initTouches;
  
  return Dismissable;
})();
  
  
