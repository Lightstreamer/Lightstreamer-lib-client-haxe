package ls.haxe.util;

import com.lightstreamer.client.ItemUpdate;
import com.lightstreamer.client.SubscriptionListener;

public class BaseSubscriptionListener implements SubscriptionListener {

    public BaseSubscriptionListener() {
        // TODO Auto-generated constructor stub
    }

    @Override
    public void onClearSnapshot(String arg0, int arg1) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onCommandSecondLevelItemLostUpdates(int arg0, String arg1) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onCommandSecondLevelSubscriptionError(int arg0, String arg1, String arg2) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onEndOfSnapshot(String arg0, int arg1) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onItemLostUpdates(String arg0, int arg1, int arg2) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onItemUpdate(ItemUpdate arg0) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onListenEnd() {
        // TODO Auto-generated method stub

    }

    @Override
    public void onListenStart() {
        // TODO Auto-generated method stub

    }

    @Override
    public void onRealMaxFrequency(String arg0) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onSubscription() {
        // TODO Auto-generated method stub

    }

    @Override
    public void onSubscriptionError(int arg0, String arg1) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onUnsubscription() {
        // TODO Auto-generated method stub

    }

}
