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
using System;

namespace com.lightstreamer.log
{
    /// <summary>
    /// <para>Interface to be implemented to consume log from the library.</para>
    /// <para>Instances of implemented classes are obtained by the library through the ILoggerProvider instance set on LightstreamerClient.setLoggerProvider.</para>
    /// </summary>
    public interface ILogger
    {
        /// <summary>
        /// <para>Receives log messages at Error level and a related exception.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        /// <param name="exception">
        /// An Exception instance related to the current log message.
        /// </param>
        void Error(string line, Exception exception);

        /// <summary>
        /// <para>Receives log messages at Warn level and a related exception.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        /// <param name="exception">
        /// An Exception instance related to the current log message.
        /// </param>
        void Warn(string line, Exception exception);

        /// <summary>
        /// <para>Receives log messages at Info level and a related exception.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        /// <param name="exception">
        /// An Exception instance related to the current log message.
        /// </param>
        void Info(string line, Exception exception);

        /// <summary>
        /// <para>Receives log messages at Debug level and a related exception.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        /// <param name="exception">
        /// An Exception instance related to the current log message.
        /// </param>
        void Debug(string line, Exception exception);

        /// <summary>
        /// <para>Receives log messages at Trace level and a related exception.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        /// <param name="exception">
        /// An Exception instance related to the current log message.
        /// </param>
        void Trace(string line, Exception exception);

        /// <summary>
        /// <para>Receives log messages at Fatal level and a related exception.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        /// <param name="exception">
        /// An Exception instance related to the current log message.
        /// </param>
        void Fatal(string line, Exception exception);

        /// <summary>
        /// <para>Checks if this logger is enabled for the Debug level.</para>
        /// <para>The property should be true if this logger is enabled for Debug events, false otherwise.</para> 
        /// <para>This property is intended to lessen the computational cost of disabled log Debug statements. Note 
        /// that even if the property is false, Debug log lines may be received anyway by the Debug methods.</para>
        /// </summary>
        bool IsDebugEnabled
        {
            get;
        }

        /// <summary>
        /// <para>Checks if this logger is enabled for the Trace level.</para>
        /// <para>The property should be true if this logger is enabled for Trace events, false otherwise.</para> 
        /// <para>This property is intended to lessen the computational cost of disabled log Trace statements. Note 
        /// that even if the property is false, Trace log lines may be received anyway by the Trace methods.</para>
        /// </summary>
        bool IsTraceEnabled
        {
            get;
        }

        /// <summary>
        /// <para>Checks if this logger is enabled for the Info level.</para>
        /// <para>The property should be true if this logger is enabled for Info events, false otherwise.</para> 
        /// <para>This property is intended to lessen the computational cost of disabled log Info statements. Note 
        /// that even if the property is false, Info log lines may be received anyway by the Info methods.</para>
        /// </summary>
        bool IsInfoEnabled
        {
            get;
        }

        /// <summary>
        /// <para>Checks if this logger is enabled for the Warn level.</para>
        /// <para>The property should be true if this logger is enabled for Warn events, false otherwise.</para> 
        /// <para>This property is intended to lessen the computational cost of disabled log Warn statements. Note 
        /// that even if the property is false, Warn log lines may be received anyway by the Warn methods.</para>
        /// </summary>
        bool IsWarnEnabled
        {
            get;
        }

        /// <summary>
        /// <para>Checks if this logger is enabled for the Error level.</para>
        /// <para>The property should be true if this logger is enabled for Error events, false otherwise.</para> 
        /// <para>This property is intended to lessen the computational cost of disabled log Error statements. Note 
        /// that even if the property is false, Error log lines may be received anyway by the Error methods.</para>
        /// </summary>
        bool IsErrorEnabled
        {
            get;
        }

        /// <summary>
        /// <para>Checks if this logger is enabled for the Fatal level.</para>
        /// <para>The property should be true if this logger is enabled for Fatal events, false otherwise.</para> 
        /// <para>This property is intended to lessen the computational cost of disabled log Fatal statements. Note 
        /// that even if the property is false, Fatal log lines may be received anyway by the Fatal methods.</para>
        /// </summary>
        bool IsFatalEnabled
        {
            get;
        }
    }
}
