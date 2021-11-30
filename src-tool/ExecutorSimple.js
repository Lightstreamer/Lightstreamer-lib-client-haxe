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
    var active = 0;
    
    function getExecuteTaskClosure(task) {
      return function() {
        if (task.delay) {
          task.time = task.delay;
          task.delay = 0;
          //can't be repetitive
          ExecutorSimple.addPackedTimedTask(task,task.time,false);
        } else {
          ExecutorSimple.executeTask(task);
          if (!task.repetitive) {
            active--;
          }
        }
      }
    }
    /**
     * An Executor based on a multiple setTimeouts/setInterval (basically each task is bound to one or the other)
     * @exports ExecutorSimple
     * @extends module:ExecutorInterface
     */
    var ExecutorSimple = {  
      
      toString: function() {
        return ["[","ExecutorSimple","]"].join("|");
      },

      getQueueLength: function() {
        return active;
      },
      
      packTask: function(fun,context,params) {
        return {fun:fun,context:context||null,params:params||null};
      },
      
      addPackedTimedTask: function(task,time,repetitive) {
        task.time = time;
        if (isNaN(task.time)) {
          throw "ExecutorSimple error time: " + task.time;
        }
        task.repetitive = repetitive;
        
        active++;
        if (repetitive) {
          task.ref = setInterval(getExecuteTaskClosure(task),task.time);
        } else {
          task.ref = setTimeout(getExecuteTaskClosure(task),task.time);
        }
        
      },
      
      addRepetitiveTask: function(fun,interval,context,params) {
        return this.addTimedTask(fun,interval,context,params,true);
      },
      
      stopRepetitiveTask: function(task) {
        if (!task) {
          return;
        }
        clearInterval(task.ref);
        active--;
      },
      
      addTimedTask: function(fun,time,context,params,repetitive) {
        var task = this.packTask(fun,context,params);
        this.addPackedTimedTask(task,time,repetitive);
        return task;
      },
      
      modifyTaskParam: function(task,index,newParam) {
        task.params[index] = newParam;
      },
      
      modifyAllTaskParams: function(task,extParams) {
        task.params = extParams;
      },
      
      delayTask: function(task,delay) {
        if (task.repetitive) {
          throw "Can't delay repetitive tasks";
        }
        
        if (!task.delay) {
          task.delay = 0;
        }
        task.delay += delay;
      },
      
      executeTask: function(task,extParams) {
        try {

            //IE doesn't like the simple form:
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
          //TODO report
        } 
        
      }
      
    };
   
    ExecutorSimple["getQueueLength"] = ExecutorSimple.getQueueLength;
    ExecutorSimple["packTask"] = ExecutorSimple.packTask;
    ExecutorSimple["addPackedTimedTask"] = ExecutorSimple.addPackedTimedTask;
    ExecutorSimple["addRepetitiveTask"] = ExecutorSimple.addRepetitiveTask;
    ExecutorSimple["stopRepetitiveTask"] = ExecutorSimple.stopRepetitiveTask;
    ExecutorSimple["addTimedTask"] = ExecutorSimple.addTimedTask;
    ExecutorSimple["modifyTaskParam"] = ExecutorSimple.modifyTaskParam;
    ExecutorSimple["modifyAllTaskParams"] = ExecutorSimple.modifyAllTaskParams;
    ExecutorSimple["delayTask"] = ExecutorSimple.delayTask;
    ExecutorSimple["executeTask"] = ExecutorSimple.executeTask;
    
   

    return ExecutorSimple;
})();

   
 
 