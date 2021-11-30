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
import LightstreamerConstants from "./LightstreamerConstants";
import Executor from "../src-tool/Executor";
import Environment from "../src-tool/Environment";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
  
  var MAX_POINTS = 3;
  var THREAD_TIME = 1000;
  
  
  /**
   * Creates an object to be used to listen to events from a 
   * {@link LightstreamerClient} instance.
   * The created object will try to update the Status Bar of the browser with 
   * information about the status of the connection. It will also display
   * an "animation" to represent the activity of the connection with a series of
   * dots growing and decreasing over time.
   * <BR>Note that most modern browsers don't have or hide the status bar or prevent 
   * client code from writing in it.
   * @constructor
   * 
   * @param {Number} threadTime This is the interval (expressed in milliseconds) 
   * between each frame of the "animation". If not specified will default to 1000
   * (1 second).
   * @param {Number} points The number of dots to be shown before resetting to 0 and
   * starting over. If not specified will default to 3.
   * 
   * @class This class is a simple implementation of the {@link ClientListener}
   * interface that will print information about the status of the connection
   * in the status bar of the browser.
   * 
   * @extends ClientListener
   */
  var StatusBarProgressIndicator = function(threadTime,points) {
    this.statusBarText = "";
    this.pN = 0;
    this.cycle = false;
    this.currentStatus = LightstreamerConstants.DISCONNECTED;
    this.changeStatusThread=null;
    this.threadTime = threadTime || THREAD_TIME;
    this.points = points || MAX_POINTS;
  };

  var wsSTR = LightstreamerConstants.CONNECTED + LightstreamerConstants.WS_STREAMING;
  var httpSTR = LightstreamerConstants.CONNECTED + LightstreamerConstants.HTTP_STREAMING;
  var wsPOLL = LightstreamerConstants.CONNECTED + LightstreamerConstants.WS_POLLING;
  var httpPOLL = LightstreamerConstants.CONNECTED + LightstreamerConstants.HTTP_POLLING;
  var sensing = LightstreamerConstants.CONNECTED + LightstreamerConstants.SENSE;
  
  
  StatusBarProgressIndicator.prototype = {
      /**
       * @inheritdoc
       */
      onStatusChange: function(status) {
        if (status) {
          this.currentStatus = status;
          this.pN = 0;
        }
        
        var totalText = "Lightstreamer ";
         
        if (this.currentStatus == wsSTR || this.currentStatus == httpSTR) {
          totalText += "is in streaming mode";
        } else if (this.currentStatus == sensing) {
          totalText += "is stream-sensing";
        } else if (this.currentStatus == wsPOLL || this.currentStatus == httpPOLL) {
          totalText += "is in smart polling mode";
        } else if (this.currentStatus == LightstreamerConstants.STALLED) {  
          totalText += "connection is stalled";
        } else if (this.currentStatus == LightstreamerConstants.WILL_RETRY) {  
          totalText += "is disconnected; a new connection will be established soon";
        } else if (this.currentStatus == LightstreamerConstants.TRYING_RECOVERY) {  
          totalText += "is disconnected, but trying to recover the current session";
        } else if (this.currentStatus == LightstreamerConstants.DISCONNECTED) {  
          totalText += "is disconnected."; 
        } else { //CONNECTING
          totalText += "is connecting";
        }
        
        var alive = this.currentStatus != LightstreamerConstants.DISCONNECTED && this.currentStatus != LightstreamerConstants.STALLED;
                
        if (alive) {
          for (var i = 1; i <= this.pN; i++) {
            totalText = totalText + ".";
          }
          if (this.pN >= this.points) {
            this.pN = 0;
          } else {
            this.pN++;
          }
        } 
        window.status = totalText;
      },
      
      /**
       * @private
       */
      stopRefreshing: function() {
        if (this.changeStatusThread) {
          Executor.stopRepetitiveTask(this.changeStatusThread);
          window.status = "";
        }
      },
      
      /**
       * @private
       */
      startRefreshing: function() {
        if (!this.changeStatusThread) {
          this.changeStatusThread = Executor.addRepetitiveTask(this.onStatusChange,this.threadTime,this);
        }
      },
      
      /**
       * @inheritdoc
       */
      onListenStart: function(lsClient) {
        this.startRefreshing();
        
        this.onStatusChange(lsClient.getStatus());
      },
      
      /**
       * @inheritdoc
       */
      onListenEnd: function(lsClient) {
        this.stopRefreshing();
      }
      
  };
  
  StatusBarProgressIndicator.prototype["onStatusChange"] = StatusBarProgressIndicator.prototype.onStatusChange;
  StatusBarProgressIndicator.prototype["onListenStart"] = StatusBarProgressIndicator.prototype.onListenStart;
  StatusBarProgressIndicator.prototype["onListenEnd"] = StatusBarProgressIndicator.prototype.onListenEnd;

  return StatusBarProgressIndicator;
})();
  
  