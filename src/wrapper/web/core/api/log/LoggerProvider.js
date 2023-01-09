export default /*@__PURE__*/(function() {
  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports LoggerProvider
   * @class Simple interface to be implemented to provide custom log producers
   * through {@link module:LoggerManager.setLoggerProvider}.
   * 
   * <BR>A simple implementation of this interface is included with this library: 
   * {@link SimpleLoggerProvider}.
   */
  var LoggerProvider = function() {
    
  };
  
  LoggerProvider.prototype = {
    
      /**
       * Invoked by the {@link module:LoggerManager} to request a {@link Logger} instance that will be used for logging occurring 
       * on the given category. It is suggested, but not mandatory, that subsequent 
       * calls to this method related to the same category return the same {@link Logger}
       * instance.
       * 
       * @param {String} category the log category all messages passed to the given 
       * Logger instance will pertain to. 
       * 
       * @return {Logger} A Logger instance that will receive log lines related to 
       * the given category.
       */
      getLogger: function(category) {
        
      }
      
  };
  
  return LoggerProvider;
})();
  
