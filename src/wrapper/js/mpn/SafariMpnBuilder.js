    /**
     * Creates an object to be used to create a push notification format.<BR>
     * Use setters methods to set the value of push notification fields or use a JSON structure to initialize the fields.
     *
     * @constructor
     * @exports SafariMpnBuilder
     * 
     * @param [notificationFormat] A JSON structure representing a push notification format.
     *
     * @class Utility class that provides methods to build or parse the JSON structure used to represent the format of a push notification.<BR>
     * It provides getters and setters for the fields of a push notification, following the format specified by Apple Push Notification Service (APNs).
     * This format is compatible with {@link MpnSubscription#setNotificationFormat}.
     *
     * @see MpnSubscription#setNotificationFormat
     */
var SafariMpnBuilder = function(notificationFormat) {
  this.delegate = new LSSafariMpnBuilder(notificationFormat);
};

SafariMpnBuilder.prototype = {

        /**
         * Produces the JSON structure for the push notification format specified by this object.
         * @return {String} the JSON structure for the push notification format.
         */
        build: function() {
          return this.delegate.build();
        },

        /**
         * Gets the value of <code>aps&period;alert&period;title</code> field.
         * @return {String} the value of <code>aps&period;alert&period;title</code> field, or null if absent.
         */
        getTitle: function() {
          return this.delegate.getTitle();
        },

        /**
         * Sets the <code>aps&period;alert&period;title</code> field.
         *
         * @param {String} title A string to be used for the <code>aps&period;alert&period;title</code> field value, or null to clear it.
         * @return {SafariMpnBuilder} this MpnBuilder object, for fluent use.
         */
        setTitle: function(title) {
          this.delegate.setTitle(title);
          return this;
        },

        /**
         * Gets the value of <code>aps&period;alert&period;body</code> field.
         * @return {String} the value of <code>aps&period;alert&period;body</code> field, or null if absent.
         */
        getBody: function() {
          return this.delegate.getBody();
        },

        /**
         * Sets the <code>aps&period;alert&period;body</code> field.
         *
         * @param {String} body A string to be used for the <code>aps&period;alert&period;body</code> field value, or null to clear it.
         * @return {SafariMpnBuilder} this MpnBuilder object, for fluent use.
         */
        setBody: function(body) {
          this.delegate.setBody(body);
          return this;
        },

        /**
         * Gets the value of <code>aps&period;alert&period;action</code> field.
         * @return {String} the value of <code>aps&period;alert&period;action</code> field, or null if absent.
         */
        getAction: function() {
          return this.delegate.getAction();
        },

        /**
         * Sets the <code>aps&period;alert&period;action</code> field.
         *
         * @param {String} action A string to be used for the <code>aps&period;alert&period;action</code> field value, or null to clear it.
         * @return {SafariMpnBuilder} this MpnBuilder object, for fluent use.
         */
        setAction: function(action) {
          this.delegate.setAction(action);
          return this;
        },

        /**
         * Gets the value of <code>aps&period;url-args</code> field.
         * @return {String[]} the value of <code>aps&period;url-args</code> field, or null if absent.
         */
        getUrlArguments: function() {
          return this.delegate.getUrlArguments();
        },

        /**
         * Sets the <code>aps&period;url-args</code> field.
         *
         * @param {String[]} urlArguments An array to be used for the <code>aps&period;url-args</code> field value, or null to clear it.
         * @return {SafariMpnBuilder} this MpnBuilder object, for fluent use.
         */
        setUrlArguments: function(urlArguments) {
          this.delegate.setUrlArguments(urlArguments);
          return this;
        }
};
