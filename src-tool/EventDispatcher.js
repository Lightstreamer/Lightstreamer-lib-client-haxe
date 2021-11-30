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
import Executor from "./Executor";
import List from "./List";
import Inheritance from "./Inheritance";

export default /*@__PURE__*/(function() {
  //var actionsLogger = LoggerManager.getLoggerProxy(LoggerManager.ACTIONS);   
  
  /**
   * This constructor simply calls the {@link EventDispatcher#initDispatcher initDispatcher} method. This class is supposed 
   * to be extended using {@link module:Inheritance} extension.
   * It can be either light extended or fully extended. When light extension is performed
   * the {@link EventDispatcher#initDispatcher initDispatcher} method should be called in the extended class constructor.
   * @constructor
   * 
   * @exports EventDispatcher
   * @class Class to be extended by classes requiring multiple listeners support.
   * The dispatcher can act in two different ways, either synchronously (all listeners are triggered
   * before the dispatching method exits) or asynchonously (all the listeners are triggered only when 
   * the currently running code has been executed).<br/>  
   * When extending this class is a good idea to also prepare an empty fake class to act as interface 
   * to keep track of the events that will be generated.
   * 
   *
   * 
   * 
   * @example
   * //using light extension
   * define(["Inheritance","EventDispatcher"],function(Inheritance,EventDispatcher) {
   *   
   *   var MyClass = function() {
   *     this.initDispatcher();
   *     //do stuff
   *   }
   *   
   *   MyClass.prototype = {
   *     foo: function() {
   *       //still doing stuff
   *       
   *       //send an eventName event to the listeners (their eventName method will be called)
   *       this.dispatchEvent("eventName",[paramForHandlers,otherParamForHandlers]);
   *       
   *       //do more stuff
   *     }
   *   };
   *   
   *   Inheritance(MyClass,EventDispatcher,true);
   *   return MyClass;
   * });
   * 
   * define([],function() {
   *   
   *   var MyClassListener = function() {
   *     //do stuff
   *   }
   *   
   *   MyClassListener = {
   *     eventName: function(param1,param2) {
   *       //handle event
   *     }
   *   };
   *   
   *   return MyClassListener;
   * });
   */
  var EventDispatcher = function() {
    this.initDispatcher();
  };
  
  EventDispatcher.prototype = {
      
      /**
       * Initializes the required internal structures and configures the dispatcher 
       * for sending asynchronous events.
       * <br/>If called more than once it will reset the status of the instance.
       * <br/>This method MUST be called at least once before event dispatching can 
       * be exploited, otherwise most methods will fail either silently or with unexpected
       * exceptions as no init-checks are performed by them.
       * @protected
       * 
       * @see EventDispatcher#useSynchEvents
       */
      initDispatcher: function() {
        this.theListeners = new AsymList();
        this.synchEvents = false;
      },
      
      /**
       * Adds a listener and fires the onListenStart event to it sending itself as only parameter.
       * Note that the onListenStart event is only fired on the involved listener not on previously
       * registered listeners.
       * 
       * @param {EventDispatcherListener} aListener a listener to receive events notifications. The listener does not need
       * to implement all of the possible events: missing events will not be fired on it.
       */
      addListener: function(aListener) {
        if (aListener && !this.theListeners.contains(aListener)) {
          var obj = {handler:aListener,listening:true};
          this.theListeners.add(obj);
          this.dispatchToOneListener("onListenStart",[this],obj,true);
        }
      },
      
      /**
       * Removes a listener and fires the onListenEnd event to it sending itself as only parameter.
       * Note that the onListenEnd event is only fired on the involved listener not on previously
       * registered listeners.
       * 
       * @param {EventDispatcherListener} aListener the listener to be removed.
       */
      removeListener: function(aListener) {
        if (!aListener) {
          return;
        }
        
        var obj = this.theListeners.remove(aListener);
        if (obj) {
          this.dispatchToOneListener("onListenEnd",[this],obj,true);
        }
      },
      
      /**
       * Returns an array containing the currently active listeners.
       * 
       * @returns {Array.<EventDispatcherListener>} an array of listeners.
       */
      getListeners: function() {
        return this.theListeners.asArray();
      },
      
      /**
       * Configures the EventDispatcher to send either synchronous or asynchronous events.
       * <br/>Synchronous events are fired on listeners before the {@link EventDispatcher#dispatchEvent} call
       * of the related event is returned.
       * </br>Asynchronous events are fired after the current code block is completed and possibly
       * after more code blocks are executed. Can be considered as if the calls are performed 
       * inside setTimeout with timeout 0.
       * 
       * @param {Boolean} [useSynch=false] true to fire events synchronously, any other value to fire them
       * asynchronously.
       * 
       * @see EventDispatcher#initDispatcher
       */
      useSynchEvents: function(useSynch) {
        this.synchEvents = useSynch === true;
      },

      /**
       * @private 
       * @param evt
       * @param params
       * @param listener
       * @param forced
       */
      dispatchToOneListener: function(evt,params,listener,forced) {
        if (this.synchEvents) {
          this.dispatchToOneListenerExecution(evt,params,listener,true);
        } else {
          Executor.addTimedTask(this.dispatchToOneListenerExecution,0,this,[evt,params,listener,forced]);
        }
      },
      
      /**
       * @private
       * @param evt
       * @param params
       * @param listener
       * @param forced
       */
      dispatchToOneListenerExecution: function(evt,params,listener,forced) {
        if (listener && listener.handler[evt] && (forced || listener.listening)) {
          try {
            //if we don't distinguish the two cases we will have problems on IE
            if (params) {
              listener.handler[evt].apply(listener.handler,params);
            } else {
              listener.handler[evt].apply(listener.handler);
            }
          } catch(_e) {
            //actionsLogger.logError("An error occurred while executing an event on a listener",evt,_e);
          }
        }
      },
      
      /**
       * Fires an event on all the listeners.
       * @param {String} evt The name of the event to be fired. A method with this name will be called on the listeners. 
       * @param {Array} [params] An array of objects to be used as parameters for the functions handling the event.
       * @see EventDispatcher#useSynchEvents
       */
      dispatchEvent: function(evt,params) {
        /*if (actionsLogger.isDebugLogEnabled()) {
          actionsLogger.logDebug("Dispatching event on listeners",evt);
        }*/
        
        var that = this;
        this.theListeners.forEach(function(el) {
          that.dispatchToOneListener(evt,params,el,false);
        });
      }
  };

  //closure compiler exports
  EventDispatcher.prototype["initDispatcher"] = EventDispatcher.prototype.initDispatcher;
  EventDispatcher.prototype["addListener"] = EventDispatcher.prototype.addListener;
  EventDispatcher.prototype["removeListener"] = EventDispatcher.prototype.removeListener;
  EventDispatcher.prototype["getListeners"] = EventDispatcher.prototype.getListeners;
  EventDispatcher.prototype["useSynchEvents"] = EventDispatcher.prototype.useSynchEvents;
  EventDispatcher.prototype["dispatchEvent"] = EventDispatcher.prototype.dispatchEvent;
  
  /**
   * extend the List class to power up the remove method:
   * as we get from outside object but we want to wrap them
   * before adding to the list we need a way to remove
   * the wrapped object given the original one
   * we also change the return value
   * @private
   */
  var AsymList = function() {
    this._callSuperConstructor(AsymList);
  };
  AsymList.prototype = {
    remove: function(remEl) {
      var i = this.find(remEl);
      if (i < 0) {
        return false;
      }
      var toRet = this.data[i];
      toRet.listening = false;
      this.data.splice(i,1);
      return toRet;
    },
    find: function(el) {
      for (var i=0; i<this.data.length; i++) {
        if (this.data[i].handler == el) {
          return i;
        }
      }
      return -1;
    },
    asArray: function() {
      var toRet = [];
      this.forEach(function(aListener) {
        toRet.push(aListener.handler);
      });
      return toRet;
    }
  };
  Inheritance(AsymList,List);
  
  /**
   * This constructor does nothing
   * @constructor
   *
   * @exports EventDispatcherListener
   * @class Simple interface to be implemented to listen for the default {@link EventDispatcher} events.
   * Note that there is no need to implement all of the methods as if an event method is missing it is 
   * simply not fired.  
   */
  var EventDispatcherListener = function() {
    
  };
  EventDispatcherListener.prototype = {
      /**
       * Event that is fired when a listener is added to an {@link EventDispatcher} through {@link EventDispatcher#addListener}
       * @param {EventDispatcher} dispatcher the dispatcher that fired the event.
       */
      onListenStart: function(dispatcher) {
        
      },
      /**
       * Event that is fired when a listener is removed from an {@link EventDispatcher} through {@link EventDispatcher#removeListener}
       * @param {EventDispatcher} dispatcher the dispatcher that fired the event.
       */
      onListenEnd: function(dispatcher) {
        
      }
  };
  
  
  return EventDispatcher;
})(); 
  
