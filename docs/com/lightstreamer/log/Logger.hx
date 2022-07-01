package com.lightstreamer.log;

import com.lightstreamer.native.NativeTypes;

/** 
 * Interface to be implemented to consume log from the library. <BR>
 * Instances of implemented classes are obtained by the library through the LoggerProvider instance set on `LightstreamerClient.setLoggerProvider`.
 */
interface Logger {
  /** 
   * Receives log messages at Fatal level and a related exception.
   * 
   * @param line The message to be logged.
   * 
   * @param exception An Exception instance related to the current log message.
   * 
   */
  function fatal(line: String, ?exception: NativeException): Void;
  /** 
   * Receives log messages at Error level and a related exception.
   * 
   * @param line The message to be logged.
   * 
   * @param exception An Exception instance related to the current log message.
   * 
   */
  function error(line: String, ?exception: NativeException): Void;
  /** 
   * Receives log messages at Warn level and a related exception.
   * 
   * @param line The message to be logged.
   * 
   * @param exception An Exception instance related to the current log message.
   * 
   */
  function warn(line: String, ?exception: NativeException): Void;
  /** 
   * Receives log messages at Info level and a related exception.
   * 
   * @param line The message to be logged.
   * 
   * @param exception An Exception instance related to the current log message.
   * 
   */
  function info(line: String, ?exception: NativeException): Void;
  /** 
   * Receives log messages at Debug level and a related exception.
   * 
   * @param line The message to be logged.
   * 
   * @param exception An Exception instance related to the current log message.
   * 
   */
  function debug(line: String, ?exception: NativeException): Void;
  /** 
   * Receives log messages at Trace level and a related exception.
   * 
   * @param line The message to be logged.
   * 
   * @param exception An Exception instance related to the current log message.
   * 
   */
  function trace(line: String, ?exception: NativeException): Void;
  /** 
   * Checks if this logger is enabled for the Fatal level. <BR>
   * The property should be true if this logger is enabled for Fatal events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Fatal statements. Note 
   * that even if the property is false, Fatal log lines may be received anyway by the Fatal methods.
   */
  function isFatalEnabled(): Bool;
  /** 
   * Checks if this logger is enabled for the Error level. <BR>
   * The property should be true if this logger is enabled for Error events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Error statements. Note 
   * that even if the property is false, Error log lines may be received anyway by the Error methods.
   */
  function isErrorEnabled(): Bool;
  /** 
   * Checks if this logger is enabled for the Warn level. <BR>
   * The property should be true if this logger is enabled for Warn events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Warn statements. Note 
   * that even if the property is false, Warn log lines may be received anyway by the Warn methods.
   */
  function isWarnEnabled(): Bool;
  /** 
   * Checks if this logger is enabled for the Info level. <BR>
   * The property should be true if this logger is enabled for Info events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Info statements. Note 
   * that even if the property is false, Info log lines may be received anyway by the Info methods.
   */
  function isInfoEnabled(): Bool;
  /** 
   * Checks if this logger is enabled for the Debug level. <BR>
   * The property should be true if this logger is enabled for Debug events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Debug statements. Note 
   * that even if the property is false, Debug log lines may be received anyway by the Debug methods.
   */
  function isDebugEnabled(): Bool;
  /** 
   * Checks if this logger is enabled for the Trace level. <BR>
   * The property should be true if this logger is enabled for Trace events, false otherwise. <BR> 
   * This property is intended to lessen the computational cost of disabled log Trace statements. Note 
   * that even if the property is false, Trace log lines may be received anyway by the Trace methods.
   */
  function isTraceEnabled(): Bool;
}