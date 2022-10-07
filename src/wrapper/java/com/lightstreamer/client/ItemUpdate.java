/*
 * Copyright (c) 2004-2015 Weswit s.r.l., Via Campanini, 6 - 20124 Milano, Italy.
 * All rights reserved.
 * www.lightstreamer.com
 *
 * This software is the confidential and proprietary information of
 * Weswit s.r.l.
 * You shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the license agreement you entered
 * into with Weswit s.r.l.
 */
package com.lightstreamer.client;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/**
 * Contains all the information related to an update of the field values for an item. 
 * It reports all the new values of the fields. <BR>
 * 
 * <b>COMMAND Subscription</b><BR>
 * If the involved Subscription is a COMMAND Subscription, then the values for the current 
 * update are meant as relative to the same key. <BR>
 * Moreover, if the involved Subscription has a two-level behavior enabled, then each update 
 * may be associated with either a first-level or a second-level item. In this case, the reported 
 * fields are always the union of the first-level and second-level fields and each single update 
 * can only change either the first-level or the second-level fields (but for the "command" field, 
 * which is first-level and is always set to "UPDATE" upon a second-level update); note 
 * that the second-level field values are always null until the first second-level update 
 * occurs). When the two-level behavior is enabled, in all methods where a field name has to 
 * be supplied, the following convention should be followed:<BR>
 * <ul>
 *  <li>The field name can always be used, both for the first-level and the second-level fields. 
 *  In case of name conflict, the first-level field is meant.</li>
 *  <li>The field position can always be used; however, the field positions for the second-level 
 *  fields start at the highest position of the first-level field list + 1. If a field schema had 
 *  been specified for either first-level or second-level Subscriptions, then client-side knowledge 
 *  of the first-level schema length would be required.</li>
 *</ul>
 */
public interface ItemUpdate {
  
  /**
   * Inquiry method that retrieves the name of the item to which this update pertains. <BR> 
   * The name will be null if the related Subscription was initialized using an "Item Group".
   * @return The name of the item to which this update pertains.
   * @see Subscription#setItemGroup(String)
   * @see Subscription#setItems(String[])
   */
  @Nullable 
  public String getItemName();
  
  /**
   * Inquiry method that retrieves the position in the "Item List" or "Item Group" of the item to 
   * which this update pertains.
   * @return The 1-based position of the item to which this update pertains.
   * @see Subscription#setItemGroup(String)
   * @see Subscription#setItems(String[])
   */
  public int getItemPos();
  
  /**
   * Returns the current value for the specified field
   * @param fieldName The field name as specified within the "Field List".
   * @throws IllegalArgumentException if the specified field is not part of the Subscription.
   * @return The value of the specified field; it can be null in the following cases:<BR>
   * <ul>
   *  <li>a null value has been received from the Server, as null is a possible value for a field;</li>
   *  <li>no value has been received for the field yet;</li>
   *  <li>the item is subscribed to with the COMMAND mode and a DELETE command is received 
   *  (only the fields used to carry key and command information are valued).</li>
   * </ul>
   * @see Subscription#setFields(String[])
   */
  @Nullable
  public String getValue(@Nonnull String fieldName);
  
  /**
   * Returns the current value for the specified field
   * @param fieldPos The 1-based position of the field within the "Field List" or "Field Schema".
   * @throws IllegalArgumentException if the specified field is not part of the Subscription.
   * @return The value of the specified field; it can be null in the following cases:<BR>
   * <ul>
   *  <li>a null value has been received from the Server, as null is a possible value for a field;</li>
   *  <li>no value has been received for the field yet;</li>
   *  <li>the item is subscribed to with the COMMAND mode and a DELETE command is received 
   *  (only the fields used to carry key and command information are valued).</li>
   * </ul>
   * @see Subscription#setFieldSchema(String)
   * @see Subscription#setFields(String[])
   */
  @Nullable 
  public String getValue(int fieldPos);
  
  /**
   * Inquiry method that asks whether the current update belongs to the item snapshot (which carries 
   * the current item state at the time of Subscription). Snapshot events are sent only if snapshot 
   * information was requested for the items through {@link Subscription#setRequestedSnapshot(String)} 
   * and precede the real time events. Snapshot information take different forms in different 
   * subscription modes and can be spanned across zero, one or several update events. In particular:
   * <ul>
   *  <li>if the item is subscribed to with the RAW subscription mode, then no snapshot is 
   *  sent by the Server;</li>
   *  <li>if the item is subscribed to with the MERGE subscription mode, then the snapshot consists 
   *  of exactly one event, carrying the current value for all fields;</li>
   *  <li>if the item is subscribed to with the DISTINCT subscription mode, then the snapshot 
   *  consists of some of the most recent updates; these updates are as many as specified 
   *  through {@link Subscription#setRequestedSnapshot(String)}, unless fewer are available;</li>
   *  <li>if the item is subscribed to with the COMMAND subscription mode, then the snapshot 
   *  consists of an "ADD" event for each key that is currently present.</li>
   * </ul>
   * Note that, in case of two-level behavior, snapshot-related updates for both the first-level item
   * (which is in COMMAND mode) and any second-level items (which are in MERGE mode) are qualified with 
   * this flag.
   * @return true if the current update event belongs to the item snapshot; false otherwise.
   */
  public boolean isSnapshot();
  
