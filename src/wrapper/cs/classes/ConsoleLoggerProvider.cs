/*
 * Copyright (c) 2004-2019 Lightstreamer s.r.l., Via Campanini, 6 - 20124 Milano, Italy.
 * All rights reserved.
 * www.lightstreamer.com
 *
 * This software is the confidential and proprietary information of
 * Lightstreamer s.r.l.
 * You shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the license agreement you entered
 * into with Lightstreamer s.r.l.
 */
namespace com.lightstreamer.log
{
  /// <summary>
  /// Simple concrete logging provider that logs on the system console.
  ///
  /// To be used, an instance of this class has to be passed to the library through the <seealso cref="com.lightstreamer.client.LightstreamerClient.setLoggerProvider(ILoggerProvider)"/>.
  /// </summary>
  public class ConsoleLoggerProvider: ILoggerProvider {
    readonly LSConsoleLoggerProvider _delegate;

    /// <summary>
    /// Creates an instace of the concrete system console logger.</summary>
    ///
    /// <param name="level"> The desired logging level. See <seealso cref="ConsoleLogLevel"/>.</param>
    public ConsoleLoggerProvider(int level) {
        this._delegate = new LSConsoleLoggerProvider(level);
    }

    public ILogger GetLogger(string category) {
        return _delegate.GetLogger(category);
    }
  }
}