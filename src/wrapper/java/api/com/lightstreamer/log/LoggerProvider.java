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