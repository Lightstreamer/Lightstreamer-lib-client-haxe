  /**
	 * Creates an object to be used to describe an MPN device that is going to be registered to the MPN Module of Lightstreamer Server.<BR>
     * During creation the MpnDevice tries to acquires any previously registered device token from localStorage.
     * It then saves the current device token on localStorage. Saving and retrieving the previous device token is used to handle automatically
     * the cases where the token changes. The MPN Module of Lightstreamer Server is able to move
     * MPN subscriptions associated with the previous token to the new one.
     *
     * @constructor
     * @param {String} token the device token
     * @param {String} appId the application identifier
     * @param {String} platform either "Google" for Google's Firebase Cloud Messaging (FCM) or "Apple" for Apple Push Notification Service (APNs)
     *
     * @throws IllegalArgumentException if <code>token</code> or <code>appId</code> is null or <code>platform</code> is not "Google" or "Apple".
     *
	 * @exports MpnDevice
	 *
	 * @class Class representing a device that supports Web Push Notifications.<BR>
	 * It contains device details and the listener needed to monitor its status.<BR>
	 * An MPN device is created from the application identifier, the platform and a device token (a.k.a. registration token) obtained from
	 * web push notifications APIs, and must be registered on the {@link LightstreamerClient} in order to successfully subscribe an MPN subscription.
	 * See {@link MpnSubscription}.<BR>
	 * After creation, an MpnDevice object is in "unknown" state. It must then be passed to the Lightstreamer Server with the
	 * {@link LightstreamerClient#registerForMpn} method, which enables the client to subscribe MPN subscriptions and sends the device details to the
	 * server's MPN Module, where it is assigned a permanent device ID and its state is switched to "registered".<BR>
	 * Upon registration on the server, active MPN subscriptions of the device are received and exposed with the {@link LightstreamerClient#getMpnSubscriptions}
	 * method.<BR>
	 * An MpnDevice's state may become "suspended" if errors occur during push notification delivery. In this case MPN subscriptions stop sending notifications
	 * and the device state is reset to "registered" at the first subsequent registration.
	 */
var MpnDevice = function(deviceToken, appId, platform) {
  this.delegate = new LSMpnDevice(deviceToken, appId, platform);
};

MpnDevice.prototype = {

      /**
       * Adds a listener that will receive events from the MpnDevice
       * instance.
       * <BR>The same listener can be added to several different MpnDevice
       * instances.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> a listener can be added at any time.</p>
       *
       * @param {MpnDeviceListener} listener An object that will receive the events
       * as shown in the {@link MpnDeviceListener} interface.
       * <BR>Note that the given instance does not have to implement all of the
       * methods of the MpnDeviceListener interface. In fact it may also
       * implement none of the interface methods and still be considered a valid
       * listener. In the latter case it will obviously receive no events.
       */
      addListener: function(listener) {
        this.delegate.addListener(listener);
      },

      /**
       * Removes a listener from the MpnDevice instance so that it
       * will not receive events anymore.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> a listener can be removed at any time.</p>
       *
       * @param {MpnDeviceListener} listener The listener to be removed.
       */
      removeListener: function(listener) {
        this.delegate.removeListener(listener);
      },

      /**
       * Returns an array containing the {@link MpnDeviceListener} instances that
       * were added to this client.
       *
       * @return {MpnDeviceListener[]} an Array containing the listeners that were added to this client.
       * Listeners added multiple times are included multiple times in the array.
       */
      getListeners: function() {
        return this.delegate.getListeners();
      },

      /**
       * The platform identifier of this MPN device. It equals <code>Google</code> or <code>Apple</code> and is used by the server as part of the device identification.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {String} the MPN device platform.
       */
      getPlatform: function() {
        return this.delegate.getPlatform();
      },

      /**
       * The application ID of this MPN device. It is used by the server as part of the device identification.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {String} the MPN device application ID.
       */
      getApplicationId: function() {
        return this.delegate.getApplicationId();
      },

      /**
       * The device token of this MPN device. It is passed during creation and
       * is used by the server as part of the device identification.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {String} the MPN device token.
       */
      getDeviceToken: function() {
        return this.delegate.getDeviceToken();
      },

      /**
       * The previous device token of this MPN device. It is obtained automatically from
       * localStorage during creation and is used by the server to restore MPN subscriptions associated with this previous token. May be null if
       * no MPN device has been registered yet on the application.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {String} the previous MPN device token, or null if no MPN device has been registered yet.
       */
      getPreviousDeviceToken: function() {
        return this.delegate.getPreviousDeviceToken();
      },

      /**
       * Checks whether the MPN device object is currently registered on the server or not.<BR>
       * This flag is switched to true by server sent registration events, and back to false in case of client disconnection or server sent suspension events.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {boolean} true if the MPN device object is currently registered on the server.
       *
       * @see #getStatus
       */
      isRegistered: function() {
        return this.delegate.isRegistered();
      },

      /**
       * Checks whether the MPN device object is currently suspended on the server or not.<BR>
       * An MPN device may be suspended if errors occur during push notification delivery.<BR>
       * This flag is switched to true by server sent suspension events, and back to false in case of client disconnection or server sent resume events.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {boolean} true if the MPN device object is currently suspended on the server.
       *
       * @see #getStatus
       */
      isSuspended: function() {
        return this.delegate.isSuspended();
      },

      /**
       * The status of the device.<BR>
       * The status can be:<ul>
       * <li><code>UNKNOWN</code>: when the MPN device object has just been created or deleted. In this status {@link MpnDevice#isRegistered} and {@link MpnDevice#isSuspended} are both false.</li>
       * <li><code>REGISTERED</code>: when the MPN device object has been successfully registered on the server. In this status {@link MpnDevice#isRegistered} is true and
       * {@link MpnDevice#isSuspended} is false.</li>
       * <li><code>SUSPENDED</code>: when a server error occurred while sending push notifications to this MPN device and consequently it has been suspended. In this status
       * {@link MpnDevice#isRegistered} and {@link MpnDevice#isSuspended} are both true.</li>
       * </ul>
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {String} the status of the device.
       *
       * @see #isRegistered
       * @see #isSuspended
       */
      getStatus: function() {
        return this.delegate.getStatus();
      },

      /**
       * The server-side timestamp of the device status.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {Number} The server-side timestamp of the device status.
       *
       * @see #getStatus
       */
      getStatusTimestamp: function() {
        return this.delegate.getStatusTimestamp();
      },

      /**
       * The server-side unique persistent ID of the device.<BR>
       * The ID is available only after the MPN device object has been successfully registered on the server. I.e. when its status is <code>REGISTERED</code> or
       * <code>SUSPENDED</code>.<BR>
       * Note: a device token change, if the previous device token was correctly stored on localStorage, does not cause the device ID to change: the
       * server moves previous MPN subscriptions from the previous token to the new one and the device ID remains unaltered.
       *
       * <p class="lifecycle"><b>Lifecycle:</b> This method can be called at any time.</p>
       *
       * @return {String} the MPN device ID.
       */
      getDeviceId: function() {
        return this.delegate.getDeviceId();
      }
};
