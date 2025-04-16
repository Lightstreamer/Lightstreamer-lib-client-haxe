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

export default /*@__PURE__*/(function() {  
  /**
   * @private
   */
  var LightstreamerConstants = {

    // connecting to the server
    CONNECTING: "CONNECTING",
    // connected prefix
    CONNECTED: "CONNECTED:",
    // create_session response received, trying to setup a streaming connection
    SENSE: "STREAM-SENSING",
    // receiving pushed data
    WS_STREAMING: "WS-STREAMING",
    HTTP_STREAMING: "HTTP-STREAMING",
    // connected but doesn't receive data
    STALLED: "STALLED",
    // polling for data
    WS_POLLING: "WS-POLLING",
    HTTP_POLLING: "HTTP-POLLING",
    // disconnected
    DISCONNECTED: "DISCONNECTED",
    WILL_RETRY: "DISCONNECTED:WILL-RETRY",
    TRYING_RECOVERY: "DISCONNECTED:TRYING-RECOVERY",

    WS_ALL: "WS",
    HTTP_ALL: "HTTP",
    
    RAW: "RAW",
    DISTINCT: "DISTINCT",
    COMMAND: "COMMAND",
    MERGE: "MERGE"
    
  };
    
  return LightstreamerConstants;
})();
  
