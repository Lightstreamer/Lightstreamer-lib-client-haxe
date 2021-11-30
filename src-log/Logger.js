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
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports Logger
   * @class Simple Interface to be implemented to produce log.
   */
  var Logger = function() {
  };
  

  Logger.prototype = {
      
      /**
       * Receives log messages at FATAL level.
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       * 
       * @see LoggerProvider
       */
      fatal: function(message,exception) {
        
      },
      
      /**
       * Checks if this Logger is enabled for the FATAL level. 
       * The method should return true if this Logger is enabled for FATAL events, 
       * false otherwise.
       * <BR>This property is intended to let the library save computational cost by suppressing the generation of
       * log FATAL statements. However, even if the method returns false, FATAL log 
       * lines may still be received by the {@link Logger#fatal} method
       * and should be ignored by the Logger implementation. 
       * 
       * @return {boolean} true if FATAL logging is enabled, false otherwise
       */
      isFatalEnabled: function() {
        
      },
      
      /**
       * Receives log messages at ERROR level.
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      error: function(message,exception) {
        
      },
      
      /**
       * Checks if this Logger is enabled for the ERROR level. 
       * The method should return true if this Logger is enabled for ERROR events, 
       * false otherwise.
       * <BR>This property is intended to let the library save computational cost by suppressing the generation of
       * log ERROR statements. However, even if the method returns false, ERROR log 
       * lines may still be received by the {@link Logger#error} method
       * and should be ignored by the Logger implementation. 
       * 
       * @return {boolean} true if ERROR logging is enabled, false otherwise
       */
      isErrorEnabled: function() {
        
      },
      
      /**
       * Receives log messages at WARN level.
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      warn: function(message,exception) {
        
      },
      
      /**
       * Checks if this Logger is enabled for the WARN level. 
       * The method should return true if this Logger is enabled for WARN events, 
       * false otherwise.
       * <BR>This property is intended to let the library save computational cost by suppressing the generation of
       * log WARN statements. However, even if the method returns false, WARN log 
       * lines may still be received by the {@link Logger#warn} method
       * and should be ignored by the Logger implementation. 
       * 
       * @return {boolean} true if WARN logging is enabled, false otherwise
       */
      isWarnEnabled: function() {
        
      },
      
      /**
       * Receives log messages at INFO level.
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      info: function(message,exception) {
        
      },

      /**
       * Checks if this Logger is enabled for the INFO level. 
       * The method should return true if this Logger is enabled for INFO events, 
       * false otherwise.
       * <BR>This property is intended to let the library save computational cost by suppressing the generation of
       * log INFO statements. However, even if the method returns false, INFO log 
       * lines may still be received by the {@link Logger#info} method
       * and should be ignored by the Logger implementation. 
       * 
       * @return {boolean} true if INFO logging is enabled, false otherwise
       */
      isInfoEnabled: function() {
        
      },
      
      /**
       * Receives log messages at DEBUG level.
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      debug: function(message,exception) {
        
      },

      /**
       * Checks if this Logger is enabled for the DEBUG level. 
       * The method should return true if this Logger is enabled for DEBUG events, 
       * false otherwise.
       * <BR>This property is intended to let the library save computational cost by suppressing the generation of
       * log DEBUG statements. However, even if the method returns false, DEBUG log 
       * lines may still be received by the {@link Logger#debug} method
       * and should be ignored by the Logger implementation. 
       * 
       * @return {boolean} true if DEBUG logging is enabled, false otherwise
       */
      isDebugEnabled: function() {
        
      }
  };
  
  return Logger;
})();
  
  