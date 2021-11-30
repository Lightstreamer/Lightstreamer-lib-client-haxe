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
import AbstractWidget from "./AbstractWidget";
import Cell from "./Cell";
import LoggerManager from "../src-log/LoggerManager";
import Inheritance from "../src-tool/Inheritance";
import Helpers from "../src-tool/Helpers";
import Environment from "../src-tool/Environment";
import ChartLine from "./ChartLine";
import ChartPainter from "./ChartPainter";
import IllegalStateException from "../src-tool/IllegalStateException";
import IllegalArgumentException from "../src-tool/IllegalArgumentException";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
  
  var NO_ANCHOR = "A DOM element must be provided as an anchor for the chart";
  
  function getRelativeValue(value, min, unit) {
    var val = new Number(value);
    var n = (val - min) / unit;
    return Math.round(n);
  }
  
  var gridsLogger = LoggerManager.getLoggerProxy("lightstreamer.charts");
  
  
  /*
   
   ______________________________
   | _anchor                    |
   |  ____________________      |
   |  | caContainer       |     |
   |  | ______________    |     |
   |  | | chartarea  |    |     |
   |  | |____________|    |     |
   |  | _____________     |     |
   |  | | label1    |     |     |
   |  | |___________|     |     |
   |  | _____________     |     |
   |  | | label2    |     |     |
   |  | |___________|     |     |
   |  | _____________     |     |
   |  | | labelN    |     |     |
   |  | |___________|     |     |
   |  |                   |     |
   |  |___________________|     |
   |____________________________|
   
   
   caContainer -> pos relative - overflow visible
   chartArea   -> pos absolute - overflow hidden
   
   
   */
  
  
  /**
   * Creates an object that extends {@link AbstractWidget} displaying its values
   * as a multiline chart.
   * <BR>Note that the {@link AbstractWidget#parseHtml} method is automatically called by this
   * constructor, hence the container element should have already been prepared on the page DOM. 
   * However, preparing the element later and then invoking {@link AbstractWidget#parseHtml}
   * manually is also supported.
   * @constructor
   *
   * @param {String} id The HTML "id" attribute of a DOM Element to which the chart will be attached.
   * 
   * @exports Chart
   * @class A widget displaying the data from its model as a multiline chart.
   * As with all the classes extending {@link AbstractWidget} the internal model
   * can be automatically updated by listening to one or more {@link Subscription}
   * instances. 
   * <BR>In short, once both X and Y axis have been associated to a field through 
   * {@link Chart#setXAxis} and {@link Chart#addYAxis},
   * each row in the model will be represented as a line in the chart,
   * connecting all the X,Y points corresponding to the subsequent values assumed
   * by the related fields and dynamically extending with new values. Actually,
   * it is possible to associate more fields to the Y axis so that it is possible to
   * have more than one line per row. 
   * <BR>According to the axis settings, every time a row enters the model,
   * one or more lines will be added to the chart and corresponding instances of
   * {@link ChartLine} will be generated 
   * and passed to the {@link ChartListener#onNewLine} event to be better
   * configured.
   * <BR>The behavior of the underlying model is described in {@link AbstractWidget},
   * but there is one exception: if this instance is used to listen to events from 
   * {@link Subscription} instance(s), and the first Subscription it listens to is
   * a DISTINCT Subscription, then the base behavior is overridden and the same
   * behavior defined for MERGE and RAW modes is adopted.
   * <BR>
   * <BR>Note that, in order to create a chart, the X axis should be associated
   * with a field whose values are increasing. Anyway for both X and Y axis
   * the used value must be a numeric value. If the original field values are not 
   * compliant with such restriction, they can be customized before being used by 
   * means of a parser Function.
   * <BR>Also, even if the Chart instance is listening to {@link Subscription} events,
   * it is not mandatory to use server-sent fields to plot the chart.
   * <BR>The multiline chart for the visualization of model values is
   * dynamically maintained by an instance of this class inside a container HTML 
   * element.
   * The container element must be prepared on the page in the form of any HTML 
   * element owning the "data-source='Lightstreamer'" special attribute, together 
   * with an HTML "id" attribute that has to be specified in the constructor of this class.
   * 
   * @extends AbstractWidget
   */
  var Chart = function(id) { 
    this._callSuperConstructor(Chart,arguments);
    
    this.caContainer = document.createElement("div");
    this.caContainer.style.position = "relative";
    this.caContainer.style.overflow = "visible";
    
    
    this.areaClass = "";
    this.offsetY = 0; //distance from top
    this.offsetX = 0; //distance from left
    this.screenX = null; //area width in pixel
    this.screenY = null; //area height in pixel
    this.labels = [];
    
    this.labelsFormatter = null;
    
    this.numXLabels = 0; 
    this.xFieldCode = null;
    
    this.xMin = null; //the 0 value
    this.xMax = null; //the maximum value
    this.xUnit = null; //value of a pixel
    this.xParser = null; 
    
    //by field
    this.chartArray = {};
    this.yParsers = {};
    
    this.forcedDivPainting = false;
    this.painter = null;

    this.parseHtml();
 
  };
  
  Chart.prototype = {
      /**
       * @ignore
       */
      toString: function() {
        return ["[","Chart",this.id,"]"].join("|");
      },
      
      /**
       * @ignore
       */
      forceDivPainting: function(forced) {
        //only for test purposes, disable the use of canvas methods
        this.forcedDivPainting = forced === true;
      },
      
      /**
       * @private
       */
      initPainter: function() {
        this.painter = new ChartPainter(this.forcedDivPainting);
        this.painter.setContainer(this.caContainer);
        
        this.configurePainter();
      },
      
      /**
       * @private
       */
      configurePainter: function() {
        if (this.painter) {
          this.painter.setSize(this.screenX,this.screenY);
          this.painter.setOffset(this.offsetX,this.offsetY);
          this.painter.setAreaStyle(this.areaClass);
          
          gridsLogger.logDebug("Painter configured");
        }
      },

      /**
       * @private
       */
      setChartAnchor: function(anchor,cleaning) {
        if (this.painter) {
          return;
        }
                
        if (anchor && anchor.appendChild) {
          
          anchor.appendChild(this.caContainer);
          
          if (this.screenX == null) {
            this.screenX = anchor.offsetWidth;
          }
          if (this.screenY == null) {
            this.screenY = anchor.offsetHeight;
          }
          
          this.initPainter();
          
          if (this.xMax != null) {
            this.calcXUnit(); 
            this.paintXLabels(); //screenX - xMax - chartArea.parentNode
          }
          
          for (var yField in this.chartArray) {
            for (var line in this.chartArray[yField]) {
              var cLine = this.chartArray[yField][line];
              if (cLine && cLine.isYAxisPositioned()) {
                cLine.calcYUnit(); 
                cLine.paintYLabels(); //screenY - yMax - chartArea.parentNode
              }
            }
          }         
          
          gridsLogger.logInfo("Chart is now ready to be used",this,anchor);
        } else if (!cleaning) {
          //should never pass from here
          gridsLogger.logError("A DOM element must be provided as an anchor for the chart",this);
        }
      },
      
      /**
       * @private
       */
      createLabel: function(lblClass, text, pos, axis) {
        gridsLogger.logDebug("Creating a new label for the chart",this);
        
        var lbl=document.createElement("div");
        if (lblClass != null) {
            lbl.className = lblClass;
        }
        lbl.style.position = "absolute";
        var txt = document.createTextNode(text);
        lbl.appendChild(txt);
       
        this.caContainer.appendChild(lbl);
         
         var labelWidth = lbl.offsetWidth;
         if (axis.toUpperCase() == "X") {
           lbl.style.top = (this.screenY + 5 + this.offsetY) + "px";
           lbl.style.left = (pos - (lbl.offsetWidth / 2) + this.offsetX) + "px";
        } else if (axis.toUpperCase() == "Y") {
           lbl.style.left = (this.offsetX - labelWidth) + "px";
           lbl.style.top = ((this.screenY - pos) - (lbl.offsetHeight / 2) + this.offsetY) + "px";
        }
          
        return lbl;
      },
      
      /**
       * @ignore
       */
      clearLine: function(currLine) {
        this.painter.clearLine(currLine);
      },
      
      /**
       * @ignore
       */
      drawLine: function(xvalo, yvalo, currLine) {

        if (gridsLogger.isDebugLogEnabled()) {
          gridsLogger.logDebug("Drawing line on the chart",this);
        }
        
        //from values to pixels
        var xval=this.getRelativeX(xvalo);
        var yval=currLine.getRelativeY(yvalo);
        
        if (gridsLogger.isDebugLogEnabled()) {
          gridsLogger.logDebug("New line coordinates",xval,yval);
        }
        
        this.painter.paintLine(currLine,xval,yval);
      
        if (gridsLogger.isDebugLogEnabled()) {
          gridsLogger.logDebug("New line was drawn");
        }
          
      },
      
      /**
       * @ignore
       */
      repaintAll: function(xvalo, yvalo, currLine) {
        gridsLogger.logDebug("Repaint All");
        for (var yField in this.chartArray) {
          for (var line in this.chartArray[yField]) {
            var cLine = this.chartArray[yField][line];
            if (cLine && !cLine.isEmpty()) {
               cLine.repaint();
            }
          }
        }
      },

      /**
       * @private
       */
      calcXUnit: function() {
        this.xUnit = (this.xMax - this.xMin) / this.screenX;
        if (gridsLogger.isDebugLogEnabled()) {
          gridsLogger.logDebug("Calculated X unit",this,this.xUnit);
        }
      },

      /**
       * @private
       */
      paintXLabels: function() {
        this.clearLabels();
          
        var lblVal = "";
        var pos = -1;
        if (this.numXLabels <= 0) {
          return;
        }
        if (this.numXLabels > 0) {
          lblVal = this.labelsFormatter ? this.labelsFormatter(this.xMin) : this.xMin;
          pos = this.getRelativeX(this.xMin);
          this.labels[this.labels.length] = this.createLabel(this.classXLabels, lblVal, pos, "X");
        }
        if (this.numXLabels > 1) {
          lblVal = this.labelsFormatter ? this.labelsFormatter(this.xMax) : this.xMax;
          pos = this.getRelativeX(this.xMax);
          this.labels[this.labels.length] = this.createLabel(this.classXLabels, lblVal, pos, "X");
        }
        if (this.numXLabels > 2) {
          var divider = this.numXLabels - 1;
          var step = (this.xMax - this.xMin) / divider;
          var numVal = this.xMin;
          for (var w = 1; w < divider; w++) {
            numVal += step;
            lblVal = this.labelsFormatter ? this.labelsFormatter(numVal) : numVal;
            pos = this.getRelativeX(numVal);
            this.labels[this.labels.length] = this.createLabel(this.classXLabels, lblVal, pos, "X");
          }
        }
        gridsLogger.logDebug("X labels generated",this);
      },
      
      /**
       * @private
       */
      getRelativeX: function(value) {
        return getRelativeValue(value, this.xMin,this.xUnit);
      },
      /**
       * @private
       */
      clearLabels: function() {
        for (var l = 0; l < this.labels.length; l++) { 
          if (this.labels[l] && Cell.isAttachedToDOM(this.labels[l])) {
             this.labels[l].parentNode.removeChild(this.labels[l]);
           }
         }  
         this.labels = [];
         
         gridsLogger.logDebug("X labels cleared",this);
      },

      /**
       * @inheritdoc
       */
      onListenStart: function(sub) {
        this._callSuperMethod(Chart,"onListenStart",[sub]);
        
        if (this.updateIsKey()) {
          //do not permit update is key on charts
          this.kind = AbstractWidget.ITEM_IS_KEY;
        }
        
      },

      /**
       * @private
       */
      parseValue: function(key,update,field,parser) {
        var val = update[field] === null || typeof(update[field]) == "undefined" ? this.values.get(key,field) : update[field];

        val = parser ? parser(val,key) : val;
        return val === null ? null : Helpers.getNumber(val);
      },

      /**
       * @ignore
       */
      mergeUpdate: function(key,newValues) {
        this.updateLater(key,newValues);
      },
      
      /**
       * @ignore
       */
      updateRowExecution: function(key,serverValues) {
        
        /*
         NOTE: null is like 0 but != 0
         isNaN(null) -> false
         null > 1 -> false
         null < 1 -> true
         null > -1 -> true
         null == 0 -> false
         
         Also:
         xMax > 0 -> always
         */
        
        //fix X
        var newPosX = this.parseValue(key,serverValues,this.xFieldCode,this.xParser);
        if (newPosX === null) {
          //no old, no new, exit
          return;
        }
        
        if (isNaN(newPosX) || (newPosX !== null && newPosX < this.xMin)) {
          return;
        }
        //notify X overflows
        if (newPosX > this.xMax) { 
          this.dispatchEvent("onXOverflow", [key, newPosX, this.xMin, this.xMax]);
        }
        
        for(var yFieldCode in this.chartArray) {
          //fix Y
          var newPosY = this.parseValue(key,serverValues,yFieldCode,this.yParsers[yFieldCode]);
          if (isNaN(newPosY)) {
            continue;
          }
          
          var chartLine =  this.chartArray[yFieldCode][key];
          
          if (newPosX == null || newPosY == null) {
            if (chartLine && newPosX == null && newPosY == null) {
              gridsLogger.logInfo("Got double nulls, clear line",this,chartLine);
              //both nulls means clear
              chartLine.reset();
              
              continue;
            } else {
              gridsLogger.logDebug("Got a null, ignore point",this,chartLine);
              //if there are nulls we do not paint the point
              continue;
            }
          }
          
          if (!chartLine) {
            //this is an add
            chartLine = new ChartLine(key, this, this.xFieldCode, yFieldCode);
            
            this.dispatchEvent("onNewLine",[key,chartLine,newPosX,newPosY]);
            
            if (!chartLine.isYAxisPositioned()) {
              gridsLogger.logError("Cannot create line. Please declare the Y axis",this);
              return;
            }
            
            chartLine.calcYUnit();
            chartLine.paintYLabels(); //screenY - yMax - chartArea.parentNode
          
            this.chartArray[yFieldCode][key] = chartLine;
          }

          if (!chartLine.isPointInRange(newPosY)) {  
            this.dispatchEvent("onYOverflow", [key,chartLine,newPosY,chartLine.getMin(),chartLine.getMax()]);
          }
          
          chartLine.addPoint(newPosX,newPosY);
        }
        
      },
      
      /**
       * @ignore
       */ 
      removeRowExecution: function(key) {
        for (var yField in this.chartArray) {
          this.deleteChartLine(key,yField);
        }
      },
      
      /**
       * @private
       */ 
      deleteChartLine: function(key,field) {
        if (!this.chartArray[field]) {
          return;
        }
        var cLine =  this.chartArray[field][key];
        
        cLine.reset();//this removes the painting and the history
        cLine.clearLabels();//this reemoves the labels
        
        this.painter.removeLine(cLine); //this removes the handling
        
        delete(this.chartArray[field][key]);
        
        this.dispatchEvent("onRemovedLine",[key,cLine]);
        
        gridsLogger.logDebug("Line removed",this,key,field);
        
      },

      /**
       * @inheritdoc
       */
      clean: function() {
        this._callSuperMethod(Chart,"clean"); 
        //this will call removeRowExecution per each "row"
        
        //tolgo le label sulla X
        this.clearLabels();
       
        //tolgo il grafico 
        if (this.painter) {
          this.painter.clean();
        }
       
        delete (this.painter); 
        
        this.setChartAnchor(this.caContainer.parentNode,true);
        
        gridsLogger.logDebug("Cleaned all",this);
      },
      
      /**
       * This method is automatically called by the constructor of this class.
       * It will bind the current instance with the HTML element having the id
       * specified in the constructor.
       */
      parseHtml: function() {
        gridsLogger.logInfo("Parse html for Chart",this);
        
        var cAnchor = document.getElementById(this.id);
        if (!cAnchor) {
          //waiting for a valid call
          return;
        }
        if (!Cell.verifyTag(cAnchor)) {
          throw new IllegalStateException(NO_ANCHOR);
        }
        this.setChartAnchor(cAnchor);
        
        this.parsed = true;
        
      },
      
      
      
      /**
       * Setter method that sets the stylesheet and positioning to be applied to 
       * the chart area.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> The chart area stylesheet and position attributes 
       * can be set and changed at any time.</p>
       * 
       * @throws {IllegalArgumentException} if one of the numeric values is not 
       * valid.
       *
       * @param {String} [chartCss] the name of an existing stylesheet to be applied to 
       * the chart. If not set, the stylesheet is inherited from
       * the DOM element containing the chart.
       * 
       * @param {Number} [chartHeight] the height in pixels of the chart area.
       * Such height may be set as smaller than the height of the container
       * HTML element in order to make room for the X axis labels. If not set, 
       * the whole height of the container HTML element is used.
       * 
       * @param {Number} [chartWidth] the width in pixels of the chart area.
       * Such width may be set as smaller than the width of the container HTML 
       * element in order to make room for the Y axis labels. If not set, 
       * the whole width of the container HTML element is used.
       * 
       * @param {Number} [chartTop=0] the distance in pixels between the top margin of the 
       * chart area and the top margin of the container HTML element. 
       * Such distance may be set as a nonzero value in order to make room for
       * the first Y axis label. If not set, 0 is used.
       * 
       * @param {Number} [chartLeft=0] the distance in pixels between the left margin of 
       * the chart area and the left margin of the container HTML element. 
       * Such distance may be set as a nonzero value in order to make room for the 
       * Y axis labels. If not set, 0 is used.
       */
      configureArea: function(chartCss,chartHeight,chartWidth,chartTop,chartLeft) {
        if (chartCss) {
          this.areaClass = chartCss;
        }
        if (chartTop) {
          this.offsetY = this.checkPositiveNumber(chartTop, true);
        }
        if (chartLeft) {
          this.offsetX = this.checkPositiveNumber(chartLeft, true);
        }
        if (chartHeight) {
          this.screenY = this.checkPositiveNumber(chartHeight, true);
        }
        if (chartWidth) {
          this.screenX = this.checkPositiveNumber(chartWidth, true);
        }
        
        this.configurePainter();
        
        
        
        if (chartWidth || chartHeight) {
          
          if (chartWidth && this.xMax != null) {
            this.calcXUnit();    
            this.paintXLabels(); //screenX - xMax - chartArea.parentNode
          }
          
          for (var yField in this.chartArray) {
            for (var line in this.chartArray[yField]) {
              var cLine = this.chartArray[yField][line];
              if (cLine && cLine.isYAxisPositioned() && this.xMax != null) {
                
                if (chartHeight) {
                  cLine.calcYUnit();
                  cLine.paintYLabels(); //screenY - yMax - chartArea.parentNode
                }
                
                if (cLine && !cLine.isEmpty()) {
                  cLine.repaint();
                }
              }
            }
          }
        }
        
      },

      /**
       * Setter method that sets the field to be used as the source of the
       * X-coordinate for each update. An optional parser can be passed to normalize
       * the value before it is used to plot the chart.
       * The resulting values should be in the limits posed by the 
       * {@link Chart#positionXAxis} method, otherwise a
       * {@link ChartListener#onXOverflow} event is fired to handle the situation.
       * null can also be specified, in which case, if the associated Y value is null
       * the chart will be cleared, otherwise the update will be ignored.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> The X axis field can be set at any time.
       * Until set, no chart will be printed. If already set, the new setting only
       * affects the new points while all the previously plotted points are cleaned.</p>
       * 
       * @param {String} field A field name representing the X axis.
       * @param {CustomParserFunction} [xParser] A parser function that can be used to normalize
       * the value of the X field before using it to plot the chart.
       * If the function is not supplied,
       * then the field values should represent valid numbers in JavaScript or be null.
       */
      setXAxis: function(field, xParser) {
        this.xFieldCode = field;
        this.xParser = xParser;
        this.clean();
        gridsLogger.logDebug("X axis is now configured on field",field,this);
      },
      
      /**
       * Adds field(s) to be used as the source of the Y-coordinate for each update
       * An optional parser can be passed to normalize the value before it is used to 
       * plot the chart.
       * The resulting values should be in the limits posed by the 
       * {@link ChartLine#positionYAxis} related to the involved line, otherwise a 
       * {@link ChartListener#onYOverflow} event is fired to handle the situation.
       * null can also be specified, in which case, if the associated X value is null
       * the chart line will be cleared, otherwise the update will be ignored.
       * <BR>It is possible to specify an array of fields instead of specifying a 
       * single field. If that's the case multiple chart lines will be generated
       * per each row in the model.
       * <BR>Note that for each field in the underlying model it is possible to associate
       * only one line. If multiple lines based on the same fields are needed, dedicated
       * fields should be added to the model, through {@link AbstractWidget#updateRow}.
       * In case this instance is used to listen to events from {@link Subscription}
       * instance(s), updateRow() can be invoked from within {@link SubscriptionListener#onItemUpdate}.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> The method can be invoked at any time, in order to
       * add fields to be plotted or in order to change the parser associated to
       * fields already being plotted.
       * Until invoked for the first time, no chart will be printed.</p>
       *
       * @param {String} field A field name representing the Y axis. An array
       * of field names can also be passed. Each field will generate its own line.
       * @param {(CustomParserFunction|CustomParserFunction[])} [yParser] A parser function that can be used to normalize
       * the value of the Y field before using it to plot the chart.
       * If the function 
       * is not supplied, then the field values should represent valid numbers in JavaScript or be null.
       * <BR>If an array has been specified for the field parameter, then an array of parser functions can 
       * also be passed. Each parser will be executed on the field having the same index
       * in the array. On the other hand, if an array of fields is passed but only one 
       * parser has been specified, then the parser will be applied to all of the fields.
       * 
       * @see Chart#removeYAxis
       */
      addYAxis: function(field, yParser) {
        if (Helpers.isArray(field)) {
          
          gridsLogger.logDebug("Configuring multiple Y axis",this);
          
          for (var i = 0; i<field.length; i++) {
            if (Helpers.isArray(yParser)) {
              this.addYAxis(field[i],yParser[i]);
            } else {
              this.addYAxis(field[i],yParser);
            }
          }
          
        } else {
          if (!this.chartArray[field]) {
            this.chartArray[field] = {};
          }
          this.yParsers[field] = yParser;
          
          gridsLogger.logDebug("Y axis is now configured on field",field,this);
        }
        
      },
      
      /**
       * Removes field(s) currently used as the source of the Y-coordinate for each update
       * and all the related {@link ChartLine}. 
       * <BR>It is possible to specify an array of fields instead of specifying a 
       * single field. If that's the case all the specified fields and related chart lines 
       * will be removed.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> The method can be invoked at any time, in order to
       * remove plotted fields.</p>
       *
       * @param {String} field A field name representing the Y axis. An array
       * of field names can also be passed. 
       * 
       * @see Chart#addYAxis
       */
      removeYAxis: function(field) {
        if (Helpers.isArray(field)) {
          gridsLogger.logDebug("removing multiple Y axis",this);
          
          for (var i = 0; i<field.length; i++) {
            this.removeYAxis(field[i]);
          }
          
        } else {
          if (!this.chartArray[field]) {
            return;
          }
          
          for (var key in this.chartArray[field]) {
            this.deleteChartLine(key,field);
          }
          
          delete(this.chartArray[field]);
          delete(this.yParsers[field]);
        
          gridsLogger.logDebug("Y axis is now removed",field,this);
        }
        
      },
      
      /**
       * Operation method that sets or changes the limits for the visible part
       * of the X axis of the chart (that is, the minimum and maximum X-coordinates
       * shown in the chart).
       * If these limits are changed while the internal model is not empty 
       * then this causes a repaint of the whole chart.
       * <BR>Note that rising the minimum X value shown also clears from
       * the memory all the points whose X value becomes lower. So, those points
       * will not be displayed again after lowering again the minimum X value.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> The X axis limits can be set at any time.</p>
       *
       * @throws {IllegalArgumentException} if the min parameter is greater 
       * than the max one.
       *
       * @param {Number} min lower limit for the visible part of the X axis.
       * @param {Number} max higher limit for the visible part of the X axis.
       */
      positionXAxis: function(min, max) {
        this.xMax = Number(max);
        this.xMin = Number(min);
        
        if (isNaN(this.xMax) || isNaN(this.xMin)) {
          throw new IllegalArgumentException("Min and max must be numbers");
        } else if (this.xMin > this.xMax) {
          throw new IllegalArgumentException("The maximum value must be greater than the minimum value");
        }
    
        
        if (this.screenX != null) {
          this.calcXUnit();
          this.paintXLabels();  //screenX - xMax - chartArea.parentNode
        }
        
        
        this.repaintAll();
        
    
        gridsLogger.logDebug("X axis is now positioned",this);
      },
        
      /**
       * Setter method that configures the legend for the X axis. The legend
       * consists of a specified number of labels for the values in the X axis.
       * The labels values are determined based on the axis limits; the labels
       * appearance is controlled by supplying a stylesheet and a formatter
       * function.
       * <BR>Note that the room for the X axis labels on the page is not provided
       * by the library; it should be provided by specifying a chart height
       * smaller than the container element height, through the
       * {@link Chart#configureArea} setting. Moreover, as the first and last labels
       * are centered on the chart area borders, a suitable space should be
       * provided also on the left and right of the chart area, through the
       * same method.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> Labels can be configured at any time.
       * If not set, no labels are displayed relative to the X axis.</p>
       *
       * @throws {IllegalArgumentException} if labelsNum is not a valid
       * poisitive integer number.
       *
       * @param {Number} labelsNum the number of labels to be spread on the
       * X axis; it should be 1 or greater.
       * @param {String} [labelsClass] the name of an existing stylesheet, to be
       * applied to the X axis label HTML elements. The parameter is optional;
       * if missing or null, then no specific stylesheet will be applied.
       * @param {LabelsFormatter} [labelsFormatter] a Function instance
       * used to format the X axis values designated for the labels. 
       * If the function is not supplied, then the value will be used with no further formatting.
       * 
       */
      setXLabels: function(labelsNum, labelsClass, labelsFormatter) {
        this.numXLabels = this.checkPositiveNumber(labelsNum,true);
        this.classXLabels = labelsClass;
        this.labelsFormatter = labelsFormatter || null;
        
        if (this.xUnit != null) {
          // the X axis is already configured, I design the labels
          this.paintXLabels();  //screenX & xMax (xUnit) - chartArea.parentNode
        }
      
        gridsLogger.logDebug("X labels now configured",this);
      },
      
      /**
       * Adds a listener that will receive events from the Chart 
       * instance.
       * <BR>The same listener can be added to several different Chart 
       * instances.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> a listener can be added at any time.</p>
       * 
       * @param {ChartListener} listener An object that will receive the events
       * as shown in the {@link ChartListener} interface.
       * <BR>Note that the given instance does not have to implement all of the 
       * methods of the ChartListener interface. In fact it may also 
       * implement none of the interface methods and still be considered a valid 
       * listener. In the latter case it will obviously receive no events.
       */
      addListener: function(listener) {
        this._callSuperMethod(Chart,"addListener",[listener]);
      },
      
      /**
       * Removes a listener from the Chart instance so that it
       * will not receive events anymore.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> a listener can be removed at any time.</p>
       * 
       * @param {ChartListener} listener The listener to be removed.
       */
      removeListener: function(listener) {
        this._callSuperMethod(Chart,"removeListener",[listener]);
      },
      
      /**
       * Returns an array containing the {@link ChartListener} instances that
       * were added to this client.
       * 
       * @return {ChartListener[]} an array containing the listeners that were added to this instance.
       * Listeners added multiple times are included multiple times in the array.
       */
      getListeners: function() {
        return this._callSuperMethod(Chart,"getListeners");
      }
      
  };
  
  //closure compiler exports
  Chart.prototype["parseHtml"] = Chart.prototype.parseHtml;
  Chart.prototype["configureArea"] = Chart.prototype.configureArea;
  Chart.prototype["setXAxis"] = Chart.prototype.setXAxis;
  Chart.prototype["addYAxis"] = Chart.prototype.addYAxis;
  Chart.prototype["removeYAxis"] = Chart.prototype.removeYAxis;
  Chart.prototype["positionXAxis"] = Chart.prototype.positionXAxis;
  Chart.prototype["setXLabels"] = Chart.prototype.setXLabels;
  Chart.prototype["addListener"] = Chart.prototype.addListener;
  Chart.prototype["removeListener"] = Chart.prototype.removeListener;
  Chart.prototype["getListeners"] = Chart.prototype.getListeners;
  Chart.prototype["clean"] = Chart.prototype.clean;
  Chart.prototype["onListenStart"] = Chart.prototype.onListenStart;
  Chart.prototype["updateRowExecution"] = Chart.prototype.updateRowExecution;
  Chart.prototype["removeRowExecution"] = Chart.prototype.removeRowExecution;
  
  
  
