/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.log;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/** 
 * Interface to be implemented to consume log from the library. <BR>
 * Instances of implemented classes are obtained by the library through the LoggerProvider instance set on {@link com.lightstreamer.client.LightstreamerClient#setLoggerProvider}.
*/
public interface Logger {

    /** 
     * Receives log messages at Error level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
     */
    void error(@Nonnull String line, @Nullable Throwable exception);

    /** 
     * Receives log messages at Warn level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void warn(@Nonnull String line, @Nullable Throwable exception);

    /** 
     * Receives log messages at Info level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void info(@Nonnull String line, @Nullable Throwable exception);

    /** 
     * Receives log messages at Debug level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void debug(@Nonnull String line, @Nullable Throwable exception);
    
    /** 
     * Receives log messages at Trace level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void trace(@Nonnull String line, @Nullable Throwable exception);

    /** 
     * Receives log messages at Fatal level and a related exception.
     * 
     * @param line The message to be logged.
     * 
     * @param exception An Exception instance related to the current log message.
     * 
    */
    void fatal(@Nonnull String line, @Nullable Throwable exception);

    /** 
     * Checks if this logger is enabled for the Trace level. <BR>
     * The property should be true if this logger is enabled for Trace events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Trace statements. Note 
     * that even if the property is false, Trace log lines may be received anyway by the Trace methods.
     * @return true if the Trace logger is enabled
    */
    boolean isTraceEnabled();

    /** 
     * Checks if this logger is enabled for the Debug level. <BR>
     * The property should be true if this logger is enabled for Debug events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Debug statements. Note 
     * that even if the property is false, Debug log lines may be received anyway by the Debug methods.
     * @return true if the Debug logger is enabled
    */
    boolean isDebugEnabled();

    /** 
     * Checks if this logger is enabled for the Info level. <BR>
     * The property should be true if this logger is enabled for Info events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Info statements. Note 
     * that even if the property is false, Info log lines may be received anyway by the Info methods.
     * @return true if the Info logger is enabled
    */
    boolean isInfoEnabled();

    /** 
     * Checks if this logger is enabled for the Warn level. <BR>
     * The property should be true if this logger is enabled for Warn events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Warn statements. Note 
     * that even if the property is false, Warn log lines may be received anyway by the Warn methods.
     * @return true if the Warn logger is enabled
    */
    boolean isWarnEnabled();

    /** 
     * Checks if this logger is enabled for the Error level. <BR>
     * The property should be true if this logger is enabled for Error events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Error statements. Note 
     * that even if the property is false, Error log lines may be received anyway by the Error methods.
     * @return true if the Error logger is enabled
    */
    boolean isErrorEnabled();

    /** 
     * Checks if this logger is enabled for the Fatal level. <BR>
     * The property should be true if this logger is enabled for Fatal events, false otherwise. <BR> 
     * This property is intended to lessen the computational cost of disabled log Fatal statements. Note 
     * that even if the property is false, Fatal log lines may be received anyway by the Fatal methods.
     * @return true if the Fatal logger is enabled
    */
    boolean isFatalEnabled();
}