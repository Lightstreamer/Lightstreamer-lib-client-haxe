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

include_once 'QuoteListener.php';

use com\lightstreamer\client\LightstreamerClient;
use com\lightstreamer\client\Subscription;
use com\lightstreamer\log\ConsoleLoggerProvider;
use com\lightstreamer\log\ConsoleLogLevel;

LightstreamerClient::setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel::$DEBUG));

$sub = new Subscription('MERGE', ['item1', 'item2', 'item3'], ['stock_name', 'last_price']);
$sub->setDataAdapter('QUOTE_ADAPTER');
$sub->setRequestedSnapshot('yes');
$sub->addListener(new QuoteListener());
//$client = new LightstreamerClient('http://push.lightstreamer.com','DEMO'); 
$client = new LightstreamerClient('http://localhost:8080', 'DEMO');
$client->connect();
$client->connectionDetails->setUser('foo');
$client->connectionOptions->setRetryDelay(2000);

assert($client->connectionDetails->getUser() == 'foo');
assert($client->connectionOptions->getRetryDelay() == 2000);

$headers = ['Foo' => 'bar'];
$client->connectionOptions->setHttpExtraHeaders($headers);
