using System;

namespace com.lightstreamer.log
{
    /// <summary>
    /// <para>Interface to be implemented to consume log from the library.</para>
    /// <para>Instances of implemented classes are obtained by the library through the ILoggerProvider instance set on Server.SetLoggerProvider.</para>
    /// </summary>
    public interface ILogger
    {

        /// <summary>
        /// <para>Receives log messages at Error level.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        void Error(string line);

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
        /// <para>Receives log messages at Warn level.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        void Warn(string line);

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
        /// <para>Receives log messages at Info level.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        void Info(string line);

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
        /// <para>Receives log messages at Debug level.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        void Debug(string line);

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
        /// <para>Receives log messages at Fatal level.</para>
        /// </summary>
        /// <param name="line">
        /// The message to be logged.
        /// </param>
        void Fatal(string line);

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
