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
import IllegalArgumentException from "../src-tool/IllegalArgumentException";
import Helpers from "../src-tool/Helpers";
import LightstreamerConstants from "./LightstreamerConstants";
import Executor from "../src-tool/Executor";
import BrowserDetection from "../src-tool/BrowserDetection";

export default /*@__PURE__*/(function() {
  Environment.browserDocumentOrDie();
  
  var ATTACH_TO_BORDER_WRONG = "The given value is not valid. Admitted values are no, left and right";
  var DISPLAY_TYPE_WRONG = "The given value is not valid. Admitted values are open, closed and dyna";

  var widgetDisabled = BrowserDetection.isProbablyIE(6,true);

  function generateLogoFallback() {
    var sImg = createDefaultElement("div");
    applyStyles(sImg,{
      textAlign: "center",
      textOverflow: "ellipsis",
      fontFamily: "Arial, Helvetica, sans-serif",
      fontSize: "10px",
      color: "#333333",
      verticalAlign: "middle",
      paddingTop: "3px",
      width: "32px",
      height: "32px",
      display: "none"
    });
    sImg.innerHTML = NETSTATE_LABEL;
    return sImg;
  }
  
  function generateImage(src) {
    var sImg = createDefaultElement("img");
    sImg.src = src;
    
    applyStyles(sImg,{
      display: "none"
 //     width: "32px",
 //     height: "32px",
    });
    
    return sImg;
  }

  var BLINK_TIME = 500;

  //32x32 PGN "S" image - Base64 encoding - green version
  var GREEN_IMG = generateImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALDwAACw8BkvkDpQAAABl0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYzLjUuN6eEncwAAAQDSURBVFhH7ZZtaJVlGMet1IpcgZHVF6XQCAJBxVkUEeGG7KzlS8xe9PiyM888vnBg7gyXExbOkmDH3M7mmmVDK9nOKJ2bw41UfJ3tKCgOF80PRUUvREQQZNvd7/9wP3US5vN4Zh8CBz/uc3au+3/9n+u5X64xY279/Z8r0Hn+zXGQDWGogRbohuNwFNqhCabftOdEbAK8BltgLzRbkozH4ApchSE4CE/dlOQITYZqWAUTXdGSd0smQR6UQR20RHatPrz+/chJPidhJ1TAQph8w2ZIlmXL+wvjLAkgNAPegjdgAUyDh+BReAZC0AAXYRiM5U/GJpjgywgJp8KXYCDOxBzotWIhifz0fVUWPAshSyljHbRA8+XByo8/ORk719xTumff0Q1P+EqsIBLeCZdtcrOlrfQz92miuyM9iEfhNPwOG+HedHG+T4IF0AQ/goFhuARvQ/Z1zZC40E2++1iFWdawzCljuLHIdJ2NSkiCotjrqYgZB/Ohy5r4gzGlio04l+RVroGK1mJTWFuIgbBZmSgw3Z+vd5MPInKbl4FrKnMfc8Z7ziH5q66B2L4ikx/PN8HEYrOiLs/s7FzuGvjUUyjTAJKPh/Mykegucwzkx+eZxe/kmlB9wFz8olwmzmSq72seyR+GlEys2xPEQMDk1TxnCuLPm5KmfHNhoHwIE4/5Ess0yO6GzQf6qn+NNC81gZocx4R4qXau2d6x5Pi2jkV3Z6rve55Ov/bU1opNyVXfvLB97t8mZOSVhrzv4l3RGDH3+BbMNFBro3p/JLhwR06/WwmNMrW5LfzDwdTWTelHdaZ5POd19K65q7Zz6YlFO/6phl7PGl6TXhcmKvX6PIVGE8ACfDzVXzZU3BhwFqYqoYWqBWu3cJ8W8mhyeM7FRN+5/jJTlAg4W1RbVVtWW9ea0Fb2Png8M40QgIEOHcm17UHnkAomXnYM6PByDzIdar70ERrrK9AGEX87fC0Dh3rXcky/6NwXOrY3thSnG6gaUZfJy+Ew/Ay6JFohF+7wMkPMOvdS6jwTvRpuDDkGdHHpAkurQOH1DIxFZB7o2vzKFWT8FuqhAB645kK5n/9VwW/W/Iq1763usn3CMFf3kbTkAze0Gw71ls/+6MiG5IFTsUsDVyqTJPgQNKrJULOhxkNVywZnm5G4yCY/y5hLQjWoqoCamWlelXR+V5tk2yW1TW4LpXbqAtTbJE8zPgIPwlSYD2rLtsFM6ZBwJqh9i8O/mhS/RqYgpgbydWiENjWYNJrdfG6FBMQgICOuqE4/UMOqxnWKr2ReQQg9Cert1WKr1R4E9fut8IFFrbla9CWQ5aXp+3fEpsMuUG+vRSV6bHKVtwTmwH93yPh2eytwFBX4C/nwkj6r2tmsAAAAAElFTkSuQmCC");
  //32x32 PGN "S" image - Base64 encoding - grey version
  var GREY_IMG = generateImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALDgAACw4BQL7hQQAAABp0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYzLjUuMTAw9HKhAAAD00lEQVRYR+2WWWhUVxzG1bq0aBQsbi+KoiIIgpbGFsW3SmlB1AcfVEQxLi9CFjohZt/IIlRCJqNmAnGIEsjEENCEyczEKCpGM9rEYqlQ81BpCy2IlEJBTa6/73JOSYV4rxP7UHDgx5lkzvm+7557lv+0ae8//+cZGBgYmAWZcAy+hQ5IwA24BpchDBve2XMiNg/2QRVcgIihk/Y6jMILGIMr8Pk7MUdoOVTDUVhoRaurqxfDV/ANBKGjpqYmXldXd4vvnXAWTsJuWP7WYTDLMNP7jPYTCSC0EWqhAnbBGlgKq2ArZMEZ+B7GwTG8pA3DPF9BMFwNP4EDpxn4BdwxYlkSGR0dzYBtkGXIow1CB0SGh4fbe3p67kej0bbu7u71vozVCcM58KMxd5qbm6/ap6mvr08ing234W8ogPkTxfl7MeyCMPwBDozDQzgFmW8Mg/Eea97V1eWUlpa601hZWenE43EJSVAc8Xoq+syCnRAzIZ7T3tOMTToW83IbIBgMOgUFBW6A4uJiJ5FIWPPHiEz3CvDazCxgzGzPMZjvtQEaGhqcvLw817yoqMhpa2uzAbo9hdLtgPls+E4h2tvb3QC5ublOfn6+U1JS4qRSKYUYTFff1zjMl8E9hWDhuSGys7PdIBUVFc7Q0NAYIdb6Eku3k9kNJclk8s/a2lonJyfHDSE0G62trTdaWlo+Slff9zidfv39/Sebmpp+sTNhgxQWFv7GugjQZ65vwXQ7am2Ew+EDgUDgBxtArUKFQqHfCVk08ahO18dzXCwW+zASidwkyD+vRK+HO8DR6yJEsV6fp9BUOrAA1w0ODo6VlZW5C9POhBas2cIpLeSpeHiOJUSKEO4ZoUWpIHod2romhLay98Hj6TRJBwL06EhmN7iHlIIogA4ve5DpUPOlj9BMXx1NJ/rPgCcK0NfX55rruNax3djYODFA+aS6DD4IcXgKuiSisB0+8ApDnxP2UmJRvqiqqnID6OLSBTZhBva8KcBMRL4EXZs/W0HaXyEEO2DRaxfKx/yvHP4y4Q9xSMVMnTDO1Y23W0OIR2+1G7hqPyV9Z29v78ORkZFODC6CWhUZKjZUeGjWMsHdZhgfNuZ3abdjqAJV5ipm1njNpPu7yiRTLqlssiWUyqkHEDImW2hXwhJYDTtBZVkdbJIOhptA5dtp+FeR4jfICsRUQBbCObikApNCM8H3KDRBAL5WECuK2UJQwarCdYUvM69OCH0Gqu1VYqvUfgyq96Nw3qDSXCX6fsjw0vT9O2IboAVU29tP0phreo/DZvjvDhnfad93nMIMvAIArtySMI7UCwAAAABJRU5ErkJggg==");
  //32x32 PGN "S" image - Base64 encoding - light green version
  var LIGHT_GREEN_IMG = generateImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALDgAACw4BQL7hQQAAABp0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYzLjUuMTAw9HKhAAAECElEQVRYR+2WX2hbZRjGp9uq4qqguOnNhrKJIAycWJWJdw5RkM2LXaiIYnXeCMLYwLkJFQeK4G5mVOqFQ0VoK+iyxJg2bZrEpK3LRpqky9iyLq3705b9UcSBs/38PWffGWfV5JxOxxC8+PGlzTnv++T9vvf9nnmhUGje1eSqJtcP/28LqE3tWwgtsAE+gA7ohjQkIQztsLLeNs+5AgRbBM/CO/AF7LJ0sfbDETgP07AHHm50xgILINBS2A6vwC1u0P6R/sXwBGyCndCRGknFMwdSP/C5Cz6GLfA0LJ0txlcAyZptec+y3q8ABLoP3oW3YR2sgNvhLngEWuEjKMIMGMsfrO2wyBXSUAAJl8NhMLCDFx+DQRusVUHO/fZjMzwKrZaNrDuhA3ad+XnoqyMncvsqP2U/P3Qse2/gCpDwOqjY5CZfzfa6vyZTSfUQ/HXIwTl4A27yBufvxbAO2mEKDMxAGd6HloZtSOL1bvLK8QGTKCUulLHcZ8YmMgqkgOJlv0HGMwthLcSsiN9Z86pY3S0geZsrYKCaNPFi3BHQV4qa8cmMm7xKkGv8BMyqzM280+R7Bkj+jCsgd6jPRAtRqhA3vcWIKdd6XQHfzCX53z3bqAJNCNgvEaXxrCMgWthj4sNhqhAxp87mJGLgiglQYJLfAXmJSB9MICBiIoVvWXezHVFz6kxuGhF3/xMRQeaAuuGt0cn8L6lKAgFhR4T4vrjbFGo96f212A2XK8JXgBtY0+/oVH7LYDV5TBVwRWjtLkVOFMYym3nmxrkKCSzAI6QpP5p6PjYcHvGKkKihav8kIrd6R7WfoDkLuChkInV9sZbIxIa91QgbbZO2CxHbNMyumAA7hu+ZOp2dTpYjzsG8cEAjzoG1LbxXB/lfuQ3rBaEL9iLCaU21qFpVLavWtSLUyhcHT+C7wK907vcIiGgkF48mnCGVKHU7AjS83EGmoVYv3iVngEALgia2W3At74xLQG0iTRW+c8a1xvbA4aRXQFtdAbz8AsThNOiS6IQ1MN9PDM+85l5KtZOZ87qoJEAXly4wTwXWNxKwgCCPg67NMc8td5zPIXgKbpt1odzK/9rgVyv+xfSBVMz6hBmu7j5P8oONuuEvbVibyD2AcegaPZkrYya6SPAlaJXJkNmQ8VDVWsBpMxK/ZJMPsa4hoQyqKiAzsyJQF8gmWbsk2+RaKNmpYQjZJKtZ74QlsBzWgmzZe7DK3h+rSCr7tgMuMSmBbkMCLQMZyDfhE/haBhOj2c3nTvgQNsOTEuId1SSUYZVxXeZ3ftzv/TzhQwSTt5fFltWugvx+J3xmkTWXRX8OmoMm9hVAsJXwKcjb61CJHptc5X0VHoS6QyaImMu+C4IED/LM/wL+BDxNDVItZyFPAAAAAElFTkSuQmCC");

  var imgFallback = false;

  var DATA_STREAMING_SERVER = "DATA STREAMING STATUS";
  var ATTACHED = " (attached)";


  var NETSTATE_LABEL = "Net<br/>State";

  var STATUS_OPEN = 0;
  var STATUS_OPENING = 1;
  var STATUS_CLOSE = 2;
  var STATUS_CLOSING = 3;
  
  var NO = "no";
  var LEFT = "left";
  var RIGHT = "right";
  var ATTACH_TO_MAP = makeMap(NO,LEFT,RIGHT);
  
  var DYNA = "dyna";
  var OPEN = "open";
  var CLOSED = "closed";
  var DISPLAY_TYPES = makeMap(DYNA,OPEN,CLOSED);
  
  function makeMap() {
    var res = {};
    for (var i=0; i<arguments.length; i++) {
      res[arguments[i]] = true;
    }
    return res;
  }
  
  function applyStyles(element,styles) {
    for (var i in styles) {
      element.style[i] = styles[i];
    }
  }
  
  function createDefaultElement(tagName) {
    var el = document.createElement(tagName);
    applyStyles(el,{
      "backgroundColor": "transparent"
    });
    return el;
  }

  function checkCSSAnimation() {
    var toCheck = ["animationName", "WebkitAnimationName", "MozAnimationName", "OAnimationName", "msAnimationName"]; 
    var testEl = document.createElement("div");
    var testElStyle = testEl.style;
    
    for ( var i = 0; i < toCheck.length; i++ ) {
      if(typeof testElStyle[toCheck[i]] != "undefined") {
        return true;
      }
    }
    return false;
  }
  var TRANSITION_SUPPORTED = checkCSSAnimation();

  /**
   * Creates an object to be used to listen to events from a 
   * {@link LightstreamerClient} instance.
   * The new object will create a small visual widget to display the status of
   * the connection.
   * The created widget will have a fixed position so that it will not move
   * when the page is scrolled. 
   * @constructor
   * 
   * @param {String} attachToBorder "left" "right" or "no" to specify if the generated
   * widget should be attached to the left border, right border or should not be 
   * attached to any border. In the latter case, it should be immediately positioned
   * manually, by acting on the DOM element obtained through {@link StatusWidget#getDomNode}.
   * @param {String} distance The distance of the widget from the top/bottom (depending
   * on the fromTop parameter). The specified distance must also contain the units
   * to be used: all and only the units supported by CSS are accepted. 
   * @param {boolean} fromTop true or false to specify if the distance is related
   * to the top or to the bottom of the page.
   * @param {String} [initialDisplay] "open" "closed" or "dyna" to specify if the generated
   * widget should be initialized open, closed or, in the "dyna" case, open and then 
   * immediately closed. By default "dyna" is used. 
   * If attachToBorder is set to "no" then this setting has no effects. 
   * 
   * @throws {IllegalArgumentException} if an invalid value was passed as 
   * attachToBorder parameter.
   * 
   * @exports StatusWidget
   * @class This class is a simple implementation of the ClientListener interface, which will display a
   * small widget with details about the status of the connection. The widget contains the "S" logo
   * and three tiny leds. The "S" logo changes color and luminosity to reflect the current connection status
   * (connecting, disconnected, connected, and stalled).
   * <ul>
   * <li>The left led indicates the transport in use: green if WS/WSS; yellow if HTTP/HTTPS.</li>
   * <li>The center led indicates the mode in use: green if streaming; yellow if polling.</li>
   * <li>The right led indicates where the physical connection in held: green if this LightstreamerClient
   * is the master instance, holding the connection; yellow if this LightstreamerClient instance is a slave
   * attached to the master Lightstreamer Client instance.</li>
   * </ul>
   * By rolling over or clicking over the widget, a panel appears with full details.
   * <BR>Note that the widget is generated using some features not available
   * on old browsers but as long as the 
   * <a href="http://tools.ietf.org/html/rfc2397">"data" URL scheme</a>  is supported 
   * the minimal functions of the widget will work (for instance, IE<=7 does not have support 
   * for the "data" URL scheme).
   * <BR>Also note that on IE if "Quirks Mode" is activated the widget will not 
   * be displayed correctly. Specify a doctype on the document where the widget
   * is going to be shown to prevent IE from entering the "Quirks Mode".
   * 
   * @extends ClientListener
   */
  var StatusWidget = function(attachToBorder, distance, fromTop, initialDisplay) {
    if (widgetDisabled) {
      return;
    }

    this.ready = false;
    this.readyStatusOpen = false;
    this.cachedStatus = null;
    this.lsClient = null;


    attachToBorder = attachToBorder || LEFT;
    if (!ATTACH_TO_MAP[attachToBorder]) {
      throw new IllegalArgumentException(ATTACH_TO_BORDER_WRONG);
    }

    initialDisplay = initialDisplay || CLOSED;
    if (!DISPLAY_TYPES[initialDisplay]) {
      throw new IllegalArgumentException(DISPLAY_TYPE_WRONG);
    }

    this.isLeftBorder = attachToBorder === LEFT;

    var topClosed = fromTop ? distance : "auto";
    var bottomClosed = fromTop ?  "auto" : distance;
        
///////////////////////HTML generation

    this.statusWidgetContainer = createDefaultElement("div");
    var widgetMainNode = createDefaultElement("div");
    this.statusTextsContainer =  createDefaultElement("div");

    applyStyles(this.statusWidgetContainer,{
      "zIndex": "99999"
    });

    applyStyles(widgetMainNode, {
      "width": "42px",
      "height": "42px",
      "opacity": "0.95",
      "filter": "alpha(opacity"+"=95)",
      "backgroundColor": "#135656",
      "zIndex": "99999",
      "position": "relative"
    });



    applyStyles(this.statusTextsContainer,{
      "width":"245px",
      "height":"42px",
      "backgroundColor": "#ECE981",
      "fontFamily": "'Open Sans',Arial,sans-serif",
      "fontSize": "11px",
      "color": "#3E5B3E",

      "position": "absolute",
      "zIndex": "99998",

      "visibility": "hidden",
      "opacity": "0",
      "filter": "alpha(opacity"+"=0)",

      "transition": "all 0.5s",
      "MozTransition": "all 0.5s",
      "-webkit-transition": "all 0.5s",
      "OTransition": "all 0.5s",
      "-ms-transition": "all 0.5s"

      /*
      "transition-duration": "0.5s",
      "MozTransitionDuration": "0.5s",
      "-webkit-transition-duration": "0.5s",
      "OTransitionDuration": "0.5s",
      "-ms-transition-duration": "0.5s",

      "transition-timing-function": "ease",
      "MozTransitionTimingFunction": "ease",
      "-webkit-transition-timing-function": "ease",
      "OTransitionTimingFunction": "ease",
      "-ms-transition-timing-function": "ease",

      "transition-property": "all",
      "MozTransitionProperty": "all",
      "-webkit-transition-property": "all",
      "OTransitionProperty": "all",
      "-ms-transition-property": "all"
      */

    });



    if (attachToBorder == "no") {
      applyStyles(this.statusWidgetContainer,{
        "position": "absolute"
      });
      applyStyles(widgetMainNode, {
        "borderRadius": "4px",
        "float": "left"
      });
      applyStyles(this.statusTextsContainer,{
        "borderTopRightRadius": "4px",
        "borderBottomRightRadius": "4px",
        "left": "38px"
      });

    } else {
      applyStyles(this.statusWidgetContainer, {
        "position": "fixed",
        "top": topClosed,
        "bottom": bottomClosed
      });

      if (attachToBorder == LEFT) {
        applyStyles(this.statusWidgetContainer, {
          "left": "0px"
        });
        applyStyles(widgetMainNode, {
          "borderTopRightRadius": "4px",
          "borderBottomRightRadius": "4px",
          "float": "left"
        });
        applyStyles(this.statusTextsContainer, {
          "borderTopRightRadius": "4px",
          "borderBottomRightRadius": "4px",
          "left": "38px"
        });

      } else {//if (attachToBorder == RIGHT)
        applyStyles(this.statusWidgetContainer, {
          "right": "0px"
        });
        applyStyles(widgetMainNode, {
          "borderTopLeftRadius": "4px",
          "borderBottomLeftRadius": "4px",
          "float": "right"
        });
        applyStyles(this.statusTextsContainer, {
          "borderTopLeftRadius": "4px",
          "borderBottomLeftRadius": "4px",
          "right": "38px"
        });

      }
    }

    this.statusWidgetContainer.appendChild(widgetMainNode);
    this.statusWidgetContainer.appendChild(this.statusTextsContainer);


    var imageContainer  = createDefaultElement("div");
    applyStyles(imageContainer,{
      "position": "absolute",
      "top": "2px",
      "left": "5px",
      "width": "32px",
      "height": "32px"
    });


    widgetMainNode.appendChild(imageContainer);
    this.initImages(imageContainer);

    this.transportLed = new Led(widgetMainNode,1);
    this.streamingLed = new Led(widgetMainNode,2);
    this.masterLed = new Led(widgetMainNode,3);

    this.dataStreamingServer = createDefaultElement("div");
    applyStyles(this.dataStreamingServer,{
      "position": "absolute",
      "top": "7px",
      "left": "13px"
    });
    this.statusTextsContainer.appendChild(this.dataStreamingServer);

    this.statusText = createDefaultElement("div");
    applyStyles(this.statusText,{
      "position": "absolute",
      "top": "21px",
      "left": "13px"
    });
    this.statusTextsContainer.appendChild(this.statusText);

    this.updateWidget(OFF_LED,OFF_LED,OFF_LED,"Ready",DATA_STREAMING_SERVER,this.greyImg);


    this.activate();

    this.displayStatus = STATUS_CLOSE;
    this.pinned = false;
    if (initialDisplay != CLOSED) {
      this.openDetails(true);

      if (initialDisplay == DYNA) {
        Executor.addTimedTask(this.getMouseoutHandler(),1000);
      } else {
        this.pinned = true;
      }
    }

    var trHandler = this.getTransitionendHandler();
    Helpers.addEvent(this.statusTextsContainer,"transitionend",trHandler);
    Helpers.addEvent(this.statusTextsContainer,"webkitTransitionEnd",trHandler);
    Helpers.addEvent(this.statusTextsContainer,"MSTransitionEnd",trHandler);
    Helpers.addEvent(this.statusTextsContainer,"oTransitionEnd",trHandler);

    Helpers.addEvent(this.statusWidgetContainer,"click",this.getClickHandler());

    Helpers.addEvent(this.statusWidgetContainer,"mouseover",this.getMouseoverHandler());
    Helpers.addEvent(this.statusWidgetContainer,"mouseout",this.getMouseoutHandler());

  };
  

    
  StatusWidget.prototype = {
      
      /**
       * Inquiry method that gets the DOM element that makes the widget container.
       * It may be necessary to extract it to specify some extra styles or to position
       * it in case "no" was specified as the attachToBorder constructor parameter.
       *
       * @return {Object} The widget DOM element.
       */
      getDomNode: function() {
        return this.statusWidgetContainer;
      },

      /**
       * @private
       */
      initImages: function(imageContainer) {

        this.greyImg = GREY_IMG.cloneNode(true);
        imageContainer.appendChild(this.greyImg);

        if (!imgFallback && this.greyImg.height != 32 && BrowserDetection.isProbablyIE(7)) {
          imageContainer.removeChild(this.greyImg);

          //fallback!
          GREY_IMG = GREEN_IMG = LIGHT_GREEN_IMG = generateLogoFallback();
          imgFallback = true;

          this.greyImg = GREY_IMG.cloneNode(true);
          imageContainer.appendChild(this.greyImg);
        }

        this.greenImg = GREEN_IMG.cloneNode(true);
        imageContainer.appendChild(this.greenImg);

        this.lgreenImg = LIGHT_GREEN_IMG.cloneNode(true);
        imageContainer.appendChild(this.lgreenImg);

      },

      /**
       * @private
       */
      activate: function() {
        if (this.ready) {
          return;
        }
        
        var body = document.getElementsByTagName("body");
        if (!body || body.length == 0) {
          //no body means we can't append; if there is no body DOMContentLoaded cannot have already being fired, so let's wait for it 
          var that = this;
          //this widget uses styles not available on older browsers so that we do not need to setup a fallback to help browsers not having the DOMContentLoadEvent
          Helpers.addEvent(document,"DOMContentLoaded",function() {
            document.getElementsByTagName("body")[0].appendChild(that.statusWidgetContainer);
            that.ready = true;
            if (that.cachedStatus) {
              that.onStatusChange(that.cachedStatus);
            }
            if (that.displayStatus == STATUS_OPEN) {
              that.openDetails();
            } else {
              that.closeDetails();
            }
          });
          
        } else {
          body[0].appendChild(this.statusWidgetContainer);
          this.ready = true;
        }
      },
      
      /**
       * @inheritdoc
       */
      onListenStart: function(lsClient) {
        if(widgetDisabled) {
          return;
        }
        this.onStatusChange(lsClient.getStatus());
        this.lsClient = lsClient;
      },

      /**
       * @inheritdoc
       */
      onListenEnd: function() {
        if(widgetDisabled) {
          return;
        }

        this.updateWidget(OFF_LED,OFF_LED,OFF_LED,"Ready",DATA_STREAMING_SERVER);
        this.lsClient = null;
      },

      /**
       * @private
       */
      updateWidget: function(l1,l2,l3,text,title,sImage) {

        this.transportLed.changeColor(l1);
        this.streamingLed.changeColor(l2);
        this.masterLed.changeColor(l3);

        this.statusText.innerHTML = text;
        this.dataStreamingServer.innerHTML = title;

        this.updateWidgetS(sImage,true);
      },

      updateWidgetS: function(sImage,stopBlinking) {
        if (stopBlinking) {
          this.stopBlinking();
        }

        if (this.widgetImageNode) {
          this.widgetImageNode.style.display = "none";
        }
        sImage.style.display = "";
        this.widgetImageNode = sImage;
      },

      /**
       * @private
       */
      stopBlinking: function() {
        if (!this.blinkThread) {
          return;
        }
        this.blinkFlag = false;
        Executor.stopRepetitiveTask(this.blinkThread);
        this.blinkThread = null;
      },

      /**
       * @private
       */
      startBlinking: function() {
        this.blinkThread = Executor.addRepetitiveTask(this.doBlinking,BLINK_TIME,this);
      },

      /**
       * @private
       */
      doBlinking: function() {
        this.updateWidgetS(this.blinkFlag?this.greyImg:this.greenImg);
        this.blinkFlag = !this.blinkFlag;
      },
      
      /**
       * @inheritdoc
       */
      onStatusChange: function(status) {
        if (!this.ready || widgetDisabled) {
          this.cachedStatus = status;
          return;
        }

        var isMaster = this.lsClient && ((this.lsClient.isMaster && this.lsClient.isMaster()) || (this.lsClient.connectionSharing && this.lsClient.connectionSharing.isMaster()));

        var masterLed = isMaster ? GREEN_LED : YELLOW_LED;
        var incipit =  isMaster ? DATA_STREAMING_SERVER :  DATA_STREAMING_SERVER+ATTACHED;

        if (status == LightstreamerConstants.DISCONNECTED) {
          this.updateWidget(OFF_LED,OFF_LED,OFF_LED,"Disconnected",DATA_STREAMING_SERVER,this.greyImg);
          
        } else if (status == LightstreamerConstants.CONNECTING) {
          this.updateWidget(OFF_LED,OFF_LED,masterLed,"Connecting...",incipit,this.greyImg);
          this.startBlinking();

        } else if (status.indexOf(LightstreamerConstants.CONNECTED) == 0) {

          var HEAD_STATUS = "Connected over ";
          var separator = this.lsClient && this.lsClient.connectionDetails.getServerAddress().indexOf("https") == 0 ? "S in " : " in ";

          if (status == LightstreamerConstants.CONNECTED + LightstreamerConstants.SENSE) {
            this.updateWidget(YELLOW_LED, YELLOW_LED, masterLed, "Stream-sensing...",incipit,this.greyImg);
            this.startBlinking();

          } else if (status == LightstreamerConstants.CONNECTED + LightstreamerConstants.WS_STREAMING) {
            this.updateWidget(GREEN_LED, GREEN_LED, masterLed, HEAD_STATUS+"WS"+separator+"streaming mode",incipit,this.greenImg);

          } else if (status == LightstreamerConstants.CONNECTED + LightstreamerConstants.HTTP_STREAMING) {
            this.updateWidget(YELLOW_LED, GREEN_LED, masterLed, HEAD_STATUS+"HTTP"+separator+"streaming mode",incipit,this.greenImg);

          } else if (status == LightstreamerConstants.CONNECTED + LightstreamerConstants.WS_POLLING) {
            this.updateWidget(GREEN_LED, YELLOW_LED, masterLed, HEAD_STATUS+"WS"+separator+"polling mode",incipit,this.greenImg);

          } else if (status == LightstreamerConstants.CONNECTED + LightstreamerConstants.HTTP_POLLING) {
            this.updateWidget(YELLOW_LED, YELLOW_LED, masterLed, HEAD_STATUS+"HTTP"+separator+"polling mode",incipit,this.greenImg);
          }

        } else if (status == LightstreamerConstants.STALLED) {
          this.updateWidget(OFF_LED,OFF_LED,masterLed,"Stalled",incipit,this.lgreenImg);

        } else if (status == LightstreamerConstants.TRYING_RECOVERY) {
          this.updateWidget(OFF_LED,OFF_LED,masterLed,"Recovering...",incipit,this.lgreenImg);
          this.startBlinking();

        } else {
          this.updateWidget(OFF_LED,OFF_LED,masterLed,"Disconnected (will retry)",incipit,this.greyImg);
        }

      },
      

      openDetails: function(force) {
        if (this.displayStatus == STATUS_OPEN ||this.displayStatus == STATUS_OPENING) {
          return;
        }
        this.displayStatus = STATUS_OPENING;
        applyStyles(this.statusTextsContainer,{
          "visibility": "",
          "opacity": "1",
          "filter": "alpha(opacity"+"=100)"
        });

        if (!TRANSITION_SUPPORTED || force) {
          this.transitionendHandler();
        }
      },

      closeDetails: function(force) {
        if (this.displayStatus == STATUS_CLOSE ||this.displayStatus == STATUS_CLOSING) {
          return;
        }
        this.displayStatus = STATUS_CLOSING;
        applyStyles(this.statusTextsContainer, {
          "visibility": "hidden",
          "opacity": "0",
          "filter": "alpha(opacity" + "=0)"
        });

        this.pinned = false;

        if (!TRANSITION_SUPPORTED || force) {
          this.transitionendHandler();
        }
      },

      /**
       * @private
       */
      getMouseoverHandler: function() {
        var that = this;
        return function() {
          that.openDetails();
        };
      },

      /**
       * @private
       */
      getMouseoutHandler: function() {
        var that = this;
        return function() {
          if (!that.pinned) {
            that.closeDetails();
          }
        };
      },

      /**
       * @private
       */
      getClickHandler: function() {
        var that = this;
        return function() {
          that.clickHandler();
        };
      },

      /**
       * @private
       */
      clickHandler: function() {
        if (!this.pinned) {
          this.pinned = true;
          this.openDetails();
        } else {
          this.closeDetails();
        }
      },

      /**
       * @private
       */
      getTransitionendHandler: function() {
        var that = this;
        return function() {
          that.transitionendHandler();
        };
      },

      /**
       * @private
       */
      transitionendHandler: function() {
        if (this.statusTextsContainer.style["visibility"] == "hidden") {
          this.toggleState = STATUS_CLOSE;
        } else {
          this.toggleState = STATUS_OPEN;
        }
      }
  };

  var GREEN_LED = "#709F70";
  var YELLOW_LED = "#ECE981";
  var OFF_LED = "#135656";
  function Led(container,ledCount) {
    this.led = createDefaultElement("div");
    applyStyles(this.led,{
      "position": "absolute",
      "bottom": "3px",
      "left": 5+11*(ledCount-1)+"px",
      "width": "10px",
      "height": "3px",
      "borderRadius": "2px",
      "backgroundColor": OFF_LED
    });
    container.appendChild(this.led)
  }
  Led.prototype.changeColor = function(newColor) {
    applyStyles(this.led,{"backgroundColor": newColor});
  };


  
  //closure compiler eports
  StatusWidget.prototype["onStatusChange"] = StatusWidget.prototype.onStatusChange;
  StatusWidget.prototype["onListenStart"] = StatusWidget.prototype.onListenStart;
  StatusWidget.prototype["onListenEnd"] = StatusWidget.prototype.onListenEnd;
  StatusWidget.prototype["getDomNode"] = StatusWidget.prototype.getDomNode;

  return StatusWidget;
})();
  
