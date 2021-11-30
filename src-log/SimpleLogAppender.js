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
import SimpleLogLevels from "./SimpleLogLevels";

export default /*@__PURE__*/(function() {
  /**
   * This is an abstract class; no instances of this class should be created.
   * @constructor
   * 
   * @param {String} level The threshold level at which the SimpleLogAppender is created.
   * It should be one of "DEBUG", "INFO", "WARN", "ERROR" and "FATAL". If not
   * or wrongly specified INFO is assumed.
   * @param {String} category The category this appender should listen to.
   * If not specified the appender will get log for every available category.
   * 
   * @exports SimpleLogAppender
   * @class Abstract class serving as a base class for appender classes for the {@link SimpleLoggerProvider}.
   * An instance of an appender class can be added
   * to a {@link SimpleLoggerProvider} instance in order to consume log lines.
   * <br/>Various classes that extend LogAppender and that consume the log lines
   * in various ways are provided. The definition of custom appender
   * implementations is supported through the usage of Inheritance from the utility-toolkit.
   */
  var SimpleLogAppender = function(level,category) {
 
    /**
     * @private
     */
    this.myLevel = SimpleLogLevels.priority(level) ? level : "INFO";
    
    /**
     * @private
     */
    this.catFilter = category || "*";
    
    /**
     * @private
     */
    this.myLoggerProvider = null;

  };

  SimpleLogAppender.prototype = {
      
    /**
     * Called by SimpleLoggerProvider to notify itself to a newly added appender.
     * @param {SimpleLoggerProvider} loggerProvider the SimpleLoggerProvider instance handling this appender. 
     */
    setLoggerProvider: function(loggerProvider) {
      if (loggerProvider && loggerProvider.getLogger && loggerProvider.forceLogLevelUpdate) {
        this.myLoggerProvider = loggerProvider;
      }
    },
    
    /**
     * This implementation is empty. 
     * This is the method that is supposedly written by subclasses to publish log messages
     * 
     * @param {String} category the logger category that produced the given message.
     * @param {String} level the logging level of the given message. It should be one of DEBUG INFO WARN ERROR FATAL.
     * @param {String} mex the message to be logged. It could be a String instance, an Error instance or any other
     * object, provided that it has a toString method.
     * @param {String} header a header for the message
     */
    log: function(category, level, mex, header) {
      
    },
    
    /**
     * Utility method that can be used by subclasses to join various info in a single line.
     * The message will be composed this way:  category + " | " + level + " | " + header + " | " + mex
     * @protected 
     * @param {String} category the message category
     * @param {String} level the message level
     * @param {String} mex the message itself
     * @param {String} header a custom header
     * @returns {String}
     */
    composeLine: function(category, level, mex, header) {
      return category + " | " + level + " | " + header + " | " + mex;
    },
     
    /**
     * Inquiry method that returns the current threshold level of this SimpleLogAppender 
     * instance. 
     * 
     * @return {String} the level of this SimpleLogAppender instance. 
     * It will be one of "DEBUG", "INFO", "WARN", "ERROR" and "FATAL".
     */
    getLevel: function() {
      return this.myLevel; 
    },
    
    /**
     * Setter method that changes the current threshold level of this 
     * SimpleLogAppender instance. 
     * The filter can be changed at any time and will affect subsequent log lines
     *
     * @param {String} [level] The new level for this SimpleLogAppender instance. 
     * It should be one of "DEBUG", "INFO", "WARN", "ERROR" and "FATAL". If not or wrongly
     * specified INFO will be used. 
     */
    setLevel: function(level) {
      level = SimpleLogLevels.priority(level) ? level : "INFO";
      this.myLevel = level; 
      if ( this.myLoggerProvider != null ) {
        this.myLoggerProvider.forceLogLevelUpdate();
      }
    },
    
    /**
     * Inquiry method that returns the category for this SimpleLogAppender instance. 
     * A SimpleLogAppender only receives log lines from the {@link Logger}
     * associated to the returned category, unless
     * "*" is returned, in which case it receives log from all loggers.
     * 
     * @return {String} The category of this SimpleLogAppender instance, or "*".
     */
    getCategoryFilter: function() {
      return this.catFilter; 
    },
    
    /**
     * Setter method that changes the current category of this 
     * SimpleLogAppender instance. 
     * <br/>This SimpleLogAppender will only receive log lines from the {@link Logger}
     * associated to the specified category, unless
     * "*" is specified, in which case it will receive log from all loggers.
     * <br/>the filter can be changed at any time and will affect subsequent log lines.
     * 
     * @param {String} [category] the new category for this SimpleLogAppender, or "*". 
     * If not specified "*" is assumed
     */
    setCategoryFilter: function(category) {
      this.catFilter = category || "*"; 
    }
  }; 
  
  //google closure exports
  SimpleLogAppender.prototype["log"] = SimpleLogAppender.prototype.log;
  SimpleLogAppender.prototype["setLoggerProvider"] = SimpleLogAppender.prototype.setLoggerProvider;
  SimpleLogAppender.prototype["composeLine"] = SimpleLogAppender.prototype.composeLine;
  SimpleLogAppender.prototype["getLevel"] = SimpleLogAppender.prototype.getLevel;
  SimpleLogAppender.prototype["setLevel"] = SimpleLogAppender.prototype.setLevel;
  SimpleLogAppender.prototype["getCategoryFilter"] = SimpleLogAppender.prototype.getCategoryFilter;
  SimpleLogAppender.prototype["setCategoryFilter"] = SimpleLogAppender.prototype.setCategoryFilter;
  
  
  return SimpleLogAppender;
})();
