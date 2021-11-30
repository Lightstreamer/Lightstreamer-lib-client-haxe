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
import LoggerProxy from "./LoggerProxy";
import IllegalArgumentException from "../src-tool/IllegalArgumentException";

export default /*@__PURE__*/(function() {
  var logInstances = {};
  var currentLoggerProvider = null;
  var NOT_LOGGER_PROVIDER = "The given object is not a LoggerProvider";
  
  /**
   * This singleton should be used to obtain {@link Logger} instances to
   * be used to produce the log.
   * @exports LoggerManager
   * 
   * @example
   * define(["LoggerManager"],function(LoggerManager) {
   *  
   *  //stuff
   *  var logger = LoggerManager.getLoggerProxy("myCategory");
   *  
   *  var MyClass = function() {
   *    //more stuff
   *    logger.info("my info log");
   *    //stuff
   *    logger.error("my error log");
   *  };
   *  
   *  return MyClass;
   *  
   * });
   * 
   * //elsewhere
   * require(["MyClass","LoggerManager","MyLoggerProvider"],
   *  function(MyClass,LoggerManager,MyLoggerProvider) {
   *  
   *  LoggerManager.setLoggerProvider(new MyLoggerProvider());
   *  var m = new MyClass(); //m will send log to the MyLoggerProvider instance
   *  
   * });
   * 
   * 
   */
  var LoggerManager = {
      
    /**
     * Sets the provider that will be used to get the Logger instances; it can
     * be set and changed at any time. All the new log will be sent to the 
     * {@link Logger} instances obtained from the latest LoggerProvider set.
     * Log produced before any provider is set is discarded. 
     * 
     * @param {LoggerProvider} [newLoggerProvider] the provider to be used; if
     * missing or null all the log will be discarded until a new provider is provided.
     */  
    setLoggerProvider: function(newLoggerProvider) {
      if (newLoggerProvider && !newLoggerProvider.getLogger) {
        //null is a valid value
        throw new IllegalArgumentException(NOT_LOGGER_PROVIDER);
      }
      
      currentLoggerProvider = newLoggerProvider;
      
      //updates the alive proxies
      for (var cat in logInstances) {
        if (!currentLoggerProvider) {
          logInstances[cat].setWrappedInstance(null);
        } else {
          logInstances[cat].setWrappedInstance(currentLoggerProvider.getLogger(cat));
        }
      }
      
    },
  
    /**
     * Gets a LoggerProxy to be used to produce the log bound to a defined category.
     * One single LoggerProxy instance will be created per each category: if the method
     * is called twice for the same category then the same instance will be returned.
     * On the other hand this method can potentially cause a memory leak as once a Logger 
     * is created it will never be dismissed. It is expected that the number of 
     * categories within a single application is somewhat limited and in any case
     * not growing with time.
     * 
     * @param {String} cat The category the Logger will be bound to.
     * @returns {LoggerProxy} the instance to be used to produce the log
     * for a certain category.
     */
    getLoggerProxy: function(cat) {
      if (!logInstances[cat]) {
        if (!currentLoggerProvider) {
          logInstances[cat] = new LoggerProxy();
        } else {
          logInstances[cat] = new LoggerProxy(currentLoggerProvider.getLogger(cat));
        }
         
      }
      return logInstances[cat];
    },
    
    /**
     * @private 
     */
    resolve: function(id){ //if LogMessages is included this method will be replaced
      return id;
    }
  };
  
  LoggerManager["setLoggerProvider"] = LoggerManager.setLoggerProvider;
  LoggerManager["getLoggerProxy"] = LoggerManager.getLoggerProxy;
  LoggerManager["resolve"] = LoggerManager.resolve;
  
  return LoggerManager;
})();
  