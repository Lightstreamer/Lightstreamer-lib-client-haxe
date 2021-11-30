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

export default /*@__PURE__*/(function() {
  /**
   * @private
   */
  var DynaElement = function(uniqueKey,ownerTable) {
    this.key = uniqueKey;
    /*DynaGrid*/ this.ownerTable = ownerTable;
    this.myParent = null;
    this.node = null;
    this.id = "hc6|"+ownerTable.getId()+"|"+uniqueKey;  
  };
  
  DynaElement.prototype = {
    /*public*/ invisible: function() {
      if (this.node == null) {
        return;
      }
    },
    
    /*public*/ getParentNode: function() {
      return this.myParent;
    },
    
    /*public*/ setParentNode: function(newParent) {
      this.myParent = newParent;
    },
    
    /*public*/ isolation: function() {
      if (this.myParent) {
        this.myParent.removeChild(this);
      }
    },
    
    /*public*/ isSonOf: function(parent) {
      return this.myParent == parent;
    },
    
    /*public*/ getKey: function() {
      return this.key;
    },
    
    /*public*/ getId: function() {
      return this.id;
    },
    
    /*public*/ element: function() {
      if (this.node != null) {
        return this.node;
      } //else
        
      //clone template
      this.node = this.ownerTable.getTemplateClone();
      
      this.node.setAttribute("id",this.id); 
      
      //get "important" elements from the clone 
      var lsTags = Cell.getLSTags(this.node,this.ownerTable.getNodeTypes());             
      for (var pi = 0; pi < lsTags.length; pi++) {
        var currCell = lsTags[pi];
        var currFieldSymbol = currCell.getField();  
        if (!currFieldSymbol) {
          //no field specified
          continue;
        }
        
        this.ownerTable.onNewCell(currCell,this.key,currFieldSymbol);
      }
      
      return this.node;
    },
    
    /*public*/ clean: function() {
      if (this.node) {
        delete(this.node);
      }
    }
    
  };
  
  return DynaElement;
})();

