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
import Environment from "./Environment";

export default /*@__PURE__*/(function() {
  /*
   ******FROM RFC 2965
    
   3.1  Syntax:  General

   The two state management headers, Set-Cookie2 and Cookie, have common
   syntactic properties involving attribute-value pairs.  The following
   grammar uses the notation, and tokens DIGIT (decimal digits), token

   (informally, a sequence of non-special, non-white space characters),
   and http_URL from the HTTP/1.1 specification [RFC2616] to describe
   their syntax.

   av-pairs    =     av-pair *(";" av-pair)
   av-pair     =     attr ["=" value]              ; optional value
   attr        =     token
   value       =     token | quoted-string

   Attributes (names) (attr) are case-insensitive.  White space is
   permitted between tokens.  Note that while the above syntax
   description shows value as optional, most attrs require them.

   NOTE: The syntax above allows whitespace between the attribute and
   the = sign.

    
   *******FROM RFC 2616
    
   Many HTTP/1.1 header field values consist of words separated by LWS
   or special characters. These special characters MUST be in a quoted
   string to be used within a parameter value (as defined in section
   3.6).

     token          = 1*<any CHAR except CTLs or separators>
     separators     = "(" | ")" | "<" | ">" | "@"
                    | "," | ";" | ":" | "\" | <">
                    | "/" | "[" | "]" | "?" | "="
                    | "{" | "}" | SP | HT

  *******SO

  we broke the rules as the address of the Lightstreamer server was used inside a cookie name with its :// part
  so we solve the problem by encoding the cookie name before writing/reading it.
  
  we don't change the values as we use only legal characters: 
    the applicationName is alphanumeric
    the engine random number is a number... 
    we tie the applicationName and the engine number with a _ (which is legal)
    the timestamp (1st value of the "big cookie") is a number
    the engine kind (2nd value of the "big cookie") is a single letter...
    the frame name (3rd value of the "big cookie") contains the host name (after the substitution of . and - for other reasons) 
      and is tied with applicationName and engine number with _ (again, legal)
    the host name (optional 4th value of the big cookie) may contain . and - (both legal)
    we separate the values in a single cookies with a | (which is legal)
    
 */
  
  var cookiesEnabled = false;
  
  /**
   * This module contains some utility methods to read and write cookies.
   * <br/>The module makes some assumptions on the cookie usage: some cookie options
   * are not configurable and use fixed defaults.
   * @exports CookieManager
   */
  var CookieManager = {
    
    /**
     * Checks if the module is able to read and write cookies: when the module is loaded it performs
     * a simple check to verify the functionality. When running on Node.js or WebWorkers it is always false. 
     * @returns {Boolean}
     */
    areCookiesEnabled: function() {
      return cookiesEnabled;
    },
    
    /**
     * Returns document.cookie if {@link module:CookieManager.areCookiesEnabled areCookiesEnabled} is true, null otherwise
     * @returns the document.cookie or null
     */
    getAllCookiesAsSingleString: function() {
      if (!this.areCookiesEnabled()) {
        return null;
      }
      return document.cookie.toString();
    },
    
    /**
     * Writes a cookie. The path specified in the cookie is always /
     * @param {String} key the name of the cookie to be written. The key is encoded before it is used.
     * @param {String} val the value of the cookie to be written
     */
    writeCookie: function(key, val) {
      this.writeCookieExe(key, val,"");
    },
    
    /**
     * @private
     */
    writeCookieExe: function(key, val, expireStr) {
      if (!this.areCookiesEnabled()) {
        return;
      }
      
      //Prepare to write cookie
      
      var domainStr = ""; //hasDefaultDomain ? "" : "domain=."+document.domain+"; ";
  
      var valStr = encodeURIComponent(key) + "=" + val + "; ";
      
      var cookieStr = valStr + domainStr + expireStr + "path=/;";
      
      document.cookie = cookieStr;
      
      //Cookies updated
    },
    
    /**
     * Reads a cookie from the browser
     * @param {String} key the name of the cookie to be read. The key is encoded before it is used.
     * @returns {String} the cookie value or null if the cookie does not exists or if {@link module:CookieManager.areCookiesEnabled areCookiesEnabled} is false.
     */
    readCookie: function(key) {
      if (!this.areCookiesEnabled()) {
        return null;
      }
      key = encodeURIComponent(key) + "=";
      
      //... we've cookies!
      var cookies = this.getAllCookiesAsSingleString();

      /*if (cookies.charAt(cookies.length-1) == "=") {
        //rekonq 0.4.0 shows this bug where a = is placed in place of an ; on the last cookie in list...
        cookies = cookies.substring(0,cookies.length-1);
        
        //rekonq 0.7.90 does not show the issue.
      }*/
      
      //tokenize the cookies string ";"
      cookies = cookies.split(";");
      for(var i=0; i < cookies.length; i++) {
        cookies[i] = Helpers.trim(cookies[i]);
          
        //check if we found the cookie we were looking for
        if (cookies[i].indexOf(key) == 0) {
          //we've the cookie, let's return the value
          return cookies[i].substring(key.length,cookies[i].length);
          
        } //else this is not the cookie you are looking for 
    
      }
      
      //cookie not found
      return null;
    },
    
    /**
     * Removes a cookie by setting its expire date to "yesterday"
     * @param key {String} key the name of the cookie to be deleted. The key is encoded before it is used.
     */ 
    removeCookie: function(key) { 
      if (!this.areCookiesEnabled()) {
        return;
      }
      //Removing cookie
      
      var yesterday = new Date();
      yesterday.setTime(yesterday.getTime()-86400000); //Yesterday: (-1*24*60*60*1000)); using -1 should be good too
      var expireStr = "expires="+yesterday.toUTCString()+"; ";
    
      this.writeCookieExe(key, "deleting", expireStr);
      
      //Cookie removed
    },

    /**
     * @private
     */
    checkCookiesFunctionality: function() {
      /*if (typeof navigator != "undefined") {
        if (navigator.cookieEnabled) {
          //cookies
        } else {
          //no cookie
        }
      }*/
      
      if (!Environment.isBrowserDocument()) {
        return;
      }
      
      if (document.location.protocol != "http:" && document.location.protocol != "https:") {
        //do not write cookies if loaded from filesystem.
        return;
      }
      
      
      cookiesEnabled = true; //enable to test
      
      //Checking cookies functionality
   
     // it is used to guard against a possible competition with other pages
      var rand = Helpers.randomG(); 
      
      // I'm not interested in the test above, I do a test of functionality
      
      var cookieTestName = "LS__cookie_test"+rand;
      this.writeCookie(cookieTestName, "testing");
      var testCookie = this.readCookie(cookieTestName);
      if (testCookie == "testing") {
        //Cookies functionality write test passed
        this.removeCookie(cookieTestName);
        testCookie = this.readCookie(cookieTestName);
        if (testCookie == null) {
          //Cookies functionality delete test passed
          //cookiesEnabled = true;
          return;
        }
      }
      
      //no way
      //Cookies functionality tests failed
      cookiesEnabled = false;
      
    }
     
  };
  
  CookieManager.checkCookiesFunctionality();
  
  //closure compiler exports
  CookieManager["areCookiesEnabled"] = CookieManager.areCookiesEnabled;
  CookieManager["getAllCookiesAsSingleString"] = CookieManager.getAllCookiesAsSingleString;
  CookieManager["writeCookie"] = CookieManager.writeCookie;
  CookieManager["removeCookie"] = CookieManager.removeCookie;
  CookieManager["readCookie"] = CookieManager.readCookie;
  
  return CookieManager;
})();
    
