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
import Cell from "./Cell";
import ASSERT from "../src-test/ASSERT";

export default /*@__PURE__*/(function() {
  /**
   * @private 
   */
  var ChartPainter = function(forcedDivPainting) {
    
    var useCanvas = false;
    if (!forcedDivPainting) { //forcedDivPainting is for testing purposes only
      try {
        var canvasEl = document.createElement("canvas");
        if (canvasEl.getContext){
          useCanvas = true;
        }
      } catch(e) {
      }
    }
    
    this.useCanvas = useCanvas;
    this.chartArea;
    this.lines = {};
  };
  
  
  ChartPainter.prototype = {
      setContainer: function(domElement) {
        this.chartArea = document.createElement("div");
        this.chartArea.style.position = "absolute";
        this.chartArea.style.overflow = "hidden";
        
        domElement.appendChild(this.chartArea);     
      },
      
      clean: function() {
        if (this.chartArea && Cell.isAttachedToDOM(this.chartArea)) {
          this.chartArea.parentNode.removeChild(this.chartArea);
        }
      },
      
      setSize: function(width, height) {
        this.chartArea.style.width = width + "px";
        this.chartArea.style.height = height + "px";
        this.areaHeight = height;
        this.areaWidth = width;
      },
      
      setOffset: function(offsetX,offsetY) {
        this.chartArea.style.top = offsetY + "px";
        this.chartArea.style.left = offsetX + "px";
      },
      
      setAreaStyle: function(areaStyle) {
        this.chartArea.className = areaStyle;
      },
      
      /////////////////
      
      addLine: function(chartLine) {
        var id = chartLine.getId();
        this.lines[id] = this.useCanvas ? new CanvasLine(chartLine,this) : new DivLine(chartLine,this);
      },
      
      removeLine: function(chartLine) { 
        var id = chartLine.getId();
        if (this.lines[id]) {
          this.lines[id].remove();
          delete(this.lines[id]);  
        }
      },
      
      clearLine: function(chartLine) {
        var id = chartLine.getId();
        if (this.lines[id]) {
          this.lines[id].clear();
        }
      },
      
      paintLine: function(chartLine,xval,yval) {
        var id = chartLine.getId();
        if (!this.lines[id]) {
          this.addLine(chartLine);
        }

        this.lines[id].drawTo(xval,yval);
      }
      
  };
  
  
  var CanvasLine = function(chartLine,painter) {
    this.chartLine = chartLine;
    this.lastX = null;
    this.lastY = null;
    this.painter = painter;
    this.canvasObj = null;
    this.canvasEl = null;
  };
  CanvasLine.prototype = {
      
      initCanvas: function() {

        if (!this.canvasEl) {
          var canvasEl = document.createElement("canvas");
          canvasEl.style.position = "absolute";
          canvasEl.style.overflow = "hidden";
          
          var canvasObj = canvasEl.getContext("2d");
          this.painter.chartArea.appendChild(canvasEl);  
          
          this.canvasEl = canvasEl;
          this.canvasObj = canvasObj;
        }
        
        this.canvasEl.width = this.painter.areaWidth;
        this.canvasEl.height = this.painter.areaHeight;
        
      },
      
      drawTo: function(xval,yval) {
        yval = this.painter.areaHeight - yval;
        if (this.lastX === null) {
          this.initCanvas();
          this.drawPoint(xval,yval);
          return;
        }
        this.canvasObj.beginPath();
        this.canvasObj.strokeStyle = this.chartLine.lineColor;
        this.canvasObj.lineWidth = this.chartLine.lineSize;
        this.canvasObj.moveTo(this.lastX,this.lastY);
        this.canvasObj.lineTo(xval,yval);
        this.canvasObj.stroke();
        
        
        this.drawPoint(xval,yval);
      },
      drawPoint: function(xval,yval) {
        this.lastX = xval;
        this.lastY = yval;
        
        var offset = Math.round(this.chartLine.pointSize/2);
        
        this.canvasObj.fillStyle = this.chartLine.pointColor;
        this.canvasObj.fillRect(xval-offset, yval-offset, this.chartLine.pointSize, this.chartLine.pointSize);
      },
      clear: function() {
        this.lastX = null;
        this.lastY = null;
        this.canvasObj.clearRect(0,0,this.canvasEl.width,this.canvasEl.height);
      },
      remove:function() {
        this.lastX = null;
        this.lastY = null;
        this.painter.chartArea.removeChild(this.canvasEl);
        this.canvasEl = null;
      }
  };
  
  
  var DivLine = function(chartLine,painter) {
    this.chartLine = chartLine;
    this.lastX = null;
    this.lastY = null;
    this.painter = painter;
    
    this.pointArray = [];
  };
  DivLine.prototype = {
      drawTo: function(xval,yval) {
        if (this.lastX === null) {
          this.drawPoint(xval,yval);
          return;
        } 
        
        //DRAW LINE
        var dx=xval-this.lastX;
        var dy=yval-this.lastY;

        var dxabs=Math.abs(dx);
        var dyabs=Math.abs(dy);
          
        var pix = null;
        var end = 0;
        var move = 0;
        var slope = 0;
        if (dxabs>=dyabs) {
          slope=dy/dx;
          end = dx;
          move = dx >= 0 ? 1 : -1;
        } else {
          slope=dx/dy;
          end = dy;
          move = dy >= 0 ? 1 : -1;
        }
          
        var pixDimX = 0;
        var pixDimY = 0;
        var pixRoundDimX = null;
        var pixRoundDimY = null;
        var getDim = true;
          
        var moreHorizontal = true;
        if (dxabs<dyabs) {
          moreHorizontal = false;
        } 
          
        for (var i = 0; i != end; i += move) {
          var px = 0;
          var py = 0;
          var pw = 0;
          var ph = 0;
          var isPointDiv = false;
          if ((i + move) == end) {
            isPointDiv = true;
            getDim = true;
          }
            
          pix=document.createElement("div");
          if (isPointDiv) {
            pix.style.backgroundColor = this.chartLine.pointColor;
            pix.style.width = this.chartLine.pointSize +"px";
            pix.style.height = this.chartLine.pointSize +"px";
          } else {
            pix.style.backgroundColor = this.chartLine.lineColor;
            pix.style.width = this.chartLine.lineSize +"px";
            pix.style.height = this.chartLine.lineSize +"px";
          }
          pix.style.position = "absolute";
          pix.style.fontSize = "0px";

          this.painter.chartArea.appendChild(pix);
          this.pointArray.push(pix);
          
          if (getDim) {
            getDim = false;
            pixRoundDimX = Math.ceil(pix.offsetWidth/2);
            pixRoundDimY = Math.ceil(pix.offsetHeight/2);
            pixDimX = pix.offsetWidth;
            pixDimY = pix.offsetHeight;
          }
          pw = pixDimX;
          ph = pixDimY;
          
          if (moreHorizontal) {
            //calculate the position of the new div
            px=Math.round(i+this.lastX);
            py=Math.round(this.painter.areaHeight -(slope*i+this.lastY));
            if (!isPointDiv) {
              //if not the latest one it could be bigger
              var morePoints = 0;
              //check if I can enlarge a point instead of creating a new one
              while (((i+move)!=(end-move))&&(py == Math.round(this.painter.areaHeight -(slope*(i+move)+this.lastY)))) {
                i += move;
                morePoints++;
              }
              
              var toAddDim = pixRoundDimX * morePoints;
              //increase div size
              pw = pixDimX + toAddDim;
              if (move < 0) {
                // if is going left but it grows to the right I have to move the position
                px -= toAddDim;
              }
            }
                
          } else {
            px=Math.round(slope*i+this.lastX);
            py=Math.round(this.painter.areaHeight -(i+this.lastY));
            if (!isPointDiv) {
              var morePoints = 0;
              while (((i+move)!=(end-move))&&(px == Math.round(slope*(i+move)+this.lastX))) {
                i += move;
                morePoints++;
              }
              var toAddDim = pixRoundDimY * morePoints;
              ph = pixDimY + toAddDim;
              if (move > 0) {
                py -= toAddDim;
              }
            }
          }
            
            
          px -= Math.floor(pixRoundDimX / 2);
          py -= Math.floor(pixRoundDimY / 2);
          
          pix.style.left=px + "px";
          pix.style.top=py + "px";
          pix.style.width=pw + "px";
          pix.style.height=ph + "px";
          
        }
        
        
        this.drawPoint(xval,yval);
        
        
      },
      
      drawPoint: function(xval,yval) {
        //in the div case we skip painting the initial point, 
        //other points are drawn by the main method
        //DRAW POINT
        
        this.lastX = xval;
        this.lastY = yval;
      },
      
      clear: function() {
        if (this.pointArray[0] && Cell.isAttachedToDOM(this.pointArray[0])) {
          for (var p = 0; p < this.pointArray.length; p++) {
            this.pointArray[p].parentNode.removeChild(this.pointArray[p]);
          }
        }
        
        this.pointArray = [];
        this.lastX = null;
        this.lastY = null;
      },
      
      remove:function() {
        this.clear();
      }
      
  };
  
  
  return ChartPainter;
})();
  
