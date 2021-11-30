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
import Helpers from "./Helpers";
import EnvironmentStatus from "./EnvironmentStatus";
import Environment from "./Environment";

export default /*@__PURE__*/(function() {
    var step = 50;
    var newStuffFlag = false;
    var toBeExecuted = [];
    var now = Helpers.getTimeStamp();
    var RESET_TIME = 3*60*60*1000; //3 hours
    var resetAt = now+RESET_TIME; //workaround for Safari 5 windows: after several hours the toBeExecuted array becomes unusable (OOM)
    var toBeRepeated = [];
    var timer = null;
    var nextId = 0;
    //var goodWakeups = 0;
    
    function sortFun(a,b) {
      if (a.time === b.time) {
        return a.orderId - b.orderId;
      }
      return a.time-b.time;
    }
    
    //TICK handling stuff
    var origin = Environment.isBrowserDocument() && (document.location.protocol == "http:" || document.location.protocol == "https:") ? (document.location.protocol+"//"+document.location.hostname+(document.location.port?":"+document.location.port:"")) : "*";
    var DEFAULT_GENERATE_TICK = function() { /*setTimeout(doTick,0); */ };
    var generateTickExecution = DEFAULT_GENERATE_TICK;
    var pendingGeneratedTick = false;
    function doTick() {
      pendingGeneratedTick = false;
      execute();
    }
    //we need to call this for urgent task as on FX5 and CH11 setInterval/setTimeout calls 
    //are made 1 per second on background pages (and our 50ms tick is based on a setInterval) 
    function generateTick() {
      if (!pendingGeneratedTick) {
        pendingGeneratedTick = true;
        generateTickExecution();
      }
    }
    
    
    function doInit() {
      if (!timer) {
        //set up the method to generate the tick
        //  on recent browsers we send a post message and trigger the doTick when we receive such message
        if (Environment.isBrowserDocument() && typeof postMessage != "undefined") {
          generateTickExecution = function() {
              try {
                  window.postMessage("Lightstreamer.run",origin);                    
              } catch (e) {
                  // sometimes on IE postMessage fails mysteriously but, if repeated, works
                  try {
                      window.postMessage("Lightstreamer.run",origin);
                  } catch (e) {
                      // await next tick (at most 50ms on foreground page and 1s in background pages)
                  }
              }
          };
          
          var postMessageHandler = function(event){
            if (event.data == "Lightstreamer.run" && origin == "*" || event.origin == origin) {
              doTick();
            }
          };
          Helpers.addEvent(window,"message", postMessageHandler);
          
          ///verify if postMessage can be used 
          generateTick();
          if (pendingGeneratedTick == false) {
            //post message can't be used, rollback
            Helpers.removeEvent(window,"message", postMessageHandler);
            generateTickExecution =  DEFAULT_GENERATE_TICK;
          }
          
        } else if (Environment.isNodeJS() && typeof process != "undefined" && process.nextTick) {
          //  on node versions having the nextTick method we rely on that
          generateTickExecution  = function() {
            process.nextTick(doTick);
          };
          
        } //  other cases will use the default implementation that's currently empty
        
      } else {
        clearInterval(timer);
      }
      
      //for "normal" tasks we use an interval
      timer = setInterval(execute,step);
    }
    
    
    //main execution method, the core of the Executor
    function execute() {
      if (EnvironmentStatus.unloaded) {
        clearInterval(timer);
        return;
      }
      
      var last = now;
      now = Helpers.getTimeStamp();
      if (now < last) {
        // not to be expected, but let's protect from this, because, otherwise,
        // the order of the events might not be respected
        now = last;
      }
      //adjustTimer(last, now);
      
      if (toBeExecuted.length > 0) {
        if (newStuffFlag) {
          toBeExecuted.sort(sortFun);
          newStuffFlag = false;
        } //no new tasks = no need to sort
        
        var exeNow;
        while (toBeExecuted.length > 0 && toBeExecuted[0].time <= now && !EnvironmentStatus.unloaded) {
          exeNow = toBeExecuted.shift();
          if (exeNow.fun) {
            Executor.executeTask(exeNow);
            
            //prepare to re-enqueue repetetive tasks
            if (exeNow.step) {  
              toBeRepeated.push(exeNow);
            }
          } 
        }
      } 

      if (toBeExecuted.length <= 0) { //if queue is empty reset the index
        nextId = 0;
      }
      
      // re-enqueue repetetive tasks 
      var t;
      while(toBeRepeated.length > 0) {
        t = toBeRepeated.shift();
        if (t.step) { //a task might have called stopRepetitiveTask on this task
          t.orderId = nextId++;
          Executor.addPackedTimedTask(t,t.step,true);
        }
      }
      
      if (now >= resetAt) {
        resetAt = now+RESET_TIME;
        toBeExecuted = [].concat(toBeExecuted);
      }
    }

    /**
     * An Executor based on a single setInterval that is triggered every 50ms to dequeue expired tasks.
     * When 0ms tasks are enqueued a postMessage call is used to trigger an immediate execution; on nodejs
     * the process.nextTick method is used in place of the postMessage; on older browser where postMessage
     * is not supported no action is taken.
     * 
     * @exports Executor
     * @extends module:ExecutorInterface
     */
    var Executor = {  
      
      toString: function() {
        return ["[","Executor",step,toBeExecuted.length,/*this.goodWakeups,*/"]"].join("|");
      },
     
    
      getQueueLength: function() {
        return toBeExecuted.length;
      },
      
      packTask: function(fun,context,params) {
        return {fun:fun,context:context||null,params:params||null,orderId:nextId++};
      },
      
      addPackedTimedTask: function(task,time,repetitive) {
        task.step = repetitive ? time : null;
        task.time = now + parseInt(time);
        // WARNING: "now" has not been refreshed;
        // hence, with this implementation, the order of the events is guaranteed
        // only when "time" is the same (or growing);
        // we assume that sequences of tasks to be kept ordered will have a the same "time"
        
        if (isNaN(task.time)) {
          try {
            throw new Error();
          } catch(e) {
            var err = "Executor error for time: " + time;
            if (e.stack) {
              err+= " " +e.stack;
            }
            throw err;
          }
        }
        toBeExecuted.push(task);
        newStuffFlag = true;
      },
      
      addRepetitiveTask: function(fun,interval,context,params) {
        return this.addTimedTask(fun,interval,context,params,true);
      },

      stopRepetitiveTask: function(task) {
        if (!task) {
          return;
        }
        task.fun = null;
        task.step = null;
      },

      addTimedTask: function(fun,time,context,params,repetitive) {
        var task = this.packTask(fun,context,params);
        this.addPackedTimedTask(task,time,repetitive);
        if (time == 0) {
          generateTick();
        }
        return task;
      },
      
      modifyTaskParam: function(task,index,newParam) {
        task.params[index] = newParam;
      },
      
      modifyAllTaskParams: function(task,extParams) {
        task.params = extParams;
      },
      
      delayTask: function(task,delay) {
        task.time += delay;
        newStuffFlag = true;
      },
      
      executeTask: function(task,extParams) {
        try {

            //IE doesn't like the simple form when useParams is null:
            //task.fun.apply(task.context, task.params);
            //if we leave the above code instead of using the below code, we fall into IE weird problem, where
            //the execution fails in exception, task.fun results not null nor undefined, but if we try to print it 
            //(toString) or call it results as undefined (exception "Object expected").
          
          var useParams = extParams || task.params;
          
          if (task.context) {
            if (useParams) {
              task.fun.apply(task.context, useParams);
            } else {
              task.fun.apply(task.context);
            }
          } else if (useParams) {
            task.fun.apply(null, useParams);
          } else {
            task.fun();
          }
          
        } catch (_e) {
          var sendName = null;
          try {
            sendName = task.fun.name || task.fun.toString();
          } catch(_x) {
          }
          //TODO report sendName
        } 
        
      }
      
   };
   
   if (Environment.isWebWorker()) {
     //we need this workaround otherwise on firefox 10 the Executor may not run as expected.
     //I wasn't able to create a simple test case as it seems that the number of classes involved
     //and the loading order have an impact on the issue (so that it is possible that once built the
     //issue will not be there)
     //I don't want to include BrowserDetection here so that I apply the workaround on all browsers
     setTimeout(doInit,1);
     
     //other possible workarounds (referring to the failing test)
     //that make the Executor run correctly:
     // *do not include Subscription
     // *do not include the descriptor classes (inside the library code)
     // *set the step value to a higher value (75 and 100 are suggested values that seem to work)
     
   } else {
     doInit();
   }
   
   Executor["getQueueLength"] = Executor.getQueueLength;
   Executor["packTask"] = Executor.packTask;
   Executor["addPackedTimedTask"] = Executor.addPackedTimedTask;
   Executor["addRepetitiveTask"] = Executor.addRepetitiveTask;
   Executor["stopRepetitiveTask"] = Executor.stopRepetitiveTask;
   Executor["addTimedTask"] = Executor.addTimedTask;
   Executor["modifyTaskParam"] = Executor.modifyTaskParam;
   Executor["modifyAllTaskParams"] = Executor.modifyAllTaskParams;
   Executor["delayTask"] = Executor.delayTask;
   Executor["executeTask"] = Executor.executeTask;
   
   return Executor;
})();

   
 
 
/*
      function adjustTimer(last, now) {
        var diff = now - last;
        
        if (diff <= step) {
          goodWakeups++;
        } else {
          goodWakeups--;
        }
        
        if (goodWakeups >= 10) {
          changeStep(step+1);
          goodWakeups = 0;
        } else if (goodWakeups < 0) {
          if (step >= 2) {
            changeStep(Math.round(step / 2));
            goodWakeups = 0;
          } else {
            goodWakeups = 0;
          }
        }
      }
      
      function changeStep (newStep) {
        step = newStep;
        doInit();
      }
*/