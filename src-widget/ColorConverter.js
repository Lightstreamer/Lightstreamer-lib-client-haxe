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
import Environment from "../src-tool/Environment";
import LoggerManager from "../src-log/LoggerManager";
import BrowserDetection from "../src-tool/BrowserDetection";
import IFrameHandler from "../src-tool/IFrameHandler";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
  
  /*
    
      From the "Cascading Style Sheets, level 1 - W3C Recommendation 17 Dec 1996, revised 11 Apr 2008":
      ----
      6.3    Color units
      ...
      The RGB color model is being used in numerical color specifications. These examples all specify the same color:
      EM { color: #f00 }              // #rgb 
      EM { color: #ff0000 }           // #rrggbb 
      EM { color: rgb(255,0,0) }      // integer range 0 - 255 
      EM { color: rgb(100%, 0%, 0%) } // float range 0.0% - 100.0% 
      
      The format of an RGB value in hexadecimal notation is a '#' immediately followed by either three or six hexadecimal characters. 
      The three-digit RGB notation (#rgb) is converted into six-digit form (#rrggbb) by replicating digits, not by adding zeros. For example, 
      #fb0 expands to #ffbb00. This makes sure that white (#ffffff) can be specified with the short notation (#fff) and removes any dependencies 
      on the color depth of the display.
      ----
      [http://www.w3.org/TR/CSS1/#color-units] 
     
     */
  
  var gridsLogger = LoggerManager.getLoggerProxy("lightstreamer.grids");
  
  /**
   * three possible forms
   * "#FFFFFF" -> [255,255,255]
   * "FFFFFF" -> [255,255,255]
   * "#FFF" -> [255,255,255]
   * @private
   */
  function hexColorToRGBArray(hexColor) {
    if (hexColor.indexOf("#") == 0) {
      hexColor = hexColor.substring(1,hexColor.length);
    }
    if (hexColor.length == 3) {
      hexColor = hexColor.charAt(0)+hexColor.charAt(0)+hexColor.charAt(1)+hexColor.charAt(1)+hexColor.charAt(2)+hexColor.charAt(2);
    } else if (hexColor.length != 6) {
      gridsLogger.warn( "A hexadecimal color value must be 3 or 6 character long. An invalid value was specified, will be ignored");
      return null;
    }
    
    var strR = hexColor.substring(0,2);
    var strG = hexColor.substring(2,4);
    var strB = hexColor.substring(4,6);
    
    
    var numR = hexToDec(strR);
    var numG = hexToDec(strG);
    var numB = hexToDec(strB);
    if (numR == null || numG == null || numB == null) {
      return null;
    }
    
    return [numR,numG,numB];

  }
  
  var hexMap = {"A":10,"B":11,"C":12,"D":13,"E":14,"F":15};
  function makeNum(str) {
    if ((str >= 0) && (str <= 9)) {
      return new Number(str);
    }
    str = str.toUpperCase();
    
    if (hexMap[str]) {
      return hexMap[str];
    } else {
      gridsLogger.warn("A hexadecimal number must contain numbers between 0 and 9 and letters between A and F. An invalid value was specified, will be ignored");
      return null;
    }
  }  
  function hexToDec(hex) {
    //return parseInt(hex,16); <- why not?
    var res = 0;
    var cicle = 0;
    var i;
    for (i = hex.length; i >= 1; i--) {
      var tmp = makeNum(hex.substring(i-1,i));
      if (tmp == null) {
        return null;
      }
      var x;
      for (x = 1; x <= cicle; x++) {
        tmp *= 16;
      }
      cicle++;
      res += tmp;
    }
    return res;
  }
  
  function ifPercToNum(num) {
    if (num.indexOf("%") == num.length-1) {
      num = parseFloat(num.substring(0,num.length-1));
      if (num > 100 || num < 0) {
        gridsLogger.warn("A RGB element must be a number >=0 and <=255 or a percentile >=0 and <=100. An invalid value was specified, will be ignored");
        return null;
      }
      num = 2.55*num;
    }
    return num;
  }
  
  function isOkColor(foundColor, notExpectedColor) {
    if (!foundColor || foundColor == "") {
      return false;
    } else if (!notExpectedColor) {
      return true;
    } else if (foundColor != notExpectedColor) {
      return true;
    } else {
      return false;
    }
  }
  
  function translateColorNameByDIV(colorName) {
    var elem = document.createElement("DIV");
    elem.style.backgroundColor = colorName;
    var val = ColorConverter.getStyle(elem,bgJS, colorName);
    if (val == null) {
      // admitted by getStyle; but possible?
      return null;
    }
  
    if (val[0] == 255 && val[1] == 255 && val[2] == 255) {
      if (colorName.toUpperCase() != "WHITE" ) {
        //I failed. I try to hang firstly
        // the son on the page
        var bodyEl = document.getElementsByTagName("BODY")[0];
        if (bodyEl) {
          bodyEl.appendChild(elem);
          val = ColorConverter.getStyle(elem,bgJS, colorName);
          bodyEl.removeChild(elem);  
        }
      }
    }
    
    colorMap[colorName] = val;
    return colorMap[colorName];
  }
  
  /**
   * "white" -> [255,255,255]
   */
  function nameToRGBArray(colorName) {
    var res = "";
    /* on IE we notice the double change of background, on FX no
     * on FX using the engine to change the background does not work, on IE yes
     * for Opera we create a div, we assign the color and we make a getStyle
     */
    if (colorMap[colorName]) {
      return colorMap[colorName];
    }


  //if (BrowserDetection.isProbablyOldOpera()) {
  //if (window.getComputedStyle || (document.defaultView && document.defaultView.getComputedStyle)) {
  
    //20110616: IE9 is still like this
    if(!BrowserDetection.isProbablyIE()) { 
      return translateColorNameByDIV(colorName); //will fill colorMap itself
      
    } else {
      
      try {
        colorFrame = IFrameHandler.getFrameWindow("weswit__ColorFrame",true);
        if (colorFrame) {
          colorFrame.document.bgColor = colorName;
          res = colorFrame.document.bgColor;
        }
          
      } catch(_e) {
        res=null;
      }
      
    }
    //may still fail
    if (!res || res == colorName) {
      var initBG = document.bgColor;
      document.bgColor = colorName;
      res = document.bgColor;
      document.bgColor = initBG;
    }
  
    if (!res || res == colorName) {
      return translateColorNameByDIV(colorName); //will fill colorMap itself
    } //else is in the hex form
    colorMap[colorName] = hexColorToRGBArray(res);
    return colorMap[colorName];
  }
    
  function RGBStringToRGBArray(rgbColor) {
    var lenPre;
    var thirdLimit;
    if (rgbColor.indexOf("rgb(") == 0) {
      lenPre = 4;
      thirdLimit = ")";
    } else if (rgbColor.indexOf("rgba(") == 0) {
      lenPre = 5;
      thirdLimit = ",";
    } else{
      gridsLogger.warn("A RGB color value must be in the form 'rgb(x, y, z)' or 'rgba(x, y, z, a)'. An invalid value was specified, will be ignored");
      return null;
    }
    rgbColor = rgbColor.substring(lenPre,rgbColor.length);
    
    var v1 = rgbColor.indexOf(",");
    var numR = ifPercToNum(rgbColor.substring(0,v1));
    var v2 = rgbColor.indexOf(",",v1+1);
    var numG = ifPercToNum(rgbColor.substring(v1+1,v2));
    var v3 = rgbColor.indexOf(thirdLimit,v2+1);
    var numB = ifPercToNum(rgbColor.substring(v2+1,v3));
    
    if (numR == null || numG == null || numB == null) {
      return null;
    }
    
    
    return [numR,numG,numB];
  }
  
  

