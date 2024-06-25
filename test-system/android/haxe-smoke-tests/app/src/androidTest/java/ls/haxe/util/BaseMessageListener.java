package ls.haxe.util;

import com.lightstreamer.client.ClientMessageListener;

public class BaseMessageListener implements ClientMessageListener {

    public BaseMessageListener() {
    }

    @Override
    public void onAbort(String arg0, boolean arg1) {
    }

    @Override
    public void onDeny(String arg0, int arg1, String arg2) {
    }

    @Override
    public void onDiscarded(String arg0) {
    }

    @Override
    public void onError(String arg0) {
    }

    @Override
    public void onProcessed(String arg0, String arg1) {
    }
}
