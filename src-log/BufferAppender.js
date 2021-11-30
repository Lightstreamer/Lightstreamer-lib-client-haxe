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
import Inheritance from "../src-tool/Inheritance";
import SimpleLogAppender from "./SimpleLogAppender";
import SimpleLogLevels from "./SimpleLogLevels";

export default /*@__PURE__*/(function() {
  /**
   * Constructor for BufferAppender.
   * @constructor
   * 
   * @param {String} level The threshold level at which the SimpleLogAppender is created.
   * It should be one of "DEBUG", "INFO", "WARN", "ERROR" and "FATAL". If not
   * or wrongly specified INFO is assumed.
   * @param {String} category The category this appender should listen to.
   * If not specified the appender will get log for every available category.
   * See {@link SimpleLogAppender#setCategoryFilter}.
   * @param {Number} size The maximum number of log messages stored in the internal buffer. 
   * If 0 or no value is passed, unlimited is assumed.
   * 
   * @exports BufferAppender
   * @class BufferAppender extends SimpleLogAppender and implements an internal buffer 
   * store for log messages. The messages can be extracted from the buffer when needed.
   * The buffer size can be limited or unlimited. If limited it is implemented as 
   * a FIFO queue. 
   *
   * @extends SimpleLogAppender
   */
  var BufferAppender = function(level, category, size) {

    this._callSuperConstructor(BufferAppender, [level, category]);
  
    //Buffer size
    if ( !size || size < 0 ) {
      this.historyDim = 0;
    } else {
      this.historyDim = size;
    }

    //first element in the buffer
    this.first = 0;

    //last element
    this.last = -1;

    //the buffer
    this.buffer = {};
    
  };

  BufferAppender.prototype = {
      
    /**
     * Operation method that resets the buffer making it empty.
     */
    reset: function() {
      this.first = 0;
      this.last = -1;
      this.buffer = {};
    },

    /**
     * Retrieve log messages from the buffer.
     * The extracted messages are then removed from the internal buffer.
     *
     * @param {String} [sep] separator string between the log messages in the result string. If null or not specified "\n" is used.
     * 
     * @return {String} a concatenated string of all the log messages that have been retrieved.
     */
    extractLog: function(sep) {
      var res = this.getLog(null,sep);
      this.reset();
      return res;
    },
    
    /**
     * Retrieve log messages from the buffer.
     * The extracted messages are NOT removed from the internal buffer.
     *
     * @param {Number} [maxRows] the number of log lines to be retrieved. If not specified all the available lines are retrieved.
     * @param {String} [sep] separator string between the log messages in the result string. If not specified "\n" is used.
     * @param {String} [level] the level of the log to be retrieved.
     * 
     * @return {String} a concatenated string of all the log messages that have been retrieved.
     */
    getLog: function(maxRows, sep, level) {
      var i;
      var _dump = "";
        
      level = level || "DEBUG";
        
      if (!maxRows) {
        i = this.first;
      } else {   
        i = this.last - maxRows + 1;      
        if (i < this.first) {
          i = this.first;
        }
      }
       
      sep = sep || "\n";
      
      var priority = SimpleLogLevels.priority(level);
      while (i <= this.last) {
        
         if ( SimpleLogLevels.priority(this.buffer[i].level) >= priority ) {
          _dump += this.buffer[i].mex;
        }
        _dump += sep;
        i++;
      }

      return _dump;
    },
    
    /**
     * Add a log message in the internal buffer.
     * 
     * @param {String} category the logger category that produced the given message.
     * @param {String} level the logging level of the given message. It should be one of DEBUG INFO WARN ERROR FATAL.
     * @param {String} mex the message to be logged. It could be a String instance, an Error instance or any other
     * object, provided that it has a toString method.
     * @param {String} header a header for the message
     */
    log: function(category, level, mex, header) {
      var i = ++this.last;
      
      if ( this.historyDim != 0 && i >= this.historyDim ) {
        this.buffer[this.first] = null;
        this.first++;
      }
      
      mex = this.composeLine(category, level, mex, header);
      this.buffer[i] = {
          level: level,
          mex: mex
      };

    },
    
    /**
     * Gets the number of buffered lines
     * @returns {Number} the number of buffered lines
     */
    getLength: function() {
      return this.last-this.first+1;
    }
    
  

  };
  
  BufferAppender.prototype["reset"] = BufferAppender.prototype.reset;
  BufferAppender.prototype["getLog"] = BufferAppender.prototype.getLog;
  BufferAppender.prototype["extractLog"] = BufferAppender.prototype.extractLog;
  BufferAppender.prototype["log"] = BufferAppender.prototype.log;
  BufferAppender.prototype["getLength"] = BufferAppender.prototype.getLength;
  
  Inheritance(BufferAppender, SimpleLogAppender);
  return BufferAppender;
})();  
