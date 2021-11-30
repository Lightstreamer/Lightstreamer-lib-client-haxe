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
import IllegalStateException from "./IllegalStateException";

export default /*@__PURE__*/(function() {
  var isBrowserDocumentVar = (typeof window !== "undefined"  && typeof navigator !== "undefined" && typeof document !== "undefined");
  var isWebWorkerVar = typeof importScripts !== "undefined"; //potentially WebWorkers may appear on node.js
  var isNodeJSVar = typeof process == "object" && (/node(\.exe)?$/.test(process.execPath) || (process.node && process.v8) || (process.versions && process.versions.node && process.versions.v8 ));
  
  if (isBrowserDocumentVar && !document.getElementById) {
    throw new IllegalStateException("Not supported browser");
  }
  /**
   * @exports Environment
   */
  var Environment = {
      
      /**
       * Checks if the code is running inside an HTML document.
       * <BR/>Note that browsers not supporting DOM Level 2 (i.e.: document.getElementById) 
       * are not recognized by this method
       * 
       * @returns {Boolean} true if the code is running inside a Browser document, false otherwise.
       * 
       * @static
       */
      isBrowserDocument: function() {
        return isBrowserDocumentVar;
      },
      
      /**
       * Checks if the code is running inside a Browser. The code might be either running inside a
       * HTML page or inside a WebWorker.
       * <BR/>Note that browsers not supporting DOM Level 2 (i.e.: document.getElementById) 
       * are not recognized by this method
       * 
       * @returns {Boolean} true if the code is running inside a Browser, false otherwise.
       * 
       * @static
       */
      isBrowser: function() {
        return !isNodeJSVar && (isBrowserDocumentVar || isWebWorkerVar);
      },
      
      /**
       * Checks if the code is running inside Node.js.
       * 
       * @returns {Boolean} true if the code is running inside Node.js, false otherwise.
       * 
       * @static
       */
      isNodeJS: function() {
        return !isBrowserDocumentVar && isNodeJSVar;
      },
      
      /**
       * Checks if the code is running inside a WebWorker.
       * 
       * @returns {Boolean} true if the code is running inside a WebWorker, false otherwise.
       * 
       * @static
       */
      isWebWorker: function() {
        return !isBrowserDocumentVar && !isNodeJSVar && isWebWorkerVar;
      },

      /**
       * Checks if the code is not running on a known environment
       * @returns {boolean} true if the code not running on a known environment, false otherwise.
       */
      isOther: function() {
        return !isBrowserDocumentVar && !isNodeJSVar && !isWebWorkerVar;
      },

      /**
       * Helper method that will throw an IllegalStateException if the return value of isBrowserDocument is false.
       * This method is supposedly called as first thing in a module definition.
       * 
       * @throws {IllegalStateException} if this function is not called inside a HTML page. The message of the error
       * is the following: "Trying to load a browser-only module on non-browser environment".
       * 
       * @static
       * 
       * @example
       * define(["Environment"],function(Environment) {
       *   Environment.browserDocumentOrDie();
       *   
       *   //module definition here
       * });
       */
      browserDocumentOrDie: function() {
        if(!this.isBrowserDocument()) {
          throw new IllegalStateException("Trying to load a browser-only module on non-browser environment");
        }
      }
  
  };
  
  Environment["isBrowserDocument"] = Environment.isBrowserDocument;
  Environment["isBrowser"] = Environment.isBrowser;
  Environment["isNodeJS"] = Environment.isNodeJS;
  Environment["isWebWorker"] = Environment.isWebWorker;
  Environment["browserDocumentOrDie"] = Environment.browserDocumentOrDie;
    
  return Environment;
})();
    
