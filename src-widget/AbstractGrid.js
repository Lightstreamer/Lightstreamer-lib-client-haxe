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
import CellMatrix from "./CellMatrix";
import Executor from "../src-tool/Executor";
import Cell from "./Cell";
import Helpers from "../src-tool/Helpers";
import FadersHandler from "./FadersHandler";
import AbstractWidget from "./AbstractWidget";
import IllegalArgumentException from "../src-tool/IllegalArgumentException";
import IllegalStateException from "../src-tool/IllegalStateException";
import LoggerManager from "../src-log/LoggerManager";
import Environment from "../src-tool/Environment";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
  
  var BG_ATTR = "backgroundColor";
  var COLOR_ATTR = "color";
  
  var NO_TYPES = "The given array is not valid or empty";
  
  var WRONG_INTERPRETATION = "The given value is not valid, use UPDATE_IS_KEY or ITEM_IS_KEY.";
  var NON_EMPTY_ERROR = "This method can only be called while the grid is empty.";
  
  var defaultTags = ["div","span","input"];
  
  
  function preformatValue(val) {
    return val === null ? "" : val;
  }
  
  var gridsLogger = LoggerManager.getLoggerProxy("lightstreamer.grids"); 
 
  
  /**
   * This is an abstract class; no instances of this class should be created.
   * @constructor
   * 
   * @exports AbstractGrid
   * @class The base class for the hierarchy of the *Grid classes.
   * Extends {@link AbstractWidget} to abstract a representation of the
   * internal tabular model as a visible grid made of HTML elements.
   * A specialized (derived) object, rather than an AbstractGrid instance, should
   * be created and used. Two of such classes are available with the library:
   * {@link StaticGrid} and {@link DynaGrid}.
   * This class is used by the mentioned specialized grid objects to inherit the 
   * support for their basic configurations and common utilities.
   * <BR>The class is not meant as a base class for the creation of custom grids.
   * The class constructor and its prototype should never be used directly.
   *
   * @extends AbstractWidget
   */
  var AbstractGrid = function() {

    //AbstractGrid(id)
    
    this._callSuperConstructor(AbstractGrid,arguments);
    
    //AbstractGrid
    this.useInner = false;  
    this.fieldSymbols = null; 
    
    
    //ScreenTableHelper
    this.tagsToCheck = defaultTags; 
    
    //Scroll - DynaScroll
    this.addOnTop = false; 
    
    //Sorting
    this.sortField = null; 
    this.descendingSort = false;  
    this.numericSort = false;  
    this.commaAsDecimalSeparator = false; 
    
    this.fader = new FadersHandler(50); 
    
    this.currentUpdateKey = null;
    this.currentUpdateValues = null;
    
    this.rowCount = 0; 
    this.maxRow = 0; 
    
    this.grid = new CellMatrix();  
    
  };
  
  
  AbstractGrid.prototype = {
      
      /**
       * @protected
       * @param key
       * @param newValues
       * @ignore
       */
      mergeUpdate: function(key,newValues) {
        if (gridsLogger.isDebugLogEnabled()) {
          gridsLogger.logDebug("Merging this update values with the values of the current update",this);
        }
        
        for (var i in newValues) {
          this.currentUpdateValues[i] = newValues[i];
        }
        
        this.fillFormattedValues(this.currentUpdateKey,newValues);
      },
      
      /**
       * @protected
       * @param gridKey
       * @param updated
       * @ignore
       */
      fillFormattedValues: function(gridKey,updated) {       
        for (var i in updated) {
          
          this.grid.forEachCellInPosition(gridKey,i, function(upCell) {
            if (gridsLogger.isDebugLogEnabled()) {
              gridsLogger.logDebug("Filling formatted values in cell",gridKey,i);
            }
            upCell.setNextFormattedValue(preformatValue(updated[i]));
          });
        }
      },
      
      /**
       * Sort comparison method
       * @protected
       * @ignore
       */
      isBefore: function(val1, val2) { 
        
        if (val1 == null || val2 == null) {
          if (val1 != val2) {
            //only one value is null
            if (val1 == null) {
              //consider null smaller than anything else
              return !this.descendingSort;
            } else {
              return this.descendingSort;
            }
          }
        }
        
        if (this.descendingSort) {
          return val1 > val2;
        } else {
          return val1 < val2;
        }
      },
      
      
      /**
       * Setter method that enables or disables the interpretation of the
       * values in the model as HTML code. 
       * For instance, if the value "&lt;a href='news03.htm'&gt;Click here&lt;/a&gt;"
       * is placed in the internal model (either by manual call of the 
       * {@link AbstractWidget#updateRow} method or by listening on a 
       * {@link SubscriptionListener#onItemUpdate} event)   
       * and HTML interpretation is enabled, then the target cell
       * will contain a link; otherwise it will contain that bare text.
       * Note that the setting applies to all the cells in the associated grid.
       * Anyway if it's not the content of a cell that is going to be updated,
       * but one of its properties, then this setting is irrelevant for such cell.
       * <BR>WARNING: When turning HTML interpretation on, make sure that
       * no malicious code may reach the internal model (for example 
       * through the injection of undesired JavaScript code from the Data Adapter).
       *
       * <p class="default-value"><b>Default value:</b> false.</p>
       *
       * <p class="lifecycle"><b>Lifecycle:</b> this setting can be changed at any time.
       * <BR>Note that values that have already been placed in the grid cells will not
       * be updated to reflect the new setting.</p>
       * 
       * @throws {IllegalStateException} if parseHtml has not been executed yet.
       * @throws {IllegalArgumentException} if the given value is not a valid
       * boolean value. 
       *
       * @param {boolean} enable true/false to enable/disable HTML interpretation
       * for the pushed values.
       */
      setHtmlInterpretationEnabled: function(enable) { 
        this.useInner = this.checkBool(enable);
      },
      
      /**
       * Inquiry method that gets the type of interpretation to be applied for
       * the pushed values for this grid. In fact, the values can be
       * put in the target cells as HTML code or as text.
       *
       * @return {boolean} true if pushed values are interpreted as HTML code, false
       * otherwise.
       *
       * @see AbstractGrid#setHtmlInterpretationEnabled
       */
      isHtmlInterpretationEnabled: function() {
        return this.useInner;
      },
      
      /**
       * Setter method that specifies a list of HTML element types to be searched for 
       * during the mapping of the grid to the HTML made by {@link AbstractGrid#parseHtml}.
       *
       * <p class="default-value"><b>Default value:</b> an array containing DIV SPAN and INPUT.</p>
       *
       * <p class="lifecycle"><b>Lifecycle:</b> Node types can be specified at any time.
       * However, if the list is changed after the execution of the {@link AbstractGrid#parseHtml}
       * method then it will not be used until a new call to such method is performed.
       * </p>
       *
       * @param {String[]} nodeTypes an array of Strings representing the names of the node 
       * types to be searched for. If the array contains an asterisk (*) then all the 
       * node types will be checked.
       * 
       * @see AbstractGrid#parseHtml
       */
      setNodeTypes: function(nodeTypes) {
        if (nodeTypes && nodeTypes.length > 0) {
          this.tagsToCheck = nodeTypes;
        } else {
          throw new IllegalArgumentException(NO_TYPES);
        }
      },
      
      /**
       * Inquiry method that gets the list of node of types that would be searched
       * in case of a call to {@link AbstractGrid#parseHtml}.
       *
       * @return {String[]} a list of node type names.
       *
       * @see AbstractGrid#setNodeTypes
       */
      getNodeTypes: function() {
        return this.tagsToCheck;
      },
      
      /**
       * Setter method that decides whenever new rows entering the model will be
       * placed at the top of the grid or at the bottom.
       * <BR>Note that if the sort is enabled on the Grid through {@link AbstractGrid#setSort}
       * then this setting is ignored as new rows will be placed on their right
       * position based on the sort configuration.
       * <BR>Also note that the sort/add policy may be ignored depending on the grid
       * configuration; see the use of the "data-item" cell attribute in {@link StaticGrid}.
       * 
       * <p class="default-value"><b>Default value:</b> false.</p>
       *
       * <p class="lifecycle"><b>Lifecycle:</b> this setting can be changed at any time.
       * <BR>Note anyway that changing this setting while the internal model
       * is not empty may result in a incosistent view.</p>
       *
       * @throws {IllegalArgumentException} if the given value is not a valid
       * boolean value. 
       *
       * @param {boolean} isAddOnTop true/false to place new rows entering the model
       * as the first/last row of the grid.
       */
      setAddOnTop: function(isAddOnTop) {
        if (this.sortField != null) {
          gridsLogger.logWarn("Scroll direction is ignored if sort is enabled");
        }
        
        this.addOnTop = this.checkBool(isAddOnTop);
      },
      
      /**
       * Inquiry method that gets true/false depending on how new rows 
       * entering the grid are treated. If true is returned, new rows will be placed on top of
       * the grid. Viceversa, if false is returned, new rows are placed at the 
       * bottom.
       *
       * @return {boolean} true if new rows are added on top, false otherwise.
       *
       * @see AbstractGrid#setAddOnTop
       */
      isAddOnTop: function() {
        return this.addOnTop;
      },
    
      /**
       * Setter method that configures the sort policy of the grid. If no
       * sorting policy is set, new rows are always added according with the 
       * {@link AbstractGrid#setAddOnTop} setting.
       * If, on the other hand, sorting is enabled, then new
       * rows are positioned according to the sort criteria.
       * Sorting is also maintained upon update of an existing row; this may cause the row to be 
       * repositioned.
       * <BR>If asynchronous row repositioning is undesired, it is possible to 
       * set the sort and immediately disable it with two consecutive calls
       * to just enforce grid sorting based on the current contents.
       * <BR>The sort can also be performed on fields that are part of the model 
       * but not part of the grid view.
       * <BR>Note that the sort/add policy may be ignored depending on the grid
       * configuration; see the use of the "data-item" cell attribute in {@link StaticGrid}.
       *
       * <p class="default-value"><b>Default value:</b> no sort is performed.</p>
       *
       * <p class="lifecycle"><b>Lifecycle:</b> The sort configuration can be set and changed
       * at any time.</p>
       * 
       * @throws {IllegalArgumentException} if one of the boolean parameters is neither
       * missing, null, nor a valid boolean value.
       * 
       * @param {String} sortField The name of the field to be used as sort field, 
       * or null to disable sorting.
       * @param {boolean} [descendingSort=false] true or false to perform descending or
       * ascending sort. This parameter is optional; if missing or null,
       * then ascending sort is performed.
       * @param {boolean} [numericSort=false] true or false to perform numeric or
       * alphabetical sort. This parameter is optional; if missing or null, then
       * alphabetical sort is performed.
       * @param {boolean} [commaAsDecimalSeparator=false] true to specify that sort
       * field values are decimal numbers in which the decimal separator is
       * a comma; false to specify it is a dot. This setting is used only if
       * numericSort is true, in which case it is optional, with false as its
       * default value.
       */
      setSort: function(sortField, descendingSort, numericSort, commaAsDecimalSeparator) {
        if (!sortField) { 
          this.sortField = null;
          return;
        }
        
        this.sortField = sortField;
        this.descendingSort = this.checkBool(descendingSort,true);
        this.numericSort = this.checkBool(numericSort,true);
        this.commaAsDecimalSeparator = this.checkBool(commaAsDecimalSeparator,true);
           
        this.sortTable();
      },
      
      /**
       * Inquiry method that gets the name of the field currently used as sort
       * field, if available.
       * 
       * @return {Number} The name of a field, or null if sorting is not currently
       * enabled.
       *
       * @see AbstractGrid#setSort
       */    
      getSortField: function() {
        return this.sortField;
      },
      
      /**
       * Inquiry method that gets the sort direction currently configured.
       *
       * @return {boolean} true if descending sort is being performed, false if ascending
       * sort is, or null if sorting is not currently enabled.
       *
       * @see AbstractGrid#setSort
       */    
      isDescendingSort: function() {
        return this.sortField === null ? null : this.descendingSort;
      },
      
      /**
       * Inquiry method that gets the type of sort currently configured.
       *
       * @return {boolean} true if numeric sort is being performed, false if alphabetical
       * sort is, or null if sorting is not currently enabled.
       *
       * @see AbstractGrid#setSort
       */     
      isNumericSort: function() {
        return this.sortField === null ? null : this.numericSort;
      },
      
      /**
       * Inquiry method that gets the type of interpretation to be used to
       * parse the sort field values in order to perform numeric sort.
       *
       * @return {boolean} true if comma is the decimal separator, false if it is a dot;
       * returns null if sorting is not currently enabled or numeric sorting
       * is not currently configured.
       *
       * @see AbstractGrid#setSort
       */    
      isCommaAsDecimalSeparator: function() {
        return this.sortField === null  || !this.numericSort ? null : this.commaAsDecimalSeparator;
      },
      
      /**
       * Creates an array containing all the unique values of the "data-field" 
       * properties in all of the HTML elements associated to this grid during the 
       * {@link AbstractGrid#parseHtml} execution. The result of this method is supposed to be
       * used as "Field List" of a Subscription.
       * <BR>Execution of this method is pointless if HTML elements associated to this
       * grid specify a field position instead of a field name in their "data-field"
       * property.
       * <BR>Note that elements specifying the "data-fieldtype" property set to "extra" or "second-level", 
       * will be ignored by this method. This permits to distinguish fields that are part
       * of the main subscription (not specifying any "data-fieldtype" or specifying "first-level"), part of a 
       * second-level Subscription (specifying "second-level") and not part of a Subscription at all, 
       * but still manageable in a direct way (specifying "extra"). 
       * 
       * @return {String[]} The list of unique values found in the "data-field" properties
       * of HTML element of this grid.
       * 
       * @see Subscription#setFields
       */
      extractFieldList: function() {
        return this.extractTypedFieldList(Cell.FIRST_LEVEL);
      },
      
      /**
       * Creates an array containing all the unique values, of the "data-field" properties
       * in all of the HTML elements, having the "data-fieldtype" property set to "second-level",
       * associated to this grid during the {@link AbstractGrid#parseHtml} execution.
       * <BR>The result of this method is supposed to be 
       * used as "Field List" of a second-level Subscription.
       * <BR>Execution of this method is pointless if HTML elements associated to this
       * grid specify a field position instead of a field name in their "data-field"
       * property.
       * 
       * @return {String[]} The list of unique values found in the "data-field" properties
       * of HTML element of this grid.
       *
       * @see AbstractGrid#extractFieldList
       * @see Subscription#setCommandSecondLevelFields
       */
      extractCommandSecondLevelFieldList: function() {
        return this.extractTypedFieldList(Cell.SECOND_LEVEL);
      },
      
      /**
       * Operation method that is used to authorize and execute the binding of the 
       * widget with the HTML of the page.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> This method can only be called once the HTML structure
       * the instance is expecting to find are ready in the DOM.
       * That said, it can be invoked at any time and subsequent invocations will update
       * the binding to the current state of the page DOM. Anyway, newly found cells
       * will be left empty until the next update involving them.</p>
       * 
       * @see Chart
       * @see DynaGrid
       * @see StaticGrid
       */
      parseHtml: function() {
        
      },
      
      /**
       * Operation method that is used to force the choice of what to use
       * as key for the integration in the internal model, when receiving
       * an update from a Subscription this grid is listening to. 
       * <BR>Specifying "ITEM_IS_KEY" tells the widget to use the item as key;
       * this is the behavior that is already the default one when the Subscription
       * is in "MERGE" or "RAW" mode (see {@link AbstractWidget} for details).
       * <BR>Specifying "UPDATE_IS_KEY" tells the widget to use a progressive number
       * as key; this is the behavior that is already the default one when the
       * Subscription is in "DISTINCT" mode (see {@link AbstractWidget} for details).
       * <BR>Note that when listening to different Subscriptions the default behavior 
       * is set when the grid is added as listener for the first one and then applied 
       * to all the others regardless of their mode. 
       * 
       * <p class="lifecycle"><b>Lifecycle:</b>this method can only be called
       * while the internal model is empty.</p>
       * 
       * @throws {IllegalArgumentException} if the given value is not valid.
       * @throws {IllegalStateException} if called while the grid is not empty.
       * 
       * @param {String} interpretation either "ITEM_IS_KEY" or "UPDATE_IS_KEY",
       * or null to restore the default behavior.
       */
      forceSubscriptionInterpretation: function(interpretation) {
        if (this.rowCount > 0) {
          throw new IllegalStateException(NON_EMPTY_ERROR);
        }
        if (!interpretation) {
          this.forcedInterpretation = false;
          this.chooseInterpretation();
          
        } else {
          if (interpretation != AbstractWidget.UPDATE_IS_KEY && interpretation != AbstractWidget.ITEM_IS_KEY) {
            throw new IllegalArgumentException(WRONG_INTERPRETATION);
          }
          
          this.kind = interpretation;
          this.forcedInterpretation = true;
        }
      },
      
      /**
       * @private
       */
      extractTypedFieldList: function(type) {
        var fieldSymbolsSet = this.computeFieldSymbolsSet(type);
        
        var incrementalSchema = [];
        
        for (var fieldSymbol in fieldSymbolsSet) {
          incrementalSchema.push(fieldSymbol);
        }
        
        return incrementalSchema; 
      },
      
      /**
       * @protected
       * @ignore
       */
      makeSortValue: function(val) {
        if (this.numericSort) {
          return Helpers.getNumber(val, this.commaAsDecimalSeparator);
        } else if (val === null) {
          return val;
        } else {
          return (new String(val)).toUpperCase();
        }
      },
      
      /**
       * @protected
       * @ignore
       */
      visualUpdateExecution: function(key,vUpdateInfo,updateKey) {
        
        updateKey = updateKey || key;
        
        var cold2HotTime = vUpdateInfo.coldToHotTime;
        var toColdFadeTime = cold2HotTime + vUpdateInfo.hotTime;
        var hot2ColdTime = toColdFadeTime + vUpdateInfo.hotToColdTime;
        var hotRowStyle = vUpdateInfo.hotRowStyle;
        var coldRowStyle = vUpdateInfo.coldRowStyle;
        
        var cold2HotCall = [];
         
        //let's pass cell by cell
        var entireRow = this.grid.getRow(key); 
        
        for (var col in entireRow) {
          
          var noNumIndex = -1;
          var mayCell = entireRow[col];
          for (var i=0; mayCell && (mayCell.isCell || i<mayCell.length); i++) {
            var cell = mayCell.isCell ? mayCell : mayCell[i];
            mayCell = mayCell.isCell ? null : mayCell;
            
            if (cell.getNum() === null) {
              noNumIndex++;
            }
            
            var slidingCell = this.getSlidingCell ? this.getSlidingCell(cell,updateKey,col,cell.getNum(),noNumIndex) : cell;
            
            var pfVal = cell.getNextFormattedValue();
            //what if the value is not yet on the cell but then we set a null?
            if(pfVal == null) {
              //we don't have to update this cell
              continue;
            }

            var phaseNum = cell.setUpdating(); //updateCount++; updating = true;

            var coldCellStyle = cell.getNextColdArray(coldRowStyle);
            var hotCellStyle = cell.getNextHotArray(hotRowStyle);
            
            if (hotCellStyle) { //if hotCellStyle is not null coldCellStyle cannot be null
              var go = false;
              var c2h = false;
              var h2c = false;
              var bgHot = null; 
              var bgCold = null; 
              var colHot = null; 
              var colCold = null; 
               
              //there are cell-bound styles: overwrite row-bound styles
              if (hotCellStyle) {
                if (hotCellStyle[BG_ATTR]) {
                  go = true;
                  bgHot = hotCellStyle[BG_ATTR];
                  bgCold = coldCellStyle[BG_ATTR];
                }
                if (hotCellStyle[COLOR_ATTR]) {
                  go = true;
                  colHot = hotCellStyle[COLOR_ATTR];
                  colCold = coldCellStyle[COLOR_ATTR];
                }
              }
              
              if (go) { //I have to do fading
                
                if (cold2HotTime > 0) {
                  var updateCellCommand = Executor.packTask(slidingCell.asynchUpdateValue,slidingCell,[phaseNum,this.useInner]);
                  var fadeId = this.fader.getNewFaderId(slidingCell, false, bgHot, colHot, cold2HotTime, updateCellCommand);
                  this.fader.launchFader(fadeId);
                  c2h = true;
                } else {   
                  this.fader.stopFader(slidingCell); //stop active fading if any
                   
                }     
              
                 
                if (vUpdateInfo.hotToColdTime > 0) {
                  var applyStyleCommand = Executor.packTask(slidingCell.asynchUpdateStyles,slidingCell,[phaseNum,Cell.COLD]);
                
                  var fadeId = this.fader.getNewFaderId(slidingCell, true, bgCold, colCold, vUpdateInfo.hotToColdTime, applyStyleCommand);
                  Executor.addTimedTask(this.fader.launchFader,toColdFadeTime,this.fader,[fadeId]);
                  
                  h2c = true;
                }
              }
              
              if (!c2h) {
                
                //cell update call 
                
                if (cold2HotTime > 0) {
                  Executor.addTimedTask(slidingCell.asynchUpdateValue,cold2HotTime,slidingCell,[phaseNum,this.useInner]); 
                } else {
                  var updateTask = Executor.packTask(slidingCell.asynchUpdateValue,slidingCell,[phaseNum,this.useInner]);
                  cold2HotCall.push(updateTask);
                }
              }  
              
              if (!h2c) {
                //final cold state call
                Executor.addTimedTask(slidingCell.asynchUpdateStyles,hot2ColdTime,slidingCell,[phaseNum,Cell.COLD]);
              }
              
              
            } else { //no styles to apply
              
              if (cold2HotTime > 0) {
                //Executor.addTimedTask(this.asynchUpdateCell,cold2HotTime,this,[updateKey,col,phaseNum]);
                Executor.addTimedTask(slidingCell.asynchUpdateValue,cold2HotTime,slidingCell,[phaseNum,this.useInner]);
              } else {
                //var updateTask = Executor.packTask(this.asynchUpdateCell,this,[updateKey,col,phaseNum]);
                var updateTask = Executor.packTask(slidingCell.asynchUpdateValue,slidingCell,[phaseNum,this.useInner]);
                cold2HotCall.push(updateTask);
              }
              
              if (coldCellStyle) {
                   //final cold state call
                   if (vUpdateInfo.hotToColdTime > 0) {
                     bgCold = coldCellStyle[BG_ATTR];
                     colCold = coldCellStyle[COLOR_ATTR];
                     
                     var applyStyleCommand = Executor.packTask(slidingCell.asynchUpdateStyles,slidingCell,[phaseNum,Cell.COLD]);
                
                     var fadeId = this.fader.getNewFaderId(slidingCell, true, bgCold, colCold, vUpdateInfo.hotToColdTime, applyStyleCommand);
                     Executor.addTimedTask(this.fader.launchFader,toColdFadeTime,this.fader,[fadeId]);
                   } else {
                     Executor.addTimedTask(slidingCell.asynchUpdateStyles,hot2ColdTime,slidingCell,[phaseNum,Cell.COLD]);
                   }
                }
              
            }   
            
          }
        }  
        
        for (var t=0; t<cold2HotCall.length; t++) {
          Executor.executeTask(cold2HotCall[t]);
        }
        
      },
      
      /** 
       * abstract method
       * @protected
       * @ignore
       */ 
      updateRowExecution: function(key,serverValues) {},
      /** 
       * abstract method
       * @protected
       * @ignore
       */ 
      removeRowExecution: function(key) {},
      /** 
       * abstract method
       * @protected
       * @ignore
       */ 
      sortTable: function() {},   
      /** 
       * abstract method
       * @protected
       * @ignore
       */ 
      computeFieldSymbolsSet: function(type){}
      
  };
  
  //closure compiler exports
  AbstractGrid.prototype["setHtmlInterpretationEnabled"] = AbstractGrid.prototype.setHtmlInterpretationEnabled;
  AbstractGrid.prototype["isHtmlInterpretationEnabled"] = AbstractGrid.prototype.isHtmlInterpretationEnabled;
  AbstractGrid.prototype["setNodeTypes"] = AbstractGrid.prototype.setNodeTypes;
  AbstractGrid.prototype["getNodeTypes"] = AbstractGrid.prototype.getNodeTypes;
  AbstractGrid.prototype["setAddOnTop"] = AbstractGrid.prototype.setAddOnTop;
  AbstractGrid.prototype["isAddOnTop"] = AbstractGrid.prototype.isAddOnTop;
  AbstractGrid.prototype["setSort"] = AbstractGrid.prototype.setSort;
  AbstractGrid.prototype["getSortField"] = AbstractGrid.prototype.getSortField;
  AbstractGrid.prototype["isDescendingSort"] = AbstractGrid.prototype.isDescendingSort;
  AbstractGrid.prototype["isNumericSort"] = AbstractGrid.prototype.isNumericSort;
  AbstractGrid.prototype["isCommaAsDecimalSeparator"] = AbstractGrid.prototype.isCommaAsDecimalSeparator;
  AbstractGrid.prototype["extractFieldList"] = AbstractGrid.prototype.extractFieldList;
  AbstractGrid.prototype["extractCommandSecondLevelFieldList"] = AbstractGrid.prototype.extractCommandSecondLevelFieldList;
  AbstractGrid.prototype["parseHtml"] = AbstractGrid.prototype.parseHtml;
  AbstractGrid.prototype["forceSubscriptionInterpretation"] = AbstractGrid.prototype.forceSubscriptionInterpretation;
  AbstractGrid.prototype["updateRowExecution"] = AbstractGrid.prototype.updateRowExecution;
  AbstractGrid.prototype["removeRowExecution"] = AbstractGrid.prototype.removeRowExecution;
  
  Inheritance(AbstractGrid,AbstractWidget);
  return AbstractGrid;
})();
  
