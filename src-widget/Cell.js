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
  
  var FIELD = "field";
  var TABLE = "grid";
  var ROW = "row";
  var ITEM = "item";
  var UPDATE = "update";
  var VALUE = "value";
  var IDENTIFICATION_NUMBER = "replica";
  
  var TYPE = "fieldtype";
  var VALID_TYPES = {
    "extra": true,
    "first-level": true,
    "second-level": true
  };
  var EXTRA = "extra";
  var FIRST_LEVEL = "first-level";
  var SECOND_LEVEL = "second-level";
  
  var HOT = 1;
  var COLD = 2;
  
  var VOID_VAL = "\u00A0"; // Constant to be inserted into cells in the DOM to empty them.
  //var VOID_HTML = "&nbsp;"; //?
 
  var SOURCE_ATTR_NAME = "source";
  var SOURCE_ATTR_VALUE = "lightstreamer";
  
  var valueType= {
      "input": true,
      "textarea": true};
  
  
  //reads an attribute from an element
  function getLSAttribute(el,name) {
    if (Cell.useOldNames === false) {
      return getNewAttribute(el,name);
    
    } else if (Cell.useOldNames === true) {
      return getOldAttribute(el,name);
      
    } else {
      var res = getNewAttribute(el,name);
      if (res) {
        Cell.useOldNames = false;
        return res;
      }
      
      res = getOldAttribute(el,name);
      if (res) {
        Cell.useOldNames = true;
      }
      return res;
      
    }
  }
  
  function getNewAttribute(el,name) {
    if (el.dataset) {
      if (el.dataset[name]) {
        return el.dataset[name];
      } else {
        return el.getAttribute("data-"+name);  
      }
    } else {
      return el.getAttribute("data-"+name);
    }
  }
  
  function getOldAttribute(el,name) {
    return el.getAttribute(name);
  }
  
  /**
   * Merges two arrays of css attributes
   */
  function mergeStyleArrays(localAttr, rowAttr) {
    if (!localAttr) {
      return rowAttr;
    }

    for (var type in rowAttr) {
      if (!localAttr[type]) {
        if (localAttr[type] === null || localAttr[type] === ""){
          continue;
        }
        localAttr[type] = rowAttr[type];
      }
    }
    return localAttr;
  }
  
  /**
   * verifies that the source="lightstreamer" property is present
   */
  function verifyTag (node) {
    var str = getLSAttribute(node,SOURCE_ATTR_NAME);
    return str && str.toLowerCase() == SOURCE_ATTR_VALUE;
  }
  
  
/*
 * Update-What functions
 * depending on the attribute to be updated
 * a different write/read method will be attached to the cell
 */
  
  
////////////////updateWhat -> style.something
  
  function getUpdateStyleFunction(updateWhat)  {
    return function(val) {
      this.el.style[updateWhat] = val === VOID_VAL ? null : val;
    };
  }
  function getRetrieveStyleFunction(retrieveWhat) {
     return function(){
      return this.el.style[retrieveWhat] || "";
     };
  }

////////////////updateWhat -> form.value
    
  function updateFormValue(val) {
    if (!val || val === VOID_VAL) {
      this.el.value="";
    } else {
      this.el.value=val;
    }
  }
  
  function retrieveFormValue() {
    return this.el.value;
  }

////////////////updateWhat -> content <- this is the "normal" case
  
  function updateContent(val,useInner) {
    if (useInner) {
      this.el.innerHTML = val;
      
    } else { 
      if (this.el.childNodes.length != 1 || this.el.firstChild.nodeType != 3) {
        // we pass by here if
        // * in the cell there is html (more than one child indicates at least one tag; one child but not
        // nodeType 3 is not a text node): clean it
        // * or the cell is completely empty (no firstChild):
        // it was created by LS_cell and its contents was empty
        if (this.el.firstChild != null) {
          this.el.innerHTML = "";
        }
        this.el.appendChild(document.createTextNode(val));
      } else {
        // if the cell was taken over by convertHtmlStructures
        // it is definitely a TextNode;
        // if the cell has already been updated once in life
        // it is certainly a TextNode
        // in any case the test means that here there is necessarily a TextNode
        this.el.firstChild.nodeValue = val;
      }
   
    } 
  }
  function retrieveContent(getInner) {
    if (getInner) {
      return this.el.innerHTML;
    } else if(this.el.firstChild) {
      return this.el.firstChild.nodeValue;
    } 
    return "";
  }
  
