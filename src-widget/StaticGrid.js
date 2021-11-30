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
import AbstractGrid from "./AbstractGrid";
import VisualUpdate from "./VisualUpdate";
import Cell from "./Cell";
import SlidingCell from "./SlidingCell";
import CellMatrix from "./CellMatrix";
import IllegalArgumentException from "../src-tool/IllegalArgumentException";
import IllegalStateException from "../src-tool/IllegalStateException";
import Helpers from "../src-tool/Helpers";
import ASSERT from "../src-test/ASSERT";
import LoggerManager from "../src-log/LoggerManager";
import DoubleKeyMap from "../src-tool/DoubleKeyMap";
import Environment from "../src-tool/Environment";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
  
  var NULL_CELL = "The given cell is null or undefined";
  var WRONG_GRID = "The cell does not belong to the Grid";
  var INVALID_ROOT = "The given root element is not valid";
  var NO_ITEMS_TO_EXTRACT = "Cant extract schema from cells declared with the data-row property; use data-item instead.";
  var MIX_ROW_ITEMS = "Cant mix data-item and data-row declarations on the same grid";
  var NO_CELLS = "Please specify at least one cell";
  
  function swap(arr,a,b) {
    var tmp = arr[a];
    arr[a] = arr[b]; 
    arr[b] = tmp;
  }
  
  var gridsLogger = LoggerManager.getLoggerProxy("lightstreamer.grids");   
  
  /**
   * Creates an object that extends {@link AbstractGrid} displaying its values
   * in a grid made of HTML elements. The grid rows are displayed into statically 
   * prepared HTML rows. The object can be supplied to
   * {@link Subscription#addListener} and {@link Subscription#removeListener}
   * in order to display data from one or more Subscriptions.
   * @constructor
   * 
   * @param {String} id An identification string to be specified in the HTML element
   * as the data "data-grid" property 
   * value to make it possible for this StaticGrid instance to recognize its cells.
   * The binding between the cells and the StaticGrid is performed during the 
   * {@link AbstractGrid#parseHtml} execution. 
   * 
   * @param {boolean} autoParse If true the {@link AbstractGrid#parseHtml} method is executed
   * before the constructor execution is completed. If false the parseHtml method
   * has to be called later by custom code. It can be useful to set this flag
   * to false if, at the time of the StaticGrid instance creation, the HTML elements
   * designated as cells are not yet ready on the page.
   * 
   * @param {Object} rootEl if specified, the cells to make up the HTML grid will
   * only be searched in the list of descendants of this node. Equivalent to a
   * {@link StaticGrid#setRootNode} call, but useful if autoParse is true.
   * 
   * @param {Object[]} cells an array of DOMElement instances that will make up the
   * HTML grid for this StaticGrid instance. If specified and not empty, the parseHtml 
   * method will avoid searching cells in the DOM of the page. Equivalent to multiple
   * {@link StaticGrid#addCell} calls, but also useful if autoParse is true.
   * 
   * @exports StaticGrid
   * @class An {@link AbstractGrid} implementation that can be used to display
   * the values from the internal model in a statically prepared grid.   
   * The HTML structure suitable for the visualization of the tabular model values  
   * must be prepared up-front in the DOM of the page as a matrix of HTML cells.
   * The cells making up the grid can be any HTML element   
   * owning the "data-source='Lightstreamer'" special attribute. Such cells, to be
   * properly bound to the StatiGrid instance must also define the following
   * custom attributes:
   * <ul>
   * <li>"data-grid": an identification string that has to be equal to the id 
   * that is specified in the constructor of this class. This id is used
   * to properly bind a cell to its StaticGrid instance.</li>
   * <li>"data-field": the name of a field in the internal model whose value will
   * be displayed in this cell.</li>
   * <li>"data-fieldtype" (optional): "extra", "first-level" or "second-level" to 
   * specify the type of field. If not specified "first-level" is assumed.
   * The "data-fieldtype" property is only exploited in the {@link AbstractGrid#extractFieldList}
   * and {@link AbstractGrid#extractCommandSecondLevelFieldList} methods.</li>
   * <li>"data-row" (only if "data-item" is not specified): a progressive number
   * representing the number of the row associated with the cell.
   * When a new row enters the grid its position will be decided by the 
   * {@link AbstractGrid#setAddOnTop} and {@link AbstractGrid#setSort} settings.
   * The "data-row" attribute will define to which row a cell pertains.
   * <BR>Note that the maximum value available for a data-row attribute in all
   * the cells pertaining to this StaticGrid will define the size of the view.
   * If the number of rows in the model exceeds the number of rows defined in the 
   * HTML grid, rows that would have been displayed in the extra rows are not shown
   * in the view but are maintained in the model. 
   * <BR>Note that if this instance is used to listen to events from 
   * {@link Subscription} instance(s), and the first Subscription it listens to is
   * a DISTINCT Subscription, then the behavior is different: when the number of rows 
   * in the model exceeds the number of rows defined in the HTML grid, adding a new 
   * row will always cause the removal of the oldest row from the model, with a
   * consequent repositioning of the remaining rows. 
   * </li>
   * <li>"data-item" (only if "data-row" is not specified): the name of a row in
   * the internal model, whose value (for the chosen field) will be displayed in
   * this cell; this attribute should
   * only be used if this instance is used to listen to events from 
   * {@link Subscription} instance using the MERGE mode; so, this attribute should 
   * identify the name or the 1-based position of an item in the MERGE Subscription.
   * This way it is possible to define a static positioning for each item in 
   * the MERGE Subscription. On the contrary, by using "data-row" attributes, each
   * item will be placed based only on the {@link AbstractGrid#setAddOnTop} and
   * {@link AbstractGrid#setSort} settings and the positioning may depend on the
   * arrival order of the updates.
   * </li>
   * <li>"data-replica" (optional): this attribute can be specified in case there
   * are more cells associated to the same field. If used, it will permit to access
   * the single cells during {@link StaticGridListener#onVisualUpdate} executions.</li>
   * </ul>
   * <BR>
   * <BR>The association between the StaticGrid and the HTML cells is made during the
   * execution of the {@link AbstractGrid#parseHtml} method. Note that only the elements 
   * specified in the {@link AbstractGrid#setNodeTypes} and that are descendants of the node
   * specified in the {@link StaticGrid#setRootNode} are taken into account, unless a list
   * of cells has been manually specified in the constructor or through the {@link StaticGrid#addCell}
   * method, in which case no elements other than the given ones are taken into 
   * account.
   * <BR>Cells already associated to the grid can be removed from the page DOM,
   * hence from the grid, at any time. Cells already associated can also be moved or
   * altered so that they become no longer suitable for association or other HTML
   * elements may be made suitable, but, in this case, all changes will affect the
   * grid only after the next invocation of {@link AbstractGrid#parseHtml}.
   * <BR>Make sure that all the associated cells specify the same attribute among
   * "data-row" and "data-item"; the behavior of the grid is left unspecified
   * when this condition is not met.
   * <BR>
   * <BR>By default, the content of the HTML element designated as cell will be 
   * updated with the value from the internal model; in case the cell is an INPUT
   * or a TEXTAREA element, the "value" property will be updated instead.
   * It is possible to update any attribute of the HTML element or its CSS 
   * styles by specifying the "data-update" custom attribute. 
   * To target an attribute the attribute name has to be specified; it can be a 
   * standard property (e.g. "data-update='href'"), a custom "data-" attribute 
   * (e.g. "data-update='data-foo'") or even a custom attribute not respecting
   * the "data-" standard (e.g. "data-update='foo'").
   * To target CSS attributes the "data-update='style.attributeName'" form has to 
   * be used (e.g. "data-update='style.backgroundColor'"); note that the form
   * "data-update='style.background-color'" will not be recognized by some browsers.
   * <BR>WARNING: also events like "onclick" can be assigned; in such cases make 
   * sure that no malicious code may reach the internal model (for example 
   * through the injection of undesired JavaScript code from the Data Adapter).
   * <BR>More visualization actions can be performed through the provided  
   * {@link VisualUpdate} event objects received on the {@link StaticGridListener}. 
   *
   * @extends AbstractGrid
   */
  var StaticGrid = function(id, autoParse, rootEl, cells) {
    
    this._callSuperConstructor(StaticGrid,[id]); 
    
    this.explicitSetting = false;
    
    this.rootEl = null;
    this.setRootNode(rootEl || document);
    
    this.tableCells = [];
    if (cells) {
      this.addCell(cells);
    }
    
    this.keyRowMap = new DoubleKeyMap();
   
    this.usingItems = null;
    
    autoParse = this.checkBool(autoParse,true);
    if (autoParse) {
      this.parseHtml();
    }
    
  };
  
  StaticGrid.prototype = {
      /**
       * @ignore
       */
      toString: function() {
        return ["[",this.id,"]"].join("|");
      },
       

//////////////////////////////////TEMPLATE SETUP       
      
      /**
       * Operation method that adds an HTML cell pointer to the StaticGrid.
       * <BR>Note that if at least one cell is manually specified then the 
       * {@link AbstractGrid#parseHtml} will not perform any search in the DOM of the page
       * and will only use the given cells.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> Cell pointers can be added to a StaticGrid at any time.
       * However, before an HTML element is actually used as a cell by the StaticGrid
       * a call to {@link AbstractGrid#parseHtml} is necessary.</p>
       *
       * @param {Object} cellElement A DOM pointer to an HTML node.
       * The specified HTML node should be a "legal" cell for the StaticGrid
       * (i.e. should be defined according with the requirements for the
       * StaticGrid as described in the overview of this class). Moreover, 
       * nodes of any types are allowed.
       */
      addCell: function(cellElement) {
        if (!cellElement) {
          throw new IllegalArgumentException(NULL_CELL);
        }
        
        if (Helpers.isArray(cellElement)) {
          for (var i=0; i<cellElement.length; i++) {
            this.addCell(cellElement[i]);
          }
          return;
        } 
        
        var newCell = new Cell(cellElement);
        var table = newCell.getTable();
        if (!table || table != this.id) {
          throw new IllegalArgumentException(WRONG_GRID);
        }
        this.explicitSetting = true;
        this.tableCells.push(newCell);
      },
      
      /**
       * Setter method that specifies the root node to be used when searching for
       * grid cells. If specified, only descendants of the supplied node will
       * be checked.
       * <br>Anyway note that if nodes are explicitly set through the constructor or through 
       * the {@link StaticGrid#addCell} method, then the search will not be performed at all.
       *
       * <p class="default-value"><b>Default value:</b> the entire document.</p>
       *
       * <p class="lifecycle"><b>Lifecycle:</b> a root node can be specified at any time.
       * However, before a new search is performed for the StaticGrid
       * a call to {@link AbstractGrid#parseHtml} is necessary.</p>
       *
       * @param {Object} rootNode a DOM node to be used as starting point
       * when searching for grid cells.
       */
      setRootNode: function(rootNode) {
        if (rootNode && rootNode.getElementsByTagName) {
          this.rootEl = rootNode;
        } else {
          throw new IllegalArgumentException(INVALID_ROOT);
        }
      },
      
      /**
       * Creates an array containing all of the unique values of the "data-item" 
       * properties in all of the HTML elements associated to this grid during the 
       * {@link AbstractGrid#parseHtml} execution. 
       * The result of this method is supposed to be used as "Item List" of a Subscription.
       *
       * <BR>Execution of this method is pointless if HTML elements associated to this
       * grid through "data-item" specify an item position instead of an item name.
       * 
       * @return {String[]} The list of unique values found in the "data-item" properties
       * of HTML element of this grid.
       */
      extractItemList: function() {
        this.checkParsed();
        
        if (this.usingItems === false) {
          throw new IllegalStateException(NO_ITEMS_TO_EXTRACT);
        }
        
        var itemSymbolsSet = this.computeItemSymbolsSet();
                
        var incrementalGroup = [];
        
        for (var itemSymbol in itemSymbolsSet) {
          incrementalGroup.push(itemSymbol);
        }
        
        return incrementalGroup;
      },

      /**
       * @inheritdoc
       */
      parseHtml: function() {
        this.parsed = true;
        
        this.grid.cellsGarbageCollection();
        
        var lsTags;
        if (this.explicitSetting) {
          lsTags = this.tableCells;
         
          //on the next parseHtml call only newly added cells will be parsed
          this.tableCells = [];
          
        } else {
          lsTags = Cell.getLSTags(this.rootEl,this.tagsToCheck);
          
        }
        
        for (var j = 0; j < lsTags.length; j++) {
          
          var table = lsTags[j].getTable();
          
          if (!table || table != this.id) {
            //this is not the table you're looking for
            continue;
          }
          
          var row = lsTags[j].getRow();
          
          if (!row) {
            continue;
          }
          if (!isNaN(row)) {
            row = Number(row);
          }
         
          if (this.usingItems === null) {
            this.usingItems = isNaN(row);
            
          } else if (this.usingItems != isNaN(row)) {
            throw IllegalStateException(MIX_ROW_ITEMS);
          }
         
          if (!this.usingItems) {
            this.maxRow = row > this.maxRow ? row : this.maxRow;
          }

          var fieldSymbol = lsTags[j].getField();
          if (!fieldSymbol) {
            continue;
          }
          
          if (this.grid.alreadyInList(lsTags[j])) {
            continue;
          }
          
          this.grid.addCell(lsTags[j]);
          
        }
        
        if (!this.grid.isEmpty()) {
          //at least one cell, that's ok for us
          return;
        }
       
        throw new IllegalStateException(NO_CELLS);

      },
      
      /**
       * @protected
       * @ignore
       */
      computeFieldSymbolsSet: function(type) {
        var fieldSymbolsSet = {};
        this.grid.forEachCell(function(singleCell,itemSymbol,fieldSymbol) {
          if (singleCell.getFieldType() == type) {
            fieldSymbolsSet[fieldSymbol] = true;
          }
        });
        return fieldSymbolsSet;
      },
      
      /**
       * @protected
       * @ignore
       */
      computeItemSymbolsSet: function() {
        var itemSymbolsSet = {};
        this.grid.forEachRow(function(itemSymbol){
          itemSymbolsSet[itemSymbol] = true;
        });
        return itemSymbolsSet;
      },
      
      
/////////////////////////////////////VISUAL EXECUTION      
      /**
       * @protected
       * @ignore
       */
      updateRowExecution: function(key,serverValues) {
   
        var isNew = !this.values.getRow(key);
       
        //I need to find the position of the updating row
        var gridKey;
        if (this.usingItems) {
          //special case, item instead of row, only works for itemIsKey 
          //In this case upwardScroll and/or sorting settings are ignored
          //as each key has only one possible place to go
          gridKey = key;
          
        } else { // if (!this.usingItems) {
          
          //1 choose the new position
          
          var oldSortVal = this.sortField != null ? this.makeSortValue(this.values.get(key,this.sortField)) : null;
          var newSortVal = this.sortField != null ? this.makeSortValue(serverValues[this.sortField]) : null;
          var dontMove = oldSortVal == newSortVal || (typeof serverValues[this.sortField] == "undefined"); 
          if (this.sortField != null && dontMove == false) {
            gridKey = this.calculateSortedPosition(key,oldSortVal,newSortVal);
            
          } else if (isNew) {
            //No sort and new row: 
            //When upward scroll is not active, new updates are placed at the top of the model data table, so that old updates scroll downward. 
            //On the other hand, when upward scroll is active, new updates are placed at the bottom of the model data table.
            
            if (this.addOnTop) {
              gridKey = 1; 
            } else if (this.updateIsKey()) {
              //add on bottom with update is key means place the new row in the last row and scroll upward anything else (the top row will overflow and be deleted)
              gridKey = this.rowCount == this.maxRow ? this.rowCount : this.rowCount+1;
            } else {
              //add on bottom without update is key means place the new row on the bottom even if not visible
              gridKey = this.rowCount+1;
            }
            
          } else {
            //not new and doesn't move, simply update the row
            gridKey = this.keyRowMap.get(key);
          }
          
          
          if (this.updateIsKey() && this.maxRow == this.rowCount && isNew && this.sortField != null ) {
            //new row (isNew) on a full static grid (this.maxRow == this.rowCount) on a sorted table (this.sortField != null) on a grid where overflow is deleted
            
            //I need to remove the oldest row
            var oldest = this.getOldestKey();
            var freePos = this.scrollOut(oldest);
            
            if(freePos<gridKey) {
              //if the freePos is above our target location, as everything below such pos will scroll up our target location will scroll up too 
              gridKey--;
            }
            
            //let's place the new row in the freed position, makeroom will take care of placing it in its new proper location
            this.keyRowMap.set(key,freePos);
            
            //doing so we need to inc back rowCount (was decreased by scrollOut) and then faking this as non-new row to prevent 
            //another increase
            this.rowCount++;
            isNew = false;
            
          }
          
          //2 (if necessary) scroll other rows to make room for this one 
          
          if (this.keyRowMap.existReverse(gridKey) && this.keyRowMap.getReverse(gridKey) != key) {
            //the place we want is occupied, let's scroll
            
            //this method will move the key row to the gridKey position and will scroll other rows accordingly
            this.makeRoom(gridKey,key); //NOTE: in case of updateIsKey the method will handle the scrollOut itself
          }
          
          //update references
          this.keyRowMap.set(key,gridKey);
          
        } //END-if (!this.usingItems) 
        
        if (isNew) {
          this.rowCount++;
        }
        
        if (!this.updateIsKey() && gridKey > this.maxRow && !this.grid.getRow(gridKey)) {
          //new row out of sight
          //let's make new fake cells for it
          
          //updateIsKey can't pass from here: out-of-sight rows are completely deleted
          //gridKey > this.maxRow  === out of sight
          //!this.grid.getRow(toPos) no cells defined for the row
          
          var toCopyRow = this.grid.getRow(gridKey-1);
          var fakeRow = CellMatrix.scrollRow(toCopyRow,null,this.useInner);
          this.grid.insertRow(fakeRow,gridKey);
          
        }
        
        //3 fill formatter values
        this.fillFormattedValues(gridKey,serverValues);
        
        var upInfo = this.dispatchVisualUpdateEvent(key,gridKey,serverValues);
        
        //5 do visualUpdateExecution (ie place values on cells)
        this.visualUpdateExecution(gridKey,upInfo,key); 
  
      },
      
      /**
       * @private
       */
      dispatchVisualUpdateEvent: function(key,gridKey,serverValues) {
        //this references are used to handle reentrant calls; if an
        //updateRow call is performed during the VisualUpdate it is 
        //merged in this update instead of spawning a new update.
        //TODO if the sort value is changed during the second update call
        //the row may appear in the wrong place should override
        //mergeUpdate to prevent the case
        this.currentUpdateKey = gridKey;
        this.currentUpdateValues = serverValues;
        
        //call onVisualUpdate callback
        var upInfo = new VisualUpdate(this.grid,serverValues,gridKey);  
        this.dispatchEvent("onVisualUpdate",[key,upInfo,gridKey]);
        
        this.currentUpdateKey = null;
        this.currentUpdateValues = null;
        
        return upInfo;
      },
      
      /**
       * @protected
       * @ignore
       */
      getSlidingCell: function(cell,updateKey,col,num,noNumIndex) {
        if(this.usingItems) {
          return cell;
        }       
        
        return new SlidingCell(this,updateKey,col,num,noNumIndex);
      },
      
      /**
       * @protected
       * @ignore
       */
      getCellByKey: function(key,col,num) {
        var gridKey = this.keyRowMap.get(key);
        
        return this.grid.getCell(gridKey,col,num);
      },
      
      /**
       * @protected
       * @ignore
       */
      removeRowExecution: function(key) {
        var gridKey = this.usingItems ? key : this.keyRowMap.get(key);
        
        this.dispatchEvent("onVisualUpdate",[key,null,gridKey]);
        
        if (!this.usingItems) {
          if (gridKey != this.rowCount) {
            this.makeRoom(this.rowCount,key); //make the row to be deleted the last row of the grid
            gridKey = this.keyRowMap.get(key); //reload the gridkey
          }
//>>excludeStart("debugExclude", pragmas.debugExclude);         
          if (!ASSERT.verifyValue(this.rowCount,gridKey)) {
            gridsLogger.logError("Unexpected position of row to be wiped");
          }
//>>excludeEnd("debugExclude");          
        }
        
        this.grid.forEachCellInRow(gridKey,function(cell) {
          cell.clean();
        });
        
        this.rowCount--;
        
        if (!this.usingItems) {
          this.keyRowMap.remove(key);
        }
      },
      
      /**
       * @private
       */
      scrollOut: function(key) {
        var cPos = this.keyRowMap.get(key);
        this.keyRowMap.remove(key);
        
        this.rowCount--;
        this.values.delRow(key);
        
        if (this.updateIsKey()) {
          this.removeFromFifo(key);
        }
        
        
        return cPos;
      },
      
      /**
       * @private
       */
      makeRoom: function(endPos,key) {
        //myRow will go @ endPos position
        //NOTE: the only thing that scroll is this.grid (and maps have to be updated)
        
        var origPos = this.keyRowMap.get(key);
        if (endPos == origPos) {
          //it actually doesn't move
          return;
        }
        
        //move this row to a fake row
        var fakeRow = origPos ? CellMatrix.scrollRow(this.grid.getRow(origPos),null,this.useInner) : null;
        var origKey = origPos ? this.keyRowMap.getReverse(origPos) : null;
        
        var unit; //unit to go to the next row to be moved
        var start; //first rows that moves
        var stop; //last row that moves
        
        if (origPos) {
          if (origPos > endPos) {
            //goDown
            start = origPos-1; 
            stop = endPos;
            unit = -1;
            
          } else {
            //goUp
            start = origPos+1;
            stop = endPos;
            unit = 1;
            
          }
        
        } else if (this.sortField != null || this.addOnTop) {
          // goDown
          stop = endPos; //X
          start = this.rowCount; //C
          unit = -1;
          
        } else {
          //goUp
          start = 1; //A
          stop = endPos; //X  //this.rowCount
          unit = 1;
        }
        
     
        for (var fromPos = start; fromPos-unit!=stop; fromPos+=unit) {
          var toPos = fromPos-unit;
          
          var fromRow = this.grid.getRow(fromPos);
          var toRow = this.grid.getRow(toPos);
          
          if (!toRow && !this.updateIsKey()) {
            //matrix will grow
           
            toRow = {};
            this.grid.insertRow(toRow,toPos);
//>>excludeStart("debugExclude", pragmas.debugExclude);            
            ASSERT.verifyNotOk(origPos);
//>>excludeEnd("debugExclude");            
          }

          if (!toRow) {
            //overflow
//>>excludeStart("debugExclude", pragmas.debugExclude);            
            ASSERT.verifyOk(this.updateIsKey());
            ASSERT.verifyValue(fromPos,start);
//>>excludeEnd("debugExclude");            
            
            var fromKey = this.keyRowMap.getReverse(fromPos); // fromPos 10 fromKey 4 toPos 11
            
            this.scrollOut(fromKey);
          
          } else {
            CellMatrix.scrollRow(fromRow,toRow,this.useInner);
            
            var fromKey = this.keyRowMap.getReverse(fromPos);
            this.keyRowMap.set(fromKey,toPos);
          }
          
        } 
        
        if (fakeRow) {
          CellMatrix.scrollRow(fakeRow,this.grid.getRow(endPos),this.useInner);   

          this.keyRowMap.set(origKey,endPos);
        } else {
          
          this.grid.forEachCellInRow(endPos,function(cell) {
            cell.clean();
          });
          
        }
        
        
      },
      
////////LIVE SORT
      
      /**
       * @private
       */
      calculateSortedPosition: function(toUpdateKey,oldSortVal,newSortVal) {
        var up = 1;
        var down = this.rowCount;
        var j = -1;
        
        //do a binary search to find the new place
        while (up < down) {
          j = Math.floor((up + down) /2);
          var thisKey = null;
          if (j <= this.rowCount) {
            var compare = this.keyRowMap.getReverse(j);
            if (compare == toUpdateKey) {
              thisKey = oldSortVal;
            } else {
              thisKey = this.makeSortValue(this.values.get(compare,this.sortField)); 
            }
          }
          if (this.isBefore(newSortVal,thisKey)) {
            down = j - 1;
          } else {
            up = j + 1;
          }
        }
        
        if (up == down) {
          //up == down, our place is right after or right before this one
          var compare = this.keyRowMap.getReverse(up);
          var compareKey = this.makeSortValue(this.values.get(compare,this.sortField));
          
          if (this.isBefore(newSortVal,compareKey)) {
            return up;
          } else {
            return up + 1;
          }
        } else {
          return up;
        }
      },
      
////////INITIAL SORT
      
      /**
       * @private
       */
      partition: function(newRowToKey, left, right, pivotIndex) {
        
        var pivotValue = this.makeSortValue(this.values.get(newRowToKey[pivotIndex],this.sortField));
        
        //Move pivot to end
        swap(newRowToKey,right,pivotIndex);
        
        var sI = left;
        for (var i=left; i<right; i++) {
          var iVal = this.makeSortValue(this.values.get(newRowToKey[i],this.sortField));
          if (!this.isBefore(pivotValue, iVal)) {
          //if (iVal < pivotValue) {
            swap(newRowToKey,i,sI);
            sI++;
          }
        }
        swap(newRowToKey,sI,right);
        return sI;
      },
      
      /**
       * @private
       */
      quickSort: function(newRowToKey,left,right) {
        if (left < right) {
          var pivot = Math.round(left + (right-left)/2);
          
          var pivotNewIndex = this.partition(newRowToKey, left, right, pivot);
          
          this.quickSort(newRowToKey,left,pivotNewIndex-1);
          this.quickSort(newRowToKey,pivotNewIndex+1,right);
        }
      },
      
      /**
       * @protected
       * @ignore
       */
      sortTable: function() {
        if (this.usingItems) {
          return;
        }
        
        var newRowToKey = {};
        this.keyRowMap.forEachReverse(function(row,key) {
          newRowToKey[row] = key;
        });
        
        this.quickSort(newRowToKey,1,this.rowCount);
        
        var tmpGrid = {};
        var newMap = new DoubleKeyMap();
        
        for (var i in newRowToKey) {
          newMap.set(newRowToKey[i],i);
          
          var oldKeyPerPos = this.keyRowMap.getReverse(i);
          if (newRowToKey[i] == oldKeyPerPos) {
            continue;
          }
          
          //let's move the current row to a safe place before we write upon it
          var targetRow = this.grid.getRow(i);
          tmpGrid[oldKeyPerPos] = CellMatrix.scrollRow(targetRow,null,this.useInner);
          
          var keyToMove = newRowToKey[i];
          
          var rowToMove = tmpGrid[keyToMove] ? tmpGrid[keyToMove] : this.grid.getRow(this.keyRowMap.get(keyToMove));
          
          CellMatrix.scrollRow(rowToMove,targetRow,this.useInner);
          
        }
        
        this.keyRowMap = newMap;
        
      },     
      
      /**
       * Adds a listener that will receive events from the StaticGrid 
       * instance.
       * <BR>The same listener can be added to several different StaticGrid 
       * instances.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> a listener can be added at any time.</p>
       * 
       * @param {StaticGridListener} listener An object that will receive the events
       * as shown in the {@link StaticGridListener} interface.
       * <BR>Note that the given instance does not have to implement all of the 
       * methods of the StaticGridListener interface. In fact it may also 
       * implement none of the interface methods and still be considered a valid 
       * listener. In the latter case it will obviously receive no events.
       */
      addListener: function(listener) {
        this._callSuperMethod(StaticGrid,"addListener",[listener]);
      },
      
      /**
       * Removes a listener from the StaticGrid instance so that it
       * will not receive events anymore.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> a listener can be removed at any time.</p>
       * 
       * @param {StaticGridListener} listener The listener to be removed.
       */
      removeListener: function(listener) {
        this._callSuperMethod(StaticGrid,"removeListener",[listener]);
      },
      
      /**
       * Returns an array containing the {@link StaticGridListener} instances that
       * were added to this client.
       * 
       * @return {StaticGridListener[]} an array containing the listeners that were added to this instance.
       * Listeners added multiple times are included multiple times in the array.
       */
      getListeners: function() {
        return this._callSuperMethod(StaticGrid,"getListeners");
      }
      
  };
  
  //closure compiler exports
  StaticGrid.prototype["addCell"] = StaticGrid.prototype.addCell;
  StaticGrid.prototype["setRootNode"] = StaticGrid.prototype.setRootNode;
  StaticGrid.prototype["extractItemList"] = StaticGrid.prototype.extractItemList;
  StaticGrid.prototype["parseHtml"] = StaticGrid.prototype.parseHtml;
  StaticGrid.prototype["addListener"] = StaticGrid.prototype.addListener;
  StaticGrid.prototype["removeListener"] = StaticGrid.prototype.removeListener;
  StaticGrid.prototype["getListeners"] = StaticGrid.prototype.getListeners;
  StaticGrid.prototype["updateRowExecution"] = StaticGrid.prototype.updateRowExecution;
  StaticGrid.prototype["removeRowExecution"] = StaticGrid.prototype.removeRowExecution;
  
  
