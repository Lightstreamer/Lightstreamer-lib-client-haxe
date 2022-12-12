namespace com.lightstreamer.log
{
    /// <summary>
    /// <para>Simple interface to be implemented to provide custom log consumers to the library.</para>
    /// <para>An instance of the custom implemented class has to be passed to the library through the 
    /// Server.SetLoggerProvider method.</para>
    /// <remarks>
    ///     <para>Exceptions thrown to the caller are not logged.</para>
    ///     <para>Exceptions asynchronously notified to the client are logged at ERROR level.</para>
    ///     <para>All tracing is done at INFO and DEBUG levels.</para>
    ///     <para>Full exception stack traces are logged at DEBUG level.</para>
    /// </remarks>
    /// </summary>
    public interface ILoggerProvider
    {
        /// <summary>
        /// <para>Request for an ILogger instance that will be used for logging occuring on the given 
        /// category. It is suggested, but not mandatory, that subsequent calls to this method
        /// related to the same category return the same ILogger instance.</para>
        /// </summary>
        /// <param name="category"><para>the log category all messages passed to the given ILogger instance will pertain to.
        /// The following categories are used by the library:</para>
        ///     <para></para><para>Lightstreamer.DotNet.Server:</para>
        ///         <para>Loggers for Lightstreamer .NET Remote Server and Remote Adapter Library.</para>
        ///     
        ///     <para></para><para>Lightstreamer.DotNet.Server.ServerMain:</para>
        ///         <para>At INFO level, Remote Server startup is logged;</para>
        ///         <para>At DEBUG level, command line argument recognition is logged.</para>
        ///     
        ///     <para></para><para>Lightstreamer.DotNet.Server.NetworkedServerStarter:</para> 
        ///         <para>At INFO level, Connection status is logged.</para>
        ///     
        ///     <para></para><para>Lightstreamer.DotNet.Server.MetadataProviderServer:</para>
        ///         <para>At INFO level, processing options are logged.</para>
        ///         <para>At DEBUG level, processing of requests for the Metadata Adapter is logged.</para>
        ///     
        ///     <para></para><para>Lightstreamer.DotNet.Server.DataProviderServer:</para>
        ///         <para>At INFO level, processing options are logged.</para>
        ///         <para>At DEBUG level, processing of requests for the Data Adapter is logged.</para>
        ///     
        ///     <para></para><para>Lightstreamer.DotNet.Server.RequestReply:</para>
        ///         <para>At INFO level, Connection details are logged;</para>
        ///         <para>At DEBUG level, request, reply and notify lines are logged.</para>
        ///     
        ///     <para></para><para>Lightstreamer.DotNet.Server.RequestReply.Replies.Keepalives:</para>
        ///         <para>At DEBUG level, the keepalives on request/reply streams are logged, so that they can be inhibited.</para>
        ///     
        ///     <para></para><para>Lightstreamer.DotNet.Server.RequestReply.Notifications:</para>
        ///         <para>At DEBUG level, the notify lines are logged, so that they can be inhibited.</para>
        ///     
        ///     <para></para><para>Lightstreamer.DotNet.Server.RequestReply.Notifications.Keepalives:</para>
        ///         <para>At DEBUG level, the keepalives on notification streams are logged, so that they can be inhibited.</para>
        /// <para>See also the provided <exref target= "./app.config">sample configuration file</exref>.</para>
        ///     
        /// </param>
        /// <returns>
        /// An ILogger instance that will receive log lines related to the given category.
        /// </returns>
        ILogger GetLogger(string category);
    }
}
