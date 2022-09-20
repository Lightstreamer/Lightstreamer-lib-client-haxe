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
      display: "none",
      width: "28px",
      height: "28px"
    });
    
    return sImg;
  }

  var BLINK_TIME = 500;

  // "S" image - Base64 encoding - green version
  var GREEN_IMG = generateImage("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyBpZD0iTGl2ZWxsb18xIiBkYXRhLW5hbWU9IkxpdmVsbG8gMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmlld0JveD0iMCAwIDEyNi4xMDgxIDE2OS41MzgiPgogIDxkZWZzPgogICAgPGxpbmVhckdyYWRpZW50IGlkPSJTZnVtYXR1cmFfc2VuemFfbm9tZV83NyIgZGF0YS1uYW1lPSJTZnVtYXR1cmEgc2VuemEgbm9tZSA3NyIgeDE9IjUxLjQ2MTMiIHkxPSI3NC4wMDIyIiB4Mj0iLTM3LjgyMjkiIHkyPSI0OC43MTM2IiBncmFkaWVudFRyYW5zZm9ybT0idHJhbnNsYXRlKDYwLjE5MDkgMTEuNjQ2OCkgcm90YXRlKC0zLjc0MTUpIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCIgc3RvcC1jb2xvcj0iI2ZmZiIvPgogICAgICA8c3RvcCBvZmZzZXQ9Ii4xNjQyIiBzdG9wLWNvbG9yPSIjZmZmIiBzdG9wLW9wYWNpdHk9Ii45NzQzIi8+CiAgICAgIDxzdG9wIG9mZnNldD0iLjM5NTMiIHN0b3AtY29sb3I9IiNmZmYiIHN0b3Atb3BhY2l0eT0iLjkwMjQiLz4KICAgICAgPHN0b3Agb2Zmc2V0PSIuNjY2IiBzdG9wLWNvbG9yPSIjZmZmIiBzdG9wLW9wYWNpdHk9Ii43ODQzIi8+CiAgICAgIDxzdG9wIG9mZnNldD0iLjk2NDciIHN0b3AtY29sb3I9IiNmZmYiIHN0b3Atb3BhY2l0eT0iLjYyMTMiLz4KICAgICAgPHN0b3Agb2Zmc2V0PSIxIiBzdG9wLWNvbG9yPSIjZmZmIiBzdG9wLW9wYWNpdHk9Ii42Ii8+CiAgICA8L2xpbmVhckdyYWRpZW50PgogICAgPGxpbmVhckdyYWRpZW50IGlkPSJTZnVtYXR1cmFfc2VuemFfbm9tZV83Ny0yIiBkYXRhLW5hbWU9IlNmdW1hdHVyYSBzZW56YSBub21lIDc3IiB4MT0iMzcuNzUzMyIgeTE9Ijk1LjkzMiIgeDI9Ii01MS40MDQyIiB5Mj0iNzAuNjc5MyIgeGxpbms6aHJlZj0iI1NmdW1hdHVyYV9zZW56YV9ub21lXzc3Ii8+CiAgICA8bGluZWFyR3JhZGllbnQgaWQ9IlNmdW1hdHVyYV9zZW56YV9ub21lXzc3LTMiIGRhdGEtbmFtZT0iU2Z1bWF0dXJhIHNlbnphIG5vbWUgNzciIHgxPSItNjMuNjgwNCIgeTE9IjM1LjE3NiIgeDI9IjU1Ljc4NTgiIHkyPSIzNS4xNzYiIHhsaW5rOmhyZWY9IiNTZnVtYXR1cmFfc2VuemFfbm9tZV83NyIvPgogICAgPGxpbmVhckdyYWRpZW50IGlkPSJTZnVtYXR1cmFfc2VuemFfbm9tZV83Ny00IiBkYXRhLW5hbWU9IlNmdW1hdHVyYSBzZW56YSBub21lIDc3IiB4MT0iLTYwLjk2MjMiIHkxPSIxMDUuNjEzIiB4Mj0iNTguNTA0OCIgeTI9IjEwNS42MTMiIHhsaW5rOmhyZWY9IiNTZnVtYXR1cmFfc2VuemFfbm9tZV83NyIvPgogIDwvZGVmcz4KICA8ZyBpZD0ibG9nb01hcmsiPgogICAgPGEgeGxpbms6aHJlZj0iYWRpZW50Ij4KICAgICAgPHBhdGggaWQ9ImxvZ29NYXJrX19QYXRoSXRlbV8iIGRhdGEtbmFtZT0ibG9nb01hcmsgJmFtcDtsdDtQYXRoSXRlbSZhbXA7Z3Q7IiBkPSJNMTExLjkxODMsNjguNDEyMWMtOS4wNzU2LTkuNDUyNy0yMi45ODk1LTExLjc1NDUtMzcuNzI4OS03LjY1ODFsLTE0LjY0NzMsNC4wNDUyYy02LjYyOCwxLjg0MTYtMTIuMzk5Mi0yLjEzMDktMTIuODY2OS04Ljg1NDctLjQ2NzctNi43MjM3LDQuNTQyNi0xMy42ODk1LDExLjE3MDYtMTUuNTMxMSwwLDAtMTQuNTk1Niw0LjA1NTktMjIuODQxOCw2LjM0NzUtMS42NDQ4LDQuMTcyMi0yLjQ0MjcsOC42MTk5LTIuMTM2NSwxMy4wMjEzLDEuMDA0OSwxNC40NDc1LDEzLjE5MTcsMTkuODY3NCwyNy40MzIzLDE1LjkxMTFsMTAuMDQ0Ni0yLjc2NjFjMzMuNzg5NS05LjM4OTEsNDIuOTM4OCwxOS43NjM3LDM2LjY0NjUsMzYuNDAxOCwxMi4yMTM2LTEwLjE5ODgsMTUuMzA1Ni0yNy44NTc0LDQuOTI3NC00MC45MTY5WiIgc3R5bGU9ImZpbGw6IHVybCgjU2Z1bWF0dXJhX3NlbnphX25vbWVfNzcpOyIvPgogICAgPC9hPgogICAgPGEgeGxpbms6aHJlZj0iYWRpZW50Ij4KICAgICAgPHBhdGggaWQ9ImxvZ29NYXJrX19QYXRoSXRlbV8tMiIgZGF0YS1uYW1lPSJsb2dvTWFyayAmYW1wO2x0O1BhdGhJdGVtJmFtcDtndDsiIGQ9Ik02NS42NTQ4LDg3Ljk5MzlsLTE0LjY0NjksNC4wNDY1Yy0xNS4zOTc0LDQuMjc4MS0zOS43MTM3LTMuMDcxNC0zNy41Mzc2LTMzLjM0MTktOC44MTIyLDEwLjQwMjMtMTAuMTM1NywyNS40OTQyLS45ODQxLDM3LjAwOTUsOS4zNDA4LDguNDU4NCwyMi45OTk5LDExLjc0OTMsMzcuNzQ1NCw3LjY1MjdsMTQuNjQ3MS00LjA0NTRjNi42MjY2LTEuODQxNCwxMi4zOTg5LDIuMTI5NSwxMi44NjY2LDguODUzMiwuNDY3Nyw2LjcyMzctNC41NDM2LDEzLjY5MjktMTEuMTcwMywxNS41MzQzLC4yODE2LS4wNzkzLDE0LjQ2MDktNC4wMTg5LDIyLjY1NDctNi4yOTQ4LDcuMTc3OS0yMi45ODQyLTYuNjg2Ni0zNC4xMDYtMjMuNTc0OS0yOS40MTQxWiIgc3R5bGU9ImZpbGw6IHVybCgjU2Z1bWF0dXJhX3NlbnphX25vbWVfNzctMik7Ii8+CiAgICA8L2E+CiAgICA8cGF0aCBpZD0ibG9nb01hcmtfX0NvbXBvdW5kUGF0aEl0ZW1fIiBkYXRhLW5hbWU9ImxvZ29NYXJrICZhbXA7bHQ7Q29tcG91bmRQYXRoSXRlbSZhbXA7Z3Q7IiBkPSJNNjcuNTg5OSwxLjc1NWwtMjMuOTY0NSw2LjYzNDNDMTcuODEzOCwxNS41NjA0LTEuNzAzNSw0Mi42OTg0LC4xMTc4LDY4Ljg4MjJjLjc4MDgsMTEuMjI1NCw1LjM1ODYsMjAuNDgxLDEyLjM2ODQsMjYuODI1OUMtLjkzODMsNzguODE1MSw4LjE2MTEsNTQuMjE5LDMwLjQwNzQsNDguMDM4MmM0Ljg1NzMtMS4zNTA0LDI3LjQzODUtNy42MjQ5LDI3LjQzODUtNy42MjQ5bC40MzQ3LS4wOTdjNi42MjY3LTEuODQxNCwxMi4zOTk1LDIuMTI5NCwxMi44NjcxLDguODUzbDQ2LjU1Ni0xMi45MzU4QzExNS44ODI0LDEwLjA0OTYsOTMuNDAxNS01LjQxNzgsNjcuNTg5OSwxLjc1NVptMTcuMzIzMiwzNS40MTU0Yy00Ljc4NTctMTIuMDg5My0xOC4zNjM2LTExLjg0MjctMjUuOTMxMS05LjczODhsLTEuNjY2NCwuNDM3Ni0yNy40NDAxLDcuNjI1Yy0zLjQ0MTUsLjk1NTctNi43NDI2LDIuMjgwMi05Ljg1NywzLjkyMTgsNS44MzI0LTguODQ4LDE0LjY2MTItMTUuODUwMywyNC44MDcyLTE4LjY2OTdsMjMuOTY2MS02LjYzNDZjMTIuODQ1Ny0zLjU2OTEsMjguNTMsMi4wNTE5LDMzLjM0NjQsMTguMjczMWwtMTcuMjI1LDQuNzg1NVoiIHN0eWxlPSJmaWxsOiB1cmwoI1NmdW1hdHVyYV9zZW56YV9ub21lXzc3LTMpOyIvPgogICAgPHBhdGggaWQ9ImxvZ29NYXJrX19Db21wb3VuZFBhdGhJdGVtXy0yIiBkYXRhLW5hbWU9ImxvZ29NYXJrICZhbXA7bHQ7Q29tcG91bmRQYXRoSXRlbSZhbXA7Z3Q7IiBkPSJNMTExLjkxODMsNjguNDEyMWMxMy40MjQ0LDE2Ljg5MjksNC4zMjQ1LDQxLjQ4OS0xNy45MjEzLDQ3LjY3LTQuODU3MywxLjM1MDQtMjcuNDM4Niw3LjYyNDktMjcuNDM4Niw3LjYyNDlsLS40MzQ2LC4wOTY4Yy02LjYyNjgsMS44NDE2LTEyLjM5OTQtMi4xMjkyLTEyLjg2NzEtOC44NTI5TDYuNjk5OSwxMjcuODg2OWMxLjgyMTMsMjYuMTgzOCwyNC4zMDMsNDEuNjUxMSw1MC4xMTQ1LDM0LjQ3ODRsMjMuOTY0NC02LjYzNDJjMjUuODExOS03LjE3MTIsNDUuMzI5Mi0zNC4zMDkzLDQzLjUwNzktNjAuNDkzLS43ODA4LTExLjIyNTQtNS4zNTg4LTIwLjQ4MS0xMi4zNjg0LTI2LjgyNlptLTMyLjAwNTYsNzQuODY4NWwtMjMuOTY0NCw2LjYzNDRjLTEyLjg0NTgsMy41NjkxLTI4LjUzMTctMi4wNTItMzMuMzQ4MS0xOC4yNzNsMTcuMjI1Mi00Ljc4NThjNC43ODU3LDEyLjA4OTYsMTguMzYzNiwxMS44NDMsMjUuOTMyNyw5Ljc0MDNsMS42NjYzLS40MzksMjcuNDM4Ni03LjYyNTFjMy40NDE0LS45NTU0LDYuNzQ0Mi0yLjI3ODcsOS44NTY5LTMuOTIxNy01LjgzMDYsOC44NDk2LTE0LjY1OTQsMTUuODUwNS0yNC44MDcyLDE4LjY2OTlaIiBzdHlsZT0iZmlsbDogdXJsKCNTZnVtYXR1cmFfc2VuemFfbm9tZV83Ny00KTsiLz4KICA8L2c+Cjwvc3ZnPg==");
  // "S" image - Base64 encoding - grey version
  var GREY_IMG = GREEN_IMG; // currently the color switch is not implemented
  // "S" image - Base64 encoding - light green version
  var LIGHT_GREEN_IMG = GREEN_IMG; // currently the color switch is not implemented

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
   * and three tiny leds.
   * <ul>
   * <li>The left led indicates the transport in use: green if WS/WSS; yellow if HTTP/HTTPS.</li>
   * <li>The center led indicates the mode in use: green if streaming; yellow if polling.</li>
   * <li>The right led indicates where the physical connection is held: green if this LightstreamerClient
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
      "backgroundColor": "#003D06",
      "zIndex": "99999",
      "position": "relative"
    });



    applyStyles(this.statusTextsContainer,{
      "width":"245px",
      "height":"42px",
      "backgroundColor": "#E2E2E2",
      "fontFamily": "'Open Sans',Arial,sans-serif",
      "fontSize": "11px",
      "color": "#003D06",

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
      "top": "4px",
      "left": "7px",
      "width": "28px",
      "height": "28px"
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
    this.updateWidgetS(this.greyImg);
        // added temporarily, as currently the color switch is not implemented

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
        this.dataStreamingServer.innerHTML = "<b>" + title + "</b>";

        // this.updateWidgetS(sImage,true);
            // removed temporarily, as currently the color switch is not implemented 
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
        // this.blinkThread = Executor.addRepetitiveTask(this.doBlinking,BLINK_TIME,this);
            // removed temporarily, as currently the color switch is not implemented 
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

  var GREEN_LED = "#00C922";
  var YELLOW_LED = "#F4DD80";
  var OFF_LED = "#003D06";
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
  
