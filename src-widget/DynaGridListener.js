//Listener Interface ---->
  
  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports DynaGridListener
   * @class Interface to be implemented to listen to {@link DynaGrid} events
   * comprehending notifications of changes in the shown values and, in case
   * pagination is active, changes in the number of total logical pages.
   * <BR>Events for this listeners are executed synchronously with respect to the code
   * that generates them. 
   * <BR>Note that it is not necessary to implement all of the interface methods for 
   * the listener to be successfully passed to the {@link DynaGrid#addListener}
   * method.
   * 
   * @see DynaGrid
   */
  var DynaGridListener = function() {
    
  };
  
  
  DynaGridListener.prototype = {
      
      /**
       * Event handler that receives the notification that the number of
       * logical pages has changed. The number of logical pages can grow or
       * shrink because of addition or removal of rows and because of changes
       * in the logical page size setting.
       * By implementing this method it is possible, for example, to implement
       * a dynamic page index to allow direct jump to each logical page.
       *
       *
       * @param {Number} numPages The current total number of logical pages.
       * @see DynaGrid#setMaxDynaRows
       * @see DynaGrid#goToPage
       */
      onCurrentPagesChanged: function(numPages) {
        
      },
      
      /**
       * Event handler that is called by Lightstreamer each time a row of the
       * grid is being added or modified.
       * By implementing this method, it is possible to perform custom
       * formatting on the field values, to set the cells stylesheets and to
       * control the display policy.
       * In addition, through a custom handler, it is possible to perform custom
       * display actions for the row, by directly acting on the DOM element
       * containing the grid row.
       * <BR>This event is also fired when a row is being removed from the grid,
       * to allow clearing actions related to custom display actions previously
       * performed for the row. Row removal may happen when the {@link DynaGrid}
       * is listening to events from {@link Subscription} instance(s), and the first
       * Subscription it listens to is a COMMAND Subscription;
       * removal may also happen in case of {@link AbstractWidget#removeRow} or
       * {@link AbstractWidget#clean} execution and in case of destruction of
       * a row caused by exceeding the maximum allowed number of rows (see
       * {@link DynaGrid#setMaxDynaRows}).
       * <BR>
       * <BR>This event is fired before the update is applied to both the HTML cells
       * of the grid and the internal model. As a consequence, through 
       * {@link AbstractWidget#updateRow}, it is still possible to modify the current update.
       * <BR>This notification is unrelated to paging activity. New or changed
       * rows are notified regardless that they are being shown in the current
       * page or that they are currently hidden. Also, no notifications are
       * available to signal that a row is entering or exiting the currently
       * displayed page.
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
       * @param {Object} domNode The DOM pointer to the HTML row involved.
       * The row element has been created by Lightstreamer, by cloning the
       * template row supplied to the {@link DynaGrid}.
       */
      onVisualUpdate: function(key, visualUpdate, domNode) {
        
      }
      
      
  };
//<----  Listener Interface  

export default DynaGridListener