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
import Environment from "./Environment";

export default /*@__PURE__*/(function() {
  //You'll find strange comments near the methods declarations; We use such comments to keep track of why are we using such browser sniffing 
  
  
 /* 
     stuff we never used or used in the past
   
      var is_icab = (window.ScriptEngine && (ScriptEngine().indexOf("InScript") > -1));
      var is_icab2down = (is_icab && !document.createElement);
      var is_icab3up = (is_icab && document.createElement);
      
      var is_konqueror = (navigator.vendor == "KDE")||(document.childNodes)&&(!document.all)&&(!navigator.taintEnabled);
      var is_safari = (document.childNodes)&&(!document.all)&&(!navigator.taintEnabled)&&(!navigator.accentColorName);
      var is_omniweb45plus = (document.childNodes)&&(!document.all)&&(!navigator.taintEnabled)&&(navigator.accentColorName);
      
      var is_nn6up = (navigator.product == "Gecko");
      var is_nn6 = (navigator.product == "Gecko" && !window.find);
      var is_nn7 = (navigator.product == "Gecko" && window.find);
  */
  //20110909 removed isOldKHTML and isIE5 detections. 
  //20130813 removed isProbablyWinPhone7 detection
  
  //null means "not yet checked", while false means that we are not on such browser; if we're not on a browser at all
  //we can directly set everything to false
  var INIT_VALUE = Environment.isBrowser() ? null : false;

  var LOW_UA = Environment.isBrowser() ? navigator.userAgent.toLowerCase() : null;
  
  function getSolution(myVer,reqVer,less) {
    if(!reqVer || !myVer) {
      return true;
    } else if (less === true) {
      // the given version or less
      return myVer <= reqVer;
    } else if (less === false) {
      //the given version or more 
      return myVer >= reqVer;
    } else {
      //exactly the given version
      return myVer == reqVer;
    }
  }
  
  function doUACheck(checkString) {
    return LOW_UA.indexOf(checkString) > -1;
  }
  
  function getSimpleUACheckFunction(checkString) {
    var resultVar = INIT_VALUE;
    return function() {
      if (resultVar === null) {
        resultVar = doUACheck(checkString);
      }
      return resultVar;
      
    };
  };
  
  function getChainedANDFunction(funs) {
    var resultVar = INIT_VALUE;
    return function() {
      if (resultVar === null) {
        resultVar = true;
        for (var i=0; i<funs.length; i++) {
          resultVar = resultVar && funs[i]();
        }
      }
      return resultVar;
    };
  }
  function getChainedORFunction(funs) {
    var resultVar = INIT_VALUE;
    return function() {
      if (resultVar === null) {
        resultVar = false;
        for (var i=0; i<funs.length; i++) {
          resultVar = resultVar || funs[i]();
        }
      }
      return resultVar;
    };
  }
  
  function getVersionedFunction(preCheckFunction,versionExtractionFunction) {
    var isBrowser = INIT_VALUE;
    var browserVersion = INIT_VALUE; 
    return function(requestedVersion,orLowerFlag){
      if (isBrowser === null) {
        isBrowser = preCheckFunction();
        browserVersion = isBrowser ? versionExtractionFunction() : null;
      }
      return isBrowser ? getSolution(browserVersion,requestedVersion,orLowerFlag) : false;
    };
  }
  
  function getExtractVersioByRegexpFunction(regexp) {
    var isBrowser = INIT_VALUE;
    return function() {
      if (isBrowser === null) {
        var res = regexp.exec(LOW_UA);
      
        if (res && res.length >= 2) {
          return res[1];  
        }
      }
      return null;
    };
  }
  
  function getOperaVersion() {
    if (!opera.version) {
      //pre 7.6
      //we do not need to detect Opera 6 so we're cool like this
      return 7;
    } else {
      //> 7.6
      var verStr = opera.version();
      verStr = verStr.replace(new RegExp("[^0-9.]+","g"), "");
      
      return parseInt(verStr);
    }
         //side NOTE: opera 7 mobile does not have opera.postError
  }
  
  function hasOperaGlobal() {
    return typeof opera != "undefined";
  }
    
  function getNotFunction(f) {
    return function() {
      return !f();
    };
  }
  
  
  var khtmlVar = INIT_VALUE;
  
  /**
   * Simple module that can be used to try to detect the browser in use.If possible the use of this module should be avoided:
   * it should only be used if the behavior can't be guessed using feature detection. The module does not contain an extensive list
   * of browsers, new method were added only when needed in the Lightstreamer JavaScript Client library. 
   * <br/>There are two kinds of methods, one does simply recognize the browsers, the other can also discern the browser version.
   * As most of the methods are based on User Agent inspections all the method names contain the "probably" word to recall their
   * intrinsic weakness.
   * @exports BrowserDetection
   */
  var BrowserDetection = {
      /**
       * Check if the browser in use is probably a rekonq or not
       * @method
       * @return {Boolean} true if probably a rekonq, false if probably not.
       */
      isProbablyRekonq: getSimpleUACheckFunction("rekonq"),  //used by isProbablyApple thus "spin fix"
      /**
       * Check if the browser in use is probably a WebKit based browser or not
       * @method
       * @return {Boolean} true if probably a WebKit based browser, false if probably not.
       */
      isProbablyAWebkit: getSimpleUACheckFunction("webkit"),//iframe generation
      /**
       * Check if the browser in use is probably a Playstation 3 browser or not
       * @method
       * @return {Boolean} true if probably a Playstation 3 browser, false if probably not.
       */
      isProbablyPlaystation: getSimpleUACheckFunction("playstation 3"),  //expected streaming behavior
      /**
       * Check if the browser in use is probably a Chrome (or Chrome tab)  or not. A specific version or version range can be requested.
       * @method
       * @param {Number=} requestedVersion The version to be checked. If not specified any version will do.
       * @param {Boolean=} orLowerFlag true to check versions up to the specified one, false to check for greater versions; the specified version
       * is always included. If missing only the specified version is considered.
       * @return {Boolean} true if the browser is probably the correct one, false if probably not.
       */
      isProbablyChrome: getVersionedFunction( 
                                                  getSimpleUACheckFunction("chrome/"),
                                                  getExtractVersioByRegexpFunction(new RegExp("chrome/([0-9]+)","g"))
                                                  ),  // iframe content generation / used by isProbablyApple / used by isProbablyAndroid / windows communication
      /**
       * Check if the browser in use is probably a KHTML browser or not
       * @method
       * @return {Boolean} true if probably a KHTML browser, false if probably not.
       */
      isProbablyAKhtml: function() {
        if (khtmlVar === null) {
          khtmlVar = (document.childNodes) && (!document.all) && (!navigator.taintEnabled) && (!navigator.accentColorName);
        }
        return khtmlVar;
      }, //hourglass trick
      /**
       * Check if the browser in use is probably a Konqueror or not. A specific version or version range can be requested.
       * @method
       * @param {Number=} requestedVersion The version to be checked. If not specified any version will do.
       * @param {Boolean=} orLowerFlag true to check versions up to the specified one, false to check for greater versions; the specified version
       * is always included. If missing only the specified version is considered.
       * @return {Boolean} true if the browser is probably the correct one, false if probably not.
       */
      isProbablyKonqueror: getVersionedFunction( 
                                                  getSimpleUACheckFunction("konqueror"),
                                                  getExtractVersioByRegexpFunction(new RegExp("konqueror/([0-9.]+)","g"))
                                                  ),  //iframe communications / iframe content generation
      /**
       * Check if the browser in use is probably an Internet Explorer or not. A specific version or version range can be requested.
       * @method
       * @param {Number=} requestedVersion The version to be checked. If not specified any version will do.
       * @param {Boolean=} orLowerFlag true to check versions up to the specified one, false to check for greater versions; the specified version
       * is always included. If missing only the specified version is considered.
       * @return {Boolean} true if the browser is probably the correct one, false if probably not.
       */                                                 
      isProbablyIE: function(requestedVersion,orLowerFlag){
        if (
                getVersionedFunction(
                        getSimpleUACheckFunction("msie"), 
                        getExtractVersioByRegexpFunction(new RegExp("msie\\s"+"("+"[0-9]+"+")"+"[.;]","g"))
                )(requestedVersion,orLowerFlag)
                ||
                getVersionedFunction(
                        getSimpleUACheckFunction("rv:11.0"),
                        function() { return "11"; }
                )(requestedVersion,orLowerFlag)
                ) {
          return true;
        } else {
          return false;
        }
      },  //color name resolution / eval isolation / hourglass trick / expected streaming behavior / iframe communication / iframe domain handling / iframe creation
      /**
       * Check if the browser in use is probably an Internet Explorer 11 or not.
       * @method
       * @return {Boolean} true if the browser is probably the correct one, false if probably not.
       */                                                 
      isProbablyEdge: getSimpleUACheckFunction("edge"), // expected streaming behavior
      /**
       * Check if the browser in use is probably a Firefox or not. A specific version or version range can be requested.
       * @method
       * @param {Number=} requestedVersion The version to be checked. If not specified any version will do.
       * @param {Boolean=} orLowerFlag true to check versions up to the specified one, false to check for greater versions; the specified version
       * is always included. If missing only the specified version is considered.
       * @return {Boolean} true if the browser is probably the correct one, false if probably not.
       */  
      isProbablyFX: getVersionedFunction(
                                         getSimpleUACheckFunction("firefox"),
                                         getExtractVersioByRegexpFunction(new RegExp("firefox\\/(\\d+\\.?\\d*)"))
                                         ), //mad check
      /**
       * Check if the browser in use is probably an old Opera (i.e.: up to the WebKit switch) or not. A specific version or version range can be requested.
       * @method
       * @param {Number=} requestedVersion The version to be checked. If not specified any version will do.
       * @param {Boolean=} orLowerFlag true to check versions up to the specified one, false to check for greater versions; the specified version
       * is always included. If missing only the specified version is considered.
       * @return {Boolean} true if the browser is probably the correct one, false if probably not.
       */                                          
      isProbablyOldOpera: getVersionedFunction(hasOperaGlobal,getOperaVersion) //autoscroll / expected streaming behavior / windows communication / onload expectations / iframe communications / iframe content generation / iframe generation
  };
  
  /**
   * Check if the browser in use is probably an Android stock browser or not
   * @method
   * @return {Boolean} true if probably an Android stock browser, false if probably not.
   */
  BrowserDetection.isProbablyAndroidBrowser = getChainedANDFunction([
                                                       getSimpleUACheckFunction("android"),
                                                       BrowserDetection.isProbablyAWebkit,
                                                       getNotFunction(BrowserDetection.isProbablyChrome)
                                                       ]);//spin fix / connection behavior handling
   /**
    * Check if the browser in use is probably an Opera Mobile or not
    * @method
    * @return {Boolean} true if probably a an Opera Mobile, false if probably not.
    */
   BrowserDetection.isProbablyOperaMobile = getChainedANDFunction([
                                                    BrowserDetection.isProbablyOldOpera,
                                                    getSimpleUACheckFunction("opera mobi")
                                                    ]); //expected test results
     
    /**
     * Check if the browser in use is probably an Apple Browser (i.e. Safari or Safari Mobile) or not. A specific version or version range can be requested.
     * @method
     * @param {Number=} requestedVersion The version to be checked. If not specified any version will do.
     * @param {Boolean=} orLowerFlag true to check versions up to the specified one, false to check for greater versions; the specified version
     * is always included. If missing only the specified version is considered.
     * @return {Boolean} true if the browser is probably the correct one, false if probably not.
     */ 
    BrowserDetection.isProbablyApple = getVersionedFunction( 
                                        getChainedANDFunction([ // safari + (ipad || iphone || ipod || (!android+!chrome+!rekonq))
                                            getSimpleUACheckFunction("safari"),
                                            getChainedORFunction([
                                                                  getSimpleUACheckFunction("ipad"),
                                                                  getSimpleUACheckFunction("iphone"),
                                                                  getSimpleUACheckFunction("ipod"),
                                                                  getChainedANDFunction([
                                                                                         getNotFunction(BrowserDetection.isProbablyAndroidBrowser),
                                                                                         getNotFunction(BrowserDetection.isProbablyChrome),
                                                                                         getNotFunction(BrowserDetection.isProbablyRekonq)])
                                                                  ])
                                            ]),
                                            getExtractVersioByRegexpFunction(new RegExp("version\\/(\\d+\\.?\\d*)"))
                                          ); //spin fix / windows communication
  
  BrowserDetection["isProbablyRekonq"] = BrowserDetection.isProbablyRekonq;
  BrowserDetection["isProbablyChrome"] = BrowserDetection.isProbablyChrome;
  BrowserDetection["isProbablyAWebkit"] = BrowserDetection.isProbablyAWebkit;
  BrowserDetection["isProbablyPlaystation"] = BrowserDetection.isProbablyPlaystation;
  BrowserDetection["isProbablyAndroidBrowser"] = BrowserDetection.isProbablyAndroidBrowser;
  BrowserDetection["isProbablyOperaMobile"] = BrowserDetection.isProbablyOperaMobile;
  BrowserDetection["isProbablyApple"] = BrowserDetection.isProbablyApple;
  BrowserDetection["isProbablyAKhtml"] = BrowserDetection.isProbablyAKhtml;
  BrowserDetection["isProbablyKonqueror"] = BrowserDetection.isProbablyKonqueror;
  BrowserDetection["isProbablyIE"] = BrowserDetection.isProbablyIE;
  BrowserDetection["isProbablyEdge"] = BrowserDetection.isProbablyEdge;
  BrowserDetection["isProbablyFX"] = BrowserDetection.isProbablyFX;
  BrowserDetection["isProbablyOldOpera"] = BrowserDetection.isProbablyOldOpera;
  return BrowserDetection;
})();
  
  
  