  /**
   * Inquiry method that asks whether the value for a field has changed after the reception of the last 
   * update from the Server for an item. If the Subscription mode is COMMAND then the change is meant as 
   * relative to the same key.
   * @param fieldName The field name as specified within the "Field List".
   * @throws IllegalArgumentException if the specified field is not part of the Subscription.
   * @return Unless the Subscription mode is COMMAND, the return value is true in the following cases:
   * <ul>
   *  <li>It is the first update for the item;</li>
   *  <li>the new field value is different than the previous field 
   *  value received for the item.</li>
   * </ul>
   *  If the Subscription mode is COMMAND, the return value is true in the following cases:
   * <ul>
   *  <li>it is the first update for the involved key value (i.e. the event carries an "ADD" command);</li>
   *  <li>the new field value is different than the previous field value received for the item, 
   *  relative to the same key value (the event must carry an "UPDATE" command);</li>
   *  <li>the event carries a "DELETE" command (this applies to all fields other than the field 
   *  used to carry key information).</li>
   * </ul>
   * In all other cases, the return value is false.
   * @see Subscription#setFields(String[])
   */
  public boolean isValueChanged(@Nonnull String fieldName);
  
  /**
   * Inquiry method that asks whether the value for a field has changed after the reception of the last 
   * update from the Server for an item. If the Subscription mode is COMMAND then the change is meant as 
   * relative to the same key.
   * @param fieldPos The 1-based position of the field within the "Field List" or "Field Schema".
   * @throws IllegalArgumentException if the specified field is not part of the Subscription.
   * @return Unless the Subscription mode is COMMAND, the return value is true in the following cases:
   * <ul>
   *  <li>It is the first update for the item;</li>
   *  <li>the new field value is different than the previous field 
   *  value received for the item.</li>
   * </ul>
   *  If the Subscription mode is COMMAND, the return value is true in the following cases:
   * <ul>
   *  <li>it is the first update for the involved key value (i.e. the event carries an "ADD" command);</li>
   *  <li>the new field value is different than the previous field value received for the item, 
   *  relative to the same key value (the event must carry an "UPDATE" command);</li>
   *  <li>the event carries a "DELETE" command (this applies to all fields other than the field 
   *  used to carry key information).</li>
   * </ul>
   * In all other cases, the return value is false.
   * @see Subscription#setFieldSchema(String)
   * @see Subscription#setFields(String[])
   */
  public boolean isValueChanged(int fieldPos);
  
  /**
   * Returns an immutable Map containing the values for each field changed with the last server update. 
   * The related field name is used as key for the values in the map. 
   * Note that if the Subscription mode of the involved Subscription is COMMAND, then changed fields 
   * are meant as relative to the previous update for the same key. On such tables if a DELETE command 
   * is received, all the fields, excluding the key field, will be present as changed, with null value. 
   * All of this is also true on tables that have the two-level behavior enabled, but in case of 
   * DELETE commands second-level fields will not be iterated.
   * 
   * @throws IllegalStateException if the Subscription was initialized using a field schema.
   * 
   * @return An immutable Map containing the values for each field changed with the last server update.
   * 
   * @see Subscription#setFieldSchema(String)
   * @see Subscription#setFields(String[])
   */
  @Nonnull 
  public Map<String, String> getChangedFields();
  
  /**
   * Returns an immutable Map containing the values for each field changed with the last server update. 
   * The 1-based field position within the field schema or field list is used as key for the values in the map. 
   * Note that if the Subscription mode of the involved Subscription is COMMAND, then changed fields 
   * are meant as relative to the previous update for the same key. On such tables if a DELETE command 
   * is received, all the fields, excluding the key field, will be present as changed, with null value. 
   * All of this is also true on tables that have the two-level behavior enabled, but in case of 
   * DELETE commands second-level fields will not be iterated.
   * 
   * @return An immutable Map containing the values for each field changed with the last server update.
   * 
   * @see Subscription#setFieldSchema(String)
   * @see Subscription#setFields(String[])
   */
  @Nonnull 
  public Map<Integer, String> getChangedFieldsByPosition();
  
  
  /**
   * Returns an immutable Map containing the values for each field in the Subscription.
   * The related field name is used as key for the values in the map. 
   * 
   * @throws IllegalStateException if the Subscription was initialized using a field schema.
   * 
   * @return An immutable Map containing the values for each field in the Subscription.
   * 
   * @see Subscription#setFieldSchema(String)
   * @see Subscription#setFields(String[])
   */
  @Nonnull 
  public Map<String, String> getFields();
  

  /**
   * Returns an immutable Map containing the values for each field in the Subscription.
   * The 1-based field position within the field schema or field list is used as key for the values in the map. 
   * 
   * @return An immutable Map containing the values for each field in the Subscription.
   * 
   * @see Subscription#setFieldSchema(String)
   * @see Subscription#setFields(String[])
   */
  @Nonnull 
  public Map<Integer, String> getFieldsByPosition();
}
