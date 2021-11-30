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
import Cell from "./Cell";
import VisibleParent from "./VisibleParent";
import InvisibleParent from "./InvisibleParent";
import DynaElement from "./DynaElement";
import BrowserDetection from "../src-tool/BrowserDetection";
import VisualUpdate from "./VisualUpdate";
import IllegalArgumentException from "../src-tool/IllegalArgumentException";
import IllegalStateException from "../src-tool/IllegalStateException";
import LoggerManager from "../src-log/LoggerManager";
import ASSERT from "../src-test/ASSERT";
import Environment from "../src-tool/Environment";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
  
  var ELEMENT = "ELEMENT";
  var PAGE = "PAGE";
  var OFF = "OFF";
  
  var WRONG_SCROLL_TYPE = "The given value is not a valid scroll type. Admitted values are OFF, ELEMENT, PAGE";
  var NO_TEMPLATE = "No template defined";
  var NO_SOURCE = "The template defined for the grid does not define the 'data-source' attribute";
  var NO_CELLS = "No valid cells defined for grid";
  var NO_PAGINATION = "This grid is configured to no support pagination";
  var NO_PAGE_SWITCH = "Can't switch pages while 'no-page mode' is used";
  var NO_AUTOSCROLL_ELEMENT = "Please specify an element id in order to use ELEMENT autoscroll";

  
  var gridsLogger = LoggerManager.getLoggerProxy("lightstreamer.grids");   

  
  /**
   * Creates an object that extends {@link AbstractGrid} displaying its values
   * in a grid made of HTML elements. The grid rows are displayed into dynamically 
   * generated HTML rows. The object can be supplied to
   * {@link Subscription#addListener} and {@link Subscription#removeListener}
   * in order to display data from one or more Subscriptions.
   * @constructor
   * 
   * @param {String} id The HTML "id" attribute of the HTML element that represents the template from
   * which rows of the grid will be cloned. The template can be either a visible
   * or a hidden part of the page; anyway, it will become invisible
   * as soon as the {@link AbstractGrid#parseHtml} method is executed. 
   *
   * @param {boolean} autoParse If true the {@link AbstractGrid#parseHtml} method is executed
   * before the constructor execution is completed. If false the parseHtml method
   * has to be called later by custom code. It can be useful to set this flag
   * to false if, at the time of the DynaGrid instance creation, the HTML element
   * designated as template is not yet ready on the page.
   * 
   * @exports DynaGrid
   * @class An {@link AbstractGrid} implementation that can be used to display
   * the values from the internal model in a dynamically created grid.   
   * The HTML structure suitable for the visualization of the tabular model values is 
   * dynamically maintained by Lightstreamer, starting from an HTML hidden template 
   * row, containing cells. The template row can be provided as any HTML element 
   * owning the "data-source='Lightstreamer'" special attribute. 
   * <BR>The association between the DynaGrid and the HTML template is made during the
   * execution of the {@link AbstractGrid#parseHtml} method: it is expected that the element 
   * representing the template row, in addition to the special "data-source" 
   * custom attribute, has an HTML "ID" attribute containing a unique value that has to be 
   * passed to the constructor of this class. The template will be then searched for by 
   * "id" on the page DOM.
   * <BR>Once the association is made with the row template, the cells within it have
   * to be recognized: all the elements of the types specified in the 
   * {@link AbstractGrid#setNodeTypes} are scanned for the "data-source='Lightstreamer'" 
   * attribute that authorizes the library to track the HTML element as a cell
   * for the row. 
   * <BR>
   * <BR>The "data-field" attribute will then instruct the library about
   * what field of the internal model has to be associated with the cell.
   * <BR>It is possible to associate more cells with the same field.
   * An optional "data-replica" attribute can be specified in this case. If used it will permit to access
   * the single cells during {@link DynaGridListener#onVisualUpdate} executions.
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
   * <BR>For each update to the internal model, the involved row is determined and 
   * each value is displayed in the proper cell(s). If necessary, new rows are 
   * cloned from the hidden template and attached to the DOM, or existing rows are 
   * dropped. The position of new rows is determined by the {@link AbstractGrid#setAddOnTop}
   * or {@link AbstractGrid#setSort} settings. 
   * <BR>In fact, there is a 1:1 correspondence between rows in the underlying
   * model and rows in the grid; however, pagination is also supported, so that
   * only a subset of the grid can be made visible.
   * <BR>
   * <BR>Note that the template element can contain an arbitrary HTML structure
   * and should contain HTML cells to be used to display the row field values. 
   * However, it should not contain elements to which an HTML "id" attribute has been assigned,
   * because the elements will be cloned and the HTML specification prescribes 
   * that an id must be unique in the document. (The id of the template element, 
   * required by Lightstreamer, is not cloned).
   * <BR>More visualization actions can be performed through the provided  
   * {@link VisualUpdate} event objects received on the {@link DynaGridListener}. 
   * 
   * @extends AbstractGrid
   */
  var DynaGrid = function(id,autoParse) {
    this._callSuperConstructor(DynaGrid,[id]); 
    
    this.pageNumber = 1;
    this.currentPages = 0;
    
    this.autoScrollElement = null;
    this.autoScrollType = OFF;
    

    this.initDOM();
    
    autoParse = this.checkBool(autoParse,true);
    if (autoParse) {
      this.parseHtml();
    }
    
  };
  
  
  DynaGrid.prototype = {
      
    /**
     * @ignore
     */  
    toString: function() {
      return ["[",this.id,this.rowCount,this.currentPages,"]"].join("|");
    },
   
    /**
     * Setter method that sets the maximum number of visible rows allowed
     * in the grid.
     * If a value for this property is set, then Lightstreamer
     * maintains a paging mechanism, such that only one logical page is
     * displayed at a time. Logical page 1 is shown by default, but each
     * logical page can be shown by calling the {@link DynaGrid#goToPage} method.
     * <BR>Note that, due to the dynamical nature of the grid,
     * logical pages other than page 1 may underlie to scrolling caused by
     * operations on rows belonging to lower logical pages; this effect
     * is emphasized if sorting is active.
     * <BR>Note that if this instance is used to listen to events from 
     * {@link Subscription} instance(s), and the first Subscription it listens to is
     * a DISTINCT Subscription, then the behavior is different: when the limit
     * posed by this setting is reached, adding a new row will always
     * cause the removal of the oldest row from the model, with a
     * consequent repositioning of the remaining rows.  
     *
     * <p class="default-value"><b>Default value:</b> "unlimited".</p>
     *
     * <p class="lifecycle"><b>Lifecycle:</b> this setting can be set and changed at any time. 
     * If the internal model is not empty when this method is called, it will cause 
     * the immediate adjustment of the rows to reflect the change. Moreover,
     * if applicable, the current logical page is automatically switched to page 1.
     * </p>
     *
     * @param {Number} maxDynaRows The maximum number of visible rows allowed,
     * or the string "unlimited", to mean that the grid is allowed
     * to grow without limits, without the need for paging (the check is case
     * insensitive).
     */
    setMaxDynaRows: function(maxDynaRows) {
      if (!maxDynaRows || new String(maxDynaRows).toLowerCase() == "unlimited") {
        this.maxRow = 0;
      } else {
        this.maxRow = this.checkPositiveNumber(maxDynaRows,true);
      }
      
      if (this.updateIsKey()) {
        this.limitRows();
      } else {
        this.calculatePages();
        this.sortTable();
        this.changePage(1);
      }
    },   
    
    /**
     * Inquiry method that gets the maximum number of visible rows allowed
     * in the grid. 
     *
     * @return {Number} The maximum number of visible rows allowed, or the String
     * "unlimited", to notify that the grid is allowed to grow
     * without limits.
     * 
     * @see DynaGrid#setMaxDynaRows
     */ 
    getMaxDynaRows: function() {
      if (this.maxRow == 0) {
        return "unlimited";
      }
      return this.maxRow;
    },
    
    /**
     * Operation method that shows a particular logical page in the internal model.
     * 
     * <p class="lifecycle"><b>Lifecycle:</b> once the {@link AbstractGrid#parseHtml} method has been called, 
     * this method can be used at any time.</p>
     * 
     * @throws {IllegalStateException} if this instance is used to listen to events 
     * from {@link Subscription} instance(s), and the first Subscription it listens 
     * to is a DISTINCT Subscription (in such case pagination is disabled).
     * 
     * @throws {IllegalStateException} if the maximum number of visible rows is 
     * set to unlimited.
     * 
     * @throws {IllegalArgumentException} if the given value is not a valid 
     * positive integer number.
     * 
     * @param {Number} pageNumber The number of the logical page to be displayed.
     * The request is accepted even if the supplied number is higher than the
     * number of currently available logical pages, by displaying an empty
     * logical page, that may become nonempty as soon as enough rows are added
     * to the internal model.
     *
     * @see DynaGrid#setMaxDynaRows
     * @see DynaGrid#getCurrentPages
     */
    goToPage: function(pageNumber) {
      if (this.updateIsKey()) {
        throw new IllegalStateException(NO_PAGINATION);
      }
      
      if (this.maxRow == 0) {
        throw new IllegalStateException(NO_PAGE_SWITCH);
      }
      
      pageNumber = this.checkPositiveNumber(pageNumber);
      this.changePage(pageNumber);
    },
    
    /**
     * Inquiry method that gets the current number of nonempty logical pages
     * needed to show the rows in the internal model.
     *
     * @return {Number} The current number of logical pages. If pagination is not active
     * 1 is returned.
     */
    getCurrentPages: function() {
      return this.maxRow == 0 ? 1 : this.currentPages;
    },
    
    /**
     * Setter method that enables or disables the automatic adjustment of
     * the page or element scrollbars at each new update to focus on the most
     * recently updated row.
     * If a growing grid is included in an HTML element that declares
     * (and supports) the "overflow" attribute then this element may develop
     * a vertical scrollbar in order to contain all the rows. Also if the 
     * container elements do not declare any "overflow" CSS property, then the
     * same may happen to the entire HTML page. 
     * In such a cases new rows added to the grid (or moved due to the sort settings)
     * may be placed in the nonvisible part of the including element/page. 
     * <BR>This can be avoided by enabling the auto-scroll. In this case,
     * each time a row is added or updated, the scrollbar is repositioned
     * to show the row involved. This feature, however, should be used only
     * if the update rate is low or if this grid is listening to a DISTINCT 
     * Subscription; otherwise, the automatic scrolling activity may be excessive.
     * <BR>Note that in case the grid is configured in UPDATE_IS_KEY mode (that is
     * the default mode used when the grid is listening to a DISTINCT subscription) and
     * the scrollbar is moved from its automatic position, then the auto-scroll
     * is disabled until the scrollbar is repositioned to its former 
     * position. This automatic interruption of the auto scrolling is not supported
     * on pre-webkit Opera browsers.
     * <BR>The auto-scroll is performed only if single page mode is currently
     * used (i.e. the maximum number of visible rows is set to unlimited).
     *
     * <p class="default-value"><b>Default value:</b> "OFF".</p>
     *
     * <p class="lifecycle"><b>Lifecycle:</b> The auto-scroll policy can be set and changed
     * at any time.</p>
     *
     * @param {String} type The auto-scroll policy. Permitted values are:
     * <ul>
     * <li>"OFF": No auto-scrolling is required;</li>
     * <li>"ELEMENT": An element's scrollbar should auto-scroll;</li>
     * <li>"PAGE": The browser page's scrollbar should auto-scroll.</li>
     * </ul>
     * @param {String} elementId The HTML "id" attribute of the HTML element whose scrollbar
     * should auto-scroll, if the type argument is "ELEMENT"; not used,
     * otherwise.
     * @see DynaGrid#setMaxDynaRows
     * @see AbstractGrid#forceSubscriptionInterpretation
     * 
     */
    setAutoScroll: function(type, elementId) {
      if (!type) {
        throw new IllegalArgumentException(WRONG_SCROLL_TYPE);
      }
      
      type = new String(type).toUpperCase();
      
      if (type == ELEMENT) {
        if (!elementId) {
          throw new IllegalArgumentException(NO_AUTOSCROLL_ELEMENT);
        } else {
          this.autoScrollElement = elementId;
        }
        
      } else if (type != PAGE && type != OFF) {
        throw new IllegalArgumentException(WRONG_SCROLL_TYPE);

      }
      this.autoScrollType = type;
      
      this.prepareAutoScroll();
      
    },
    
    
//////////////////////////////////TEMPLATE SETUP    
    
    /**
     * @protected
     * @inheritdoc
     */
    parseHtml: function() {
      this.parsed = true;
      
      var ancestorNode = this.clonedNode;
      if (ancestorNode) {
        if (Cell.isAttachedToDOM(ancestorNode))  {
          //template already saved and still there
          return true;  
        } else {
          //the template disappeared, reset and read again
          this.initDOM();
        }
      }
      
      ancestorNode = document.getElementById(this.id);
      //verifies the template
      if (!this.templateControl(ancestorNode)) {
        return false;
      }
      
      //clone the template
      this.template = ancestorNode.cloneNode(true);
      this.template.removeAttribute("id");
  
      //save the original template for future use (var name is misleading)
      this.clonedNode = ancestorNode;
      //save its parent too, will be used to append clones
      var ancestorParent = ancestorNode.parentNode;
      this.nodeContainer = ancestorParent;
    
      //let's hide the original template
      ancestorNode.style.display = "none";
      
      //search the position of the template in its parent
      var ancestorBrothers = ancestorParent.childNodes;
      var i = 0;
      var offsetIndex = 0;
      var refererNode = null;
      for (i = 0; i < ancestorBrothers.length; i++) {
        // Both in the upwardScroll case and the reverse
        // the brother to be signed is the same, that is
        // the brother immediately following the ancestor
        // so the first inserted "will replace" the ancestor
        // (it is inserted between the ancestor and that brother, given the invisibility
        // dell'ancestor, it seems a substitution)
        if (ancestorBrothers[i] == ancestorNode) {
          if (ancestorBrothers[i+1]) {
            refererNode = ancestorBrothers[i+1];
          } 
          offsetIndex = i+1;
          break;
        }  
      }
      
      this.clonedContainer = new VisibleParent(ancestorParent, refererNode, offsetIndex);
      this.nextParent = new InvisibleParent();
      this.prevParent = new InvisibleParent();
      
      return true;
    },
    
    /**
     * @protected
     * @ignore
     */
    computeFieldSymbolsSet: function(type) {
      var template = this.clonedNode;
      var lsTags = Cell.getLSTags(template,this.tagsToCheck);
      var fieldSymbolsSet = {};
      for (var j = 0; j < lsTags.length; j++) {
        if (lsTags[j].getFieldType() == type) {
          var fieldSymbol = lsTags[j].getField();
          if (fieldSymbol) {
            fieldSymbolsSet[fieldSymbol] = true;
          }
        }
      }
      return fieldSymbolsSet;
    },
    
    /**
     * @private
     */
    templateControl: function(template) {
      //do a control on the template and its contained cells
      if (!template) {
        //no template no party!
        throw new IllegalArgumentException(NO_TEMPLATE);
      }
      
      if (!Cell.verifyTag(template)) {
        throw new IllegalArgumentException(NO_SOURCE);
      }      
      
      var validLSTags = [];
      var lsTags = Cell.getLSTags(template,this.tagsToCheck); 
      for (var pi = 0; pi < lsTags.length; pi++) {
        if (lsTags[pi].getField()) {
          validLSTags.push(lsTags[pi]);
        }
      }
      
      if (validLSTags.length <= 0) {
        throw new IllegalArgumentException(NO_CELLS);
      }
      
      return true;
    },
    
    /**
     * @private
     */
    prepareAutoScroll: function() {
       // autoscroll management: I take the node to scroll if it is autoscroll on an html element  
      if (this.autoScrollType == ELEMENT) {
        if (this.autoScrollElement && this.autoScrollElement.appendChild) {
          // the template has already been read
          // otherwise "autoScrollElement" would be a string and
          // would not have the appendChild method
        } else {
          var scrollElement = document.getElementById(this.autoScrollElement);  
          if (!scrollElement) {
            gridsLogger.logError("Cannot find the scroll element",this);
            this.autoScrollType = OFF;
          } else {
            this.autoScrollElement = scrollElement;
          }
        }
      } 
    },
    
////////////////////////////////////////////////////VISUAL CONTROL    
    
    /**
     * @private
     */
    initDOM: function() {
      this.clonedNode = null; //original template
      this.template = null; //template clone
      this.nodeContainer = null; //the template parent
      
      this.clonedContainer = null; //Visibleparent
      this.nextParent = null; //InvisibleParent (required for paging)
      this.prevParent = null; //InvisibleParent (required for paging)
      
      this.clonesArray = {};
    },

    /**
     * @private
     */
    getTemplateClone: function() {
      return this.template.cloneNode(true);
    },
    
    /**
     * @ignore
     */
    onNewCell: function(cell,row,field) {
      this.grid.addCell(cell,row,field);
    },
        
    /**
     * @inheritdoc
     */
    clean: function() {
    //why this useless implementation here? Is it because of closure? TODO verify
      this._callSuperMethod(DynaGrid,"clean");
    },

    /**
     * @private
     */
    willAutoScroll: function() {
      if (this.autoScrollType == OFF) {
        return false;
      }
      
      if (!this.updateIsKey()) {
        //always scroll
        return true;
        
      } else {
        var scrollEl = this.autoScrollType == ELEMENT ? this.autoScrollElement : document.body;
        
        if (this.addOnTop) {
          return scrollEl.scrollTop == 0;
        }
        
        //we only scroll if the scrollbar is on the downmost position --> (scrollEl.clientHeight + scrollEl.scrollTop) == scrollEl.scrollHeight
      
        if (BrowserDetection.isProbablyOldOpera()) {
          //Opera handling of clientHeight, scrollTop and scrollHeight
          //is a little bit different:
          //When the scrollbar is on the bottom clientHeight + scrollTop is
          //equal to scrollHeight on other browsers while on opera it might
          //be a little bigger. 
          return true;
        }
          
     
        return Math.abs(scrollEl.clientHeight + scrollEl.scrollTop - scrollEl.scrollHeight) <= 1; //rogue pixel
      }
    },
    
    /**
     * @private
     */
    getNewScrollPosition: function(el) {
      var scrollEl = this.autoScrollType == PAGE ? document.body : this.autoScrollElement;
      if (this.updateIsKey()) {
        return this.addOnTop ? 0 : scrollEl.scrollHeight-scrollEl.clientHeight;
        
      } else {
      
        return el.offsetTop - scrollEl.offsetTop;
      }
    },
    
    /**
     * @private 
     */
    doAutoScroll: function(scrollTo) {
      if (gridsLogger.isDebugLogEnabled()) {
        gridsLogger.logDebug("Perform auto-scroll",this,scrollTo);
      }
      if (this.autoScrollType == PAGE) {      
        window.scrollTo(0,scrollTo);
      } else {
        this.autoScrollElement.scrollTop = scrollTo;
      }
    },
    
    /**
     * @protected
     * @ignore
     */
    sortTable: function() {
      var mySortCode = this.sortField;
      
      //temporary object, will contain all the nodes
      var tempTable = new InvisibleParent();
  
      var x = 1;
      while (this.rowCount > 0) {
        var first = this.getNodeByIndex(x);
        if (!first) {
          this.rowCount--;
          x++;
          continue;
        }
        
        //if sortField is not specified it will only reorder elements on the pages
        if (mySortCode == null) {
          tempTable.appendChild(first,true);
          this.rowCount--;
          continue;
        }
        
        var firstKey = first.getKey();
        if (firstKey == "") {
          this.rowCount--;
          x++;
          continue;
        }
        
        var sortKey = this.makeSortValue(this.values.get(firstKey,this.sortField));

        //I should exploit the calculateSortedPosition method
        
        var up = 0; 
        var down = tempTable.length - 1;
        
        while (up < down) {
          var j = Math.floor((up + down) / 2); 
          var compare = tempTable.getChild(j);
          var k = this.makeSortValue(this.values.get(compare.getKey(),this.sortField)); 
          if (!k) {
            gridsLogger.logWarn("Can't find value for sort key field",this);
            //can happen if a non existent field is specified
          }
          if (this.isBefore(sortKey,k)) {
            down = j - 1;
          } else {
            up = j + 1;
          }
        }
        var compare = tempTable.getChild(up);
        
        if (up == down) {
          var compareKey = this.makeSortValue(this.values.get(compare.getKey(),this.sortField)); 
          if (this.isBefore(sortKey,compareKey)) {
            tempTable.insertBefore(first,compare);
          } else {
            var afterDown = tempTable.getChild(down+1);
            if (!afterDown) {
              tempTable.appendChild(first,true);
            } else {
              tempTable.insertBefore(first,afterDown);
            }
          }
        } else {
          if (compare) {
            tempTable.insertBefore(first,compare);
          } else {
            tempTable.appendChild(first,true);
          }
          
        }
        this.rowCount--;
      }
      
        
      //everythin is in the temporary object, now distribute'em
      var z = 0;
      while (z < tempTable.length) {
        this.rowCount++;
        var el = tempTable.getChild(z);
        
        if (this.rowCount <= (this.maxRow * (this.pageNumber - 1))) {
          this.prevParent.appendChild(el,true);
        } else if ((this.maxRow <= 0)||(this.rowCount <= (this.maxRow * this.pageNumber))) {
          this.clonedContainer.appendChild(el,true);
        } else {
          this.nextParent.appendChild(el,true);
        }
  
      }
    },
    
    /**
     * @protected
     * @ignore
     */
    changePage: function(toPage) {
      if(this.rowCount <= 0) {
        return;
      }
      if (this.pageNumber >= toPage) {
        while (this.shiftDown(this.prevParent,this.clonedContainer,(toPage - 1) * this.maxRow)) {
          this.shiftDown(this.clonedContainer,this.nextParent,this.maxRow);
        }
      } else {       
        while (this.fitFreeSpace(this.clonedContainer,this.prevParent,(toPage - 1) * this.maxRow,false)) {
          this.fitFreeSpace(this.nextParent,this.clonedContainer,this.maxRow,false);
        }
      }
      
      this.pageNumber = toPage;
    },
    
    /**
     * @protected
     * @ignore
     */
    calculatePages: function() {
      if (gridsLogger.isDebugLogEnabled()) {
        gridsLogger.logDebug("Calculate number of pages",this);
      }
      
      var nowPages = 0;
      if (this.maxRow <= 0) {
        nowPages = 1;
      } else {
        nowPages = Math.ceil(this.rowCount / this.maxRow);
      }
  
      if (this.currentPages != nowPages) {
        this.currentPages = nowPages;
        this.dispatchEvent("onCurrentPagesChanged",[this.currentPages]);
      }
      
      return nowPages;
    },  
    
/////////////////////////////////////VISUAL EXECUTION    
  
    /**
     * @protected
     * @ignore
     */
    removeRowExecution: function(key) {
      var toRemove = this.clonesArray[key];
      if (!toRemove) {
        return;
      }
      this.rowCount--;
      
      this.calculatePages();
      
      //onTop is only possible if sort is disabled and grid is configured that way.
      var onTop = false;
      var upParent = this.prevParent;
      var downParent = this.nextParent;
      
      this.dispatchEvent("onVisualUpdate" ,[key,null,toRemove.element()]);
       
      if(this.updateIsKey() && this.addOnTop && this.sortField == null) {
        //only possible if updateIsKey
        onTop = this.addOnTop;
        upParent = this.nextParent;
        downParent = this.prevParent;
      }
      
      if (toRemove.isSonOf(this.clonedContainer)) { //this.clonedContainer is a VisibleParent 
        //remove from visible nodes
        this.clonedContainer.removeChild(toRemove);
        //if necessary scroll up
        this.fitFreeSpace(downParent, this.clonedContainer, this.maxRow, onTop);
      } else if (toRemove.isSonOf(downParent)) {
        //remove from non-visible nodes
        downParent.removeChild(toRemove);
      } else {
        this.prevParent.removeChild(toRemove);
        //if necessary scroll up (the visibile nodes)
        if (this.fitFreeSpace(this.clonedContainer, upParent, this.maxRow * (this.pageNumber - 1), onTop)) {
          //if necessary scroll up
          this.fitFreeSpace(downParent, this.clonedContainer, this.maxRow, onTop);
        }
      }
      
      this.grid.delRow(key);
      delete(this.clonesArray[key]);
      
    },
    
    /**
     * @protected
     * @ignore
     */
    updateRowExecution: function(key,serverValues) { 
      var calculatePagesFlag = false;   
      var toUpdate = this.clonesArray[key];
      
      if (!toUpdate) {
        //this is an add
        toUpdate = new DynaElement(key, this);
        this.clonesArray[key] = toUpdate;
        toUpdate.element();
      }

//>>excludeStart("debugExclude", pragmas.debugExclude);            
      ASSERT.verifyOk(toUpdate);
//>>excludeEnd("debugExclude"); 
      
      this.fillFormattedValues(key,serverValues);
      
      var upInfo = this.dispatchVisualUpdateEvent(key,serverValues,toUpdate);
      
      var performScroll = this.willAutoScroll();
      var isNew = !this.values.getRow(key);
      
      var oldSortVal = this.sortField != null ? this.makeSortValue(this.values.get(key,this.sortField)) : null;
      var newSortVal = this.sortField != null ? this.makeSortValue(serverValues[this.sortField]) : null;
      var dontMove = oldSortVal == newSortVal || (!serverValues[this.sortField] && serverValues[this.sortField] !== null);
      
      if (this.sortField != null && dontMove == false) {
        
        var insInd = this.calculateSortedPosition(toUpdate,oldSortVal,newSortVal);
        this.insertNodeAtIndex(insInd,toUpdate);
        
        if (isNew) {
          this.rowCount++;
          calculatePagesFlag = true;
        } 
        
      } else if (isNew) {
        
        //No sort and new row: 
        //When upward scroll is not active, new updates are placed at the top of the model data table, so that old updates scroll downward. 
        //On the other hand, when upward scroll is active, new updates are placed at the bottom of the model data table.

        this.appendNode(toUpdate,!this.addOnTop);
        this.rowCount++;
        calculatePagesFlag = true;
      } 
      
      //place new values in the cells
      this.visualUpdateExecution(key,upInfo);
      
      this.updateInProgress = null;
      
      //if too many rows and update_is_key remove the oldest one
      if (isNew && this.updateIsKey()) {
        this.limitRows();
      }

      if (performScroll && toUpdate.isSonOf(this.clonedContainer)) {
        var newScrollPos = this.getNewScrollPosition(toUpdate.element());
        this.doAutoScroll(newScrollPos);
      }
      
      if (calculatePagesFlag) {
        this.calculatePages();
      }
      
    },
    
    /**
     * @private
     */
    dispatchVisualUpdateEvent: function(key,serverValues,toUpdate) {
      
      this.currentUpdateKey = key;
      this.currentUpdateValues = serverValues;
      
      //this references are used to handle reentrant calls; if an
      //updateRow call is performed during the VisualUpdate it is 
      //merged in this update instead of spawning a new update.
      var upInfo = new VisualUpdate(this.grid,serverValues,key); 
      this.dispatchEvent("onVisualUpdate",[key,upInfo,toUpdate.element()]);
      
      this.currentUpdateKey = null;
      this.currentUpdateValues = null;

      return upInfo;
      
    },
   
    /**
     * @private
     */
    calculateSortedPosition: function(toUpdate,oldSortVal,newSortVal) {
      var up = 1;
      var down = this.rowCount;
      var meIndex = -1;
      var j = -1;
      
      // search an equal key or the case in which up exceeds down
      while (up < down) {
        j = Math.floor((up + down) /2);
        var thisKey = null;

        if (j <= this.rowCount) {
          var compare = this.getNodeByIndex(j);
          if (compare == toUpdate) {
            thisKey = oldSortVal;
            meIndex = j;
          } else {
            thisKey = this.makeSortValue(this.values.get(compare.getKey(),this.sortField)); 
          }
        }
        if (this.isBefore(newSortVal,thisKey)) {
          down = j - 1;
        } else {
          up = j + 1;
        }
      }

      if (up == down) {
        // up and down coincide, our place is immediately before or immediately after this point
        var compare = this.getNodeByIndex(up);
        var compareKey = this.makeSortValue(this.values.get(compare.getKey(),this.sortField));
        if (this.isBefore(newSortVal,compareKey)) {
          return up;
        } else {
          return up + 1;
        }
      } else {
        return up;
      }
    },

    /**
     * @protected
     * @ignore
     */
    getNodeByIndex: function(i) {
      
      if (i > this.rowCount || i <= 0) {
        return null;
      } 
      
      if (i <= this.prevParent.length) {
        return this.prevParent.getChild(i-1);
      } else {
        i -= this.prevParent.length;
        if (i <= this.clonedContainer.length) {
          return this.clonedContainer.getChild(i-1);
        } else {
          i -= this.clonedContainer.length;
          return this.nextParent.getChild(i-1);
        }
      } 
      
    },
    
    /**
     * @protected
     * @ignore
     */
    appendNode: function(toUpdate,onBottom) {
      
      var upParent = onBottom ? this.prevParent : this.nextParent;
      var downParent = onBottom ? this.nextParent : this.prevParent;
      
      if (downParent.length > 0 || (this.clonedContainer.length == this.maxRow && this.maxRow > 0)) {
        //there is no room in the central "window", so append in the downParent
        //having something in the downParent implies that the central window is full
        downParent.appendChild(toUpdate,onBottom);
        return downParent;
        
      } else if (this.clonedContainer.length > 0 || upParent.length == (this.maxRow * (this.pageNumber - 1))) { //as a consequence we pass from here if this.maxRow == 0 (upParent.length would be 0 and 0*x = 0)
        //central window is not empty (if empty the updates may have to be to be placed on the upParent)
        //or all the existing elements are in the upParent (and all the pages in the upParent are full)
        this.clonedContainer.appendChild(toUpdate,onBottom);
        return this.clonedContainer;
        
      } else {
        upParent.appendChild(toUpdate,onBottom);
        return upParent;
      }
    },
    
    /**
     * @protected
     * @ignore
     */
    insertNodeAtIndex: function(i, node) { 
      if (i > this.rowCount + 1 || i <= 0) {
        return;
      } 
      
      if (node == this.getNodeByIndex(i)) {
        return;
      }
      
      
      var firstP = node.getParentNode(); 
      var afterP;
      
      var parent = this.clonedContainer;
      var nextParent = this.nextParent;
      var prevParent = this.prevParent;
      
      var insBef = this.getNodeByIndex(i);
      if (insBef == null) {
        afterP = this.appendNode(node,true);
      
      } else {
        afterP = insBef.getParentNode(); 
        afterP.insertBefore(node,insBef);
      }
      
      //let's handle overflows
      if (afterP == parent) {
        if ((!firstP) || (firstP == nextParent)) {
          this.shiftDown(parent, nextParent, this.maxRow);
        } else if (firstP == prevParent) {
          this.fitFreeSpace(parent, prevParent, this.maxRow * (this.pageNumber - 1), false);
        } 
      } else if (afterP == prevParent) {
        if (firstP != prevParent) {
          if (this.shiftDown(prevParent, parent, this.maxRow * (this.pageNumber - 1))) {
            this.shiftDown(parent, nextParent, this.maxRow);
          }
        }
      } else if (afterP == nextParent) {
        if (firstP == prevParent) {
          this.fitFreeSpace(parent, prevParent, this.maxRow * (this.pageNumber - 1), false);
        } 
        this.fitFreeSpace(nextParent, parent, this.maxRow, false);
      }
      
    },
    
    /**
     * @private
     */
    fitFreeSpace: function(fromNode, toNode, maxForTo, onTop) {
      //if a place was freed in a parent we grab a row from the following parent and move it 
      //to the freed one
      if (this.maxRow <= 0) {
        //infinite visible places, only one parent has rows here.
        return false;
      }
      if (toNode.length < maxForTo && fromNode.length > 0) {
        var toMoveEl = fromNode.getChild(0);
        toNode.appendChild(toMoveEl,!onTop);
        return true;
      }
      return false;
    },
    
    /**
     * @private
     */
    shiftDown: function(fromNode, toNode, maxForFrom) {
      if (this.maxRow <= 0) {
        //infinite visible places
        return false;
      }
      if (fromNode.length > maxForFrom) {
        var toMoveEl = fromNode.getChild(fromNode.length-1);
        toNode.insertBefore(toMoveEl,toNode.getChild(0));
        
        return true;
      }
      return false;
    },
    
    /**
     * @private
     */
    limitRows: function() {
      //only updateiskey limits rows in this way
      while(this.maxRow > 0 && this.rowCount > this.maxRow) {
        this.removeRow(this.getOldestKey());
      }
    },
    
    /**
     * Adds a listener that will receive events from the DynaGrid 
     * instance.
     * <BR>The same listener can be added to several different DynaGrid 
     * instances.
     * 
     * <p class="lifecycle"><b>Lifecycle:</b> a listener can be added at any time.</p>
     * 
     * @param {DynaGridListener} listener An object that will receive the events
     * as shown in the {@link DynaGridListener} interface.
     * <BR>Note that the given instance does not have to implement all of the 
     * methods of the DynaGridListener interface. In fact it may also 
     * implement none of the interface methods and still be considered a valid 
     * listener. In the latter case it will obviously receive no events.
     */
    addListener: function(listener) {
      this._callSuperMethod(DynaGrid,"addListener",[listener]);
    },
    
    /**
     * Removes a listener from the DynaGrid instance so that it
     * will not receive events anymore.
     * 
     * <p class="lifecycle"><b>Lifecycle:</b> a listener can be removed at any time.</p>
     * 
     * @param {DynaGridListener} listener The listener to be removed.
     */
    removeListener: function(listener) {
      this._callSuperMethod(DynaGrid,"removeListener",[listener]);
    },
    
    /**
     * Returns an array containing the {@link DynaGridListener} instances that
     * were added to this client.
     * 
     * @return {DynaGridListener[]} an array containing the listeners that were added to this instance.
     * Listeners added multiple times are included multiple times in the array.
     */
    getListeners: function() {
      return this._callSuperMethod(DynaGrid,"getListeners");
    }
  
  };
  
  //closure compiler exports
  DynaGrid.prototype["setMaxDynaRows"] = DynaGrid.prototype.setMaxDynaRows;
  DynaGrid.prototype["getMaxDynaRows"] = DynaGrid.prototype.getMaxDynaRows;
  DynaGrid.prototype["goToPage"] = DynaGrid.prototype.goToPage;
  DynaGrid.prototype["getCurrentPages"] = DynaGrid.prototype.getCurrentPages;
  DynaGrid.prototype["setAutoScroll"] = DynaGrid.prototype.setAutoScroll;
  DynaGrid.prototype["parseHtml"] = DynaGrid.prototype.parseHtml;
  DynaGrid.prototype["clean"] = DynaGrid.prototype.clean;
  DynaGrid.prototype["addListener"] = DynaGrid.prototype.addListener;
  DynaGrid.prototype["removeListener"] = DynaGrid.prototype.removeListener;
  DynaGrid.prototype["getListeners"] = DynaGrid.prototype.getListeners;
  DynaGrid.prototype["updateRowExecution"] = DynaGrid.prototype.updateRowExecution;
  DynaGrid.prototype["removeRowExecution"] = DynaGrid.prototype.removeRowExecution;
  
