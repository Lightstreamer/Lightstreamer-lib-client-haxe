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
import IllegalArgumentException from "../src-tool/IllegalArgumentException";
import Environment from "../src-tool/Environment";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
    
  /**
   * Constructor for DOMAppender.
   * @constructor
   * 
   * @throws {IllegalArgumentException} if the DOMElement parameter is missing.
   * 
   * @param {String} level The threshold level at which the SimpleLogAppender is created.
   * It should be one of "DEBUG", "INFO", "WARN", "ERROR" and "FATAL". If not
   * or wrongly specified INFO is assumed.
   * @param {String} category The category this appender should listen to.
   * If not specified the appender will get log for every available category.
   * See {@link SimpleLogAppender#setCategoryFilter}.
   * @param {Object} DOMObj The DOM object to use for log message publishing.
   * 
   * @exports DOMAppender
   * @class DOMAppender extends SimpleLogAppender and implements the publishing 
   * of log messages by incrementally extending the text content of a supplied
   * container DOM object. Log lines are separated by &lt;br&gt; elements.
   * 
   * @extends SimpleLogAppender
   */
  var DOMAppender = function(level, category, DOMObj) {

    this._callSuperConstructor(DOMAppender, [level, category]);
    
    if (!DOMObj) {
      throw new IllegalArgumentException("a DOMElement instance is necessary for a DOMAppender to work.");
    }
    
    this.DOMObj = DOMObj; 
    
    this.nextOnTop = false;
    this.useInner = false;

  };
  
  
  DOMAppender.prototype = {
  
    /**
     * Setter method that specifies how new log lines have to be included 
     * in the given container DOM object. In fact, some log lines may contain
     * custom parts (for instance, field values) that may be expressed in HTML
     * and intended for HTML rendering. In this case, instead of putting the
     * log messages in text nodes, the appender can be set for directly adding messages to the
     * innerHTML of the container object.
     * <BR>WARNING: When turning HTML interpretation on, make sure that
     * no malicious code may reach the log.
     * 
     * @param {boolean} useInnerHtml Flag to switch On/Off the use of innerHTML. 
     * false by default.
     */
    setUseInnerHtml: function(useInnerHtml) {
      this.useInner = useInnerHtml === true;
    },
    
    /**
     * Setter method that specifies if new log messages have to be
     * shown on top of the previous ones.
     * 
     * @param {boolean} [nextOnTop] Layout of log messages in the DOM object; 
     * if true the newest log line is displayed on top of DOM object.
     * false by default.
     */
    setNextOnTop: function(nextOnTop) {
      this.nextOnTop = nextOnTop === true;
    },
    
    /**
     * Publish a log message on the specified DOM object. 
     * 
     * @param {String} category the logger category that produced the given message.
     * @param {String} level the logging level of the given message. It should be one of DEBUG INFO WARN ERROR FATAL.
     * @param {String} mex the message to be logged. It could be a String instance, an Error instance or any other
     * object, provided that it has a toString method.
     * @param {String} header a header for the message
     * 
     */  
    log: function(category, level, mex, header) {
      var _line = this.composeLine(category, level, mex, header);
      
      if (this.useInner) {
        if (this.nextOnTop) {
          this.DOMObj.innerHTML = _line + "<br>" + this.DOMObj.innerHTML;
        } else {
          this.DOMObj.innerHTML += _line + "<br>";
        }
      } else {
        if (this.nextOnTop) {
          var lineObj = document.createTextNode(_line);
          var brObj = document.createElement("br");

          this.DOMObj.insertBefore(brObj,this.DOMObj.firstChild);
          this.DOMObj.insertBefore(lineObj,this.DOMObj.firstChild);
        } else {
          var lineObj = document.createTextNode(_line);
          var brObj = document.createElement("br");
      
          this.DOMObj.appendChild(lineObj);
          this.DOMObj.appendChild(brObj);
        }       
      }
      
    }

  };

  //closure compiler externs
  DOMAppender.prototype["setUseInnerHtml"] = DOMAppender.prototype.setUseInnerHtml;
  DOMAppender.prototype["setNextOnTop"] = DOMAppender.prototype.setNextOnTop;
  DOMAppender.prototype["log"] = DOMAppender.prototype.log;
  
  Inheritance(DOMAppender, SimpleLogAppender);
  return DOMAppender;
})();