//Listener Interface ---->
  
  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor 
   * 
   * @exports StaticGridListener
   * @class Interface to be implemented to listen to {@link StaticGrid} events.
   * <BR>Events for this listeners are executed synchronously with respect to the code
   * that generates them.
   * <BR>Note that it is not necessary to implement all of the interface methods for 
   * the listener to be successfully passed to the {@link StaticGrid#addListener}
   * method.
   * 
   * @see StaticGrid
   */
  var StaticGridListener = function() {
    
  };
  
  StaticGridListener.prototype = {
      /**
       * Event handler that is called by Lightstreamer each time a row of the
       * underlying model is added or modified and the change is going to be
       * applied to the corresponding cells in the grid.
       * By implementing this method, it is possible to perform custom
       * formatting on the field values, to set the cell stylesheets and to
       * control the display policy.
       * In addition, through a custom handler it is possible to perform custom
       * display actions for the row.
       * <BR>Note that the availability of cells currently associated to the row
       * fields depends on how the StaticGrid was configured.
       * <BR>This event is also fired when a row is removed from the model,
       * to allow clearing actions related to custom display actions previously
       * performed for the row. Row removal may happen when the {@link StaticGrid}
       * is listening to events from {@link Subscription} instance(s), and the first
       * Subscription it listens to is a COMMAND or a DISTINCT Subscription;
       * removal may also happen in case of {@link AbstractWidget#removeRow} or
       * {@link AbstractWidget#clean} execution.
       * <BR>On the other hand, in case the row is just repositioned on the grid
       * no notification is supplied, but the formatting and style are kept for
       * the new cells.
       * <BR>This event is fired before the update is applied to both the HTML cells
       * of the grid and the internal model. As a consequence, through 
       * {@link AbstractWidget#updateRow} it is still possible to modify the current update.
       *
       * @param {String} key the key associated with the row that is being 
       * added/removed/updated (keys are described in {@link AbstractWidget}).
       *  
       * @param {VisualUpdate} visualUpdate a value object containing the
       * updated values for all the cells, together with their display settings.
       * The desired settings can be set in the object, to substitute the default 
       * settings, before returning.
       * <BR>visualUpdate can also be null, to notify a clearing action.
       * In this case, the row is being removed from the page. 
       * 
       * @param {String} position the value of the data-row or data-item
       * value of the cells targeted by this update.
       */
      onVisualUpdate: function(key, visualUpdate, position) {
        return;
      }
  };
//<----  Listener Interface  
  
  Inheritance(StaticGrid,AbstractGrid);
  return StaticGrid;
})();
  
