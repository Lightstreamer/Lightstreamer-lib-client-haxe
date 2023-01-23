//Listener Interface ---->
  
  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor 
   * 
   * @exports StaticGridListener
   * @class Interface to be implemented to listen to {@link StaticGrid} events.
   * <BR>Events for this listeners are executed synchronously with respect to the code
   * that generates them.
   * <BR>Note that it is not necessary to implement all of the interface methods for 
   * the listener to be successfully passed to the {@link StaticGrid#addListener}
   * method.
   * 
   * @see StaticGrid
   */
  var StaticGridListener = function() {
    
  };
  
  StaticGridListener.prototype = {
      /**
       * Event handler that is called by Lightstreamer each time a row of the
       * underlying model is added or modified and the change is going to be
       * applied to the corresponding cells in the grid.
       * By implementing this method, it is possible to perform custom
       * formatting on the field values, to set the cell stylesheets and to
       * control the display policy.
       * In addition, through a custom handler it is possible to perform custom
       * display actions for the row.
       * <BR>Note that the availability of cells currently associated to the row
       * fields depends on how the StaticGrid was configured.
       * <BR>This event is also fired when a row is removed from the model,
       * to allow clearing actions related to custom display actions previously
       * performed for the row. Row removal may happen when the {@link StaticGrid}
       * is listening to events from {@link Subscription} instance(s), and the first
       * Subscription it listens to is a COMMAND or a DISTINCT Subscription;
       * removal may also happen in case of {@link AbstractWidget#removeRow} or
       * {@link AbstractWidget#clean} execution.
       * <BR>On the other hand, in case the row is just repositioned on the grid
       * no notification is supplied, but the formatting and style are kept for
       * the new cells.
       * <BR>This event is fired before the update is applied to both the HTML cells
       * of the grid and the internal model. As a consequence, through 
       * {@link AbstractWidget#updateRow} it is still possible to modify the current update.
       *
       * @param {String} key the key associated with the row that is being 
       * added/removed/updated (keys are described in {@link AbstractWidget}).
       *  
       * @param {VisualUpdate} visualUpdate a value object containing the
       * updated values for all the cells, together with their display settings.
       * The desired settings can be set in the object, to substitute the default 
       * settings, before returning.
       * <BR>visualUpdate can also be null, to notify a clearing action.
       * In this case, the row is being removed from the page. 
       * 
       * @param {String} position the value of the data-row or data-item
       * value of the cells targeted by this update.
       */
      onVisualUpdate: function(key, visualUpdate, position) {
        return;
      }
  };
//<----  Listener Interface  

export default StaticGridListener