//Listener Interface ---->    
  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports ChartListener
   * @class Interface to be implemented to listen to {@link Chart} events
   * comprehending notifications of chart overflow and new line creations.
   * <BR>Events for this listeners are executed synchronously with respect to the code
   * that generates them. 
   * <BR>Note that it is not necessary to implement all of the interface methods for 
   * the listener to be successfully passed to the {@link Chart#addListener}
   * method.
   * <BR>A ready made implementation of ChartListener providing basic functionalities
   * is distributed with the library: {@link SimpleChartListener}.
   */
  var ChartListener = function() {
  };
  
  ChartListener.prototype = {
      
    /**
     * Event handler that is called each time that, due to an update to the internal
     * model of the {@link Chart} this instance is listening to, a new 
     * {@link ChartLine} is being generated and displayed.
     * By implementing this method, it is possible to configure the appearance
     * of the new line.
     * <BR>A new line can be generated only when a new row enters the
     * model. Moreover, based on the configuration of {@link Chart#addYAxis} a new
     * row in the model may generate more than one line resulting in this event being
     * fired more than one time for a single update.
     * 
     * @param {String} key The key associated with the row that caused the line
     * of this event to be generated (keys are described in {@link AbstractWidget}).
     * @param {ChartLine} newChartLine The object representing the new line that has 
     * been generated.
     * @param {Number} currentX The X-coordinate of the first point of the line
     * of this event.
     * @param {Number} currentY The Y-coordinate of the first point of the line
     * of this event.
     * 
     */
    onNewLine: function(key,newChartLine,currentX,currentY) {
        
    },
      
    /**
     * Event handler that is called each time that, due to an update to the internal
     * model of the {@link Chart} this instance is listening to, one of the currently 
     * active {@link ChartLine} is being removed.
     * 
     * @param {String} key The key associated with the row that was removed causing
     * this event to be fired (keys are described in {@link AbstractWidget}).
     * @param {ChartLine} removedChartLine The object representing the line that has 
     * been removed.
     * 
     * @see Chart#removeYAxis
     */
    onRemovedLine: function(key,removedChartLine) {
        
    },
      
    /**
     * Event handler that is called when a new update has been received
     * such that one or more points have to be added to the chart lines,
     * but cannot be shown because their X-coordinate value is higher than
     * the upper limit set for the X axis.
     * By implementing this event handler, the chart axis can be repositioned
     * through {@link Chart#positionXAxis} so that the new points can be shown
     * on the chart.
     * <BR>Note that if a new update is received such that one or more points
     * have to be added to the chart lines but cannot be shown because their
     * X-coordinate value is lower than the lower limit set for the X axis,
     * then this event handler is not called, but rather the new update is
     * ignored. X axis limits should always be set in such a way as to avoid
     * this case.
     *
     * @param {String} key The key associated with the row that during its update
     * made the overflow happen.
     * @param {Number} lastX The X-coordinate value of the new points to be
     * shown on the chart and that exceeds the current upper limit.
     * @param {Number} xMin The current lower limit for the visible part
     * of the X axis.
     * @param {Number} xMax The current upper limit for the visible part
     * of the X axis.
     */
    onXOverflow: function(key, lastX, xMin, xMax) {
        
    },
      
    /**
     * Event handler that is called when a new update has been received
     * such that a new point for this line has to be added to the chart,
     * but cannot be shown because its Y-coordinate value is higher than
     * the upper limit set for the Y axis on this line, or lower than the
     * lower limit.
     * By implementing this event handler, the line can be repositioned
     * through {@link ChartLine#positionYAxis} so that the new point can be shown
     * on the chart.
     *
     * @param {String} key The key associated with the row that during its update
     * made the overflow happen.
     * @param {ChartLine} toUpdateChartLine The object representing the line that 
     * made the overflow happen.
     * @param {Number} lastY The Y-coordinate value of the new point to be
     * shown on the chart and that exceeds the current upper or lower limit.
     * @param {Number} yMin The current lower limit for the visible part
     * of the Y axis.
     * @param {Number} yMax The current upper limit for the visible part
     * of the Y axis.
     */
    onYOverflow: function(key,toUpdateChartLine,lastY,yMin,yMax) {
        
    }
      
  };
//<----  Listener Interface      
  
  
  Inheritance(Chart,AbstractWidget);
  return Chart;
})();
  
  /**
   * Callback for {@link Chart#setXAxis} and {@link Chart#addYAxis}
   * @callback CustomParserFunction
   * @param {String} fieldValue the field value to be parsed.
   * @param {String} key the key associated with the given value
   * @return {Number} a valid number to be plotted or null if the value has to be considered unchanged
   */
  
  /**
   * Callback for {@link Chart#setXLabels} and {@link ChartLine#setYLabels}
   * @callback LabelsFormatter
   * @param {Number} value the value to be formatted before being print in a label. 
   * @return {String} the String to be set as content for the label.
   */
  