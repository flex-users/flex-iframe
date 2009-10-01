/**
 * -----------------------------------------------------------------------
 * The purpose of the controller class is to route view events from the event source 
 * to the top level where they can be picked up by listeners registered by FABridge.
 * 
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
package com.netthreads.view.controller
{
    import flash.events.Event;

    import com.netthreads.util.IFrame;
    import com.netthreads.event.ResizeFrameEvent;
    import com.netthreads.event.CentreFrameEvent;
    
    [Event(name="CentreFrameEvent", type="flash.events.Event")]
	[Event(name="ResizeFrameEvent", type="flash.events.Event")]

    /**
    * Main Map ViewController
    * 
    * Note: Because this is used as an mxml component the constructor has no parameters.
    *
    */
    public class MapViewController extends ViewController
    {
		public static var GROUP_NAME:String = "situations";
		
        [Bindable] public var map:IFrame = null;

        /**
        * Make a note of our frame object.
        * 
        */
        public function MapViewController()
        {
        	// Nowt
        }
        
        /**
        * Called by map control when resized
        * 
        */
		public function resize():void
		{
			var ev:ResizeFrameEvent = new ResizeFrameEvent(map.width, map.height);
			this.dispatchEvent(ev);
		}

        /**
        * Called by map control when resized
        * 
        */
		public function centre(latitude:Number, longitude:Number):void
		{
			var ev:CentreFrameEvent = new CentreFrameEvent(latitude, longitude);
			this.dispatchEvent(ev);
		}
        
    }
}