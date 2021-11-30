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
  var VisibleParent = function(node, firstNotLSBrother, offset) {
    this._callSuperConstructor(VisibleParent);
   
    this.domNode = node;
    this.toInsBefore = firstNotLSBrother;
    this.offsetIndex = offset;
    this.oneMap = true;
    
    this.topChild = this.toInsBefore;
    
    this.init();
   
  };
  
  /**
   * @private
   */
  VisibleParent.prototype = {
   
    /*public*/ removeChild: function(node) {
      if (this.length <= 0) {
        return;
      }
      //one less child
      this.length--;
      //remove from hashmap
      delete(this.hashMap[node.getId()]);
      //remove from DOM
      var el = node.element();
      if (el == this.topChild) {
        this.topChild = el.nextSibling; 
      }
      this.domNode.removeChild(el);
      node.setParentNode(null);
    },
    
    /*public*/ insertBefore: function(newNode, node) {
      if (node == newNode) {
        //insertBefore itself. Nothing to do
        return;
      }
      if (!newNode) {
        //handle the insertion
        return;
      }
      if (!node) {
        //insertBefore nothing, consider it as an appendChild
        this.appendChild(newNode,true);
        return;
      }
      if (this.hashMap[node.getId()] == null) {
        //insertBefore a non-existent node,  consider it as an appendChild
        this.appendChild(newNode,true);
        return;
      }
      //internally handle the insertion
      this.insertOperation(newNode);
      //put it in the DOM
      this.domNode.insertBefore(newNode.element(), node.element());
    },
    
    /*public*/ appendChild: function(node, appendOnBottom) {
      if (!node) {
        //nothing to insert, nothing to do
        return;
      }
      //handle the insertion
      this.insertOperation(node);
      
      //extract the element
      var el = node.element();
      if (appendOnBottom) {
        
        if (!this.topChild) {
          this.topChild = el;
        }
        
        //place it on the DOM
        if (!this.toInsBefore) {
          //as the latest son
          this.domNode.appendChild(el);
        } else {
          //as the latest son excluding elements not handled by this class
          this.domNode.insertBefore(el,this.toInsBefore);
        }
      } else {
        //put it on top
        this.domNode.insertBefore(el,this.topChild);
        this.topChild = el;
      }
      
    },
    
    /*private*/ insertOperation: function(node) {
      if (node.isSonOf(this)) {
        //the node is already handled by this instance
        return;
      }
      //increase the counter
      this.length++;
      //save it on the hashmap
      this.hashMap[node.getId()] = node;
      //if son of someone else get rid of the connection between them
      node.isolation();
      //adopt it
      node.setParentNode(this);
    },
    
    /*public*/ getChild: function(index) {
      if (this.length <= index) {
        return null;
      }
      //get a son by index
      index += this.offsetIndex;
      //get its id to find it in the hashmap
      var mapping = this.domNode.childNodes[index].getAttribute("id");
      //get it
      return this.getElementById(mapping);
    },
    
    /*public*/ getElementById: function(id) {
      //get the element from the hashmap
      return this.hashMap[id];
    },
    
    /*public*/ clean: function() {
      if (this.domNode) {
        delete(this.domNode);
      }
      if(this.toInsBefore) {
        delete(this.toInsBefore);
      }
      for (var i in this.hashMap) {
        this.hashMap[i].clean();
      }
    }
    
  };
  
  Inheritance(VisibleParent,AbstractParent);
  return VisibleParent;
})();

