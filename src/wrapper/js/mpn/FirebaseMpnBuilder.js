    /**
     * Creates an object to be used to create a push notification format.<BR>
     * Use setters methods to set the value of push notification fields or use a JSON structure to initialize the fields.
     *
     * @constructor
     * @exports FirebaseMpnBuilder
     *
     * @param [notificationFormat] A JSON structure representing a push notification format.
     *
     * @class Utility class that provides methods to build or parse the JSON structure used to represent the format of a push notification.<BR>
     * It provides getters and setters for the fields of a push notification, following the format specified by Google's Firebase Cloud Messaging (FCM).
     * This format is compatible with {@link MpnSubscription#setNotificationFormat}.
     *
     * @see MpnSubscription#setNotificationFormat
     */
var FirebaseMpnBuilder = function(notificationFormat) {
  this.delegate = new LSFirebaseMpnBuilder(notificationFormat);
};

FirebaseMpnBuilder.prototype = {

      /**
       * Produces the JSON structure for the push notification format specified by this object.
       * @return {String} the JSON structure for the push notification format.
       */
      build: function() {
        return this.delegate.build();
      },

      /**
       * Gets sub-fields of the <code>webpush&period;headers</code> field.
       * @return {Object} a map with sub-fields of the <code>webpush&period;headers</code> field, or null if absent.
       */
      getHeaders: function() {
        return this.delegate.getHeaders();
      },

      /**
       * Sets sub-fields of the <code>webpush&period;headers</code> field.
       *
       * @param {Object} headers map to be used for sub-fields of the <code>webpush&period;headers</code> field, or null to clear it.
       * @return {FirebaseMpnBuilder} this MpnBuilder object, for fluent use.
       */
      setHeaders: function(headers) {
        this.delegate.setHeaders(headers);
        return this;
      },

      /**
       * Gets the value of <code>webpush&period;notification&period;title</code> field.
       * @return {String} the value of <code>webpush&period;notification&period;title</code> field, or null if absent.
       */
      getTitle: function() {
        return this.delegate.getTitle();
      },

      /**
       * Sets the <code>webpush&period;notification&period;title</code> field.
       *
       * @param {String} title A string to be used for the <code>webpush&period;notification&period;title</code> field value, or null to clear it.
       * @return {FirebaseMpnBuilder} this MpnBuilder object, for fluent use.
       */
      setTitle: function(title) {
        this.delegate.setTitle(title);
        return this;
      },

      /**
       * Gets the value of <code>webpush&period;notification&period;body</code> field.
       * @return {String} the value of <code>webpush&period;notification&period;body</code> field, or null if absent.
       */
      getBody: function() {
        return this.delegate.getBody();
      },

      /**
       * Sets the <code>webpush&period;notification&period;body</code> field.
       *
       * @param {String} body A string to be used for the <code>webpush&period;notification&period;body</code> field value, or null to clear it.
       * @return {FirebaseMpnBuilder} this MpnBuilder object, for fluent use.
       */
      setBody: function(body) {
        this.delegate.setBody(body);
        return this;
      },

      /**
       * Gets the value of <code>webpush&period;notification&period;icon</code> field.
       * @return {String} the value of <code>webpush&period;notification&period;icon</code> field, or null if absent.
       */
      getIcon: function() {
        return this.delegate.getIcon();
      },

      /**
       * Sets the <code>webpush&period;notification&period;icon</code> field.
       *
       * @param {String} icon A string to be used for the <code>webpush&period;notification&period;icon</code> field value, or null to clear it.
       * @return {FirebaseMpnBuilder} this MpnBuilder object, for fluent use.
       */
      setIcon: function(icon) {
        this.delegate.setIcon(icon);
        return this;
      },

      /**
       * Gets sub-fields of the <code>webpush&period;data</code> field.
       * @return {Object} a map with sub-fields of the <code>webpush&period;data</code> field, or null if absent.
       */
      getData: function() {
        return this.delegate.getData();
      },

      /**
       * Sets sub-fields of the <code>webpush&period;data</code> field.
       *
       * @param {Object} data A map to be used for sub-fields of the <code>webpush&period;data</code> field, or null to clear it.
       * @return {FirebaseMpnBuilder} this MpnBuilder object, for fluent use.
       */
      setData: function(data) {
        this.delegate.setData(data);
        return this;
      }
};
