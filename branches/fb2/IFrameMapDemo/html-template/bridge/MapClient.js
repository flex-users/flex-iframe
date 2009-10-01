/*
 * MapClient presents common interface for map functions. The controller implements the 
 * target map type functionality.
 * 
 * MIT License. A. Rutherford, www.netthreads.co.uk
 */

function MapClient(frame, controller)
{
	this.frame = frame;
	this.controller = controller;

    // Offset from the edge of the frame. Is more for IE than other browsers.
	if (this.IS_IE)
	{
		this.offset = 35;
	}
	else
	{
		this.offset = 20;
	}
}

MapClient.prototype.IS_IE =  navigator.appName.toUpperCase() == 'MICROSOFT INTERNET EXPLORER';

MapClient.prototype.include = function(src, type)
{
	type = type || 'text/javascript';
	
	if (this.IS_IE)
	{
		document.write('<script src="'+src+'"></script>');
	}
	else
	{
		var script = document.createElement('script');
		
		script.setAttribute('type', type);
		script.setAttribute('src', src);

		var head = document.getElementsByTagName('head')[0];
   		head.appendChild(script);
   	}
}

MapClient.prototype.init = function()
{
    var self = this;
    
    this.frame.FABridge.addInitializationCallback("flash", function()
	{
	    
	    var flexApp = self.frame.FABridge.flash.root();
	    
	    // ---------------------------------------------------------------
	    // Register event handlers
	    // ---------------------------------------------------------------
	    flexApp.addEventListener("ResizeFrameEvent", function(event) {self.controller.resizeFrame(event.getWidth()-self.offset, event.getHeight()-self.offset)});
	    flexApp.addEventListener("CentreFrameEvent", function(event) {self.controller.centerOn(event.getLatitude(), event.getLongitude())});
	    
	    // ---------------------------------------------------------------
	    // Register client handlers
	    // ---------------------------------------------------------------
	    self.controller.addMapViewChangedHandler(function(a,b,c,d)
	    {
	    	var flexApp = self.frame.FABridge.flash.root();
	    	flexApp.onMapViewChanged(a,b,c,d);
	    });
	    
	    // ---------------------------------------------------------------
	    // Send map ready to application which will show it.
	    // ---------------------------------------------------------------
	    flexApp.onMapReady();
	    
	    // ---------------------------------------------------------------
	    // Initial resize
	    // ---------------------------------------------------------------
	    self.controller.resizeFrame(flexApp.getMapFrame().getWidth()-self.offset, flexApp.getMapFrame().getHeight()-self.offset);
	});
}


