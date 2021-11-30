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

export default /*@__PURE__*/(function() {  
  var nextId = 0;
  
  /**
   * This class makes it possible to have a Cell interface bound to a key instead of being bound to a position.
   * So if the logic cell moves across different rows this class is always able to call methods on it.
   * This is not a complete proxy though
   * @private
   */
  var SlidingCell = function(ownerGrid, key, field, num, noNumIndex) {
    this.ownerGrid = ownerGrid;
    this.key = key;
    this.field = field;
    this.num = num || null;
    this.noNumIndex = noNumIndex;
    
    this.cellId = "s"+nextId++;
  };
  
  
  
  SlidingCell.prototype = {
    
    /*private*/ getCurrentCell: function() {
      var cell = this.ownerGrid.getCellByKey(this.key,this.field,this.num);
      if(!cell) {
        return null;
      }
      if (cell.isCell) {
        if (this.num === cell.getNum() && this.noNumIndex <= 0) {
          return cell;
        }
      } else {
        var nowI = -1;
        for (var i = 0; i < cell.length; i++) {
          var parsingCellNum = cell[i].getNum();
          if (parsingCellNum === null) {
            nowI++;
          }
          
          if (this.num === parsingCellNum && this.noNumIndex == nowI) {
            return cell[i];
          }
        }
      }
      
      return null;
      
    },
    
    
    /*public*/ incFadePhase: function() {
      var c = this.getCurrentCell();
      return c ? c.incFadePhase() : null;
    },
    /*public*/  getCellId: function() {
      return this.cellId;
    },
    /*public*/ getFadePhase: function() {
      var c = this.getCurrentCell();
      return c ? c.getFadePhase() : null;
    },
    /*public*/ getEl: function() {
      var c = this.getCurrentCell();
      return c ? c.getEl() : null;
    },
    
    /*public*/ asynchUpdateStyles: function(phaseNum,type) {
      var c = this.getCurrentCell();
      if (c) {
        c.asynchUpdateStyles(phaseNum,type);
      }
    },
    
    /*public*/ asynchUpdateValue: function(phaseNum,useInner) {
      var c = this.getCurrentCell();
      if (c) {
          c.asynchUpdateValue(phaseNum,useInner);
        }
    }
    
  };

  return SlidingCell;
})();

