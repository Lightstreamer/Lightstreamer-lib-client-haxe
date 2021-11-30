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
import Environment from "../src-tool/Environment";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();

  var imagesNames = {
      "CONNECTING": "connecting.png",
      "CONNECTED:STREAM-SENSING": "stream_sense.png",
      "CONNECTED:WS-STREAMING": "ws_streaming.png",
      "CONNECTED:HTTP-STREAMING": "http_streaming.png",
      "CONNECTED:WS-POLLING": "ws_polling.png",
      "CONNECTED:HTTP-POLLING": "http_polling.png",
      "STALLED": "stalled.png",
      "DISCONNECTED": "disconnected.png",
      "DISCONNECTED:WILL-RETRY": "willretry.png",
      "DISCONNECTED:TRYING-RECOVERY": "recovery.png"
  };
  
  /**
   * Shows a custom image indicating the status of the connection
   * @param {String} imagesFolder the folder containing the images; the images 
   * have to be named as follows:
   * connecting.png, stream_sense.png, ws_streaming.png, http_streaming.png, 
   * ws_polling.png, http_polling.png, stalled.png, disconnected.png,
   * willretry.png, recovery.png
   */
  var StatusImageWidget = function(imagesFolder,imagesContainer,messageContainer) {
    imagesFolder = imagesFolder || "";
    this.imagesContainer = imagesContainer || null;
    this.messageContainer = messageContainer || null;
    
    if (this.messageContainer) {
      this.messageContainer.innerHTML = "DISCONNECTED";
    }
    
    if (this.imagesContainer) {
      this.preloadedImages = {};
      
      //preload images
      for (var i in imagesNames) {
        var newImg = new Image();
        newImg.src = imagesFolder+imagesNames[i];
        
        this.preloadedImages[i] = newImg;
      }
      
      this.currentSon = this.preloadedImages["DISCONNECTED"]; 
      this.imagesContainer.appendChild(this.currentSon);
      
    }
  };
  
  StatusImageWidget.prototype = {
      /**
       * @inheritdoc
       */
      onStatusChange: function(status) {
        if (this.messageContainer) {
          this.messageContainer.innerHTML = status;
        }
        
        if (this.imagesContainer) {
          var newSon = this.preloadedImages[status];
          this.imagesContainer.replaceChild(newSon,this.currentSon);
          this.currentSon = newSon;
        }
      }
  };
  
  StatusImageWidget.prototype["onStatusChange"] = StatusImageWidget.prototype.onStatusChange;
 
  return StatusImageWidget;
})();
  
  