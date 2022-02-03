<?php

set_include_path(get_include_path().PATH_SEPARATOR.__DIR__.'/../../bin/php/lib');
spl_autoload_register(
  function($class){
    $file = stream_resolve_include_path(str_replace('\\', '/', $class) .'.php');
    if ($file) {
      include_once $file;
    }
  }
);

use com\lightstreamer\client\{Subscription, LightstreamerClient, SubscriptionListener, ClientListener};
use com\lightstreamer\log\{ConsoleLoggerProvider, ConsoleLogLevel};

class QuoteListener implements SubscriptionListener {
  public function onClearSnapshot($itemName, $itemPos) {}
  public function onCommandSecondLevelItemLostUpdates($lostUpdates, $key) {}
  public function onCommandSecondLevelSubscriptionError($code, $message, $key) {}
  public function onEndOfSnapshot($itemName, $itemPos) {}
  public function onItemLostUpdates($itemName, $itemPos, $lostUpdates) {}
  public function onItemUpdate($itemUpdate) {}
  public function onListenEnd($subscription){}
  public function onListenStart($aSub) {
    logInfo("SubscriptionListener.onListenStart");
    global $sub;
    assert($sub == $aSub);
  }
  public function onRealMaxFrequency($frequency) {}
  public function onSubscription() {}
  public function onSubscriptionError($code, $message) {}
  public function onUnsubscription() {}
}

class CListener implements ClientListener {
  public function onListenStart($aClient) {
    logInfo("ClientListener.onListenStart");
    global $client;
    assert($client == $aClient);
  }
  public function onListenEnd($client) {}
  public function onServerError($errorCode, $errorMessage) {}
  public function onStatusChange($status) {}
  public function onPropertyChange($property) {}
}

$loggerProvider = new ConsoleLoggerProvider(ConsoleLogLevel::$DEBUG);
$logger = $loggerProvider->getLogger("test");
LightstreamerClient::setLoggerProvider($loggerProvider);

function logInfo($s) {
  global $logger;
  $logger->info($s);
}

$sub = new Subscription('MERGE', ['item1', 'item2', 'item3'], ['stock_name', 'last_price']);
$sub->setDataAdapter('QUOTE_ADAPTER');
$sub->setRequestedSnapshot('yes');
assert($sub->getDataAdapter() == "QUOTE_ADAPTER");
assert($sub->getRequestedSnapshot() == "yes");
assert($sub->getItems() == ["item1","item2","item3"]);
assert($sub->getFields() == ["stock_name","last_price"]);
$sub->addListener(new QuoteListener());

//$client = new LightstreamerClient('http://push.lightstreamer.com','DEMO'); 
$client = new LightstreamerClient('http://localhost:8080', 'DEMO');
$client->addListener(new CListener());

$client->connectionDetails->setUser('foo');
assert($client->connectionDetails->getUser() == 'foo');

$client->connectionOptions->setRetryDelay(2000);
$client->connectionOptions->setHttpExtraHeaders(['Foo' => 'bar']);
assert($client->connectionOptions->getRetryDelay() == 2000);
assert($client->connectionOptions->getHttpExtraHeaders() == ['Foo' => 'bar']);

$client->subscribe($sub);
$client->connect();

\haxe\EntryPoint::run();