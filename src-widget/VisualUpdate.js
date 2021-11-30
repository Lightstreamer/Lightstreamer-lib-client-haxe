/*
  Copyright (c) Lightstreamer Srl

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
import LoggerManager from "../src-log/LoggerManager";
import Inheritance from "../src-tool/Inheritance";
import Setter from "../src-tool/Setter";
import IllegalArgumentException from "../src-tool/IllegalArgumentException";

export default /*@__PURE__*/(function() {
  var gridsLogger = LoggerManager.getLoggerProxy("lightstreamer.grids");
  
  var NO_CELL = "No cell defined for this field";
  
  var DEFAULT_HOT_TIME = 1200;
  
  /**
   * Used by Lightstreamer to provide a value object to each call of the
   * {@link StaticGridListener#onVisualUpdate} and 
   * {@link DynaGridListener#onVisualUpdate} events. This constructor
   * is not supposed to be used by custom code.
   * @constructor
   *
   * @exports VisualUpdate
   * @class Contains all the information related to a row update that is about
   * to be displayed on a grid. This may happen because of a call to the
   * {@link AbstractWidget#updateRow} method, or, in case
   * an AbstractGrid is used to listen to a {@link Subscription}, because of
   * an update received from Lightstreamer Server.
   * <BR> Specifically, for each row it supplies:
   * <ul>
   * <li>The current values for the row fields in the grid and in the
   * underlying model and a method to modify the value in the gris cells
   * before updating them on the DOM.</li>
   * <li>Methods to set the stylesheets to be applied to the HTML cells.</li>
   * <li>Methods to configure the visual effect to be applied to the HTML
   * cells in order to emphasize the changes in the cell values.</li>
   * </ul>
   * The provided visual effect consists of the following sequence:
   * <ul>
   * <li>A change in the cell colors, with a fading behaviour, to temporary
   * "hot" colors.</li>
   * <li>The change of the values to the new values and the change of the
   * stylesheets to the full "hot" stylesheet; after the change, the cell
   * stays in this "hot" phase for a while.</li>
   * <li>A change in the cell colors, with a fading behaviour, to the final
   * "cold" colors.</li>
   * <li>The change of the stylesheets to the full "cold" stylesheets.</li>
   * </ul>
   * <BR/>The class constructor, its prototype and any other properties should never
   * be used directly.
   *    
   * @see StaticGridListener#onVisualUpdate
   * @see DynaGridListener#onVisualUpdate
   */
  var VisualUpdate = function() {
    
    //TODO we didn't want the parameters to appear in the docs,
    //what about now?
    this.cellsGrid = arguments[0];
    this.updatingRow = arguments[1];
    this.key = arguments[2];
    
    
    this.coldToHotTime = 0;
    this.hotToColdTime = 0;
    this.hotTime = DEFAULT_HOT_TIME;
    
    this.hotRowStyle = null;
    this.coldRowStyle = null;
    

  };
  
  VisualUpdate.prototype = {
    
    
    /**
     * Inquiry method that gets the value that is going to be shown in the grid 
     * in a specified cell or the current value if the value is not going to be 
     * changed.
     * <BR>Note that if the value is not changing then no effects or styles are
     * going to be applied on the cell itself. If the effect is desired even if
     * the value in the cell is unchanged, then a call to {@link VisualUpdate#setCellValue} can
     * be performed using the value from this getter.
     * <BR>In order to inquiry the values for the row cells on the underlying
     * model, the {@link VisualUpdate#getChangedFieldValue} method is available.
     * 
     * @throws {IllegalArgumentException} if no cells were associated with
     * the specified field.
     * 
     * @param {String} field The field name associated with one of the cells in the
     * grid (the "data-field" attribute).  
     * @param {String} [replicaId] A custom identifier that can be used in case two
     * or more cells were defined for the same field (the "data-replica" attribute).
     * If more cells have been defined but this parameter is not specified, then a random
     * cell will be selected.
     *    
     * @return {String} A text or null; if the value for the specified field has never been
     * assigned in the model, the method also returns null.
     *
     * @see VisualUpdate#setCellValue
     * @see VisualUpdate#getChangedFieldValue
     */
    getCellValue: function(field,replicaId) { 
      var cell = this.cellsGrid.getCell(this.key,field,replicaId);
      if (!cell) {
        throw new IllegalArgumentException(NO_CELL);
      }
     
      if (!cell.isCell) {
        //multiple cells for field and replicaID not specified
        cell = cell[0];
      }
      
      return cell.getNextFormattedValue() || cell.retrieveValue();
    },
    
    /**
     * Setter method that assigns the value to be shown in a specified cell of 
     * the grid.
     * The specified value is the text that will be actually written in the cell
     * (for instance, it may be a formatted version of the original value),
     * unless it is null, in which case the value currently shown will be kept.
     * The latter may still be the initial cell value (or the cell value
     * specified on the template) if no formatted value hasn't been supplied
     * for the field yet.
     * <BR>Note that this method does not update the internal model of the AbstractGrid
     * so that if a value is set through this method it can't be used 
     * for features working on such model (e.g. it can't be used to sort the grid).
     * If a change to the model is required use the {@link AbstractWidget#updateRow} method.
     * 
     * @throws {IllegalArgumentException} if no cells were associated with
     * the specified field.
     *
     * @param {String} field The field name associated with one of the cells in the
     * grid (the "data-field" attribute).  
     * @param {String} value the value to be written in the cell, or null.
     * @param {String} [replicaId] A custom identifier that can be used in case two
     * or more cells were defined for the same field (the "data-replica" attribute).
     * If more cells were defined but this parameter is not specified, then a random
     * cell will be selected.
     */
    setCellValue: function(field, value, replicaId) { 
      var cell = this.cellsGrid.getCell(this.key,field,replicaId);
      if (!cell) {
        throw new IllegalArgumentException(NO_CELL);
      }
      if (cell.isCell) {
        cell.setNextFormattedValue(value);
      } else for (var i=0; i<cell.length; i++) {
        cell[i].setNextFormattedValue(value);
      }
    },
    
    
    /**
     * Inquiry method that gets the value that is going to update the underlying
     * model of the grid for the associated field. It can be null if no change 
     * for the specified field is going to be applied.
     * 
     * @param {String} field The name of a field from the model.    
     *
     * @return {String} The new value of the specified field (possibly null), or null
     * if the field is not changing.
     * If the value for the specified field has never been
     * assigned in the model, the method also returns null.
     */
    getChangedFieldValue: function(field) {
      return this.updatingRow[field] || null;
    },
        
    /**
     * Setter method that configures the length of the "hot" phase for the
     * current row. The "hot" phase is one of the phases of the visual effect
     * supplied by Lightstreamer to emphasize the change of the row values.
     * <br/>By default 1200 ms is set.
     *
     * @param {Number} val Duration in milliseconds of the "hot" phase.
     */
    setHotTime: function(val) { 
      this.hotTime = this.checkPositiveNumber(val, true);  
    },
  
    /**
     * Setter method that configures the length of the color fading phase
     * before the "hot" phase. This fading phase is one of the phases of
     * the visual effect supplied by Lightstreamer to emphasize the change
     * of the row values. A 0 length means that the color switch to "hot"
     * colors should be instantaneous and should happen together with value
     * and stylesheet switch.
     * <BR>Warning: The fading effect, if enabled, may be computation
     * intensive for some client environments, when high-frequency updates
     * are involved.
     * <br/>By default 0 ms (no fading at all) is set.
     * 
     * @param {Number} val Duration in milliseconds of the fading phase before
     * the "hot" phase.
     */
    setColdToHotTime: function(val) { 
      this.coldToHotTime = this.checkPositiveNumber(val, true);
    },
  
    /**
     * Setter method that configures the length of the color fading phase
     * after the "hot" phase. This fading phase is one of the phases of
     * the visual effect supplied by Lightstreamer to emphasize the change
     * of the row values. A 0 length means that the color switch from "hot"
     * to final "cold" colors should be instantaneous and should happen
     * together with the stylesheet switch.
     * <BR>Warning: The fading effect, if enabled, may be very computation
     * intensive for some client environments, when high-frequency updates
     * are involved.
     * <br/>By default 0 ms (no fading at all) is set.
     *
     * @param {Number} val Duration in milliseconds of the fading phase after
     * the "hot" phase.
     */
    setHotToColdTime: function(val) {
      this.hotToColdTime = this.checkPositiveNumber(val, true);  
    },
    

    /**
     * @private
     */
    addStyle: function(field, hotValue, coldValue, _type, num) {
      
      var cell = this.cellsGrid.getCell(this.key,field,num);
      if (!cell) {
        throw new IllegalArgumentException(NO_CELL);
      }
      if (cell.isCell) {
        cell.addStyle(hotValue, coldValue, _type);
      } else for (var i=0; i<cell.length; i++) {
        cell[i].addStyle(hotValue, coldValue, _type);
      }
      
    },
    
    /**
     * @private
     */
    addRowStyle: function(hotValue, coldValue, _type) {
      if (!this.hotRowStyle) {
        this.hotRowStyle = {};
        this.coldRowStyle = {};
      }
      
      this.hotRowStyle[_type] = hotValue || "";
      this.coldRowStyle[_type] = coldValue || "";
    },
   
    
    /**
     * Setter method that configures the stylesheet changes to be applied
     * to all the HTML cells of the involved row, while changing the field values.
     * A temporary "hot" style can
     * be specified as different than the final "cold" style. This allows
     * Lightstreamer to perform a visual effect, in which a temporary "hot"
     * phase is visible. By using this method, stylesheet attributes can be
     * specified one at a time.
     * <BR>If nonzero fading times are specified, through
     * {@link VisualUpdate#setColdToHotTime} and/or {@link VisualUpdate#setHotToColdTime},
     * then the "color" and "backgroundColor" attributes, if set, will be
     * changed with a fading behaviour.
     * Note that if color attributes are not set and nonzero fading times are
     * specified in {@link VisualUpdate#setColdToHotTime} and/or {@link VisualUpdate#setHotToColdTime},
     * this will cause a delay of the "hot" and "cold" phase switches;
     * however, as fading times refer to the whole row, you may need to set
     * them as nonzero in order to allow fading on some specific fields only.
     * <BR>If a row stylesheet is set through the {@link VisualUpdate#setStyle} method,
     * then this method should be used only to set stylesheet properties
     * not set by the row stylesheet. This condition applies throughout the
     * whole lifecycle of the cell (i.e. manipulating the same style property 
     * through both methods, even at different times, does not guarantee
     * the result).
     * <br/>By default for each stylesheet attribute that is not
     * specified neither with this method nor with {@link VisualUpdate#setStyle}, the
     * current value is left unchanged.
     *
     * @param {String} hotValue the temporary "hot" value for the involved
     * attribute, or null if the attribute should not change while entering
     * "hot" phase; an empty string causes the current attribute value
     * to be cleared.
     * @param {String} coldValue the final "cold" value for the involved
     * attribute, or null if the attribute should not change while exiting
     * "hot" phase; an empty string causes the "hot" phase attribute value
     * to be cleared.
     * @param {String} attrName the name of an HTML stylesheet attribute.
     * The DOM attribute name should be used, not the CSS name (e.g.
     * "backgroundColor" is accepted, while "background-color" is not).
     * Note that if the "color" or "backgroundColor" attribute is being set,
     * then several color name conventions are supported by the underlying
     * DOM manipulation functions; however, in order to take advantage of the
     * color fading support, only the "#RRGGBB" syntax is fully supported.
     */
    setAttribute: function(hotValue, coldValue, attrName) { 
      this.addRowStyle(hotValue, coldValue, attrName);
    },
    
    /**
     * Setter method that configures the stylesheets to be applied to the
     * HTML cells of the involved row, while changing the field values.
     * A temporary "hot" style can
     * be specified as different than the final "cold" style. This allows
     * Lightstreamer to perform a visual effect, in which a temporary "hot"
     * phase is visible. By using this method, the names of existing
     * stylesheets are supplied.
     * <BR>Note that in order to specify cell colors that can change with
     * a fading behavior, the {@link VisualUpdate#setAttribute} method should be used instead,
     * as fading is not supported when colors are specified in the stylesheets
     * with this method. So, if nonzero fading times are specified in
     * {@link VisualUpdate#setColdToHotTime} and/or {@link VisualUpdate#setHotToColdTime},
     * this will just cause a delay of the "hot" and "cold" phase switches;
     * however, as fading times refer to the whole row, you may need to set
     * them as nonzero in order to allow fading on some specific fields only.
     * for each stylesheet attribute that is not
     * specified neither with this method nor with {@link VisualUpdate#setStyle}, the
     * current value is left unchanged.
     * <br/>By default no stylesheet is applied to the cell.
     *
     * @param {String} hotStyle the name of the temporary "hot" stylesheet,
     * or null if the cells style should not change while entering "hot" phase.
     * @param {String} coldStyle the name of the final "cold" stylesheet,
     * or null if the cells style should not change while exiting "hot" phase.
     */
    setStyle: function(hotStyle, coldStyle) {
      this.addRowStyle(hotStyle, coldStyle, "CLASS");
    },
    
    /**
     * Setter method that configures the stylesheet changes to be applied
     * to the HTML cell related with a specified field, while changing its
     * value.
     * The method can be used to override, for a specific field, the settings
     * made through {@link VisualUpdate#setAttribute}.
     * <BR>If a specific stylesheet is assigned to the field through the
     * {@link VisualUpdate#setStyle} or {@link VisualUpdate#setCellStyle} method,
     * then this method can be used only in order to set stylesheet properties
     * not set by the assigned specific stylesheet. This condition applies
     * throughout the whole lifecycle of the cell (i.e. it is discouraged
     * to manipulate the same style property through both methods,
     * even at different times).
     * <br/>By default  the settings possibly made by {@link VisualUpdate#setAttribute}
     * are used.</p>
     * 
     * @throws {IllegalArgumentException} if no cells were associated with
     * the specified field.
     *
     * @param {String} field The field name associated with one of the cells in the
     * grid (the "data-field" attribute).  
     * @param {String} hotValue the temporary "hot" value for the involved
     * attribute, or null if the attribute should not change while entering
     * "hot" phase; an empty string causes the current attribute value
     * to be cleared.
     * @param {String} coldValue the final "cold" value for the involved
     * attribute, or null if the attribute should not change while exiting
     * "hot" phase; an empty string causes the "hot" phase attribute value
     * to be cleared.
     * @param {String} attrName the name of an HTML stylesheet attribute.
     * The DOM attribute name should be used, not the CSS name (e.g.
     * "backgroundColor" is accepted, while "background-color" is not).
     * @param {String} [replicaId] A custom identifier that can be used in case two
     * or more cells were defined for the same field (the "data-replica" attribute).
     * If more cells were defined but this parameter is not specified, then a random
     * cell will be selected.
     * 
     * @see VisualUpdate#setAttribute
     */
    setCellAttribute: function(field, hotValue, coldValue, attrName, replicaId) {
      this.addStyle(field, hotValue, coldValue, attrName, replicaId);      
    },
    
    /**
     * Setter method that configures the stylesheet to be applied to the
     * HTML cell related with a specified field, while changing its value.
     * <BR>This method can be used to override, for a specific field, the settings
     * made through {@link VisualUpdate#setStyle}.
     * <br/>By default the stylesheet possibly set through {@link VisualUpdate#setStyle}
     * is used.</p>
     * 
     * @throws {IllegalArgumentException} if no cells were associated with
     * the specified field.
     *
     * @param {String} field The field name associated with one of the cells in the
     * grid (the "data-field" attribute).  
     * @param {String} hotStyle the name of the temporary "hot" stylesheet,
     * or null if the cell style should not change while entering "hot" phase
     * (regardless of the settings made through {@link VisualUpdate#setStyle} and
     * {@link VisualUpdate#setAttribute}).
     * @param {String} coldStyle the name of the final "cold" stylesheet,
     * or null if the cell style should not change while exiting "hot" phase
     * (regardless of the settings made through {@link VisualUpdate#setStyle} and
     * {@link VisualUpdate#setAttribute}).
     * @param {String} [replicaId] A custom identifier that can be used in case two
     * or more cells were defined for the same field (the "data-replica" attribute).
     * If more cells were defined but this parameter is not specified, then a random
     * cell will be selected.
     * 
     * @see VisualUpdate#setStyle
     */
    setCellStyle: function(field, hotStyle, coldStyle, replicaId) { 
      this.addStyle(field, hotStyle, coldStyle, "CLASS", replicaId);
    },
    
    /**
     * Receives an iterator function and invokes it once per each field 
     * of the underlying model changed with the current update.
     * <BR>Note that in case of an event generated by the creation of a new row
     * all the field will be iterated.
     * <BR>Note that the iterator is executed before this method returns.
     * <BR>Note that the iterator will iterate through all of the changed fields
     * including fields not having associated cells. Also, even if a field is 
     * associated with more cells it will be passed to the iterator only once.
     * 
     * @param {ChangedFieldCallback} iterator Function instance that will be called once per 
     * each field changed on the current update on the internal model.
     * 
     * @see VisualUpdate#getChangedFieldValue
     */
    forEachChangedField: function(iterator) {
      for (var i in this.updatingRow) {
        try {
          iterator(i,this.updatingRow[i]);
        } catch(_e) {
          gridsLogger.logError("Exception thrown while executing the iterator Function",_e);
        }
      }
    }
    
  };
  
  //closure compiler exports
  VisualUpdate.prototype["getCellValue"] = VisualUpdate.prototype.getCellValue;
  VisualUpdate.prototype["setCellValue"] = VisualUpdate.prototype.setCellValue;
  VisualUpdate.prototype["getChangedFieldValue"] = VisualUpdate.prototype.getChangedFieldValue;
  VisualUpdate.prototype["setHotTime"] = VisualUpdate.prototype.setHotTime;
  VisualUpdate.prototype["setColdToHotTime"] = VisualUpdate.prototype.setColdToHotTime;
  VisualUpdate.prototype["setHotToColdTime"] = VisualUpdate.prototype.setHotToColdTime;
  VisualUpdate.prototype["setAttribute"] = VisualUpdate.prototype.setAttribute;
  VisualUpdate.prototype["setStyle"] = VisualUpdate.prototype.setStyle;
  VisualUpdate.prototype["setCellAttribute"] = VisualUpdate.prototype.setCellAttribute;
  VisualUpdate.prototype["setCellStyle"] = VisualUpdate.prototype.setCellStyle;
  VisualUpdate.prototype["forEachChangedField"] = VisualUpdate.prototype.forEachChangedField;
  
  Inheritance(VisualUpdate,Setter,true,true);
  return VisualUpdate;
})();
  
  /**
   * Callback for {@link VisualUpdate#forEachChangedField}
   * @callback ChangedFieldCallback
   * @param {String} field name of the involved changed field.
   * @param {String} value the new value for the field. See {@link VisualUpdate#getChangedFieldValue} for details.
   * Note that changes to the values made through {@link VisualUpdate#setCellValue} calls will not be reflected
   * by the iterator, as they don't affect the model.
   */
  