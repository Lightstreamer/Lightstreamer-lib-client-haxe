# Copyright (C) 2023 Lightstreamer Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
from lightstreamer.client import *
import sys, logging, time

logging.basicConfig(level=logging.DEBUG, format="%(message)s", stream=sys.stdout)

loggerProvider = ConsoleLoggerProvider(ConsoleLogLevel.INFO)
LightstreamerClient.setLoggerProvider(loggerProvider)

sub = Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
sub.setDataAdapter("QUOTE_ADAPTER")
sub.setRequestedSnapshot("yes")

class SubListener(SubscriptionListener):
  def onItemUpdate(self, update):
    print("UPDATE " + update.getValue("stock_name") + " " + update.getValue("last_price"))

sub.addListener(SubListener())

client = LightstreamerClient("http://push.lightstreamer.com","DEMO")
client.subscribe(sub)
client.connect()

time.sleep(3)

client.disconnect()