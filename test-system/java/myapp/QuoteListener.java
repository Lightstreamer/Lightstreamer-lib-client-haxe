package myapp;

import com.lightstreamer.client.ItemUpdate;
import com.lightstreamer.client.Subscription;
import com.lightstreamer.client.SubscriptionListener;

public class QuoteListener implements SubscriptionListener
{
    public void onClearSnapshot(String itemName, int itemPos)
    {
        System.out.println("Clear Snapshot for " + itemName + ".");
    }

    public void onCommandSecondLevelItemLostUpdates(int lostUpdates, String key)
    {
        System.out.println("Lost Updates for " + key + " (" + lostUpdates + ").");
    }

    public void onCommandSecondLevelSubscriptionError(int code, String message, String key)
    {
        System.out.println("Subscription Error for " + key + ": " + message);
    }

    public void onEndOfSnapshot(String itemName, int itemPos)
    {
        System.out.println("End of Snapshot for " + itemName + ".");
    }

    public void onItemLostUpdates(String itemName, int itemPos, int lostUpdates)
    {
        System.out.println("Lost Updates for " + itemName + " (" + lostUpdates + ").");
    }

    public void onItemUpdate(ItemUpdate itemUpdate)
    {
        //System.out.println("New update for " + itemUpdate.ItemName);

        //IDictionary<String, String> listc = itemUpdate.ChangedFields;
        //foreach (String value in listc.Values)
        //{
        //    System.out.println(" >>>>>>>>>>>>> " + value);
        //}
    }

    public void onListenEnd(Subscription subscription)
    {
        // throw new System.NotImplementedException();
    }

    public void onListenStart(Subscription subscription)
    {
        // throw new System.NotImplementedException();
    }

    public void onRealMaxFrequency(String frequency)
    {
        System.out.println("Real frequency: " + frequency + ".");
    }

    public void onSubscription()
    {
        System.out.println("Start subscription.");
    }

    public void onSubscriptionError(int code, String message)
    {
        System.out.println("Subscription error: " + message);
    }

    public void onUnsubscription()
    {
        System.out.println("Stop subscription.");
    }

}