///////
    
  
  var bgCSS = "background-color"; 
  var bgJS = "backgroundColor";
  var transp = "transparent";
  
  var colorMap = {};
  var colorFrame=null; 

  /**
   * @private
   */
  var ColorConverter = {
   
    /**
     * Translates a color from any (string) form in an RGB array
     */
    translateToRGBArray: function(val) {
      if (val.indexOf("rgb") == 0) {
        //"rgb(0, 255, 0)"
        return RGBStringToRGBArray(val);
      } else if (val.indexOf("#") == 0) {
        //"#00FF00"
        return hexColorToRGBArray(val);
      } else {
        //"green"
        return nameToRGBArray(val);
      }
    },
    
    
    /*public*/ getStyle: function(elem,styleProp,notExpectedColor) {
      if (elem == null) {
        //no element? let's say white
        return [255,255,255];
      }
      
      var val = "";
      try {
        //do not move if conditions or opera will hate you
        if (window.getComputedStyle || (document.defaultView && document.defaultView.getComputedStyle)) {
          //try with getComputedStyle
          var styleObj = document.defaultView.getComputedStyle(elem, null);
          if (styleObj) {
            var compProp = styleProp == bgJS ? bgCSS : styleProp;
            val = styleObj.getPropertyValue(compProp);
          }
        }
      }catch(e){}
      
      
      
      try {
        if (!isOkColor(val,notExpectedColor) && elem.currentStyle) {
          //try with currentStyle
          var compProp = styleProp == bgCSS ? bgJS : styleProp;
          val = elem.currentStyle[compProp];
        }
      }catch(e){}
      
      try {
        if (!isOkColor(val,notExpectedColor)) {
          //so far so bad... let's read from css, finger crossed
          var upProp = styleProp == bgCSS ? bgJS : styleProp;
          if (elem.style[upProp] != "") {
            val = elem.style[upProp];
          } else {
            return [255,255,255];
          }
        }
      }catch(e){}
      
      if (val == transp && elem.parentNode) {
        //trasparent color, let's check the parent
        return this.getStyle(elem.parentNode,styleProp);
      } else if (val == transp) {
        return [255,255,255];
      }
      
      if (!isOkColor(val,notExpectedColor)) {
        return [255,255,255];
      }
  
      return this.translateToRGBArray(val);
    }
    
  };
  
  return ColorConverter;
})();

