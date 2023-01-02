namespace com.lightstreamer.log
{
    /// <summary>
    /// <para>Simple interface to be implemented to provide custom log consumers to the library.</para>
    /// <para>An instance of the custom implemented class has to be passed to the library through the 
    /// LightstreamerClient.setLoggerProvider method.</para>
    /// </summary>
    public interface ILoggerProvider
    {
        /// <summary>
        /// <para>Request for an ILogger instance that will be used for logging occuring on the given 
        /// category. It is suggested, but not mandatory, that subsequent calls to this method
        /// related to the same category return the same ILogger instance.</para>
        /// </summary>
        /// <param name="category">the log category all messages passed to the given ILogger instance will pertain to.
        /// </param>
        /// <returns>
        /// An ILogger instance that will receive log lines related to the given category.
        /// </returns>
        ILogger GetLogger(string category);
    }
}
