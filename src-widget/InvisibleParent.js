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
import AbstractParent from "./AbstractParent";
import Inheritance from "../src-tool/Inheritance";

export default /*@__PURE__*/(function() {
  /**
   * @private
   */
  var InvisibleParent = function() {
    this._callSuperConstructor(InvisibleParent);
    
    this.oneMap = false;
    
    this.init();
  };
  
  /**
   * @private
   */
  InvisibleParent.prototype = {
    
    /*public*/ removeChild: function(node) {
      if (this.length <= 0) {
        return;
      }
      this.length--;
      //move brothers below the removing-child
      var index = this.hashMap[node.getId()];
      var pi;
      for (pi = index; pi < this.length; pi++) {
        this.map[pi] = this.map[pi+1];
        this.hashMap[this.map[pi].getId()] = pi;
      }
      //remove references
      this.hashMap[node.getId()] = null;
      this.map[this.length] = null;
      
      node.setParentNode(null);
    },
    
    /*public*/ insertBefore: function(newNode, node) {
      if (node == newNode) {
        return;
      }
      if (!newNode) {
        return;
      }
      if (!node) {
        this.appendChild(newNode,true);
        return;
      }
      if (this.hashMap[node.getId()] == null) {
        this.appendChild(newNode,true);
        return;
      }
      //get rid of the previous parent 
      newNode.isolation();
     
      var newIndex = this.hashMap[node.getId()];
      //scroll-down following brothers
      for (var pi = this.length; pi >= newIndex + 1; pi--) {
        this.map[pi] = this.map[pi-1];
        this.hashMap[this.map[pi].getId()] = pi;
      }
      this.insertOperation(newNode, newIndex);
    },
    
    /*public*/ appendChild: function(node,appendOnBottom) {
      if (!node) {
        return;
      }
      //get rid of the previous parent 
      node.isolation();
      
      if (appendOnBottom || this.length == 0) {
        this.insertOperation(node, this.length);
      } else {
        this.insertBefore(node, this.map[0]);
      }
      
    },
    
    /*private*/ insertOperation: function(node, index) {
      this.length++;
      this.hashMap[node.getId()] = index;
      this.map[index] = node;
      node.setParentNode(this);
      node.invisible();
    },
    
    /*public*/ getChild: function(index) {
      return this.map[index];
    },
    
    /*public*/ getElementById: function(id) {
      return this.map[this.hashMap[id]];
    },
    
    /*public*/ clean: function() {
      for (var i=0; i<this.length; i++) {
        this.map[i].clean();
      }
    }
    
  };
  
  Inheritance(InvisibleParent,AbstractParent);
  return InvisibleParent;
})();
  
