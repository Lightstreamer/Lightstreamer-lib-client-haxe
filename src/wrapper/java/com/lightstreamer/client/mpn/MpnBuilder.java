package com.lightstreamer.client.mpn;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nonnull;

/**
 * Utility class that provides methods to build or parse the JSON structure used to represent the format of a push notification.<BR>
 * It provides getters and setters for the fields of a push notification, following the format specified by Google's Firebase Cloud Messaging (FCM).
 * This format is compatible with {@link MpnSubscription#setNotificationFormat(String)}.
 * 
 * @see MpnSubscription#setNotificationFormat(String)
 */
public class MpnBuilder {
    
    /**
     * Creates an empty object to be used to create a push notification format from scratch.<BR>
     * Use setters methods to set the value of push notification fields.
     */
    public MpnBuilder() {

    }
    
    /**
     * Creates an object based on the specified push notification format.<BR>
     * Use getter methods to obtain the value of push notification fields.
     * 
     * @param notificationFormat A JSON structure representing a push notification format.
     * 
     * @throws IllegalArgumentException if the notification is not a valid JSON structure.
     */
    @SuppressWarnings("unchecked") 
    public MpnBuilder(@Nonnull String notificationFormat) {

    }

    /**
     * Produces the JSON structure for the push notification format specified by this object.
     * @return the JSON structure for the push notification format.
     */
    public @Nonnull String build() {

    }

    /**
     * Sets the <code>android.collapse_key</code> field.
     * 
     * @param collapseKey A string to be used for the <code>android.collapse_key</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder collapseKey(String collapseKey) {

    }
    
    /**
     * Gets the value of <code>android.collapse_key</code> field.
     * @return the value of <code>android.collapse_key</code> field, or null if absent.
     */
    public String collapseKey() {

    }
    
    /**
     * Sets the <code>android.priority</code> field.
     * 
     * @param priority A string to be used for the <code>android.priority</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder priority(String priority) {

    }
    
    /**
     * Gets the value of <code>android.priority</code> field.
     * @return the value of <code>android.priority</code> field, or null if absent.
     */
    public String priority() {

    }
    
    /**
     * @deprecated
     * The <code>content_available</code> is no more supported on Firebase Cloud Messaging.
     * 
     * @param contentAvailable Ignored.
     * @return this MpnBuilder object, for fluent use.
     */
    @Deprecated
    public MpnBuilder contentAvailable(String contentAvailable) {

    }
    
    /**
     * @deprecated
     * The <code>content_available</code> is no more supported on Firebase Cloud Messaging.
     * 
     * @return always null.
     */
    @Deprecated
    public String contentAvailableAsString() {

    }
            
    /**
     * @deprecated
     * The <code>content_available</code> is no more supported on Firebase Cloud Messaging.
     * 
     * @param contentAvailable Ignored.
     * @return this MpnBuilder object, for fluent use.
     */
    @Deprecated
    public MpnBuilder contentAvailable(Boolean contentAvailable) {

    }
    
    /**
     * @deprecated
     * The <code>content_available</code> is no more supported on Firebase Cloud Messaging.
     * 
     * @return always null.
     */
    @Deprecated
    public Boolean contentAvailableAsBoolean() {

    }

    /**
     * Sets the <code>android.ttl</code> field with a string value.
     * 
     * @param timeToLive A string to be used for the <code>android.ttl</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder timeToLive(String timeToLive) {

    }
    
    /**
     * Gets the value of <code>android.ttl</code> field as a string.
     * @return a string with the value of <code>android.ttl</code> field, or null if absent.
     */
    public String timeToLiveAsString() {

    }
            
    /**
     * Sets the <code>android.ttl</code> field with an integer value.
     * 
     * @param timeToLive An integer to be used for the <code>android.ttl</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder timeToLive(Integer timeToLive) {

    }
    
    /**
     * Gets the value of <code>android.ttl</code> field as an integer.
     * @return an integer with the value of <code>android.ttl</code> field, or null if absent.
     */
    public Integer timeToLiveAsInteger() {

    }
    
    /**
     * Sets the <code>android.notification.title</code> field.
     * 
     * @param title A string to be used for the <code>android.notification.title</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder title(String title) {        

    }
    
    /**
     * Gets the value of <code>android.notification.title</code> field.
     * @return the value of <code>android.notification.title</code> field, or null if absent.
     */
    public String title() {

    }

