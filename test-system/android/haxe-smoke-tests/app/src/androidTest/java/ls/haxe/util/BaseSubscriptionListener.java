package ls.haxe.util;

import com.lightstreamer.client.ItemUpdate;
import com.lightstreamer.client.SubscriptionListener;

public class BaseSubscriptionListener implements SubscriptionListener {

    public BaseSubscriptionListener() {
    }

    @Override
    public void onClearSnapshot(String arg0, int arg1) {
    }

    @Override
    public void onCommandSecondLevelItemLostUpdates(int arg0, String arg1) {
    }

    @Override
    public void onCommandSecondLevelSubscriptionError(int arg0, String arg1, String arg2) {
    }

    @Override
    public void onEndOfSnapshot(String arg0, int arg1) {
    }

    @Override
    public void onItemLostUpdates(String arg0, int arg1, int arg2) {
    }

    @Override
    public void onItemUpdate(ItemUpdate arg0) {
    }

    @Override
    public void onListenEnd() {
    }

    @Override
    public void onListenStart() {
    }

    @Override
    public void onRealMaxFrequency(String arg0) {
    }

    @Override
    public void onSubscription() {
    }

    @Override
    public void onSubscriptionError(int arg0, String arg1) {
    }

    @Override
    public void onUnsubscription() {
    }
}
