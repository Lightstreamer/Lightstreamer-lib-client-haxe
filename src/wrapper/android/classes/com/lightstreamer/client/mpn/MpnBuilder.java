package com.lightstreamer.client.mpn;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nonnull;
import com.lightstreamer.client.mpn.LSMpnBuilder;

/**
 * Utility class that provides methods to build or parse the JSON structure used to represent the format of a push notification.<BR>
 * It provides getters and setters for the fields of a push notification, following the format specified by Google's Firebase Cloud Messaging (FCM).
 * This format is compatible with {@link MpnSubscription#setNotificationFormat(String)}.
 * 
 * @see MpnSubscription#setNotificationFormat(String)
 */
public class MpnBuilder {
    final LSMpnBuilder delegate;

    /**
     * Creates an empty object to be used to create a push notification format from scratch.<BR>
     * Use setters methods to set the value of push notification fields.
     */
    public MpnBuilder() {
        this.delegate = new LSMpnBuilder();
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
        this.delegate = new LSMpnBuilder(notificationFormat);
    }

    /**
     * Produces the JSON structure for the push notification format specified by this object.
     * @return the JSON structure for the push notification format.
     */
    public @Nonnull String build() {
        return delegate.build();
    }

    /**
     * Sets the <code>android.collapse_key</code> field.
     * 
     * @param collapseKey A string to be used for the <code>android.collapse_key</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder collapseKey(String collapseKey) {
        delegate.collapseKey(collapseKey);
        return this;
    }
    
    /**
     * Gets the value of <code>android.collapse_key</code> field.
     * @return the value of <code>android.collapse_key</code> field, or null if absent.
     */
    public String collapseKey() {
        return delegate.collapseKey();
    }
    
    /**
     * Sets the <code>android.priority</code> field.
     * 
     * @param priority A string to be used for the <code>android.priority</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder priority(String priority) {
        delegate.priority(priority);
        return this;
    }
    
    /**
     * Gets the value of <code>android.priority</code> field.
     * @return the value of <code>android.priority</code> field, or null if absent.
     */
    public String priority() {
        return delegate.priority();
    }

    /**
     * Sets the <code>android.ttl</code> field with a string value.
     * 
     * @param timeToLive A string to be used for the <code>android.ttl</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder timeToLive(String timeToLive) {
        delegate.timeToLive(timeToLive);
        return this;
    }
    
    /**
     * Gets the value of <code>android.ttl</code> field as a string.
     * @return a string with the value of <code>android.ttl</code> field, or null if absent.
     */
    public String timeToLiveAsString() {
        return delegate.timeToLiveAsString();
    }
            
    /**
     * Sets the <code>android.ttl</code> field with an integer value.
     * 
     * @param timeToLive An integer to be used for the <code>android.ttl</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder timeToLive(Integer timeToLive) {
        delegate.timeToLive(timeToLive);
        return this;
    }
    
    /**
     * Gets the value of <code>android.ttl</code> field as an integer.
     * @return an integer with the value of <code>android.ttl</code> field, or null if absent.
     */
    public Integer timeToLiveAsInteger() {
        return delegate.timeToLiveAsInteger();
    }
    
    /**
     * Sets the <code>android.notification.title</code> field.
     * 
     * @param title A string to be used for the <code>android.notification.title</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder title(String title) {  
        delegate.title(title);      
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.title</code> field.
     * @return the value of <code>android.notification.title</code> field, or null if absent.
     */
    public String title() {
        return delegate.title();
    }

    /**
     * Sets the <code>android.notification.title_loc_key</code> field.
     * 
     * @param titleLocKey A string to be used for the <code>android.notification.title_loc_key</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder titleLocKey(String titleLocKey) {      
        delegate.titleLocKey(titleLocKey);  
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.title_loc_key</code> field.
     * @return the value of <code>android.notification.title_loc_key</code> field, or null if absent.
     */
    public String titleLocKey() {
        return delegate.titleLocKey();
    }

