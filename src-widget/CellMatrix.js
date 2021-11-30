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
import Matrix from "../src-tool/Matrix";
import Inheritance from "../src-tool/Inheritance";
import Cell from "./Cell";

export default /*@__PURE__*/(function() {
  function rowGarbageCollection(currRow) {
    var somethingInRow = false;
    for (var field in currRow) {
      if (!singleCellGarbageCollection(currRow[field])) {
        delete(currRow[field]);
      } else {
        somethingInRow = true;
      }
    }
    return somethingInRow;
  }
  
  function singleCellGarbageCollection(currCell) {
    if (currCell.isCell) {
      return currCell.isAttachedToDOMById();
  
    } else {
      var foundGroup = false;
      for(var i=0; i<currCell.length; ) {
        if (!currCell[i].isAttachedToDOMById()) {
          currCell.splice(i,1);
        } else {
          foundGroup = true;
          i++;
        }
      }
      return foundGroup;
    }
    
  }
  
  function makeFakeCell(orig,useInner) {
    var fakeCell = new Cell(document.createElement("p"));
    fakeCell.scrollHere(orig,useInner);
    
    var origNum = orig.getNum();
    fakeCell.getNum = function() {
      return origNum;
    };
    
    return fakeCell;
  }
  
  function cleanAll(cell) {
    if (cell.isCell) {
      cell.clean();
    } else for (var n=0; n<cell.length; n++){
      cell[n].clean();
    }
  }
  
  function copyAll(cell,useInner) {
    if (cell.isCell) {
      //creating a fake cell
      return makeFakeCell(cell,useInner);
      
    } else  {
      //create multiple fake cells
      var ret = [];
      for (var n = 0; n<cell.length; n++){
        ret[n] = makeFakeCell(cell[n],useInner);
      }
      return ret;
    }
  }
  
  /**
   * @private
   */
  var CellMatrix = function(pMatrix) {
    this._callSuperConstructor(CellMatrix,[pMatrix]);
  };
  
  CellMatrix.scrollRow = function(fromRow,toRow,useInner) {
    
    //for starters let's create a list of
    //all the possible columns by scanning both
    //"from" and "to" rows
    var colList = {};
    for (var c in fromRow) {
      colList[c] = true;
    }
    if (!toRow) {
      toRow = {};
    } else for (var c in toRow) {
      colList[c] = true;
    }
    
  
    //we have to scroll a row to another row; problem is that for a column there can be
    //more than one cell AND that this can be not symmetric between two different rows.
    //ALSO some of these cells can be identified by an id and several can be identified by a NULL
   
    for (var col in colList) {
      if (!fromRow[col]) {
        //column does not exist on origin: clean target
        cleanAll(toRow[col]);
        
      } else if (!toRow[col]) {
        //column does not exist on target: make a fake row
        toRow[col] = copyAll(fromRow[col],useInner);
        
      } else if(toRow[col].isCell && fromRow[col].isCell) {
        //both are cells, simple case
        toRow[col].scrollHere(fromRow[col],useInner);
        
      } else {
        //one or both are arrays, let's search and match
        
        //make both arrays
        var fromCells = fromRow[col].isCell ? [fromRow[col]] : fromRow[col];
        if (toRow[col].isCell) { //in any case will become an array
          var orig = toRow[col];
          toRow[col] = [orig]; 
        }
        //make a copy of the to-row array so that we can cross-out matched cells
        var toCells = [].concat(toRow[col]);
        
        //scan from-cells
        for (var n=0; n<fromCells.length; n++) {
          var matched = false;
          //search the correspondant to-cell if any
          for (var m=0; m<toCells.length; m++) {
            if (toCells[m].getNum() === fromCells[n].getNum()) { //a null would match with the first null available if any
              //if found do the scoll
              toCells[m].scrollHere(fromCells[n],useInner);
              matched = true;
              //and cross-out
              toCells.splice(m,1);
              break;
            }
          }
          
          if (!matched) {
            //if not add a fake cell to the to-row
            toRow[col].push(makeFakeCell(fromCells[n],useInner));
          }
        }
        //finally clean non-matched cells
        cleanAll(toCells);
      
      }
       
    }
      
    return toRow;
  };
  
  
  CellMatrix.prototype = {
      
      alreadyInList: function(elToCheck) {
        var cell = this.getCell(elToCheck.getRow(),elToCheck.getField());
        if (!cell) {
          return false;
        }
        if (cell.isCell) {
          return cell.isSameEl(elToCheck);
          
        } else for (var i=0; i<cell.length; i++) {
          if (cell[i].isSameEl(elToCheck)) {
            return true;
          }
        }
        return false;
      },
      
      addCell: function(newCell,row,col) {
        row = row || newCell.getRow();
        col = col || newCell.getField();
        
        var cell = this.getCell(row,col);
        if (!cell) {
          this.insert(newCell,row,col);
        } else if (cell.isCell) {
          var container = [cell,newCell];
          this.insert(container,row,col);
          
        } else {
          cell.push(newCell);
          //this.insert(cell,row,col); //useless
        }
      },
      
      forEachCell: function(cb) {
        var that = this;
        this.forEachElement(function(el,row,col) {
          that.forEachCellInElement(el,row,col,cb);
        });
      },
      
      forEachCellInRow: function(_row,cb) {
        var that = this;
        this.forEachElementInRow(_row,function(el,row,col) {
          that.forEachCellInElement(el,row,col,cb);
        });
      },
      
      forEachCellInPosition: function(_row,_col,cb) {
        var _cell = this.get(_row,_col);
        if (!_cell) {
          return;
        }
        this.forEachCellInElement(_cell,_row,_col,cb);
      },
      
      /*private*/ forEachCellInElement: function(cell,row,col,cb) {
        if (cell.isCell) {
          cb(cell,row,col);
        } else for(var i=0; i<cell.length; i++) {
          cb(cell[i],row,col,cell[i].getNum());
        }
      },
      
      getCell: function(_row,_col,num) {
        if (!num) {
          return this.get(_row,_col);
        } else {
          var cell = this.get(_row,_col);
          if (cell) {
            if (!cell.isCell) {
              for (var i=0; i<cell.length; i++) {
                if (cell[i].getNum() == num) {
                  return cell[i];
                }
              }
            } else if (cell.getNum() == num) {
              return cell;
            }
          }  
          
          return null;
          
        }
      },
     
      cellsGarbageCollection: function() {
        var _cells = this.getEntireMatrix();
        for (var _row in _cells) {
          if (!rowGarbageCollection(_cells[_row])) {
            delete _cells[_row];
          }
        }
      }
  };
  
  
  Inheritance(CellMatrix,Matrix,false,true);
  
  return CellMatrix;
})();
  