//Listener Interface ---->
  
  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports DynaGridListener
   * @class Interface to be implemented to listen to {@link DynaGrid} events
   * comprehending notifications of changes in the shown values and, in case
   * pagination is active, changes in the number of total logical pages.
   * <BR>Events for this listeners are executed synchronously with respect to the code
   * that generates them. 
   * <BR>Note that it is not necessary to implement all of the interface methods for 
   * the listener to be successfully passed to the {@link DynaGrid#addListener}
   * method.
   * 
   * @see DynaGrid
   */
  var DynaGridListener = function() {
    
  };
  
  
  DynaGridListener.prototype = {
      
      /**
       * Event handler that receives the notification that the number of
       * logical pages has changed. The number of logical pages can grow or
       * shrink because of addition or removal of rows and because of changes
       * in the logical page size setting.
       * By implementing this method it is possible, for example, to implement
       * a dynamic page index to allow direct jump to each logical page.
       *
       *
       * @param {Number} numPages The current total number of logical pages.
       * @see DynaGrid#setMaxDynaRows
       * @see DynaGrid#goToPage
       */
      onCurrentPagesChanged: function(numPages) {
        
      },
      
      /**
       * Event handler that is called by Lightstreamer each time a row of the
       * grid is being added or modified.
       * By implementing this method, it is possible to perform custom
       * formatting on the field values, to set the cells stylesheets and to
       * control the display policy.
       * In addition, through a custom handler, it is possible to perform custom
       * display actions for the row, by directly acting on the DOM element
       * containing the grid row.
       * <BR>This event is also fired when a row is being removed from the grid,
       * to allow clearing actions related to custom display actions previously
       * performed for the row. Row removal may happen when the {@link DynaGrid}
       * is listening to events from {@link Subscription} instance(s), and the first
       * Subscription it listens to is a COMMAND Subscription;
       * removal may also happen in case of {@link AbstractWidget#removeRow} or
       * {@link AbstractWidget#clean} execution and in case of destruction of
       * a row caused by exceeding the maximum allowed number of rows (see
       * {@link DynaGrid#setMaxDynaRows}).
       * <BR>
       * <BR>This event is fired before the update is applied to both the HTML cells
       * of the grid and the internal model. As a consequence, through 
       * {@link AbstractWidget#updateRow}, it is still possible to modify the current update.
       * <BR>This notification is unrelated to paging activity. New or changed
       * rows are notified regardless that they are being shown in the current
       * page or that they are currently hidden. Also, no notifications are
       * available to signal that a row is entering or exiting the currently
       * displayed page.
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
       * @param {Object} domNode The DOM pointer to the HTML row involved.
       * The row element has been created by Lightstreamer, by cloning the
       * template row supplied to the {@link DynaGrid}.
       */
      onVisualUpdate: function(key, visualUpdate, domNode) {
        
      }
      
      
  };
//<----  Listener Interface    
  

  
  Inheritance(DynaGrid,AbstractGrid);
  return DynaGrid;
})();
  
