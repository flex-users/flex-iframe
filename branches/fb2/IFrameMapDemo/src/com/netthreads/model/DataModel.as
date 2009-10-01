/**
 * -----------------------------------------------------------------------
 * DataModel
 * 
 * Parses supplied KML for placemark data and generates master list of VOs
 * 
 * Relevant views are notified to a change in the data by adding listeners. 
 * -----------------------------------------------------------------------
 * Copyright 2008 -  Alistair Rutherford - www.netthreads.co.uk, Apr 2008
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * -----------------------------------------------------------------------
 */
package com.netthreads.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import com.netthreads.vo.PlaceVO;
	
    [Event(name="updated", type="flash.events.Event")]
	
	public class DataModel extends EventDispatcher
	{
	    // ---------------------------------------------------------------
	    // These defns are needed to help ES4 parse the loaded xml
	    // ---------------------------------------------------------------
        private namespace webNameSpace = "http://earth.google.com/kml/2.2";
        use namespace webNameSpace;
            		
		public static var EVENT_UPDATED:String = "updated";
		
		private static var _instance:DataModel = null;
		private var _data:ArrayCollection = null;
		
		private var request:HTTPService = null; 

		
        /**
        * Singleton access. 
        * 
        */
		public static function getInstance():DataModel
		{
			if (_instance==null)
			{
				_instance = new DataModel();
			}
			
			return _instance;
		}

        /**
        * Constructor. Build service. 
        * 
        */
		public function DataModel():void
		{
			// Holds data
			_data = new ArrayCollection();
			
			// Build request from scratch
			request = new HTTPService();
			
			request.url = "assets/henge.xml";
			request.resultFormat=HTTPService.RESULT_FORMAT_E4X;
			
			request.addEventListener(ResultEvent.RESULT, onResult)
			request.addEventListener(FaultEvent.FAULT, onFault)
		}
		
		/**
		 * Handle result of request.
		 * 
		 */		
		public function onResult(event:*=null):void
		{
		    // Extract VO's from result	
            var xmlResult:XML = XML(event.result);
            
            var places:XMLList = xmlResult..Placemark; // Note: dotdot notation. e4x
            
			_data.removeAll();
			
		    for each (var value:* in places) // e4x
            {
                var place:PlaceVO = parsePlacemark(value);

				_data.addItem(place);                
            }
    
            // Send message to subscribed views
            this.dispatchEvent(new Event(EVENT_UPDATED));

            trace("data recieved");
		}

		/**
		 * Request fault.
		 * 
		 */
		public function onFault(event:FaultEvent):void
		{
			trace(event);
		}

		/**
		 * Reload data.
		 * 
		 */		
		public function refresh():void
		{
			// Send request for data
			request.send();
		}

		/**
		 * Return reference to data list.
		 *  
		 */		
		public function get data():ArrayCollection
		{
			return _data;
		}

		/**
		 * Parse individual block of XML. 
		 *
		 */
		private function parsePlacemark(data:XML):PlaceVO
		{
			var place:PlaceVO = null;
			
			try
			{
            	var id : String = data.name;
            	
            	var description : String = data.description;
            	
            	// Process positions
            	var lnglat:String = data.Point.coordinates
				var coords:Array = lnglat.split(",");
										
            	var latitude:Number = Number(coords[1]);
            	var longitude:Number = Number(coords[0]);

				place = new PlaceVO();
				
				place.id = id;
				
				place.description = description;
				
				place.latitude = latitude;
				place.longitude = longitude;
			}
			catch(e:Error)
			{
				trace(e);
			}
			
			return place;		
		}		 
	}
	
}