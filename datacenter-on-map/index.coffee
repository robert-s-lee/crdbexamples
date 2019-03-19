window.main = () ->
    ### obtain a reference to the SVG ###
    vis = d3.select('svg')
    
    ### --- Circle dragging --- ###
    
    ### define a drag behavior ###
    drag = d3.behavior.drag()
        .on 'drag', () ->
            ### move the circle ###
            d3.select(this)
                .attr('cx', d3.event.x)
                .attr('cy', d3.event.y)
                
    ### --- Circle creation --- ###
    
    ### create a rectangle to serve as background ###
    background = vis.append('rect')
        .attr('class', 'background')
        .attr('width', vis.attr('width'))
        .attr('height', vis.attr('height'))
        
    ### when the user clicks the background ###
    background.on 'click', () ->
        ### retrieve mouse coordinates ###
        p = d3.mouse(this)
        
        ### create a new circle at point p ###
        vis.append('circle')
            .attr('class', 'node')
            .attr('r', 20)
            .attr('cx', p[0])
            .attr('cy', p[1])
            .call(drag)
            