    /**
     * Sets the <code>android.notification.title_loc_key</code> field.
     * 
     * @param titleLocKey A string to be used for the <code>android.notification.title_loc_key</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder titleLocKey(String titleLocKey) {        

    }
    
    /**
     * Gets the value of <code>android.notification.title_loc_key</code> field.
     * @return the value of <code>android.notification.title_loc_key</code> field, or null if absent.
     */
    public String titleLocKey() {

    }

    /**
     * Sets the <code>android.notification.title_loc_args</code> field.
     * 
     * @param titleLocArguments A list of strings to be used for the <code>android.notification.title_loc_args</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder titleLocArguments(List<String> titleLocArguments) {        

    }
    
    /**
     * Gets the value of <code>android.notification.title_loc_args</code> field.
     * @return a list of strings with the value of <code>android.notification.title_loc_args</code> field, or null if absent.
     */
    public List<String> titleLocArguments() {

    }

    /**
     * Sets the <code>android.notification.body</code> field.
     * 
     * @param body A string to be used for the <code>android.notification.body</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder body(String body) {        

    }
    
    /**
     * Gets the value of <code>android.notification.body</code> field.
     * @return the value of <code>android.notification.body</code> field, or null if absent.
     */
    public String body() {

    }

    /**
     * Sets the <code>android.notification.body_loc_key</code> field.
     * 
     * @param bodyLocKey A string to be used for the <code>android.notification.body_loc_key</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder bodyLocKey(String bodyLocKey) {        

    }
    
    /**
     * Gets the value of <code>android.notification.body_loc_key</code> field.
     * @return the value of <code>android.notification.body_loc_key</code> field, or null if absent.
     */
    public String bodyLocKey() {

    }

    /**
     * Sets the <code>android.notification.body_loc_args</code> field.
     * 
     * @param bodyLocArguments A list of strings to be used for the <code>android.notification.body_loc_args</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder bodyLocArguments(List<String> bodyLocArguments) {        

    }
    
    /**
     * Gets the value of <code>android.notification.body_loc_args</code> field.
     * @return a list of strings with the value of <code>android.notification.body_loc_args</code> field, or null if absent.
     */
    public List<String> bodyLocArguments() {

    }
    
    /**
     * Sets the <code>android.notification.icon</code> field.
     * 
     * @param icon A string to be used for the <code>android.notification.icon</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder icon(String icon) {        

    }
    
    /**
     * Gets the value of <code>android.notification.icon</code> field.
     * @return the value of <code>android.notification.icon</code> field, or null if absent.
     */
    public String icon() {

    }

    /**
     * Sets the <code>android.notification.sound</code> field.
     * 
     * @param sound A string to be used for the <code>android.notification.sound</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder sound(String sound) {        

    }
    
    /**
     * Gets the value of <code>android.notification.sound</code> field.
     * @return the value of <code>android.notification.sound</code> field, or null if absent.
     */
    public String sound() {

    }
    
    /**
     * Sets the <code>android.notification.tag</code> field.
     * 
     * @param tag A string to be used for the <code>android.notification.tag</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder tag(String tag) {        

    }
    
    /**
     * Gets the value of <code>android.notification.tag</code> field.
     * @return the value of <code>android.notification.tag</code> field, or null if absent.
     */
    public String tag() {

    }
    
    /**
     * Sets the <code>android.notification.color</code> field.
     * 
     * @param color A string to be used for the <code>android.notification.color</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder color(String color) {        

    }
    
    /**
     * Gets the value of <code>android.notification.color</code> field.
     * @return the value of <code>android.notification.color</code> field, or null if absent.
     */
    public String color() {

    }
    
    /**
     * Sets the <code>android.notification.click_action</code> field.
     * 
     * @param clickAction A string to be used for the <code>android.notification.click_action</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder clickAction(String clickAction) {        

    }
    
    /**
     * Gets the value of <code>android.notification.click_action</code> field.
     * @return the value of <code>android.notification.click_action</code> field, or null if absent.
     */
    public String clickAction() {

    }
     
    /**
     * Sets sub-fields of the <code>android.data</code> field.
     * 
     * @param data A map to be used for sub-fields of the <code>android.data</code> field, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder data(Map<String, String> data) {        

    }
    
    /**
     * Gets sub-fields of the <code>android.data</code> field.
     * @return A map with sub-fields of the <code>android.data</code> field, or null if absent. 
     */
    public Map<String, String> data() {

    }
}
