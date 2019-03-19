(function() {

  window.main = function() {
    /* obtain a reference to the SVG
    */
    var background, drag, vis;
    vis = d3.select('svg');
    /* --- Circle dragging ---
    */
    /* define a drag behavior
    */
    drag = d3.behavior.drag().on('drag', function() {
      /* move the circle
      */      return d3.select(this).attr('cx', d3.event.x).attr('cy', d3.event.y);
    });
    /* --- Circle creation ---
    */
    /* create a rectangle to serve as background
    */
    background = vis.append('rect').attr('class', 'background').attr('width', vis.attr('width')).attr('height', vis.attr('height'));
    /* when the user clicks the background
    */
    return background.on('click', function() {
      /* retrieve mouse coordinates
      */
      var p;
      p = d3.mouse(this);
      /* create a new circle at point p
      */
      return vis.append('circle').attr('class', 'node').attr('r', 20).attr('cx', p[0]).attr('cy', p[1]).call(drag);
    });
  };

}).call(this);
