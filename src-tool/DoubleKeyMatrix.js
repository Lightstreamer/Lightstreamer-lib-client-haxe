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
import Inheritance from "./Inheritance";
import Matrix from "./Matrix";

export default /*@__PURE__*/(function() {
  //trick for Inheritance+closure not needed 'cause we're only calling public super-methods
  /*var names = {
    insert : "insert",
    del : "del",
    delRow: "delRow"
  };
  var reverse = {};
  for (var i in names) {
    reverse[names[i]] = i;
  }*/

  /**
   * Creates an empty DoubleKeyMatrix
   * @constructor
   *
   * @exports DoubleKeyMatrix
   * @class A very specific Matrix that keeps a map tracking on which row a determined column is: in order to 
   * do this it is mandatory that no two rows have an element in the same column: checks are not performed to
   * keep this constraint true.
   * 
   * @todo Implementation lacks most methods: I only implemented what I needed. Most likely no one will ever use
   * this class anyway.
   * 
   * @extends Matrix
   */
  var DoubleKeyMatrix = function() {
    this._callSuperConstructor(DoubleKeyMatrix);
   
    /**
     * @private
     */
    this.reverseIndex = {};
  };
  
  DoubleKeyMatrix.prototype = {
      /**
       * Inserts an element in the matrix. If another element is already present in the
       * specified position it is overwritten. The reverse-mapping is kept up to date but no
       * checks on possible duplicated column values are performed
       * @todo do the check?
       * 
       * @param insObject {Object} the element to be added.
       * @param row {String|Number} the row in the matrix where the element is placed.
       * @param column {String|Number} the column in the row where the element is placed.
       */
      insert: function(insObject,row,column) {
        if (typeof this.reverseIndex[column] != "undefined") {
          //already in map, we must not repeat the entry
          return;
        }
        
        this.reverseIndex[column] = row;
        this._callSuperMethod(DoubleKeyMatrix,"insert",[insObject,row,column]);
        
      },
      
      /*extractRow: function(row) {
        var rowObj = this._callSuperMethod(DoubleKeyMatrix,'extractRow',[row]);
        for (var column in rowObj) {
          delete(this.reverseIndex[column]);
        }
        return rowObj;
      },*/
      
      /**
       * Removes the element at the specified position in the matrix and updates the column index.
       * @param row {String|Number} the row in the matrix where the element is located.
       * @param column {String|Number} the column in the row where the element is located.
       */
      del: function(row, column) {
        this._callSuperMethod(DoubleKeyMatrix,"del",[row,column]);
        delete(this.reverseIndex[column]);
      },
      
      /**
       * Removes the element at the specified position in the matrix and updates the column index:
       * as column must be unique in the entire matrix it is enough to specify it to identify an unique
       * element within the matrix.
       * @param column {String|Number} the column where the element is located.
       */
      delReverse: function(column) {
        var row = this.reverseIndex[column];
        if (typeof row == "undefined") {
          return;
        }
        this.del(row,column);
      },
      
      /**
       * Removes the row at the specified position in the matrix and updates the column index.
       * @param row {String|Number} the row position.
       */
      delRow: function(row) {
        var rowObj = this.getRow(row);
        for (var column in rowObj) {
          delete(this.reverseIndex[column]);
        }
        this._callSuperMethod(DoubleKeyMatrix,"delRow",[row]);
      }
      
      
  };
  
  DoubleKeyMatrix.prototype["insert"] = DoubleKeyMatrix.prototype.insert;
  DoubleKeyMatrix.prototype["del"] = DoubleKeyMatrix.prototype.del;
  DoubleKeyMatrix.prototype["delReverse"] = DoubleKeyMatrix.prototype.delReverse;
  DoubleKeyMatrix.prototype["delRow"] = DoubleKeyMatrix.prototype.delRow;
 
  
  Inheritance(DoubleKeyMatrix,Matrix);
  
  return DoubleKeyMatrix;
})();
  
  
