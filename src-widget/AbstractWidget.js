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
import Matrix from "../src-tool/Matrix";
import LoggerManager from "../src-log/LoggerManager";
import Setter from "../src-tool/Setter";
import EventDispatcher from "../src-tool/EventDispatcher";
import IllegalStateException from "../src-tool/IllegalStateException";
import LightstreamerConstants from "./LightstreamerConstants";
import DoubleKeyMatrix from "../src-tool/DoubleKeyMatrix";

export default /*@__PURE__*/(function() {
  var gridsLogger = LoggerManager.getLoggerProxy("lightstreamer.grids");
  
  var ITEM_IS_KEY = "ITEM_IS_KEY";
  var UPDATE_IS_KEY = "UPDATE_IS_KEY";
  var KEY_IS_KEY = "KEY_IS_KEY";
  
  var PARSE_FIRST = "Please parse html before calling this method";
  
  var REMOVE = 1;
  var UPDATE = 2;
  
  var MAX_FIFO_HOLES = 100;
  
  /**
   * This is an abstract class; no instances of this class should be created.
   * @constructor
   * 
   * @exports AbstractWidget
   * @class The base class for the hierarchy of the provided widgets. It is an
   * abstract class representing a view on a set of tabular data, which is supposed
   * to be some sort of HTML visualization widget. Each row in the tabular model is associated with a key.
   * <BR>The class offers some management methods to modify/poll the model behind 
   * the view but also implements the {@link SubscriptionListener} interface to be
   * automatically fed by listening on a {@link Subscription}. 
   * <BR>When listening for Subscription events the widget will choose what to use
   * as key for its model based on the Subscription mode of the first Subscription
   * it was added to as a listener:
   * <ul>
   * <li>If the Subscription mode is MERGE or RAW, the widget will use the item as key:
   * each subscribed item will generate a row in the model. The key name will be
   * the item name when available, otherwise the 1-based item position within the
   * Subscription.</li>
   * <li>If the Subscription mode is COMMAND, the widget will use the value of the 
   * "key" field as key: each row in the COMMAND subscription will generate a row 
   * in the model. More precisely, the key value will be expressed as "&lt;item&gt; &lt;key&gt;"
   * where &lt;item&gt; is the item name when available, otherwise the 1-based item position
   * within the Subscription.
   * <BR>Note that this behavior is naturally extended to two-level subscriptions.</li>
   * <li>If the Subscription mode is DISTINCT, the widget will use a progressive 
   * number as key: each update will generate a row in the model.</li>
   * </ul>
   * For each update received, all the included fields will be integrated into
   * the row related to the update key. The field name will be the one specified on
   * the related Subscription, when available; otherwise, it will be the 1-based field
   * position within the related Subscription.
   * <BR>Note that if the Subscription contains the same item name or field name multiple
   * times, their updates will not be distinguished in the model and the last value
   * processed by the library for that name will be assigned to the model.
   * You should ensure that item name or field name collisions cannot occur if the
   * colliding names are used to represent different entities; for instance, this holds for
   * collisions between first-level and second-level fields in a two-level Subscription.
   * Collisions are also possible if the widget is added as a listener to
   * other Subscription instances. In this case, also note that the new updates will be
   * processed and integrated in the model in the way already determined for the first
   * Subscription associated; so, you should ensure that the various Subscriptions yield
   * compatible updates.
   * <BR>For each {@link SubscriptionListener#onClearSnapshot} event received from any
   * of the Subscription the widget is listening to, all the rows internally associated 
   * to the cleared item are removed. In case of collisions between different items feeding 
   * the same row the row will be considered pertaining to the first item that fed it.
   * <BR>
   * <BR>Note that methods from the SubscriptionListener should not be called by 
   * custom code.
   * <BR>Note that before any change to the internal model can be made, and
   * thus before an instance of this class can be used as listener for a 
   * Subscription, the {@link AbstractWidget#parseHtml} method has to be called to prepare the view.
   * <BR>The class is not meant as a base class for the creation of custom widgets.
   * The class constructor and its prototype should never be used directly.
   * 
   * @extends SubscriptionListener
   * 
   * @see Chart
   * @see AbstractGrid
   */
  var AbstractWidget = function() {
    
    this._callSuperConstructor(AbstractWidget);
    
    this.kind = ITEM_IS_KEY;
    this.keyField = null;
    this.commandField = null;
    
    this.updateCount = 0;
    this.fieldPosBased = null;
    
    this.values = new Matrix();
    
    this.parsed = false;
    
    this.id = arguments[0];
    
    this.useSynchEvents(true);
    
    this.cleanOnFirstSubscribe = false;
    this.cleanOnLastUnsubscribe = false;
    this.activeSubscriptions = 0;
    this.masterSubscription = null;
    this.forcedInterpretation = false;
    
    this.updateInProgress = null;
    this.suspendedUpdates = [];
    
    this.fifoKeys = [];
    this.fifoMap = {};
    this.fifoHoles = 0;
    this.fifoHead = 0;
    
    this.itemKeyMap = new DoubleKeyMatrix();
    
  };
  
  /**
   * @protected
   * @ignore
   */
  AbstractWidget.ITEM_IS_KEY = ITEM_IS_KEY;
  /**
   * @protected
   * @ignore
   */
  AbstractWidget.UPDATE_IS_KEY = UPDATE_IS_KEY;
  
  AbstractWidget.prototype = {
      /**
       * @ignore
       */
      getId: function() {
        return this.id;
      },
      /**
       * @protected
       * @ignore
       */
      checkParsed: function() {
        if (!this.parsed) {
          throw new IllegalStateException(PARSE_FIRST);
        }
      },
      /**
       * From SubscriptionListener
       * @inheritdoc
       */
      onItemUpdate: function(updateInfo) {
        var itemName = updateInfo.getItemName();
        var itemPos = updateInfo.getItemPos();
        
        this.updateCount++;

        var updateKey;
        var itemId = itemName == null ? itemPos : itemName;
        if (this.itemIsKey()) {
          updateKey = itemId;
        } else if (this.updateIsKey()) {
          updateKey = this.updateCount;
        } else { //this.keyIsKey() 
          updateKey = itemId+" "+updateInfo.getValue(this.keyField);
        }
        
        var updated = {}; //server values
        if (this.updateIsKey()) {
          updateInfo.forEachField(this.getForeachHandler(updated));
        } else {
          updateInfo.forEachChangedField(this.getForeachHandler(updated));
        }
        
        if (this.keyIsKey() && updated[this.commandField] == "DELETE") {
          this.removeRow(updateKey);
          //remove from itemKeyMap in any case (inside removeRow)
        } else {
          this.updateRow(updateKey,updated); //add and update collapsed
          this.itemKeyMap.insert(true,itemId,updateKey); //add to the itemKeyMap only in the onItemUpdate case 
          //in case a key is associated to two different items the first one to reach the map rules
        }
      },
      
      /**
       * From SubscriptionListener
       * @inheritdoc
       */
      onClearSnapshot: function(itemName, itemPos) {
        //get the associated row and remove them
        var itemId = itemName == null ? itemPos : itemName;

        var associatedRows = this.itemKeyMap.getRow(itemId);
        this.itemKeyMap.delRow(itemId);
        for (var key in associatedRows) {
          this.removeRow(key);
        } 
      },
      
      /*
      UNUSED SubscriptionListener methods
      
      onItemLostUpdates: function(itemName, itemPos, lostUpdates) {
        
      },
      
      onCommandSecondLevelItemLostUpdates: function(howMany, key) {
        
      },
      
      onEndOfSnapshot: function(itemName, itemPos) {
       
      },
      
      onSubscriptionError: function(code, message) {
        return;
      },
      
      onCommandSecondLevelSubscriptionError: function(code, message, key) {
        
      },
      
      */
      
      /**
       * From SubscriptionListener
       * @inheritdoc
       */
      onSubscription: function() {
        if (this.activeSubscriptions == 0 && this.cleanOnFirstSubscribe) {
          this.clean();
        }
        
        if (this.keyIsKey() && !this.keyField) {
          //masterSubscription may be not yet subscribed and I don't have info about this subscription... 
          //should I keep all the subscriptions in an array and then loop on them to find one that had already been subscribed?
          this.keyField = this.masterSubscription.getKeyPosition();
          this.commandField = this.masterSubscription.getCommandPosition();
        }
        
        this.activeSubscriptions++;        
      },
      
      /**
       * From SubscriptionListener
       * @inheritdoc
       */
      onUnsubscription: function() {
        this.activeSubscriptions--;
        
        if (this.activeSubscriptions == 0 && this.cleanOnLastUnsubscribe) {
          this.clean();
        }
      },
      
      /**
       * From SubscriptionListener
       * @inheritdoc
       */
      onListenStart: function(sub) {
        if (!this.masterSubscription) {
          this.masterSubscription = sub;
          
          if (!this.forcedInterpretation) {
            this.chooseInterpretation();
          }
      
        }
        
        if (sub.isSubscribed()) {
          this.onSubscription();
        }
      },
      
      /**
       * From SubscriptionListener
       * @inheritdoc
       */
      onListenEnd: function(sub) {
        if (sub.isSubscribed()) {
          this.onUnsubscription();
        }
      },
      
      /**
       * @protected
       * @ignore
       */
      chooseInterpretation: function() {
        if (!this.masterSubscription) {
          this.kind = ITEM_IS_KEY;
          return;
        }
        
        var sub = this.masterSubscription;
        
        if (sub.getMode() == LightstreamerConstants.MERGE || sub.getMode() == LightstreamerConstants.RAW) {
          this.kind = ITEM_IS_KEY;
          
        } else if (sub.getMode() == LightstreamerConstants.DISTINCT) {
          this.kind = UPDATE_IS_KEY;
          
        } else { //LightstreamerConstants.COMMAND
          this.kind = KEY_IS_KEY;
          
          try {
            sub.getFields();
            //field names
            this.keyField = "key";
            this.commandField  = "command";
            
          } catch (e) {
            //field position
          }
        }
      },
      
      /**
       * @private
       */
      getForeachHandler: function(updated) {
        var that = this;
        
        return function(name,pos,_new) {
          if (that.fieldPosBased === null) {
            that.fieldPosBased = name == null;
          }
          
          var index = that.fieldPosBased ? pos : name;
          updated[index] = _new;
          
        };
        
      },
      
      /**
       * @protected
       * @ignore
       */
      itemIsKey: function() {
        return this.kind == ITEM_IS_KEY;
      },
      
      /**
       * @protected
       * @ignore
       */
      updateIsKey: function() {
        return this.kind == UPDATE_IS_KEY;
      },
      
      /**
       * @protected
       * @ignore
       */
      keyIsKey: function() {
        return this.kind == KEY_IS_KEY;
      },

      /**
       * @protected
       * @ignore
       */
      getOldestKey: function() {
        if (this.fifoHead >= this.fifoKeys.length) {
          return null;
        }
        return this.fifoKeys[this.fifoHead];
      },
      
      /**
       * @protected
       * @ignore
       */
      removeFromFifo: function(key) {
        var pos = this.fifoMap[key];
        delete(this.fifoMap[key]);
        
        this.fifoKeys[pos] = null;
        this.fifoHoles++;
        
        if (pos == this.fifoHead) {
          while (this.fifoKeys[this.fifoHead] === null && this.fifoHead < this.fifoKeys.length) {
            this.fifoHead++;
          }
          
          if (this.fifoHead >= this.fifoKeys.length) {
            this.fifoKeys = [];
            this.fifoMap = {};
            this.fifoHoles = 0;
            this.fifoHead = 0;
            return;
          }
          
        } 
        
        
        if (this.fifoHoles >= MAX_FIFO_HOLES) {
          this.fifoMap = {};
          var oldArray = this.fifoKeys;
          this.fifoKeys = [];
          this.fifoHead = 0;
          this.fifoHoles = 0;
          
          for (var i=0; i<oldArray.length; i++) {
            if (oldArray[i] !== null) {
              this.newKey(oldArray[i]);
            }
          }
        }
      },
      
      /**
       * @private
       */
      newKey: function(key) {
        this.fifoMap[key] = this.fifoKeys.length;
        this.fifoKeys.push(key);
      },
      
      /**
       * Removes a row from the internal model and reflects the change on the view.
       * If no row associated with the given key is found nothing is done.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> once the {@link AbstractWidget#parseHtml} method has been called,
       * this method can be used at any time.</p>
       * 
       * @throws {IllegalStateException} if parseHtml has not been executed yet.
       * 
       * @param {String} key The key associated with the row to be removed.
       */
      removeRow: function(key) {
        this.checkParsed();
        
        if (this.updateInProgress) {
          this.deleteLater(key);
          return;
        }
        
        if (!this.values.getRow(key)) {
          gridsLogger.logWarn("Can't remove row that does not exist",key,this);
          return;
        }
        
        if (gridsLogger.isDebugLogEnabled()) {
          gridsLogger.logDebug("Removing row",key,this);
        }
        
        this.updateInProgress = {}; //cannot be merged with anything but still have to pass the if (this.updateInProgress) check
        
        var exeExc = null;
        try {
          this.removeRowExecution(key);
          
          this.values.delRow(key);
          this.itemKeyMap.delReverse(key);
        
          if (this.updateIsKey()) {
            this.removeFromFifo(key);
          }
        } catch(e) {
          exeExc = e;
        }
        
        this.updateInProgress = null;
        
        this.dequeuePostponedUpdates();
        
        if (exeExc !== null) {
          throw(exeExc);
        }
        
      },

      
      /**
       * @protected
       * @ignore
       */
      updateLater: function(key,newValues) {
        if (gridsLogger.isDebugLogEnabled()) {
          gridsLogger.logDebug("Postpone new update until the current update/remove is completed",this);
        }
        //postpone the update
        this.suspendedUpdates.push({type:UPDATE,key:key,obj:newValues});
      },
      
      /**
       * @protected
       * @ignore
       */
      deleteLater: function(key) {
        if (gridsLogger.isDebugLogEnabled()) {
          gridsLogger.logDebug("Postpone new remove until the current update/remove is completed",this);
        }
        
        //postpone the update
        this.suspendedUpdates.push({type:REMOVE,key:key});
      },

      /**
       * @private
       */
      dequeuePostponedUpdates: function() {
        while (this.suspendedUpdates.length > 0) {
          var otherUpdate =  this.suspendedUpdates.shift();
          
          if (otherUpdate.type == REMOVE) {
            this.removeRow(otherUpdate.key);
          } else {
            this.updateRow(otherUpdate.key,otherUpdate.obj);
          }
        }
      },
      
      /**
       * Updates a row in the internal model and reflects the change on the view.
       * If no row associated with the given key is found then a new row is
       * created.
       * <BR>Example usage:
       * <BR><code>myWidget.updateRow("key1", {field1:"val1",field2:"val2"});</code>
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> once the {@link AbstractWidget#parseHtml} method has been called,
       * this method can be used at any time. If called while an updateRow on the same
       * internal model is still executing (e.g. if called while handling an onVisualUpdate
       * callback), then the new update:
       * <ul>
       * <li>if pertaining to a different key and/or if called on a {@link Chart} instance,
       * will be postponed until the first updateRow execution terminates;</li>
       * <li>if pertaining to the same key and if called on a {@link StaticGrid} / {@link DynaGrid}
       * instance, will be merged with the current one.</li>
       * </ul>
       * </p>
       * 
       * @throws {IllegalStateException} if parseHtml has not been executed yet.
       * 
       * @param {String} key The key associated with the row to be updated/added.
       * @param {Object} newValues A JavaScript object containing name/value pairs
       * to fill the row in the mode. 
       * <BR>Note that the internal model does not have a fixed number of fields; 
       * each update can add new fields to the model by simply specifying them. 
       * Also, an update having fewer fields than the current model will have its 
       * missing fields considered as unchanged.
       */
      updateRow: function(key,newValues) { 
        this.checkParsed();
        
        if (this.updateInProgress) {
          //method called from the visualUpdate callback
          if (key == this.updateInProgress) {
            this.mergeUpdate(key,newValues);
            
          } else {
            this.updateLater(key,newValues);
          }
          
          return;
        } 


        this.updateInProgress = key;
        
        var exeExc = null;
        try {
        
          this.updateRowExecution(key,newValues);
          
          if (!this.values.getRow(key)) {
            if (gridsLogger.isDebugLogEnabled()) {
              gridsLogger.logDebug("Inserting new row",key,this);
            }
            
            if (this.updateIsKey()) {
              this.newKey(key);
            }
            this.values.insertRow(newValues,key);
            
          } else {
            if (gridsLogger.isDebugLogEnabled()) {
              gridsLogger.logDebug("Updating row",key,this);
            }
            for (var i in newValues) {
              this.values.insert(newValues[i],key,i);
            }
          }
        } catch(e) {
          exeExc = e;
        }
        
        this.updateInProgress = null;
        
        this.dequeuePostponedUpdates();
        
        if (exeExc !== null) {
          throw exeExc;
        }
        
      },
      
      /**
       * Removes all the rows from the model and reflects the change on the view.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> once the {@link AbstractWidget#parseHtml} method has been called,
       * this method can be used at any time.</p>
       * 
       * @throws {IllegalStateException} if parseHtml has not been executed yet.
       */
      clean: function() {
        
        gridsLogger.logInfo("Cleaning the model",this);
        
        var keys = [];
        this.values.forEachRow(function(row) {
          keys.push(row);
        });
        for (var i=0; i<keys.length; i++) {
          this.removeRow(keys[i]);
        }
      },
      
      /**
       * Returns the value from the model for the specified key/field pair.
       * If the row for the specified key does not exist or if the specified field
       * is not available in the row then null is returned.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       * 
       * @param {String} key The key associated with the row to be read.
       * @param {String} field The field to be read from the row.
       * 
       * @return {String} The current value for the specified field of the specified row,
       * possibly null. If the value for the specified field has never been
       * assigned in the model, the method also returns null.
       */
      getValue: function(key,field) {
        return this.values.get(key,field);
      },
      
      /**
       * Utility method that can be used to control part of the behavior of
       * the widget in case it is used as a listener for one or more 
       * {@link Subscription} instances.
       * <BR>Specifying the two flags it is possible to decide to clean the model and
       * view based on the status (subscribed or not) of the Subscriptions this 
       * instance is listening to.
       * 
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       * 
       * @param {boolean} onFirstSubscribe If true a {@link AbstractWidget#clean} call will be
       * automatically performed if in the list of Subscriptions this instance is 
       * listening to there is no Subscription in the subscribed status and an 
       * onSubscription is fired by one of such Subscriptions.
       * <BR>As a special case, if in the list of Subscriptions this instance is 
       * listening to there is no Subscription in the subscribed status and this
       * instance starts listening to a new Subscription that is already in the 
       * subscribed status, then it will be considered as if an onSubscription
       * event was fired and thus a clean() call will be performed. 
       * 
       * @param {boolean} onLastUnsubscribe If true a {@link AbstractWidget#clean} call will be
       * automatically performed if in the list of Subscriptions this instance is 
       * listening to there is only one Subscription in the subscribed status and the 
       * onUnsubscription for such Subscription is fired.
       * <BR>As a special case, if in the list of Subscriptions this instance is 
       * listening to there is only one Subscription in the subscribed status and 
       * this instance stops listening to such Subscription then it will be 
       * considered as if the onUnsubscription event for that Subscription was fired 
       * and thus a clean() call will be performed. 
       *  
       * @see Subscription#isSubscribed 
       */
      setAutoCleanBehavior: function(onFirstSubscribe, onLastUnsubscribe) {
        this.cleanOnFirstSubscribe = this.checkBool(onFirstSubscribe);
        this.cleanOnLastUnsubscribe = this.checkBool(onLastUnsubscribe);
      },
      
      /**
       * Abstract method. See subclasses descriptions for details.
       */
      parseHtml: function() {},
      /** 
       * abstract method
       * @protected
       * @ignore
       */ 
      updateRowExecution: function(key,serverValues) {},
      /** 
       * abstract method
       * @protected
       * @ignore
       */ 
      removeRowExecution: function(key) {},
      /** 
       * abstract method
       * @protected
       * @ignore
       */ 
      mergeUpdate: function(key,newValues) {}
  };
  
  //closure compiler exports
  AbstractWidget.prototype["onItemUpdate"] = AbstractWidget.prototype.onItemUpdate;
  AbstractWidget.prototype["onClearSnapshot"] = AbstractWidget.prototype.onClearSnapshot;
  AbstractWidget.prototype["onSubscription"] = AbstractWidget.prototype.onSubscription;
  AbstractWidget.prototype["onUnsubscription"] = AbstractWidget.prototype.onUnsubscription;
  AbstractWidget.prototype["onListenStart"] = AbstractWidget.prototype.onListenStart;
  AbstractWidget.prototype["onListenEnd"] = AbstractWidget.prototype.onListenEnd;
  AbstractWidget.prototype["removeRow"] = AbstractWidget.prototype.removeRow;
  AbstractWidget.prototype["updateRow"] = AbstractWidget.prototype.updateRow;
  AbstractWidget.prototype["clean"] = AbstractWidget.prototype.clean;
  AbstractWidget.prototype["getValue"] = AbstractWidget.prototype.getValue;
  AbstractWidget.prototype["setAutoCleanBehavior"] = AbstractWidget.prototype.setAutoCleanBehavior;
  AbstractWidget.prototype["parseHtml"] = AbstractWidget.prototype.parseHtml;
  AbstractWidget.prototype["updateRowExecution"] = AbstractWidget.prototype.updateRowExecution;
  AbstractWidget.prototype["removeRowExecution"] = AbstractWidget.prototype.removeRowExecution;
  AbstractWidget.prototype["mergeUpdate"] = AbstractWidget.prototype.mergeUpdate;
  
  Inheritance(AbstractWidget,EventDispatcher,false,true);
  Inheritance(AbstractWidget,Setter,true,true);
  return AbstractWidget;
})();

