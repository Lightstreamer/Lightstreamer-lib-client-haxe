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
 * Simple interface to be implemented to provide custom log consumers to the library. <BR>
 * An instance of the custom implemented class has to be passed to the library through the 
 * {@link com.lightstreamer.client.LightstreamerClient#setLoggerProvider}.
 */
public interface LoggerProvider {
    /** 
     * Request for a Logger instance that will be used for logging occurring on the given 
     * category. It is suggested, but not mandatory, that subsequent calls to this method
     * related to the same category return the same Logger instance.
     * 
     * @param category the log category all messages passed to the given Logger instance will pertain to.
     * 
     * @return A Logger instance that will receive log lines related to the given category.
     * 
     */
    @Nonnull
    Logger getLogger(@Nonnull String category);
}