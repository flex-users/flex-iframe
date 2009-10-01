/**
 * -----------------------------------------------------------------------
 * Meta data.
 * -----------------------------------------------------------------------
 * Copyright 2008 -  Alistair Rutherford - www.netthreads.co.uk, Jan 2008
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
	public class MetaDataLocator
	{
        private static var instance:MetaDataLocator = null;
        
        public static var TITLE:String = "IFrame Map Demo";
        public static var VERSION:String = "0.1.0";
        public static var COPYRIGHT:String = "(c) Alistair Rutherford";
        public static var LINK:String = "www.netthreads.co.uk";

        [Bindable] public var displayTitle:String = TITLE;
        [Bindable] public var displayVersion:String = VERSION;
        [Bindable] public var displayCopyright:String = COPYRIGHT;
        [Bindable] public var displayLink:String = LINK;

		/**
		* Singleton access
		* 
		*/
        public static function getInstance():MetaDataLocator
        {
            if ( instance == null )
            {
                instance = new MetaDataLocator();
            }
            
            return instance;
        }        
         
	}
}