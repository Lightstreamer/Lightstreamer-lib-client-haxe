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
package com.lightstreamer.internal.impl.colyseus;

import sys.net.Host;
import haxe.net.impl.SocketSys;

class LsSocket extends SocketSys {
  
  // adapted from SocketSys.initialize
  override public function initialize(secure:Bool) {
    this.secure = secure;
    var impl:Dynamic = null;
    if (secure) {
        #if (haxe_ver >= "3.3")
    #if python
                this.impl = new python.net.SslSocket();
    #else
      // BEGIN PATCH
      // this.impl = new sys.ssl.Socket();

      var ctx = com.lightstreamer.internal.Globals.instance.getTrustManagerFactory();
      this.impl = ctx.createSocket();
      // END PATCH
    #end
        #else
            throw 'Not supporting secure sockets';
        #end
    } else {
        this.impl = new sys.net.Socket();
    }
    try {
        this.impl.connect(new Host(host), port);
        //this.impl.setFastSend(true);
        this.impl.setBlocking(false);
        //this.impl.setBlocking(true);
        this.sendConnect = true;
        if (debug) trace('socket.connected!');
    } catch (e:Dynamic) {
        this.sendError = true;
        if (debug) trace('socket.error! $e');
    }

    return this;
  }
}