    /**
     * Sets the <code>android.notification.title_loc_args</code> field.
     * 
     * @param titleLocArguments A list of strings to be used for the <code>android.notification.title_loc_args</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder titleLocArguments(List<String> titleLocArguments) {  
        delegate.titleLocArguments(titleLocArguments);      
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.title_loc_args</code> field.
     * @return a list of strings with the value of <code>android.notification.title_loc_args</code> field, or null if absent.
     */
    public List<String> titleLocArguments() {
        return delegate.titleLocArguments();
    }

    /**
     * Sets the <code>android.notification.body</code> field.
     * 
     * @param body A string to be used for the <code>android.notification.body</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder body(String body) {    
        delegate.body(body);    
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.body</code> field.
     * @return the value of <code>android.notification.body</code> field, or null if absent.
     */
    public String body() {
        return delegate.body();
    }

    /**
     * Sets the <code>android.notification.body_loc_key</code> field.
     * 
     * @param bodyLocKey A string to be used for the <code>android.notification.body_loc_key</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder bodyLocKey(String bodyLocKey) {  
        delegate.bodyLocKey(bodyLocKey);      
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.body_loc_key</code> field.
     * @return the value of <code>android.notification.body_loc_key</code> field, or null if absent.
     */
    public String bodyLocKey() {
        return delegate.bodyLocKey();
    }

    /**
     * Sets the <code>android.notification.body_loc_args</code> field.
     * 
     * @param bodyLocArguments A list of strings to be used for the <code>android.notification.body_loc_args</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder bodyLocArguments(List<String> bodyLocArguments) { 
        delegate.bodyLocArguments(bodyLocArguments);       
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.body_loc_args</code> field.
     * @return a list of strings with the value of <code>android.notification.body_loc_args</code> field, or null if absent.
     */
    public List<String> bodyLocArguments() {
        return delegate.bodyLocArguments();
    }
    
    /**
     * Sets the <code>android.notification.icon</code> field.
     * 
     * @param icon A string to be used for the <code>android.notification.icon</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder icon(String icon) {   
        delegate.icon(icon);     
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.icon</code> field.
     * @return the value of <code>android.notification.icon</code> field, or null if absent.
     */
    public String icon() {
        return delegate.icon();
    }

    /**
     * Sets the <code>android.notification.sound</code> field.
     * 
     * @param sound A string to be used for the <code>android.notification.sound</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder sound(String sound) {     
        delegate.sound(sound);   
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.sound</code> field.
     * @return the value of <code>android.notification.sound</code> field, or null if absent.
     */
    public String sound() {
        return delegate.sound();
    }
    
    /**
     * Sets the <code>android.notification.tag</code> field.
     * 
     * @param tag A string to be used for the <code>android.notification.tag</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder tag(String tag) {      
        delegate.tag(tag);  
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.tag</code> field.
     * @return the value of <code>android.notification.tag</code> field, or null if absent.
     */
    public String tag() {
        return delegate.tag();
    }
    
    /**
     * Sets the <code>android.notification.color</code> field.
     * 
     * @param color A string to be used for the <code>android.notification.color</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder color(String color) {  
        delegate.color(color);      
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.color</code> field.
     * @return the value of <code>android.notification.color</code> field, or null if absent.
     */
    public String color() {
        return delegate.color();
    }
    
    /**
     * Sets the <code>android.notification.click_action</code> field.
     * 
     * @param clickAction A string to be used for the <code>android.notification.click_action</code> field value, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder clickAction(String clickAction) {    
        delegate.clickAction(clickAction);    
        return this;
    }
    
    /**
     * Gets the value of <code>android.notification.click_action</code> field.
     * @return the value of <code>android.notification.click_action</code> field, or null if absent.
     */
    public String clickAction() {
        return delegate.clickAction();
    }
     
    /**
     * Sets sub-fields of the <code>android.data</code> field.
     * 
     * @param data A map to be used for sub-fields of the <code>android.data</code> field, or null to clear it.
     * @return this MpnBuilder object, for fluent use.
     */
    public MpnBuilder data(Map<String, String> data) {   
        delegate.data(data);     
        return this;
    }
    
    /**
     * Gets sub-fields of the <code>android.data</code> field.
     * @return A map with sub-fields of the <code>android.data</code> field, or null if absent. 
     */
    public Map<String, String> data() {
        return delegate.data();
    }
}
