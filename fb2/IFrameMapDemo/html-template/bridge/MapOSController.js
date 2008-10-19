/*
 * MapOSController - This hides the implementation details of the map client interface
 * inside a controller specific to the target map type. I.e. if we were using Google maps
 * there would be a GoogleMapController class and we would plug that into the client instead.
 * 
 * MIT License. A. Rutherford, www.netthreads.co.uk
 */
function MapOSController(map)
{
    this.map = map;
    this.zoom = 12;
}

MapOSController.prototype.resizeFrame = function(width, height)
{
    try
    {
		// Resize the frame
		var mapDiv = document.getElementById("map");
		mapDiv.style.width = width+"px";
		mapDiv.style.height = height+"px";
		
		// Trigger 'moveend' handler    	
		this.map.events.triggerEvent("moveend");
    }
    catch(e)
    {
    	// For some reason calling the triggerEvent method throws this exception. Still works though.
    }
}	

MapOSController.prototype.addMapViewChangedHandler = function(handler)
{
	var self = this;

    this.mapViewChangedHandler = handler;
    
    this.map.events.register('moveend', this, function(e)
	{
		var bounds = this.map.getExtent();
		
		var left = bounds.left;
		var bottom = bounds.bottom;
		var right = bounds.right;
		var top = bounds.top;
				
    	self.mapViewChangedHandler(left, top, right, bottom);
	});
		
}

MapOSController.prototype.centerOn = function(latitude, longitude)
{
	try
	{
		var zoom = this.map.getZoom();
		
		//console.info(zoom);
		
        var lonLat = this.lonLatToMercator(new OpenLayers.LonLat(longitude, latitude));
		
		//console.info(lonLat);
		        
        this.map.setCenter(lonLat, zoom);
    }
    catch(e)
    {
    	//console.error(e);
    }
}
        
// Function to convert normal latitude/longitude to mercator easting/northings
// This is fairly typical of the gnarly stuff you want to put into the controller.
MapOSController.prototype.lonLatToMercator= function(merc) 
{
    var lon = merc.lon * 20037508.34 / 180;
    var lat = Math.log (Math.tan ((90 + merc.lat) * Math.PI / 360)) / (Math.PI / 180);
    lat = lat * 20037508.34 / 180;

    return new OpenLayers.LonLat(lon, lat);
}