////////////////updateWhat -> other attribute  
  
  function getUpdateAttributeFunction(updateWhat) {
    if (updateWhat === VALUE) {
      return updateFormValue;
    }
    return function(val) {
      if (!val || val === VOID_VAL) {
        this.el.removeAttribute(updateWhat);
      } else {
        this.el.setAttribute(updateWhat, val);
      }
    };
  }
  
  
  function getRetrieveAttributeFunction(retrieveWhat) {
    if (retrieveWhat === VALUE) {
      return retrieveFormValue;
    }
  
    return function(){
      return this.el.getAttribute(retrieveWhat);
    };
  
  }  

  
  
  var nextId = 0;
  
  /**
   * @private
   */
  var Cell = function(domCell,updateWhat) {
      this.el = domCell;
      /*public*/ this.isCell = true;
      /*public*/ this.fadePhase = 0;
     
      if (!updateWhat) {
        //reads what is to update from the HTML
        updateWhat = this.getUpdateWhat();
      }
      
      //setup read and write methods for this instance
      if (updateWhat) {
        if (updateWhat.toLowerCase().indexOf("style.") == 0) {
          var styleToUpdate = updateWhat.slice(6);
          this.updateValue = getUpdateStyleFunction(styleToUpdate);
          this.retrieveValue = getRetrieveStyleFunction(styleToUpdate);
        } else {
          this.updateValue = getUpdateAttributeFunction(updateWhat);
          this.retrieveValue = getRetrieveAttributeFunction(updateWhat);
        }
        
      } else {
        var nodeName = domCell.nodeName.toLowerCase();
        if (nodeName in valueType) {
          this.updateValue = updateFormValue;
          this.retrieveValue = retrieveFormValue;
        } else {
          this.updateValue = updateContent;
          this.retrieveValue = retrieveContent;
        }
      }
    
      this.cellId = nextId++;
      this.updateCount = 0;
     
      //will hold updates before being set on cell
      this.nextFormattedValue = null;
      this.newHotArray = null;
      this.newColdArray = null;
      
      //reads from the cell the current status for future cleaning
      this.initialValue = this.retrieveValue(true);
      this.initialClass = this.extractCSSClass();
      this.initialStyles = this.extractStyles();
      
  };
  
  //expose constants
  Cell.HOT = HOT;
  Cell.COLD = COLD;
  Cell.FIRST_LEVEL = FIRST_LEVEL;
  Cell.SECOND_LEVEL = SECOND_LEVEL;
  
  //both old and new names are accepted (i.e.: with or without the data- prefix)
  //we will not admit a mix of old and new though
  Cell.useOldNames = null; //this is only exposed for test purposes 
  

  /**
   * Extract elements from the DOM
   * @static
   */
  Cell.getLSTags = function(root,nodeTypes) {
    var lsTags = [];
    
    if (!nodeTypes) {
      nodeTypes = ["*"]; //gets all the tags
    }
     
    //TODO use selectors if available
    for (var i = 0; i < nodeTypes.length; i++) {
      var tempTags = root.getElementsByTagName(nodeTypes[i]);
      for (var v = 0; v < tempTags.length; v++) {
        if (verifyTag(tempTags[v])) {
           lsTags.push(new Cell(tempTags[v]));
        }
      }
    }
    return lsTags;
  };
  
  Cell.verifyTag = verifyTag;
 
  Cell.isAttachedToDOM = function(toFindNode) {
    var prevCurrCell = null;
    var currCell = toFindNode;
    while (currCell != null && currCell != document) {
      prevCurrCell = currCell;          
      currCell = currCell.parentNode;
    }
    if (currCell == null) {
      if (prevCurrCell != null && prevCurrCell.nodeName == "HTML") {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  };
 
  Cell.prototype = {
      
    //methods attached during creation
    //updateValue: function(value,useInner)  {}
    //retrieveValue: function() {}
      
    scrollHere: function(otherCell,useInner) {
      this.updateValue(otherCell.retrieveValue(),useInner); //from cell to cell, using inner is safe
      
      this.nextFormattedValue = otherCell.nextFormattedValue;
      this.newHotArray = otherCell.newHotArray;
      this.newColdArray = otherCell.newColdArray;
      this.updateCount = otherCell.updateCount;
      
      this.setAttributes(otherCell.extractStyles());
      this.updateCSSClass(otherCell.extractCSSClass());
      
      this.fadePhase = otherCell.fadePhase;
      
    },
    
    getEl: function() {
      return this.el;
    },
    
    extractStyles: function() {
      var res = {};
      for (var s in this.el.style) {
        res[s] = this.el.style[s];
      }
      return res;
    },
    
    extractCSSClass: function() {
      return this.el.className;
    },
    
    updateCSSClass: function(writeClass) {
      if (writeClass !== null && this.el.className != writeClass) {
        this.el.className = writeClass;
      }
    },
    
    setAttributes: function(attrArr) {
      if (!attrArr) {
        return;
      }
      for (var attrName in attrArr) { 
        if (attrName == "CLASS") {
           this.updateCSSClass(attrArr[attrName]);
        }
        try {
          if (attrArr[attrName] !== null) {
            this.el.style[attrName] = attrArr[attrName];
          }
          
        } catch(e) {
          //old browsers (FX2 IE6) may pass from here
        }
      }
    },
    
    asynchUpdateStyles: function(ph,applyWhat) {
      if (ph != this.updateCount) {
        return;
      }
      
      if (applyWhat == HOT) {
        this.setAttributes(this.newHotArray);
        this.newHotArray = null;
        
      } else { //if (applyWhat == COLD) 
        this.setAttributes(this.newColdArray);
        this.newColdArray = null;
        
      }
      
    },
    
    asynchUpdateValue: function(ph,useInner) {
      if (ph != this.updateCount) {
        return;
      }
            
      this.updateValue(this.nextFormattedValue,useInner);
      this.nextFormattedValue = null;
      this.asynchUpdateStyles(ph,HOT);
    },
    
    setUpdating: function() {
      this.updateCount++;
      return this.updateCount;
    },
    
    getField: function() {
      var fieldName = getLSAttribute(this.el,FIELD);
      if (!fieldName) {
        return null;
      }
      return fieldName;
    },
    
    getNum: function() {
      var identificationNum = getLSAttribute(this.el,IDENTIFICATION_NUMBER);
      if (!identificationNum) {
        return null;
      }
      return identificationNum;
    },
    
    getFieldType: function() {
      var fieldType = getLSAttribute(this.el,TYPE);
      if (!fieldType) {
        return FIRST_LEVEL;
      }
      fieldType = fieldType.toLowerCase();
      return VALID_TYPES[fieldType] ? fieldType : FIRST_LEVEL;
    },
    
    getTable: function() {
      return getLSAttribute(this.el,TABLE);
    },
    
    getRow: function() {
      var r1 = getLSAttribute(this.el,ITEM);
      if (!r1) {
        r1 = getLSAttribute(this.el,ROW);
      }
      return r1;
    },
    
    getUpdateWhat: function() {
      return getLSAttribute(this.el,UPDATE);
    },
    
    incFadePhase: function() {
      return ++this.fadePhase;
    },
    
    getFadePhase: function() {
      return this.fadePhase;
    },
    
    getCellId: function() {
      return this.cellId;
    },
    
    isSameEl: function(otherCell) {
      return otherCell.el === this.el;
    },
    
    getTagName: function() {
      return this.el.tagName;
    },
    
    isAttachedToDOM: function() {
      return Cell.isAttachedToDOM(this.el);
    },
    
    isAttachedToDOMById: function() {
      if (!this.el.id) {
        return this.isAttachedToDOM(this.el);
      }
      var found = document.getElementById(this.el.id);
      return (found === this.el);
    },
    
    setNextFormattedValue: function(fValue) {
      this.nextFormattedValue = fValue === "" ? VOID_VAL : fValue;
    },
    
    getNextFormattedValue: function() {
      return this.nextFormattedValue;
    },
    
    addStyle: function(hotValue, coldValue, type) {
      if (!this.newHotArray) {
        this.newHotArray = {};
      }
      if (!this.newColdArray) {
        this.newColdArray = {};
      }
      
      this.newHotArray[type] = hotValue || "";
      this.newColdArray[type] = coldValue || "";
    },
    
    getNextHotArray: function(mergeWith) {
      if (mergeWith) {
        this.newHotArray = mergeStyleArrays(this.newHotArray,mergeWith);
      }
      
      return this.newHotArray;
    },
    
    getNextColdArray: function(mergeWith) {
      if (mergeWith) {
        this.newColdArray = mergeStyleArrays(this.newColdArray,mergeWith);
      }
      
      return this.newColdArray;
    },

    clean: function() {
      this.updateValue(this.initialValue,true);
      this.updateCSSClass(this.initialClass);
      this.setAttributes(this.initialStyles);
    }
  };
  
  
  
  
  return Cell;
})();

