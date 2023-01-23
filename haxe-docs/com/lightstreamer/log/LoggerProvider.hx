package com.lightstreamer.log;

/** 
 * Simple interface to be implemented to provide custom log consumers to the library. <BR>
 * An instance of the custom implemented class has to be passed to the library through the 
 * `LightstreamerClient.setLoggerProvider`.
 */
interface LoggerProvider {
  /** 
   * Request for a Logger instance that will be used for logging occuring on the given 
   * category. It is suggested, but not mandatory, that subsequent calls to this method
   * related to the same category return the same Logger instance.
   * 
   * @param category the log category all messages passed to the given Logger instance will pertain to.
   * 
   * @return A Logger instance that will receive log lines related to the given category.
   * 
   */
  function getLogger(category: String): Logger;
}