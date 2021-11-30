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
import Helpers from "../src-tool/Helpers";

export default /*@__PURE__*/(function() {
  //used as default is*Enabled spares arguments handling
  var emptyFun = function() {
    return false;
  };
  
  //implements Logger :)
  var placeholder = {
      "error":emptyFun,
      "warn":emptyFun,
      "info":emptyFun,
      "debug":emptyFun,
      "fatal":emptyFun,
      "isDebugEnabled":emptyFun,
      "isInfoEnabled":emptyFun,
      "isWarnEnabled":emptyFun,
      "isErrorEnabled":emptyFun,
      "isFatalEnabled":emptyFun
  };
  
  
  /**
   * This constructor is used internally by {@link module:LoggerManager} and should not
   * be called manually. Use {@link module:LoggerManager.getLoggerProxy} to obtain a 
   * LoggerProxy instance.
   * @constructor
   * 
   * @exports LoggerProxy
   * 
   * @class Offers a simple proxy to {@link Logger} instances. The proxied instance can be
   * switched at any time with a different one.
   * <br>Other than the proxied methods it offers some utility methods that will join
   * together all of the specified parameters in a single string before passing it to
   * the proxied instance. 
   */
  var LoggerProxy = function(toWrap) {//called simply Log on the original .NET implementation
    this.setWrappedInstance(toWrap);
  };

  LoggerProxy.prototype = {
       
      /**
       * Called by LoggerManager to redirect the log to a different Logger
       * @param {Logger} [toWrap]
       */
      setWrappedInstance: function(toWrap) {
        this.wrappedLogger = toWrap || placeholder;
      },
      
      //fatal
      
      /**
       * Joins all the specified parameters and calls {@link Logger#fatal} on
       * the proxied instance.
       * @param {...*} mex The string or object to be logged. 
       */
      logFatal: function(mex) {
        if (!this.isFatalLogEnabled()) {
          return;
        }
        mex += this.logArguments(arguments,1);
        this.fatal(mex);
      },

      /**
       * Proxies the call to the underling {@link Logger}
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      fatal: function(mex,exc) {
        this.wrappedLogger.fatal(mex,exc);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       */
      isFatalLogEnabled: function() {
        return !this.wrappedLogger.isFatalEnabled || this.wrappedLogger.isFatalEnabled();
      },
      
      //error
     
      /**
       * Joins all the specified parameters and calls {@link Logger#error} on
       * the proxied instance.
       * @param {...*} mex The string or object to be logged. 
       */
      logError: function(mex)  {
        if (!this.isErrorLogEnabled()) {
          return;
        }
        mex += this.logArguments(arguments,1);
        this.error(mex);
      },
      
      /**
       * Joins all the specified parameters and calls {@link Logger#error} on
       * the proxied instance.
       * @param {...*} mex The string or object to be logged. 
       */
      logErrorExc: function(exc,mex) {
        if (!this.isErrorLogEnabled()) {
          return;
        }
        mex += this.logArguments(arguments,2);
        this.error(mex,exc);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      error: function(mex,exc) {
        this.wrappedLogger.error(mex,exc);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       */
      isErrorLogEnabled: function() {
        return !this.wrappedLogger.isErrorEnabled || this.wrappedLogger.isErrorEnabled();
      },

      //warn
      
      /**
       * Joins all the specified parameters and calls {@link Logger#warn} on
       * the proxied instance.
       * @param {...*} mex The string or object to be logged. 
       */
      logWarn: function(mex) {
        if (!this.isWarnLogEnabled()) {
          return;
        }
        mex += this.logArguments(arguments,1);
        this.warn(mex);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      warn: function(mex,exc) {
        this.wrappedLogger.warn(mex,exc);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       */
      isWarnLogEnabled: function() {
        return !this.wrappedLogger.isWarnEnabled || this.wrappedLogger.isWarnEnabled();
      },
      
      //info

      /**
       * Joins all the specified parameters and calls {@link Logger#info} on
       * the proxied instance.
       * @param {...*} mex The string or object to be logged. 
       */
      logInfo: function(mex) {
        if (!this.isInfoLogEnabled()) {
          return;
        }
        mex += this.logArguments(arguments,1);
        this.info(mex);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      info: function(mex,exc) {
        this.wrappedLogger.info(mex,exc);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       */
      isInfoLogEnabled: function() {
        return !this.wrappedLogger.isInfoEnabled || this.wrappedLogger.isInfoEnabled();
      },


      //debug

      /**
       * Joins all the specified parameters and calls {@link Logger#debug} on
       * the proxied instance.
       * @param {...*} mex The string or object to be logged. 
       */
      logDebug: function(mex) {
        if (!this.isDebugLogEnabled()) {
          return;
        }
        mex += this.logArguments(arguments,1);
        this.debug(mex);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       * 
       * @param {String} message The message to be logged.  
       * @param {Error} [exception] An Exception instance related to the current log message.
       */
      debug: function(mex,exc) {
        this.wrappedLogger.debug(mex,exc);
      },
      
      /**
       * Proxies the call to the underling {@link Logger}
       */
      isDebugLogEnabled: function() {
        return !this.wrappedLogger.isDebugEnabled || this.wrappedLogger.isDebugEnabled();
      },
      
      /**
       * @private
       */
      logArguments: function(args, _start){ //Joins together all of the elements of an arguments array in a custom string
        _start = _start ? _start : 0;
        var _line = " {";
        for (var i = _start; i < args.length; i++) {
          try {
            var element = args[i];
            
            if (element === null) {
              _line += "NULL";
              
            } else if (element.length < 0) {
              _line += "*";
              
            } else if (element.charAt != null) {
              _line += element;
              
            } else if (element.message) {
              _line += element.message;
              if (element.stack) {
                _line += "\n"+element.stack+"\n";
              }
              
            } else if (element[0] == element) {
              // seen on Firefox?
              _line += element;
            } else if (Helpers.isArray(element)) {
              _line += "(";
              _line += this.logArguments(element);
              _line += ")";
            } else {
              _line += element;
            }
            _line += " ";
            
          } catch (_e) {
            _line += "??? ";
          }
        }
        return _line + "}";
      }
      
      
  };
  
  //closure exports
  LoggerProxy.prototype["debug"] = LoggerProxy.prototype.debug;
  LoggerProxy.prototype["isDebugLogEnabled"] = LoggerProxy.prototype.isDebugLogEnabled;
  LoggerProxy.prototype["logDebug"] = LoggerProxy.prototype.logDebug;
  
  LoggerProxy.prototype["info"] = LoggerProxy.prototype.info;
  LoggerProxy.prototype["isInfoLogEnabled"] = LoggerProxy.prototype.isInfoLogEnabled;
  LoggerProxy.prototype["logInfo"] = LoggerProxy.prototype.logInfo;
  
  LoggerProxy.prototype["warn"] = LoggerProxy.prototype.warn;
  LoggerProxy.prototype["isWarnEnabled"] = LoggerProxy.prototype.isWarnEnabled;
  LoggerProxy.prototype["logWarn"] = LoggerProxy.prototype.logWarn;
  
  LoggerProxy.prototype["error"] = LoggerProxy.prototype.error;
  LoggerProxy.prototype["isErrorEnabled"] = LoggerProxy.prototype.isErrorEnabled;
  LoggerProxy.prototype["logError"] = LoggerProxy.prototype.logError;
  LoggerProxy.prototype["logErrorExc"] = LoggerProxy.prototype.logErrorExc;
  
  LoggerProxy.prototype["fatal"] = LoggerProxy.prototype.fatal;
  LoggerProxy.prototype["isFatalEnabled"] = LoggerProxy.prototype.isFatalEnabled;
  LoggerProxy.prototype["logFatal"] = LoggerProxy.prototype.logFatal;

  return LoggerProxy;
})();
  
