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
importScripts('../../node_modules/lightstreamer-client-web/lightstreamer-core.js')

LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.INFO));

var sub = new Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
sub.addListener({
    onItemUpdate: function(obj) {
      console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
    }
});
var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
// var client = new LightstreamerClient("http://localhost:8080","DEMO");
client.connect();
client.subscribe(sub);

setTimeout(function() {
    client.disconnect();
}, 5*1000);

onmessage = function(e) {
  console.log('Worker: Message received from main script');
  const result = e.data[0] * e.data[1];
  if (isNaN(result)) {
    postMessage('Please write two numbers');
  } else {
    const workerResult = 'Result: ' + result;
    console.log('Worker: Posting message back to main script');
    postMessage(workerResult);
  }
}