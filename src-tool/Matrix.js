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
  /**
   * Creates a Matrix instance; if specified the matrix is initialized with the given object.
   * @constructor
   * 
   * @param {Object} inputMatrix the matrix to initialize this object with.
   * 
   * @exports Matrix
   * @class Very simple object-backed bi-dimensional Matrix implementation.
   */
  var Matrix = function(inputMatrix) {
    /**
     * @private
     */
    this.matrix = inputMatrix || {};
  };
  
  
  Matrix.prototype = {
    /**
     * Inserts an element in the matrix. If another element is already present in the
     * specified position it is overwritten.
     * 
     * @param insObject {Object} the element to be added.
     * @param row {String|Number} the row in the matrix where the element is placed.
     * @param column {String|Number} the column in the row where the element is placed.
     */ 
    insert: function(insObject,row,column) {
      if (!(row in this.matrix)) {
        this.matrix[row] = {};
      }
      this.matrix[row][column] = insObject;
    },
    
    /**
     * Gets the element at the specified position in the matrix. If the position is empty null is returned.
     * @param row {String|Number} the row in the matrix where the element is located.
     * @param column {String|Number} the column in the row where the element is located.
     * @returns {Object} the element at the specified location or null.
     */
    get: function(row,column) {
      if (row in this.matrix && column in this.matrix[row]) {
        return this.matrix[row][column];
      }
      return null;
    },
    /**
     * Removes the element at the specified position in the matrix.
     * @param row {String|Number} the row in the matrix where the element is located.
     * @param column {String|Number} the column in the row where the element is located.
     */
    del: function(row, column) {
      if (!row in this.matrix) {
        return;
      }
      if (column in this.matrix[row]) {
        delete this.matrix[row][column];
      }
        
      for (var i in this.matrix[row]) {
        //at least a cell in the row
        return;
      }
      //row is empty, get rid of it
      delete this.matrix[row];
    },
    /**
     * Inserts a full row in the matrix. If another row is already present in the
     * specified position it is overwritten.
     *  
     * @param insRow {Object} the row to be added.
     * @param row {String|Number} the row position.
     */
    insertRow: function(insRow, row) {
      this.matrix[row] = insRow;
    },
    /**
     * @deprecated
     */
    getRow: function(row) {
      if (row in this.matrix) {
        return this.matrix[row];
      }
      return null;
    },
    /**
     * Removes the row at the specified position in the matrix.
     * @param row {String|Number} the row position.
     */
    delRow: function(row) {
      if (row in this.matrix) {
        delete this.matrix[row];
      }
    },
    
    /**
     * @deprecated
     */
    getEntireMatrix: function() {
      return this.matrix;
    },
    
    /**
     * Verify if there are elements in the grid
     * @returns true if the matrix is empty, false otherwise
     */
    isEmpty: function() {
      for (var row in this.matrix) {
        return false;
      }
      return true;
    },
   
    /**
     * Executes a given callback passing each element of the Matrix. The callback
     * receives the element together with its coordinates.<br/>  
     * Callbacks are executed synchronously before the method returns: calling 
     * insert or delete methods during callback execution may result in 
     * a wrong iteration.
     * 
     * @param {ForEachCallback} callback The callback to be called.
     */
    forEachElement: function(callback) {
      for (var row in this.matrix) {
        this.forEachElementInRow(row,callback);
      }
      
      /*this.forEachRow(function(row) {
        that.forEachElementInRow(row,callback);
      });*/
    },
    
    /**
     * Executes a given callback passing the key of each row containing at least one element.
     * @param {RowsCallback} callback The callback to be called. 
     */
    forEachRow: function(callback) {
      for (var row in this.matrix) {
        callback(row);
      }
    },
    
    /**
     * Executes a given callback passing each element of the specified row. The callback
     * receives the element together with its coordinates.<br/>  
     * Callbacks are executed synchronously before the method returns: calling 
     * insert or delete methods during callback execution may result in 
     * a wrong iteration.
     * 
     * @param {ForEachCallback} callback The callback to be called.
     */
    forEachElementInRow: function(row,callback) {
      var rowElements = this.matrix[row];
      for (var col in rowElements) {
        callback(rowElements[col],row,col);
      }
    }
    
  };
  
  /**
   * Callback for {@link Matrix#forEachElement} and {@link Matrix#forEachElementInRow}
   * @callback ForEachCallback
   * @param {Object} value the element.
   * @param {String|Number} row the row where the element is located
   * @return {String|Number} col the column in the row where the element is located 
   */
  
  /**
   * Callback for {@link Matrix#forEachRow}
   * @callback RowsCallback
   * @param {String|Number} row a non-empty row in the Matrix.
   */
  
  Matrix.prototype["insert"] = Matrix.prototype.insert; 
  Matrix.prototype["get"] = Matrix.prototype.get;
  Matrix.prototype["del"] = Matrix.prototype.del;
  Matrix.prototype["insertRow"] = Matrix.prototype.insertRow;
  Matrix.prototype["getRow"] = Matrix.prototype.getRow;
  Matrix.prototype["delRow"] = Matrix.prototype.delRow;
  Matrix.prototype["getEntireMatrix"] = Matrix.prototype.getEntireMatrix;
  Matrix.prototype["forEachElement"] = Matrix.prototype.forEachElement; 
  Matrix.prototype["forEachElementInRow"] = Matrix.prototype.forEachElementInRow;
  Matrix.prototype["forEachRow"] = Matrix.prototype.forEachRow;
  Matrix.prototype["isEmpty"] = Matrix.prototype.isEmpty; 
  
  
  return Matrix;
})();
  
  