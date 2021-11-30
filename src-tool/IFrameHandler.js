import BrowserDetection from "./BrowserDetection";
import EnvironmentStatus from "./EnvironmentStatus";
import Environment from "./Environment";

export default /*@__PURE__*/(function() {
    //Environment.browserDocumentOrDie();
  
    //about:blank causes entry in history on chrome (from the second iFrame on...)
    //null prevents IE from attaching
    //since chrome 33 using null causes a request to be sent by chrome, luckily the history issue seems solved now
    var DEFAULT_SRC = BrowserDetection.isProbablyAWebkit() && BrowserDetection.isProbablyChrome(32,true) ? null : "about:blank";

    var handledFrames = {}; 
    
    var IFrameHandler = {
      
      /**
       * Creates an invisible iFrame and returns its window if possible.
       * @param {String} name the name to assing to the iFrame's page
       * @param {String} [src] the path to be used to populate the iFrame. If not specified
       * about:blank or null will be used.
       * @returns {Window} the window inside the iFrame or null if the iFrame wasn't
       * generated or if the window is not accessible
       */
      createFrame: function(name,src) {
        if (!Environment.isBrowserDocument()) {
          return null;
        }
        var bodyEl = document.getElementsByTagName("BODY")[0];
        if (!bodyEl) {
          return null;
        }
        
        //if we already have this frame generated what should I do? 
        //if (handledFrames[name]) {
        
        src = src || DEFAULT_SRC;
        
        var iFrame = document.createElement("iframe");       
        
        iFrame.style.visibility = "hidden";
        iFrame.style.height = "0px";
        iFrame.style.width = "0px";
        iFrame.style.display="none";
        
        iFrame.name = name;
        iFrame.id = name;
        
        if (BrowserDetection.isProbablyIE() || BrowserDetection.isProbablyOldOpera()) {
          // on IE6 setting src after attaching the iFrame on an https page the browser may
          // give a non-secure alert. Some opera versions replicates the issue 
          iFrame.src = src;
          bodyEl.appendChild(iFrame);
        } else {
          // setting the src before attaching the iFrame to the page has issues on firefox
          // the set src is ignored and a different page may be loaded (if this is a reload and an iFrame was
          // generated with a different url on the previous life of the page). Hopefully the issue is now solved.
          bodyEl.appendChild(iFrame);
          iFrame.src = src;
        }
         
        try {
          if (iFrame.contentWindow) {
            try {
              iFrame.contentWindow.name = name;
            } catch(e) {
              //looks like this setting is not important; moreover Opera 10 may throw an exception here 
              //even if iFrame.contentWindow is valid         
            }
            handledFrames[name] = iFrame.contentWindow;
            return handledFrames[name];
            
          } else if (document.frames && document.frames[name]) {
            handledFrames[name] = document.frames[name];
            return handledFrames[name];
            
          } else {
            return null;
          }
        } catch(_e) {
          return null;
        }
        
      },
      
      /**
       * Get a previously created iFrame window or creates a new one.
       * @param {String} name the name for the iFrame. 
       * @param {Boolean} [createIfNull] if true and a previously created
       * iFrame with the specified name does not exists a new one will
       * be created
       * @param {String} [src] in case a new iFrame needs to be created
       * this will be the src assigned to it.
       * @returns {Window} the window inside the iFrame or null if the iFrame wasn't
       * generated or if the window is not accessible
       */
      getFrameWindow: function(name,createIfNull,src) {
        if (createIfNull && !handledFrames[name]) {
          this.createFrame(name,src);
        }
        
        return handledFrames[name] || null;
      },
      
      /**
       * Deletes the specified iFrame.
       * @param {String} name the name of the iFrame to be deleted. 
       */
      disposeFrame: function(name) {
        if (handledFrames[name]) {
          try {
             document.getElementsByTagName("BODY")[0].removeChild(document.getElementById(name));
          } catch(_e) {
            //don't know how to recover from here: we do nothing
          }
          delete(handledFrames[name]);
         }
       },
      
      /**
       * Deletes all the generated iFrames
       */ 
      removeFrames: function() {
        for (var name in handledFrames) {
          try {
            document.getElementsByTagName("BODY")[0].removeChild(document.getElementById(name));
          } catch (_e) {
          //we've seen IE7 passing from here
          }
        }
        
        handledFrames = {};
      }
      
    };
    
    IFrameHandler["createFrame"] = IFrameHandler.createFrame;
    IFrameHandler["getFrameWindow"] = IFrameHandler.getFrameWindow;
    IFrameHandler["disposeFrame"] = IFrameHandler.disposeFrame;
    IFrameHandler["removeFrames"] = IFrameHandler.removeFrames;
    
    
    EnvironmentStatus.addUnloadHandler(IFrameHandler.removeFrames);
    return IFrameHandler;
})();
  
