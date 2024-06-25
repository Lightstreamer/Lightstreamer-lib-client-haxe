package ls.haxe.util;

import com.lightstreamer.client.ClientListener;

public class BaseClientListener implements ClientListener {

	public BaseClientListener() {
	}

	@Override
	public void onListenEnd() {
	}

	@Override
	public void onListenStart() {
	}

	@Override
	public void onPropertyChange(String arg0) {
	}

	@Override
	public void onServerError(int arg0, String arg1) {
	}

	@Override
	public void onStatusChange(String arg0) {
	}
}
