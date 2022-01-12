"use strict";
exports.__esModule = true;
var lightstreamer_client_node_1 = require("lightstreamer-client-node");
var QuoteListener = /** @class */ (function () {
    function QuoteListener() {
    }
    QuoteListener.prototype.onClearSnapshot = function (itemName, itemPos) { };
    QuoteListener.prototype.onCommandSecondLevelItemLostUpdates = function (lostUpdates, key) { };
    QuoteListener.prototype.onCommandSecondLevelSubscriptionError = function (code, message, key) { };
    QuoteListener.prototype.onEndOfSnapshot = function (itemName, itemPos) { };
    QuoteListener.prototype.onItemLostUpdates = function (itemName, itemPos, lostUpdates) { };
    QuoteListener.prototype.onItemUpdate = function (update) {
        console.log(update.getValue("stock_name") + ": " + update.getValue("last_price"));
    };
    QuoteListener.prototype.onListenEnd = function (subscription) { };
    QuoteListener.prototype.onListenStart = function (subscription) { };
    QuoteListener.prototype.onSubscription = function () { };
    QuoteListener.prototype.onSubscriptionError = function (code, message) { };
    QuoteListener.prototype.onUnsubscription = function () { };
    QuoteListener.prototype.onRealMaxFrequency = function (frequency) { };
    return QuoteListener;
}());
var sub = new lightstreamer_client_node_1.Subscription("MERGE", ["item1", "item2", "item3"], ["stock_name", "last_price"]);
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
sub.addListener(new QuoteListener());
var client = new lightstreamer_client_node_1.LightstreamerClient("http://push.lightstreamer.com", "DEMO");
//var client = new LightstreamerClient("http://localhost:8080","DEMO");
client.connect();
client.subscribe(sub);
// setTimeout(function() {
//     client.disconnect();
// }, 5*1000);
