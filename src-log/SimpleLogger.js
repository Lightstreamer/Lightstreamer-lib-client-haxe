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
   * Constructor for SimpleLogger.
   * @constructor
   *
   * @param provider A SimpleLoggerProvider object instance used to dispatch the log messages
   * produced by this Logger instance.
   * @param category A category name for the Logger instance.
   * 
   * @exports SimpleLogger
   * @class {@link Logger} implementation returned by the {@link SimpleLoggerProvider}.
   * @extends Logger
   */
  var SimpleLogger = function(provider, category) {
    
    this.logProvider = provider;
    this.category = category;
    
    this.minLevel = "DEBUG";
  };
  
  SimpleLogger.prototype = {
      
    /**
     * Receives log messages at FATAL level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     * 
     * @see LoggerProvider
     */
    fatal: function(mex,exception) {
      if ( this.isFatalEnabled() ) {
        this.logProvider.dispatchLog(this.category, "FATAL", mex);
      }
      return;
    },    
    
    /**
     * Checks if this Logger is enabled for the FATAL level. 
     * The method should return true if this Logger is enabled for FATAL events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log FATAL statements. However, even if the method returns false, FATAL log 
     * lines may still be received by the {@link SimpleLogger#fatal} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if FATAL logging is enabled, false otherwise
     */
    isFatalEnabled: function() {
      return (SimpleLogLevels.priority("FATAL")>=SimpleLogLevels.priority(this.minLevel));
    },
    
    /**
     * Receives log messages at ERROR level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    error: function(mex,exception) {
      if ( this.isErrorEnabled() ) {
        this.logProvider.dispatchLog(this.category, "ERROR", mex);
      }
      return;
    },    
      
    /**
     * Checks if this Logger is enabled for the ERROR level. 
     * The method should return true if this Logger is enabled for ERROR events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log ERROR statements. However, even if the method returns false, ERROR log 
     * lines may still be received by the {@link SimpleLogger#error} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if ERROR logging is enabled, false otherwise
     */
    isErrorEnabled: function() {
      return (SimpleLogLevels.priority("ERROR")>=SimpleLogLevels.priority(this.minLevel));
    },
    
    /**
     * Receives log messages at WARN level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    warn: function(mex,exception) {
      if ( this.isWarnEnabled() ) {
        this.logProvider.dispatchLog(this.category, "WARN", mex);
      }  
      return;
    },    
      
    /**
     * Checks if this Logger is enabled for the WARN level. 
     * The method should return true if this Logger is enabled for WARN events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log WARN statements. However, even if the method returns false, WARN log 
     * lines may still be received by the {@link SimpleLogger#warn} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if WARN logging is enabled, false otherwise
     */
    isWarnEnabled: function() {
      return (SimpleLogLevels.priority("WARN")>=SimpleLogLevels.priority(this.minLevel));
    },
    
    /**
     * Receives log messages at INFO level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    info: function(mex,exception) {
      if ( this.isInfoEnabled() ) {
        this.logProvider.dispatchLog(this.category, "INFO", mex);
      }
      return;
    },    
    
    /**
     * Checks if this Logger is enabled for the INFO level. 
     * The method should return true if this Logger is enabled for INFO events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log INFO statements. However, even if the method returns false, INFO log 
     * lines may still be received by the {@link SimpleLogger#info} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if INFO logging is enabled, false otherwise
     */
    isInfoEnabled: function() {
      return (SimpleLogLevels.priority("INFO")>=SimpleLogLevels.priority(this.minLevel));
    },
    
    /**
     * Receives log messages at DEBUG level.
     * 
     * @param {String} message The message to be logged.  
     * @param {Error} [exception] An Exception instance related to the current log message.
     */
    debug: function(mex,exception) {
      if ( this.isDebugEnabled() ) {
        this.logProvider.dispatchLog(this.category, "DEBUG", mex);
      }
      return;
    },    
    
    /**
     * Checks if this Logger is enabled for the DEBUG level. 
     * The method should return true if this Logger is enabled for DEBUG events, 
     * false otherwise.
     * <BR>This property is intended to let the library save computational cost by suppressing the generation of
     * log DEBUG statements. However, even if the method returns false, DEBUG log 
     * lines may still be received by the {@link SimpleLogger#debug} method
     * and should be ignored by the Logger implementation. 
     * 
     * @return {boolean} true if DEBUG logging is enabled, false otherwise
     */
    isDebugEnabled: function() {
      return (SimpleLogLevels.priority("DEBUG")>=SimpleLogLevels.priority(this.minLevel));
    },
    
    /**
     * Call by SimpleLoggerProvider to configure the minimum log level enabled.
     *
     * @param {String} [level] log level enabled, if missing or if a not expected value is used
     * "DEBUG" is assumed
     */
    setLevel: function(level) {
      this.minLevel = SimpleLogLevels.priority(level) ? level : "DEBUG"; 
    }
  };
  
  //google closure exports
  SimpleLogger.prototype["fatal"] = SimpleLogger.prototype.fatal;
  SimpleLogger.prototype["isFatalEnabled"] = SimpleLogger.prototype.isFatalEnabled;
  SimpleLogger.prototype["error"] = SimpleLogger.prototype.error;
  SimpleLogger.prototype["isErrorEnabled"] = SimpleLogger.prototype.isErrorEnabled;
  SimpleLogger.prototype["warn"] = SimpleLogger.prototype.warn;
  SimpleLogger.prototype["isWarnEnabled"] = SimpleLogger.prototype.isWarnEnabled;
  SimpleLogger.prototype["info"] = SimpleLogger.prototype.info;
  SimpleLogger.prototype["isInfoEnabled"] = SimpleLogger.prototype.isInfoEnabled;
  SimpleLogger.prototype["debug"] = SimpleLogger.prototype.debug;
  SimpleLogger.prototype["isDebugEnabled"] = SimpleLogger.prototype.isDebugEnabled;
  SimpleLogger.prototype["setLevel"] = SimpleLogger.prototype.setLevel;
  

  
  return SimpleLogger;
})();

