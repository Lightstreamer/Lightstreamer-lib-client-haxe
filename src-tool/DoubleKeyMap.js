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
import IllegalArgumentException from "./IllegalArgumentException";

export default /*@__PURE__*/(function() {
  function checkValidValue(v) {
    return v !== null && typeof v != "undefined";
  }
  
  function doRemove(master,slave,key) {
    var val = master[key];
    if (checkValidValue(val)) {
      delete(master[key]);
      delete(slave[val]);
    }
  }
  
  /*
   * how does this work
   * 
   * A 1 | 1 A
   * B 2 | 2 B
   * C 3 | 3 C
   * 
   * 
   * CASE 1, one key overwriting
   *  
   *  set(a,7)
   *  
   *  --> just write
   *  A 7 | 2 B
   *  B 2 | 3 C
   *  C 3 | 7 A
   *  
   * CASE 2, double key overwriting
   * 
   *  set(b,3)
   *  
   *  --> swap B and C values (can also be seen as swap 2 and 3 values)
   *  A 7 | 2 C
   *  B 3 | 3 B
   *  C 2 | 7 A
   *    
   */
  function doSet(master,slave,a,b) {
    if (!checkValidValue(a) || !checkValidValue(b)) {
      throw new IllegalArgumentException("values can't be null nor missing");
    }
    var origB = master[a];
    var origA = slave[b];
    
    if (checkValidValue(origB)) {
      if (origB === b) {
        //value already set
        return;
      }
      
      if(checkValidValue(origA)) {
        //value already indexed in both master and slave, swap values
        //doSwap
        master[origA] = origB;
        master[a] = b;
        slave[b] = a;
        slave[origB] = origA;
        
      } else {
        //value already indexed in the master but not in the slave, replace in master and remove + add in slave
        doReplace(master,slave,a,b);
        
      }
    } else if(checkValidValue(origA)) {
      //value already indexed in the slave but not in the master, replace in slave and remove + add in master
      doReplace(slave,master,b,a);
      
    } else {
      //doAdd
      master[a] = b;
      slave[b] = a;
    }
  }
  function doReplace(master,slave,key,val) {
    delete(slave[master[key]]);
    master[key] = val;
    slave[val] = key;
  }
  
  function doForEach(coll,cb) {
    for (var key in coll) {
      cb(key,coll[key]);
    }
  }
  
  
  /**
   * Crates and empty DoubleKeyMap
   * @constructor
   * 
   * @exports DoubleKeyMap
   * @class Simple map implementation that also keeps a reverse map whose keys are 
   * the values and values are the keys of the first map. 
   * For this reason the map can't contain duplicated values: collisions are 
   * handled by swapping values. 
   */
  var DoubleKeyMap = function() {
    /**
     * @private
     */
    this.map = {};
    /**
     * @private
     */
    this.reverseMap = {};
  };
  
  DoubleKeyMap.prototype = {
      /**
       * Inserts new values in the maps. If one of the keys is already present in the respective map,
       * its value is overwritten and the related entry on the other map is deleted. If both the keys 
       * are already present in their respective map a swapping to maintain uniqueness in both maps is performed.
       * 
       * @throws {IllegalArgumentException} if one (or both) of the specified values is null or missing.
       * 
       * @param a {Object} the key to be used to insert the other value in the first map. It can't be null nor missing.
       * @param b {Object} the key to be used to insert the other value in the second map. It can't be null nor missing.
       */
      set: function(a,b) {
        doSet(this.map,this.reverseMap,a,b);
      },
      
      /**
       * Uses the given key to remove an element from the first map and the related element in the second map.
       * @param a {Object} the key to be used to remove the element from the first map.
       */
      remove: function(a) {
        doRemove(this.map,this.reverseMap,a);
      },
      /**
       * Uses the given key to remove an element from the second map and the related element in the first map.
       * @param b {Object} the key to be used to remove the element from the second map.
       */
      removeReverse: function(b) {
        doRemove(this.reverseMap,this.map,b);
      },
      
      /**
       * Gets an element from the first map using the given key.
       * @param a {Object} the key to be used to get the element from the first map.
       * @returns {Object} the found value if any or an undefined value 
       */
      get: function(a) {
        return this.map[a];
      },
      /**
       * Gets an element from the second map using the given key.
       * @param b {Object} the key to be used to get the element from the second map.
       * @returns {Object} the found value if any or an undefined value
       */
      getReverse: function(b) {
        return this.reverseMap[b];
      },
      
      /**
       * Checks if there is a value in the first map at the specified key. 
       * @param a {Object} the key to be used to get the element from the first map.
       * @returns {Boolean} true if the element exists, false otherwise.
       */
      exist: function(a) {
        return typeof this.get(a) != "undefined";
      },
      /**
       * Checks if there is a value in the second map at the specified key. 
       * @param b {Object} the key to be used to get the element from the second map.
       * @returns {Boolean} true if the element exists, false otherwise.
       */
      existReverse: function(b) {
        return typeof this.getReverse(b) != "undefined";
      },
      
      /**
       * Executes a given callback passing each element of the first map as the only
       * call parameter.<br/>  
       * Callbacks are executed synchronously before the method returns: calling 
       * {@link DoubleKeyMap#set}, {@link DoubleKeyMap#remove} or {@link DoubleKeyMap#removeReverse}
       * during callback execution may result in a wrong iteration.
       * 
       * @param {Function} callback The callback to be called.
       */
      forEach: function(callback) {
        doForEach(this.map,callback);
      },
      /**
       * Executes a given callback passing each element of the second map as the only
       * call parameter.<br/>  
       * Callbacks are executed synchronously before the method returns: calling 
       * {@link DoubleKeyMap#set}, {@link DoubleKeyMap#remove} or {@link DoubleKeyMap#removeReverse}
       * during callback execution may result in
       * a wrong iteration.
       * 
       * @param {Function} callback The callback to be called.
       */
      forEachReverse: function(callback) {
        doForEach(this.reverseMap,callback);
      }
      
  };
  
  DoubleKeyMap.prototype["set"] = DoubleKeyMap.prototype.set;
  DoubleKeyMap.prototype["remove"] = DoubleKeyMap.prototype.remove;
  DoubleKeyMap.prototype["removeReverse"] = DoubleKeyMap.prototype.removeReverse;
  DoubleKeyMap.prototype["get"] = DoubleKeyMap.prototype.get;
  DoubleKeyMap.prototype["getReverse"] = DoubleKeyMap.prototype.getReverse;
  DoubleKeyMap.prototype["exist"] = DoubleKeyMap.prototype.exist;
  DoubleKeyMap.prototype["existReverse"] = DoubleKeyMap.prototype.existReverse;
  DoubleKeyMap.prototype["forEach"] = DoubleKeyMap.prototype.forEach;
  DoubleKeyMap.prototype["forEachReverse"] = DoubleKeyMap.prototype.forEachReverse;
  
  
  return DoubleKeyMap;
})();
  
  
