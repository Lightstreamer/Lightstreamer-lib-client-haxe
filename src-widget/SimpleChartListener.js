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
import List from "../src-tool/List";

export default /*@__PURE__*/(function() {
  /**
   * Creates an object that will handle the positioning of the X axis and Y axis of 
   * a {@link Chart} based on a few simple configuration parameters.
   * <BR>Note that this listener expects to listen to only one Chart but can 
   * correctly handle different lines as long as they can be represented on the
   * same scale.
   * <BR>Methods from the {@link ChartListener} interface should not be called
   * directly on instances of this class.
   * @constructor
   * 
   * @param {Number} [xSpan=60] The size of the X axis. The units of the value depends on
   * the model of the {@link Chart} instance and possibly on the parser configured on
   * the {@link Chart#setXAxis} method. If not specified, then 60 will be used.
   * @param {Number} [yPerc=20] A percentage that is used for the first positioning of the
   * Y axis: the Y axis will have as initial maximum position a value that is yPerc% 
   * greater than the first Y position and as initial minimum position a value that
   * is yPerc% smaller than it. If not specified, then 20 (meaning 20%) will be used. 
   * 
   * @exports SimpleChartListener
   * @class Simple implementation of the {@link ChartListener} interface that can
   * be used to automatically adjust the axis of a {@link Chart} to center the lines on 
   * the Chart.
   * <BR>In case of an X overflow the X axis limits will shift by half
   * of their total length meaning that the next point falls in the middle of the
   * visible area so that the shifting is not continuous for each new value 
   * of X.
   * <BR>In case of an Y overflow the Y axis limits are stretched
   * in such a way that the new point falls on the visible part of the Y
   * axis.
   * <BR>Note that in case of an Y overflow all of the ChartLine instances of the
   * listened Chart will be stretched with the same values to keep the view consistent.
   * 
   * @extends ChartListener
   */
  var SimpleChartListener = function(xSpan,yPerc) {
    this.xSpan = xSpan || 60;
    yPerc = (yPerc || 20)/100;
    
    this.moreY = 1+yPerc;
    this.lessY = 1-yPerc;
    
    this.handledLines = new List();
    this.minY;
    this.maxY;
  };
  
  SimpleChartListener.prototype = {
    /**
     * @inheritdoc
     */
    onListenStart: function(chartTable) {
      this.chartTable = chartTable;
    },
    
    /**
     * @inheritdoc
     */
    onYOverflow: function(key,toUpdateChartLine,lastY,minY,maxY) {
      var shift = (maxY - minY)/2;
      if (lastY > maxY) {
        var newMax = maxY + shift;
        if (lastY > newMax) {
          newMax = lastY;
        }

        this.maxY = newMax;
        this.updateYAxis(minY,newMax);

      } else if (lastY < minY) {
        var newMin = minY - shift;
        if (lastY < newMin) {
          newMin = lastY;
        }
        
        this.minY = newMin;
        this.updateYAxis(newMin,maxY);
      } 
    },
    
    /**
     * @inheritdoc
     */
    onXOverflow: function(key, lastX, minX, maxX) {        
      if (lastX > maxX) {
        var xMid = (maxX + minX) /2;
        var diff = maxX - minX;
        this.chartTable.positionXAxis(xMid,xMid + diff);
      } //else {
        //overflow point from the other side are discarded
    },
    
    /**
     * @inheritdoc
     */
    onNewLine: function(key,newChartLine,nowX,nowY) {
      this.chartTable.positionXAxis(nowX,nowX+this.xSpan); 
      
      var localMin = nowY*this.lessY;
      var localMax = nowY*this.moreY;
      

      this.handledLines.add(newChartLine);
      this.minY = this.minY !== null && this.minY <= localMin ? this.minY : localMin; 
      this.maxY = this.maxY !== null && this.maxY >= localMax ? this.maxY : localMax; 
      
      this.updateYAxis(this.minY,this.maxY);
                
    },
    
    /**
     * @inheritdoc
     */
    onRemovedLine: function(key,removedChartLine) {
      this.handledLines.remove(removedChartLine);
    },
    
    /**
     * @private
     */
    updateYAxis: function(newMin,newMax) {
      this.handledLines.forEach(function(line) {
        line.positionYAxis(newMin,newMax);
      });
    }
  };
  
  //closure compiler exports
  SimpleChartListener.prototype["onListenStart"] = SimpleChartListener.prototype.onListenStart;
  SimpleChartListener.prototype["onYOverflow"] = SimpleChartListener.prototype.onYOverflow;
  SimpleChartListener.prototype["onXOverflow"] = SimpleChartListener.prototype.onXOverflow;
  SimpleChartListener.prototype["onNewLine"] = SimpleChartListener.prototype.onNewLine;
  SimpleChartListener.prototype["onRemovedLine"] = SimpleChartListener.prototype.onRemovedLine;
  
  return SimpleChartListener;
})();

