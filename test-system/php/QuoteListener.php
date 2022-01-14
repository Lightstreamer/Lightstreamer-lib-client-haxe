<?php

use com\lightstreamer\client\SubscriptionListener;

class QuoteListener implements SubscriptionListener
{
    public function onClearSnapshot($itemName, $itemPos)
    {
        echo 'Clear Snapshot for ' . $itemName . '.';
    }

    public function onCommandSecondLevelItemLostUpdates($lostUpdates, $key)
    {
        echo 'Lost Updates for ' . $key . ' (' . $lostUpdates . ').';
    }

    public function onCommandSecondLevelSubscriptionError($code, $message, $key)
    {
        echo 'Subscription Error for ' . $key . ': ' . $message;
    }

    public function onEndOfSnapshot($itemName, $itemPos)
    {
        echo 'End of Snapshot for ' . $itemName . '.';
    }

    public function onItemLostUpdates($itemName, $itemPos, $lostUpdates)
    {
        echo 'Lost Updates for ' . $itemName . ' (' . $lostUpdates . ').';
    }

    public function onItemUpdate($itemUpdate)
    {
        //echo 'New update for ' . itemUpdate.$itemName;

        //IDictionary<String, String> listc = itemUpdate.ChangedFields;
        //foreach (String value in listc.Values)
        //{
        //    echo ' >>>>>>>>>>>>> ' . value;
        //}
    }

    public function onListenEnd($subscription)
    {
        // throw new System.NotImplementedException(;
    }

    public function onListenStart($subscription)
    {
        // throw new System.NotImplementedException(;
    }

    public function onRealMaxFrequency($frequency)
    {
        echo 'Real frequency: ' . $frequency . '.';
    }

    public function onSubscription()
    {
        echo 'Start subscription.';
    }

    public function onSubscriptionError($code, $message)
    {
        echo 'Subscription error: ' . $message;
    }

    public function onUnsubscription()
    {
        echo 'Stop subscription.';
    }

}