/**
 * -----------------------------------------------------------------------
 * Simple Value Object for places read from the KML file.
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
package com.netthreads.vo
{
    public class PlaceVO
    {
		[Bindable] public var id : String;
		
		[Bindable] public var description : String;
		
		[Bindable] public var latitude:Number;
		[Bindable] public var longitude:Number;
    	
		[Bindable] public var iconURL: String;
    	
        /**
        * Clone values. Keep this up to date.
        * 
        */ 
        public function clone(place:PlaceVO):void
        {
        	this.id = place.id;

        	this.description = place.description;

        	this.latitude = place.latitude;
        	this.longitude = place.longitude;
        	
        	this.iconURL = place.iconURL;
        }
        
        /**
        * Dump contents as string.
        * 
        */
        public function toString() : String
        {
            var s : String = "PlaceVO[";
            s += ", id=";
            s += id;
            s += ", description=";
            s += ", latitude=";
            s += latitude;
            s += ", longitude=";
            s += longitude;
            s += ", iconURL=";
            s += iconURL;
            s += " ]";
            return s;
        }
    }
    
}