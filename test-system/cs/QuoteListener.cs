using System;
using com.lightstreamer.client;

namespace myapp
{
    class QuoteListener : SubscriptionListener
    {
        void SubscriptionListener.onClearSnapshot(string itemName, int itemPos)
        {
            Console.WriteLine("Clear Snapshot for " + itemName + ".");
        }

        void SubscriptionListener.onCommandSecondLevelItemLostUpdates(int lostUpdates, string key)
        {
            Console.WriteLine("Lost Updates for " + key + " (" + lostUpdates + ").");
        }

        void SubscriptionListener.onCommandSecondLevelSubscriptionError(int code, string message, string key)
        {
            Console.WriteLine("Subscription Error for " + key + ": " + message);
        }

        void SubscriptionListener.onEndOfSnapshot(string itemName, int itemPos)
        {
            Console.WriteLine("End of Snapshot for " + itemName + ".");
        }

        void SubscriptionListener.onItemLostUpdates(string itemName, int itemPos, int lostUpdates)
        {
            Console.WriteLine("Lost Updates for " + itemName + " (" + lostUpdates + ").");
        }

        void SubscriptionListener.onItemUpdate(ItemUpdate itemUpdate)
        {
            //Console.WriteLine("New update for " + itemUpdate.ItemName);

            //IDictionary<string, string> listc = itemUpdate.ChangedFields;
            //foreach (string value in listc.Values)
            //{
            //    Console.WriteLine(" >>>>>>>>>>>>> " + value);
            //}
        }

        void SubscriptionListener.onListenEnd(Subscription subscription)
        {
            // throw new System.NotImplementedException();
        }

        void SubscriptionListener.onListenStart(Subscription subscription)
        {
            // throw new System.NotImplementedException();
        }

        void SubscriptionListener.onRealMaxFrequency(string frequency)
        {
            Console.WriteLine("Real frequency: " + frequency + ".");
        }

        void SubscriptionListener.onSubscription()
        {
            Console.WriteLine("Start subscription.");
        }

        void SubscriptionListener.onSubscriptionError(int code, string message)
        {
            Console.WriteLine("Subscription error: " + message);
        }

        void SubscriptionListener.onUnsubscription()
        {
            Console.WriteLine("Stop subscription.");
        }

    }
}
