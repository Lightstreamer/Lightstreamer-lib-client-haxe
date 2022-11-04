/*
 * Copyright (c) 2004-2015 Weswit s.r.l., Via Campanini, 6 - 20124 Milano, Italy.
 * All rights reserved.
 * www.lightstreamer.com
 *
 * This software is the confidential and proprietary information of
 * Weswit s.r.l.
 * You shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the license agreement you entered
 * into with Weswit s.r.l.
 */
package com.lightstreamer.log;

import javax.annotation.Nonnull;

/** 
 * Interface to be implemented to consume log from the library. <BR>
 * Instances of implemented classes are obtained by the library through the LoggerProvider instance set on {@link com.lightstreamer.client.LightstreamerClient#setLoggerProvider}.
*/
public interface Logger {

    /** 
     * Receives log messages at Error level.
     * 
     * @param line The message to be logged.
     * 
     */
    void error(@Nonnull String line);

    /** 
     * Receives log messages at Error level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
     */
    void error(@Nonnull String line, @Nonnull Throwable exception);

    /** 
     * Receives log messages at Warn level.
     * 
     * @param line The message to be logged.
     * 
    */
    void warn(@Nonnull String line);

    /** 
     * Receives log messages at Warn level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void warn(@Nonnull String line, @Nonnull Throwable exception);

    /** 
     * Receives log messages at Info level.
     * 
     * @param line The message to be logged.
     * 
    */
    void info(@Nonnull String line);

    /** 
     * Receives log messages at Info level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void info(@Nonnull String line, @Nonnull Throwable exception);

    /** 
     * Receives log messages at Debug level.
     * 
     * @param line The message to be logged.
     * 
    */
    void debug(@Nonnull String line);

    /** 
     * Receives log messages at Debug level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void debug(@Nonnull String line, @Nonnull Throwable exception);

    /** 
     * Receives log messages at Fatal level.
     * 
     * @param line The message to be logged.
     * 
    */
    void fatal(@Nonnull String line);

    /** 
     * Receives log messages at Fatal level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void fatal(@Nonnull String line, @Nonnull Throwable exception);

    /** 
     * Checks if this logger is enabled for the Debug level. <BR>
     * The property should be true if this logger is enabled for Debug events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Debug statements. Note 
     * that even if the property is false, Debug log lines may be received anyway by the Debug methods.
    */
    boolean isDebugEnabled();

    /** 
     * Checks if this logger is enabled for the Info level. <BR>
     * The property should be true if this logger is enabled for Info events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Info statements. Note 
     * that even if the property is false, Info log lines may be received anyway by the Info methods.
    */
    boolean isInfoEnabled();

    /** 
     * Checks if this logger is enabled for the Warn level. <BR>
     * The property should be true if this logger is enabled for Warn events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Warn statements. Note 
     * that even if the property is false, Warn log lines may be received anyway by the Warn methods.
    */
    boolean isWarnEnabled();

    /** 
     * Checks if this logger is enabled for the Error level. <BR>
     * The property should be true if this logger is enabled for Error events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Error statements. Note 
     * that even if the property is false, Error log lines may be received anyway by the Error methods.
    */
    boolean isErrorEnabled();

    /** 
     * Checks if this logger is enabled for the Fatal level. <BR>
     * The property should be true if this logger is enabled for Fatal events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Fatal statements. Note 
     * that even if the property is false, Fatal log lines may be received anyway by the Fatal methods.
    */
    boolean isFatalEnabled();
}