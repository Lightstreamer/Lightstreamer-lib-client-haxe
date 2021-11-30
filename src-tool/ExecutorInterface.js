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
   * This module defines a common interface to be used to implement a task executor singleton.<br/>
   * The implementation should guarantee that, given two tasks to be executed at the same time, they are served in
   * a FIFO fashion.
   * 
   * @exports ExecutorInterface
   */
  var ExecutorInterface = {
      /**
       * Get the number of tasks in the executor queue.
       * @return {Number} the number of task to be executed. 
       */
      getQueueLength: function() {
        
      },
      
      /**
       * Creates a task object to be later executed.<br/> 
       * Note: the task is not queued for execution.<br/>
       * The returned object does not need to be cross-compatible with
       * other ExecutorInterface implementation: only the involved implementation
       * is supposed to accept the generated task.
       * 
       * @param {Function} fun the function to be executed.
       * @param {Object} [context] the object to be used as context for the function call.
       * @param {Array} [params] the parameters to be passed to the function.
       * @returns {Task} an object representing the task to be executed.
       */
      packTask: function(fun,context,params) {
        
      },
      
      /**
       * Queue a previously generated task for later execution.
       * @param {Task} task the task to be queued.
       * @param {Number} time the time that should be waited before executing the task. If the repetitive flag is 
       * true this time specifies the interval between two executions.  
       * @param {Boolean} [repetitive=false] true if the task has to be executed at fixed intervals,
       * false if it has to be executed only once.
       */
      addPackedTimedTask: function(task,time,repetitive) {
      },
      
      /**
       * Creates and enqueue a Task to be executed at fixed intervals.
       * @param {Function} fun the function to be executed.
       * @param {Number} interval the time that should be waited between each task execution.
       * @param {Object} [context] the object to be used as context for the function call.
       * @param {Array} [params] the parameters to be passed to the function.
       * @see module:ExecutorInterface.stopRepetitiveTask
       */
      addRepetitiveTask: function(fun,interval,context,params) {
      },
      
      /**
       * Stop the executions of a repetitive task.
       * @param {Task} task the task to be stopped.
       */
      stopRepetitiveTask: function(task) {
        
      },
      
      /**
       * Creates and enqueue a Task to be later executed.
       * @param {Function} fun the function to be executed.
       * @param {Number} time the time that should be waited before executing the task. If the repetitive flag is 
       * true this time specifies the interval between two executions.  
       * @param {Object} [context] the object to be used as context for the function call.
       * @param {Array} [params] the parameters to be passed to the function. 
       * @param {Boolean} [repetitive=false] true if the task has to be executed at fixed intervals,
       * false if it has to be executed only once.
       */
      addTimedTask: function(fun,time,context,params,repetitive) {
        
      },
      
      /**
       * Replaces one of the parameters of a specified task.
       * @param {Task} task the task to be modified.
       * @param {Number} index the 0-based index within the previously specified array of parameters to be replaced.
       * @param {Object} newParam the value to replace the previous parameter. 
       */
      modifyTaskParam: function(task,index,newParam) {
        
      },
      
      /**
       * Replaces the parameters array for a specified task.
       * @param {Task} task the task to be modified.
       * @param {Array} extParams the new array to be passed to the task.
       */
      modifyAllTaskParams: function(task,extParams) {
        
      },
      
      /**
       * Delays the execution of a task. 
       * @param {Task} task the task to be delayed.
       * @param {Number} delay the extra time that should be waited before executing the task.
       */
      delayTask: function(task,delay) {

      },
      
      /**
       * Executed a previously generated task.
       * @param {Task} task the task to be executed.
       * @param {Array} [extParams] an array of params to replace the task's own array. If missing the original array is used. 
       * @see module:ExecutorInterface.packTask
       */
      executeTask: function(task,extParams) {
        
      }
      
  };
  
  return ExecutorInterface;
})();
  

