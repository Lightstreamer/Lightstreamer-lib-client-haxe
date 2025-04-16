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
import utest.Runner;
import com.lightstreamer.client.*;
import com.lightstreamer.client.mpn.*;
import com.lightstreamer.internal.*;
import com.lightstreamer.log.ConsoleLoggerProvider;

class TestCore {

  static function buildSuite(runner: Runner) {
    #if python
    Logging.basicConfig({level: Logging.DEBUG, format: "%(message)s", stream: python.lib.Sys.stdout});
    #end
    LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
    runner.addCase(TestClient);
    #if LS_MPN
    runner.addCase(com.lightstreamer.client.mpn.TestMpnClient);
    #end
  }

  public static function main() {
    trace('***** Running lib ${LightstreamerClient.LIB_NAME} ${LightstreamerClient.LIB_VERSION} *****');
    var runner = new Runner();
    buildSuite(runner);
    runner.run();
    #if threads
    runner.await();
    #end
    #if sys
    Sys.exit(runner.numFailures);
    #end
  }
}