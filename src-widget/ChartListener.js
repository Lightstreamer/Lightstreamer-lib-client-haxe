//Listener Interface ---->    
  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports ChartListener
   * @class Interface to be implemented to listen to {@link Chart} events
   * comprehending notifications of chart overflow and new line creations.
   * <BR>Events for this listeners are executed synchronously with respect to the code
   * that generates them. 
   * <BR>Note that it is not necessary to implement all of the interface methods for 
   * the listener to be successfully passed to the {@link Chart#addListener}
   * method.
   * <BR>A ready made implementation of ChartListener providing basic functionalities
   * is distributed with the library: {@link SimpleChartListener}.
   */
  var ChartListener = function() {
  };
  
  ChartListener.prototype = {
      
    /**
     * Event handler that is called each time that, due to an update to the internal
     * model of the {@link Chart} this instance is listening to, a new 
     * {@link ChartLine} is being generated and displayed.
     * By implementing this method, it is possible to configure the appearance
     * of the new line.
     * <BR>A new line can be generated only when a new row enters the
     * model. Moreover, based on the configuration of {@link Chart#addYAxis} a new
     * row in the model may generate more than one line resulting in this event being
     * fired more than one time for a single update.
     * 
     * @param {String} key The key associated with the row that caused the line
     * of this event to be generated (keys are described in {@link AbstractWidget}).
     * @param {ChartLine} newChartLine The object representing the new line that has 
     * been generated.
     * @param {Number} currentX The X-coordinate of the first point of the line
     * of this event.
     * @param {Number} currentY The Y-coordinate of the first point of the line
     * of this event.
     * 
     */
    onNewLine: function(key,newChartLine,currentX,currentY) {
        
    },
      
    /**
     * Event handler that is called each time that, due to an update to the internal
     * model of the {@link Chart} this instance is listening to, one of the currently 
     * active {@link ChartLine} is being removed.
     * 
     * @param {String} key The key associated with the row that was removed causing
     * this event to be fired (keys are described in {@link AbstractWidget}).
     * @param {ChartLine} removedChartLine The object representing the line that has 
     * been removed.
     * 
     * @see Chart#removeYAxis
     */
    onRemovedLine: function(key,removedChartLine) {
        
    },
      
    /**
     * Event handler that is called when a new update has been received
     * such that one or more points have to be added to the chart lines,
     * but cannot be shown because their X-coordinate value is higher than
     * the upper limit set for the X axis.
     * By implementing this event handler, the chart axis can be repositioned
     * through {@link Chart#positionXAxis} so that the new points can be shown
     * on the chart.
     * <BR>Note that if a new update is received such that one or more points
     * have to be added to the chart lines but cannot be shown because their
     * X-coordinate value is lower than the lower limit set for the X axis,
     * then this event handler is not called, but rather the new update is
     * ignored. X axis limits should always be set in such a way as to avoid
     * this case.
     *
     * @param {String} key The key associated with the row that during its update
     * made the overflow happen.
     * @param {Number} lastX The X-coordinate value of the new points to be
     * shown on the chart and that exceeds the current upper limit.
     * @param {Number} xMin The current lower limit for the visible part
     * of the X axis.
     * @param {Number} xMax The current upper limit for the visible part
     * of the X axis.
     */
    onXOverflow: function(key, lastX, xMin, xMax) {
        
    },
      
    /**
     * Event handler that is called when a new update has been received
     * such that a new point for this line has to be added to the chart,
     * but cannot be shown because its Y-coordinate value is higher than
     * the upper limit set for the Y axis on this line, or lower than the
     * lower limit.
     * By implementing this event handler, the line can be repositioned
     * through {@link ChartLine#positionYAxis} so that the new point can be shown
     * on the chart.
     *
     * @param {String} key The key associated with the row that during its update
     * made the overflow happen.
     * @param {ChartLine} toUpdateChartLine The object representing the line that 
     * made the overflow happen.
     * @param {Number} lastY The Y-coordinate value of the new point to be
     * shown on the chart and that exceeds the current upper or lower limit.
     * @param {Number} yMin The current lower limit for the visible part
     * of the Y axis.
     * @param {Number} yMax The current upper limit for the visible part
     * of the Y axis.
     */
    onYOverflow: function(key,toUpdateChartLine,lastY,yMin,yMax) {
        
    }
      
  };
//<----  Listener Interface  