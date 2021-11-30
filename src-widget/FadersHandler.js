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
import ColorConverter from "./ColorConverter";
import Executor from "../src-tool/Executor";
import Helpers from "../src-tool/Helpers";
import Cell from "./Cell";
import Environment from "../src-tool/Environment";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
  
  //may convert into a full animation engine
  
  /**
   * @private
   */
  var FadersHandler = function(interval){
    this.fadeInterval = interval;
    this.freeFaders = new FaderPile();
    this.faderId = 0;
    this.faderList = {};
    this.fadeThread = false;

    this.runningFaders = {};
  };
  
  FadersHandler.prototype = {
    
    /**
     * @private
     * @param {Cell} cell
     * @param goingDown
     * @param endBack
     * @param endFore
     * @param millis
     * @param endCommand
     * @returns {String} id
     */
    /*public*/ getNewFaderId: function(cell, goingDown, endBack, endFore, millis, endCommand) {
      var steps = this.getHowManySteps(millis);
      var actPhase = cell.incFadePhase();
      if (!actPhase) {
        return;
      }
      var retId = this.freeFaders.get();
      if (retId == null) {
        this.faderList[this.faderId] = new Fader(cell, goingDown, endBack, endFore, steps, actPhase, endCommand);
        return this.faderId++;
      } else {
        this.faderList[retId].init(cell, goingDown, endBack, endFore, steps, actPhase, endCommand);
        return retId;
      }
    },
   
    /**
     * @private
     */
    getHowManySteps: function(time) {
      var steps = time/this.fadeInterval;
      return (steps > 1) ? steps : 1;
    },
    
    /*public*/ launchFader: function(id) {
      var fader = this.faderList[id];
      
      var currentPhase = fader.cell.getFadePhase();
      if (!currentPhase) {
        this.stopFader(fader.cell);
        return;
      }
      
      if (fader.phase < currentPhase) {
        return;
      }
      var oldId = this.runningFaders[fader.cell.getCellId()];
      var oldFader = this.faderList[oldId];
      if (oldFader) {
        if (!oldFader.goingDown) {
          if (fader.goingDown) {
            if(oldFader.endCommand) {
              Executor.executeTask(oldFader.endCommand);
            }
          } else {
            fader.actStep = oldFader.actStep;
            if (fader.steps < oldFader.steps) {
              fader.steps = oldFader.steps;
            }
          }
        }
        this.freeFaders.put(oldId);
      }
      this.runningFaders[fader.cell.getCellId()] = id;
          
      if (fader.endBack) {
        fader.startBack = ColorConverter.getStyle(fader.cell.getEl(),"backgroundColor");
      }
      if (fader.endFore) {
        fader.startFore = ColorConverter.getStyle(fader.cell.getEl(),"color");
      }
      
      if (!this.fadeThread) {
        this.fadeThreadStart(this.fadeInterval);
      }
    },
    
    /*public*/ stopFader: function(cell) {
      var oldId = this.runningFaders[cell.getCellId()];
      if (oldId || oldId == 0) {
        delete(this.runningFaders[cell.getCellId()]);
        this.freeFaders.put(oldId);
      }
    },
    
    /**
     * @private
     */
    doFade: function(lastEndTime) {
      var startTime = Helpers.getTimeStamp();
      
      var lostWaiting = 0;
      if (lastEndTime) {
        lostWaiting = startTime - (lastEndTime + this.fadeInterval);
      } 
      
      var atLeast1 = false;
      for (var ind in this.runningFaders) {
        var localFaderId = this.runningFaders[ind];
        var fader = this.faderList[localFaderId];
        
        if (fader.actStep > fader.steps) {
          this.freeFaders.put(localFaderId);
          delete (this.runningFaders[ind]);
          if (fader.endCommand) {
            Executor.addPackedTimedTask(fader.endCommand,0);
          }
        } else {
          var upEl = fader.cell.getEl();
          if (!upEl) {
            this.stopFader(fader.cell);
            continue;
          }

          if (fader.endBack == "transparent") {
            try {
              upEl.style.backgroundColor = "rgba(" +
              fader.startBack[0] + "," +
              fader.startBack[1] + "," +
              fader.startBack[2] + "," +
              this.easeInOut(100, 0, fader.steps, fader.actStep) / 100 + ")";
            } catch(e) {
              var timeToEnd = (fader.steps-fader.actStep)*this.fadeInterval;
              
              Executor.addTimedTask(toTransparent(upEl),timeToEnd);

              if (fader.endCommand) {
                Executor.addPackedTimedTask(fader.endCommand,timeToEnd);
              }
              
              this.stopFader(fader.cell);
              continue;
            }
          } else if (fader.endBack) {
            upEl.style.backgroundColor = "rgb("+
              this.easeInOut(fader.startBack[0],fader.endBack[0],fader.steps,fader.actStep) +","+
              this.easeInOut(fader.startBack[1],fader.endBack[1],fader.steps,fader.actStep) +","+
              this.easeInOut(fader.startBack[2],fader.endBack[2],fader.steps,fader.actStep) +")";
          }
          if (fader.endFore) {
            upEl.style.color = "rgb("+
              this.easeInOut(fader.startFore[0],fader.endFore[0],fader.steps,fader.actStep)+","+
              this.easeInOut(fader.startFore[1],fader.endFore[1],fader.steps,fader.actStep)+","+
              this.easeInOut(fader.startFore[2],fader.endFore[2],fader.steps,fader.actStep)+")";
  
          }
          atLeast1 = true;
        }
        fader.actStep++;
      }
      
      if (!atLeast1) {
        this.fadeThread = false;
      } else {
        var endTime = Helpers.getTimeStamp();
        var lostTime = (endTime - startTime);
        var gainedDelay = lostTime + lostWaiting;
        
        if (gainedDelay > this.fadeInterval) {
          //the delay is greater than the step size, we need
          //to skip steps
          
          //steps to skip
          var lostCycles = gainedDelay/this.fadeInterval;
          
          var lostCyclesNorm = Math.floor(lostCycles);
          
          var factionalCycles = lostCycles - lostCyclesNorm;
          
          this.recoverCycles(lostCyclesNorm);
                   
          gainedDelay = this.fadeInterval * factionalCycles;
        }
        
        this.nextFade(this.fadeInterval-gainedDelay,endTime);
      }
    },

    /**
     * @private
     */
    nextFade: function(pause,lastEndTime) {
      Executor.addTimedTask(this.doFade,pause,this,[lastEndTime]);
    },
    
    /**
     * @private
     */
    recoverCycles: function(lostCyclesNorm) {
      for (var ind in this.runningFaders) {
        var localFaderId = this.runningFaders[ind];
        var fader = this.faderList[localFaderId];
        if (fader.actStep > fader.steps) {
          // the fade is ending, no need to move further
        } else if (fader.actStep + lostCyclesNorm < fader.steps) {
          //let's skip some steps
          fader.actStep += lostCyclesNorm;
        } else {
          //move directly to the end
          fader.actStep = fader.steps;
        }
      }
      
    },
    
    /**
     * @private
     */
    fadeThreadStart: function(timeout) {
      if (this.fadeThread == true) {
        return;
      }
      this.fadeThread = true;
      
      this.nextFade(timeout);
    },
    

    /**
     * @private
     */
    easeInOut: function(minValue,maxValue,totalSteps,actualStep) {
      minValue = new Number(minValue);
      maxValue = new Number(maxValue);
      
      var delta = maxValue - minValue;
      var stepp = minValue+(((1 / totalSteps)*actualStep)*delta);
      return Math.ceil(stepp);
    },
    
    /**
     * may be exposed to offer fade functionality to non-Cell elements
     * @private
     */
    fadeCell: function(theTag, bgColor, textColor, fadeMillis, endCommand){
      //then make it a task
      var endCommandTask = Executor.packTask(endCommand);
      
      var cell = new Cell(theTag);
      var fadeId = this.getNewFaderId(cell, false, bgColor, textColor, fadeMillis, endCommandTask);
      this.launchFader(fadeId);
      return fadeId;
    }
  
  };

  function toTransparent(upEl) {
    return function() {
      upEl.style.backgroundColor = "transparent";
    };
  }


  /**
   * @private
   */
  var FaderPile = function() {
    this.length = 0;
    this.pile = {};
  };
  
  FaderPile.prototype = {
    put: function(id) {
      this.pile[this.length] = id;
      this.length++;
    },
 
    get: function() {
      if (this.length <= 0) {
        return null;
      }
      this.length--;
      return this.pile[this.length];
    }
  };


  /**
   * @private
   */
  var Fader = function(cell, goingDown, endBack, endFore, steps, phase, endCommand) {
    this.init(cell, goingDown, endBack, endFore, steps, phase, endCommand);
  };
  
  Fader.prototype = {
    init: function(cell, goingDown, endBack, endFore, steps, phase, endCommand) {
      this.endCommand = (endCommand) ? endCommand : null; 
      this.goingDown = goingDown;
      this.cell = cell;

      if (endBack === "" || endBack == "transparent") {
        this.endBack = "transparent";
      } else {
        this.endBack = (endBack) ? ColorConverter.translateToRGBArray(endBack) : null;
      }
      this.endFore = (endFore) ? ColorConverter.translateToRGBArray(endFore) : null;
      this.steps = steps;
      this.phase = phase;
      this.actStep = 0;
    }
  };
  

  return FadersHandler;
})();

