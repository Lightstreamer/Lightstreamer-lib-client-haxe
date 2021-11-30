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
import Helpers from "./Helpers";
import BrowserDetection from "./BrowserDetection";
import Environment from "./Environment";
import List from "./List";

export default /*@__PURE__*/(function() {
  //do not use EventDispatcher/Executor to avoid circular dependencies hell
    
  var onunloadFunctions = new List();
  var onloadFunctions = new List();  
  var onbeforeunloadFunctions = new List();
  var controlLoadTimeout = 1000;
  
  var isDOMLoaded = false;
  
  //closure compiler trick -->
  var names = {
    onloadDone : "onloadDone",
    onloadInprogress : "onloadInprogress",
    unloaded : "unloaded",
    unloading : "unloading",
    preunloading : "preunloading"
  };
  var reverse = {};
  for (var i in names) {
    reverse[names[i]] = i;
  }
  //<-- closure compiler trick
 
  
  function getOnloadClosure(that) {
    return getEventClosure(that,reverse['onloadDone'],reverse['onloadInprogress'],onloadFunctions,'onloadEvent');
  }
  
  function getUnloadClosure(that) {
    return getEventClosure(that,reverse['unloaded'],reverse['unloading'],onunloadFunctions,'unloadEvent');
  }
  
  function getBeforeUnloadClosure(that) {
    return getEventClosure(that,reverse['preunloading'],reverse['preunloading'],onbeforeunloadFunctions,'preUnloadEvent');
  }
  
  
  function getEventClosure(that,toCheck,toSet,toExe,methodName) {
    return function() {
      if (that[toCheck]) {
        return;
      }
      that[toSet] = true;
      
      toExe.forEach(function(elToExe) {
        try {
          singleEventExecution(elToExe,methodName);
        } catch (_e) {
        }
      });
      
      if (toCheck != 'preunloading') {
        toExe.clean();
      }

      that[toCheck] = true;
      that[toSet] = false;
    };
    
  }
  
  function singleEventExecution(elToExe,methodName) {
    if (elToExe[methodName]) {
      elToExe[methodName]();
    } else {
      elToExe();
    }
  }
  
  function asynchSingleEventExecution(elToExe,methodName) { 
    setTimeout(function() {
      singleEventExecution(elToExe,methodName);
    },0);
  }
  
  function executeLater(what,when,who,how) { 
    setTimeout(function() {
      if (who) {
        if (how) {
          what.apply(who,how);
        } else {
          what.apply(who);
        }
      } else if (how) {
        what.apply(null, how);
      } else {
        what();
      }
    },when);
  }
  
  function DOMloaded() {
    isDOMLoaded = true; //no need to initialize it anywhere
  }
    
  /**
   * Tries to track the loading status of the page. It may fallback to using timeouts or DOMContentLoaded events to address browser compatibilities: in such
   * cases there is a chance that the registered onload handlers are fired before the actual onload is. Also unload and beforeunload may not fire at all.
   * @exports EnvironmentStatus
   */
  var EnvironmentStatus = {
    /**
     * @private
     */
    onloadDone: false,
    /**
     * @private
     */
    onloadInprogress: false,
    /**
     * @private
     */
    unloaded: false,
    /**
     * @private
     */
    unloading: false,
    /**
     * @private
     */
    preunloading: false,
    
    /**
     * Checks if the load event has been fired.
     * @returns {Boolean} true if the load event has already been fired, false otherwise.
     */
    isLoaded: function() {
      return this.onloadDone;
    },
    /**
     * Checks if the unload event has been fired.
     * @returns {Boolean} true if the unload event has already been fired, false otherwise.
     */
    isUnloaded : function() {
      return this.unloaded;
    },
    /**
     * Checks if the unload event is currently being handled.
     * @returns {Boolean} true if the unload event is currently being handled, false otherwise.
     */
    isUnloading: function() {
      return this.unloading;
    },
    
    /**
     * Adds a handler for the load event. If the event was already fired the handler is sent in a setTimeout (with a 0 timeout).
     * @param {Function|EnvironmentStatusListener} the function to be executed or an object containing the onloadEvent function to be executed. 
     */
    addOnloadHandler: function(f) {
      if (this.isPreOnload()) {
        onloadFunctions.add(f);
      } else {
        asynchSingleEventExecution(f,'onloadEvent');
      }
    },
    
    /**
     * Adds a handler for the unload event. If the event was already fired the handler is sent in a setTimeout (with a 0 timeout).
     * @param {Function|EnvironmentStatusListener} the function to be executed or an object containing the unloadEvent function to be executed. 
     */
    addUnloadHandler: function(f) {
      if (this.isPreUnload()) {
        onunloadFunctions.add(f);
      } else {
        asynchSingleEventExecution(f,'unloadEvent');
      }
    },
    
    /**
     * Adds a handler for the onbeforeunload event.
     * @param {Function|EnvironmentStatusListener} the function to be executed or an object containing the preUnloadEvent function to be executed. 
     */
    addBeforeUnloadHandler: function(f) {
      onbeforeunloadFunctions.add(f);
      if (this.preunloading) {
        asynchSingleEventExecution(f,'preUnloadEvent');
      }
    },
    
    /**
     * Removes the specified load handler if present, otherwise it does nothing. 
     * @param {Function|EnvironmentStatusListener} the function or object to be removed
     */
    removeOnloadHandler: function(f) {
      onloadFunctions.remove(f);
    },
    
    /**
     * Removes the specified unload handler if present, otherwise it does nothing. 
     * @param {Function|EnvironmentStatusListener} the function or object to be removed
     */
    removeUnloadHandler: function(f) {
      onunloadFunctions.remove(f);
    },
    
    /**
     * Removes the specified onbeforeunload handler if present, otherwise it does nothing. 
     * @param {Function|EnvironmentStatusListener} the function or object to be removed.
     */
    removeBeforeUnloadHandler: function(f) {
      onbeforeunloadFunctions.remove(f);
    },
    
    /**
     * @private
     */
    isPreOnload: function() {
      return !(this.onloadDone || this.onloadInprogress);
    },
    
    /**
     * @private
     */
    isPreUnload: function() {
      return !(this.unloaded || this.unloading);
    },
  
    /**
     * @private
     */
    attachToWindow: function() {
      Helpers.addEvent(window,"unload",this.closeFun);
      Helpers.addEvent(window,"beforeunload",this.beforeCloseFun);
      
      //EXPERIMENTAL
      if (document && typeof document.readyState != "undefined") {
        var strState = document.readyState;
        if (strState.toUpperCase() == "COMPLETE") {
          //already loaded
          this.asynchExecution();
          return;
        } else {
          //It may happen that readyState is not "completed" but the onload
          //was already fired. We fire a timeout to check the case
          executeLater(this.controlReadyStateLoad,controlLoadTimeout,this);
        }
      } else if(this.isInBody()) {
        //already loaded
        this.asynchExecution();
        return;
      }
      //EXPERIMENTAL end
      

      var done = Helpers.addEvent(window,"load",this.readyFun);
      if (!done) {
        //Can't append an event listener to the onload event (webworker / nodejs)
        //Let's launch a timeout 
        this.asynchExecution(); //should not happen since we did the check on the module setup, why did we keep it?
      } else if (BrowserDetection.isProbablyOldOpera()) {
        //Old Opera did not fire the onload event on a page wrapped
        //in an iFrame if a brother iFrame is still loading (in the
        //worst case the second iFrame is a forever-frame)
        //To prevent the case we will fire a fake onload
       
        
        var checkDOM = false;
        //on Opera < 9 DOMContentLoaded does not exist, so we can't wait for it
        if (BrowserDetection.isProbablyOldOpera(9, false)) {
          checkDOM = true;
          //DOMContentLoaded did not fire yet or we should have not reach this point 
          //as per the readyState/isInBody checks
          Helpers.addEvent(document,"DOMContentLoaded",DOMloaded);
        } 
        executeLater(this.controlOperaLoad,controlLoadTimeout,this,[checkDOM]);
        
      }
    },
    
    /**
     * @private
     */
    asynchExecution: function() {
      executeLater(this.readyFun,0);
    },
    
    /**
     * @private
     */
    controlReadyStateLoad: function() {
      if (!this.onloadDone) {
        //onload not yet fired
        var strState = document.readyState;
        if (strState.toUpperCase() == "COMPLETE") {
          this.readyFun();
        } else {
          executeLater(this.controlReadyStateLoad,controlLoadTimeout,this);
        }
      }
    },
    
    /**
     * @private
     */
    controlOperaLoad: function(checkDOM) {
      if (!this.onloadDone) {
        //onload not yet fired
        if (isDOMLoaded || !checkDOM && this.isInBody()) {
          //DOM is there
          //let's fake the onload event
          this.readyFun(); 
        } else {
          //body is still missing
          executeLater(this.controlOperaLoad,controlLoadTimeout,this,[checkDOM]);
        }
      }
    },
    
    /**
     * @private
     */
    isInBody: function() {
      return (typeof document.getElementsByTagName != "undefined" && typeof document.getElementById != "undefined" && ( document.getElementsByTagName("body")[0] != null || document.body != null ) );
    }
    
  };
  
  
  EnvironmentStatus.readyFun = getOnloadClosure(EnvironmentStatus);
  EnvironmentStatus.closeFun = getUnloadClosure(EnvironmentStatus);
  EnvironmentStatus.beforeCloseFun = getBeforeUnloadClosure(EnvironmentStatus);
  if (Environment.isBrowserDocument()) {
    EnvironmentStatus.attachToWindow();
  } else {
    EnvironmentStatus.asynchExecution();
  }
  
  
  
  EnvironmentStatus["addOnloadHandler"] = EnvironmentStatus.addOnloadHandler;
  EnvironmentStatus["addUnloadHandler"] = EnvironmentStatus.addUnloadHandler;
  EnvironmentStatus["addBeforeUnloadHandler"] = EnvironmentStatus.addBeforeUnloadHandler;
  EnvironmentStatus["removeOnloadHandler"] = EnvironmentStatus.removeOnloadHandler;
  EnvironmentStatus["removeUnloadHandler"] = EnvironmentStatus.removeUnloadHandler;
  EnvironmentStatus["removeBeforeUnloadHandler"] = EnvironmentStatus.removeBeforeUnloadHandler;
  EnvironmentStatus["isLoaded"] = EnvironmentStatus.isLoaded;
  EnvironmentStatus["isUnloaded"] = EnvironmentStatus.isUnloaded;
  EnvironmentStatus["isUnloading"] = EnvironmentStatus.isUnloading;
  
  
  
  /**
   * This constructor does nothing
   * @constructor
   * 
   * @exports EnvironmentStatusListener
   * @class Interface that can be implemented to listen to {@link module:EnvironmentStatus} events.
   */
  var EnvironmentStatusListener = function() { //only for jsdoc sake, closure will remove it
    
  };
  EnvironmentStatusListener.prototype = {
      /**
       * @see module:EnvironmentStatus.addOnloadHandler
       */
      onloadEvent: function() {
        
      },
      /**
       * @see module:EnvironmentStatus.addUnloadHandler
       */
      unloadEvent: function() {
        
      },
      /**
       * @see module:EnvironmentStatus.addBeforeUnloadHandler
       */
      preUnloadEvent: function() {
        
      }
  };
  
  return EnvironmentStatus;
})();
  
