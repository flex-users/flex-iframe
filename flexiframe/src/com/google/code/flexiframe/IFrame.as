/**
 * Copyright (c) 2009 flex-iframe
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
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * -------------------------------------------------------------------------------------------------
 * $Id$
 * -------------------------------------------------------------------------------------------------
 */
package com.google.code.flexiframe
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.external.ExternalInterface;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import mx.core.Container;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.events.IndexChangedEvent;
    import mx.events.MoveEvent;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.logging.targets.TraceTarget;
    import mx.managers.BrowserManager;
    import mx.utils.URLUtil;
    
    /**
    * The event dispatched when the IFrame is loaded.
    * 
    * @eventType flash.events.Event
    */
    [Event(name="frameLoad", type="flash.events.Event")] 


    /**
    * An IFrame which you can embed into Flex applications to show an HTML page.
    * 
    * <p><b>Usage:</b><br/>
    * You must instantiate the IFrame with a unique identifier
    * (such as <code>&lt;IFrame id="myIFrame"&gt;</code> or
    * <code>var myIFrame:IFrame = new IFrame();</code>). You can assign a source
    * (<code>myIFrame.source = "http://www.google.com";</code>) or HTML content
    * (<code>myIFrame.content = "some html content...";</code>).</p>
    * 
    * <p><b>Advanced features:</b>
    *   <ul>
    *       <li>The IFrame can detect overlapping objects and hide automatically by activating the
    * overlay detection system (<code>myIFrame.overlayDetection = true;</code>).</li>
    *       <li>You can setup a loading indicator that will be displayed while the IFrame is
    *           loading (<code>myIFrame.loadIndicatorClass = myClass;</code>)</li>
    *       <li>You can call a function on the IFrame document. See the <code>callIFrameFunction</code>
    *           method documentation.</li>
    *   </ul>
    * </p>
    * 
    * @example A simple application with Google embedded
    * <listing version="3.0">
    * &lt;mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" 
    *                 xmlns:flexiframe="http://code.google.com/p/flex-iframe/"&gt;
    * 
    *     &lt;flexiframe:IFrame id="googleIFrame"
    *                        label="Google"
    *                        source="http://www.google.com"
    *                        width="80%"
    *                        height="80%"/&gt;
    * 
    * &lt;mx:Application&gt;
    * </listing>
    * For more advanced examples, check out the project home page.
    * 
    * @see http://code.google.com/p/flex-iframe
    * @author Alistair Rutherford (www.netthreads.co.uk)
    * @author Christophe Conraets (http://coenraets.org)
    * @author Brian Deitte (http://www.deitte.com)
    * @author Ryan Bell
    * @author Max
    * @author Julien Nicoulaud
    */
    public class IFrame extends Container
    {

        /**
        * Build a new IFrame.
        */
        public function IFrame()
        {
            // Call super class constructor
            super();
            
            // Listen to the stage events
            this.addEventListener(Event.REMOVED_FROM_STAGE, handleRemove);
            this.addEventListener(Event.ADDED_TO_STAGE, handleAdd);
        }
        
        
        // =========================================================================================
        // IFrame construction & management
        // =========================================================================================
        
        // Variables
        
        /**
        * Track IDs in use throughout the app for iframe instances in order to detect and
        * prevent collisions.
        */
        public static var idList:Object = new Object();
        
        /**
        * Application host.
        * 
        * Used to check potential cross-domain issues.
        */
        protected static var appHost:String;
        
        /**
        * IFrame content host.
        * 
        * Used to check potential cross-domain issues.
        */
        protected var iframeContentHost:String;
        
        /**
        * The source of the IFrame.
        */
        protected var __source:String;
        
        /**
        * The content of the IFrame.
        */
        protected var __content:String;
        
        /**
        * The frame ID.
        */
        protected var frameId:String;
        
        /**
        * The IFrame ID.
        */
        protected var iframeId:String;
        
        /**
        * The validity of the frame for the display.
        * 
        * @default true
        */
        protected var validForDisplay:Boolean = true;
        
        /**
        * Wether the frame is loaded or not.
        * 
        * @default false
        */
        protected var frameLoaded:Boolean = false;
        
        /**
        * The queued functions waiting for the frame to be loaded.
        */
        protected var functionQueue:Array = [];


        // Overriden functions

        /**
        * Generate DOM elements and build display path.
        */
        override protected function createChildren():void
        {
        	// Call super class method
            super.createChildren();
            
            // Check the external interface availability
            if (!ExternalInterface.available)
            {
                throw new Error("ExternalInterface is not available in this container. Internet " + 
                                "Explorer ActiveX, Firefox, Mozilla 1.7.5 and greater, or other " + 
                                "browsers that support NPRuntime are required.");
            }
            
            // Get the host info to check for cross-domain issues
            if (!appHost)
            {
                BrowserManager.getInstance().initForHistoryManager();
                var url:String = BrowserManager.getInstance().url;
                if (url)
                {
                    appHost = URLUtil.getProtocol(url) + "://" +
                              URLUtil.getServerNameWithPort(url);
                }
                else
                {
                    appHost = "unknown";
                }
            }

            // Generate unique id's for frame div name
            var idSuffix:int = 0;
            while (idList[id + idSuffix])
            {
                idSuffix++;
            }
            frameId = id + idSuffix;
            iframeId = "iframe_"+frameId;
            idList[frameId] = true;
            
            // Register a uniquely-named load event callback for this frame (for load notification)
            ExternalInterface.addCallback(frameId + "_load", this.handleFrameLoad);
            
            // Add functions to DOM if they aren't already there
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_CREATEIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_MOVEIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_HIDEIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_SHOWIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_SHOWDIV);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_HIDEDIV);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_LOADIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_LOADDIV_CONTENT);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_CALLIFRAMEFUNCTION);

            // Insert frame into DOM using our precreated function 'createIFrame'
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_CREATEIFRAME, frameId);
               
            buildContainerList();

            if (loadIndicatorClass)
            {
                logger.debug("loadIndicatorClass is {0}", loadIndicatorClass);
                _loadIndicator = UIComponent(new loadIndicatorClass());
                addChild(_loadIndicator);
            }
            else
            {
                logger.debug("loadIndicatorClass is null");
            }
        }
        
        /**
        * Triggered when display contents change. Adjusts frame layout.
        * 
        * @param unscaledWidth
        * @param unscaledHeight
        */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if (_loadIndicator)
            {
                if (frameLoaded)
                {
                    _loadIndicator.visible = false;
                }
                else
                {
                    _loadIndicator.visible = true;
                    var w:int = _loadIndicator.measuredWidth;
                    var h:int = _loadIndicator.measuredHeight;
                    _loadIndicator.setActualSize(w, h);
                    _loadIndicator.move((this.width - w) / 2, (this.height - h) / 2);
                }
            }
            
            // make sure we are allowed to display before doing the work of positioning the frame
            if (validForDisplay)
                moveIFrame();
        }

        /**
        * Triggered by change to component properties.
        */
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if (source)
            {
                frameLoaded = false;
                ExternalInterface.call(IFrameExternalCalls.FUNCTION_LOADIFRAME, frameId, iframeId, source);
                logger.debug("load Iframe id {0}", frameId);
                // Trigger re-layout of iframe contents.                
                invalidateDisplayList();
            } 
            else if (content) 
            {
                ExternalInterface.call(IFrameExternalCalls.FUNCTION_LOADDIV_CONTENT, frameId, iframeId, content);
                logger.debug("load Content id {0}", frameId);
                // Trigger re-layout of iframe contents.                
                invalidateDisplayList();
            }
        }
        
        // Event handlers
        
       /**
        * Triggered by addition of this object to the stage.
        * 
        * @param event Event trigger
        */
        protected function handleAdd(event:Event):void
        {
            // Hook the systemManager to provide overlaying object detection
            if (overlayDetection)
            {
                systemManager.addEventListener(Event.ADDED, systemManager_addedHandler);
                systemManager.addEventListener(Event.REMOVED, systemManager_removedHandler);
            }
            visible = true;
        }

        /**
        * Triggered by removal of this object from the stage.
        * 
        * @param event Event trigger
        */
        protected function handleRemove(event:Event):void
        {
            // Remove systemManager hooks for overlay detection 
            if (overlayDetection)
            {
                systemManager.removeEventListener(Event.ADDED, systemManager_addedHandler);
                systemManager.removeEventListener(Event.REMOVED, systemManager_removedHandler);
            }
            visible = false;
        }

        /**
        * Triggered by one of our listeners seeded all the way up the display
        * list to catch a 'changed' event which might hide or display this object.
        * 
        * @param event Event trigger
        */
        protected function handleChange(event:Event):void
        {
            var target:Object = event.target;
            
            if (event is IndexChangedEvent)
            {
                var changedEvent:IndexChangedEvent = IndexChangedEvent(event)
                var newIndex:Number = changedEvent.newIndex;
                
                visible = checkDisplay(target, newIndex);
                logger.debug("Frame {0} set visible to {1} on IndexChangedEvent", frameId, visible);
            }
        }
        
       /**
        * Triggered by one of our listeners seeded all the way up the display
        * list to catch a 'move' event which might reposition this object.
        * 
        * @param event Event trigger
        */
        protected function handleMove(event:Event):void
        {
            // This will cause moveIFrame() to be called in the next validation cycle
            invalidateDisplayList(); 
        }
        
        /**
        * Trigered when the IFrame is loaded.
        */
        protected function handleFrameLoad():void
        {            
            logger.debug("browser reports frame loaded with id {0}", frameId);
            frameLoaded = true;
            var queuedCall:Object;
            var result:Object;
            // Execute any queued function calls now that the frame is loaded
            while (functionQueue.length > 0)
            {
                queuedCall = functionQueue.pop();
                logger.debug("frame id {0} calling queued function {1}", frameId, queuedCall.functionName);
                this.callIFrameFunction(queuedCall.functionName, queuedCall.args, queuedCall.callback);
            }
            dispatchEvent(new Event("frameLoad"));
            
            invalidateDisplayList();
        }
        
        
        // IFrame management
        
        /**
        * This function updates the selected view child of the signalling container
        * and then compares the path from our IFrame up the displaylist to see if
        * the index settings match. Only an exact match all the way down to our
        * IFrame will satisfy the condition to display the IFrame contents.
        *
        * @param target Object event source
        * @param newIndex Number index from target object.
        * 
        */
        protected function checkDisplay(target:Object, newIndex:Number):Boolean
        {
            var valid:Boolean = false;
            if (target is Container)
            {
                var container:DisplayObjectContainer = DisplayObjectContainer(target);
                
                // Update current setting
                settingDict[container] = newIndex;
                
                valid = true;
                
                for (var item:Object in containerDict)
                {
                    var index:Number = lookupIndex(item as Container);
                    var setting:Number = lookupSetting(item as Container);
                    logger.debug(item.toString());
                    valid = valid&&(index==setting);
                }
            }
            
            // Remember this state so we can re-check later without a new IndexChangedEvent
            validForDisplay = valid;
            return valid;
        }
        
        /**
        * Adjust frame position to match the exposed area in the application.
        */
        protected function moveIFrame(): void
        {

            var localPt:Point = new Point(0, 0);
            var globalPt:Point = this.localToGlobal(localPt);

            ExternalInterface.call(IFrameExternalCalls.FUNCTION_MOVEIFRAME, frameId, iframeId, globalPt.x, globalPt.y, this.width, this.height);
            logger.debug("move iframe id {0}", frameId);
        }
        
        /**
        * Set source url
        * 
        * @param url Frame contents
        */
        public function set source(source: String): void
        {
            if (source)
            {
                __source = source;
                // mark unloaded now so calls in this frame will be queued 
                frameLoaded = false; 
                invalidateProperties();
                
                // Get the host info to check for cross-domain issues
                iframeContentHost = URLUtil.getProtocol(source) + "://" +
                                    URLUtil.getServerNameWithPort(source);     
            }
        }

        /**
        * Return url of frame contents
        */
        public function get source(): String
        {
            return __source;
        }
        
        /**
        * Set content string
        */
        public function set content(content: String): void
        {
            if (content)
            {
                __content = content;

                invalidateProperties();                
            }
        }

        /**
        * Return content string of div contents
        */
        public function get content(): String
        {
            return __content;
        }
        
        /**
        * Sets visibility of html iframe. Rtn calls inserted javascript functions.
        * 
        * @param visible Boolean flag
        */
        override public function set visible(value: Boolean): void
        {
            super.visible = value;

            // if we have an iframe in the same domain as the app, call the
            // specialized functions to update visibility inside the iframe
            if (visible && validForDisplay)
            {
                if (source && iframeContentHost == appHost)
                    ExternalInterface.call(IFrameExternalCalls.FUNCTION_SHOWIFRAME,frameId,iframeId);
                else
                    ExternalInterface.call(IFrameExternalCalls.FUNCTION_SHOWDIV,frameId,iframeId);
                logger.debug("show iframe id {0}", frameId);
                
                // make sure position and status indicators get updated when revealed
                invalidateDisplayList();
                
            }
            else 
            {
                if (source && iframeContentHost == appHost)
                    ExternalInterface.call(IFrameExternalCalls.FUNCTION_HIDEIFRAME,frameId,iframeId);
                else
                    ExternalInterface.call(IFrameExternalCalls.FUNCTION_HIDEDIV,frameId,iframeId);
                logger.debug("hide iframe id {0}", frameId);
            }
        }


        // =========================================================================================
        // Application objects hierarchy path
        // =========================================================================================

        /**
        * The dictionnary of the hierarchy of the parent containers.
        */
        private var containerDict:Object = null;
        
        /**
        * The dictionnary of the child indexes in the hierarchy of the parent containers.
        */
        private var settingDict:Object = null;

        /**
        * Build list of container objects on the display list path all the way down
        * to this object. We will seed the container classes we find with an event
        * listener which will be used to test if this object is to be displayed or not.
        * 
        * When the component is created the display list is traversed from the 
        * component down to the root element. At each traversal a test is made to 
        * see if current component is a container. If it is a container then the 
        * child of the element which leads back to the component is determined and 
        * a note madeof the appropriate 'index' on the path. The index is stored 
        * against a reference to the Container in a Dictionary. Also the container
        * is 'seeded' with an event handler so that if the container triggers an
        * IndexChangedEvent.CHANGE (i.e. when you click on a tab in a tab navigator)
        * the path of 'index' values down to the component can be checked. If the
        * path indicates that the indexes 'line up' to expose the component then
        * the view is made visible.
        */
        protected function buildContainerList():void
        {
            // We are going to store containers against index of child which leads down
            // to IFrame item.
            containerDict = new Dictionary();
            settingDict = new Dictionary();

            var current:DisplayObjectContainer = parent;
            var previous:DisplayObjectContainer = this;
            
            while (current!=null)
            {
                if (current is Container)
                {
                    if (current.contains(previous))
                    {
                        
                        var childIndex:Number = current.getChildIndex(previous);                
                        logger.debug("index: {0}", childIndex);
                        
                        // Store child index against container
                        containerDict[current] = childIndex;
                        settingDict[current] = childIndex;
                        
                        // Tag on a change listener             
                        current.addEventListener(IndexChangedEvent.CHANGE, handleChange);
                        current.addEventListener(MoveEvent.MOVE, handleMove);
                    }
                    
                }        
                
                previous = current;
                current = current.parent;
            }
            // make sure frame runs visible setter using initial visible state
            visible = visible;
        }
        
        /**
        * Return index of child item on path down to this object. If not
        * found then return -1;
        *
        * @param target Container object
        */
        public function lookupIndex(target:Container):Number
        {
            var index:Number = -1;
            
            try
            {
                index = containerDict[target];
            }
            catch (e:Error)
            {
                // Error not found, we have to catch this or a silent exception
                // will be thrown.
                logger.debug(e.toString());
            }
            
            return index;
        }

        /**
        * Return index of child item on path down to this object. If not
        * found then return -1;
        *
        * @param target Container object
        */
        public function lookupSetting(target:Container):Number
        {
            var index:Number = -1;
            
            try
            {
                index = settingDict[target];
            }
            catch (e:Error)
            {
                // Error not found, we have to catch this or a silent exception
                // will be thrown.
                logger.debug(e.toString());
            }
            
            return index;
        }
        

        // =========================================================================================
        // Loading indicator
        // =========================================================================================
        
        /**
        * A UIComponent class to display centered over the iframe container while
        * the browser is loading its content. Should implement measuredHeight
        * and measuredWidth in order to be properly sized.
        */
        public var loadIndicatorClass:Class;
        
        /**
        * The instance of the load indicator class.
        */
        protected var _loadIndicator:UIComponent;


        // =========================================================================================
        // Overlay object detection
        // =========================================================================================

        /**
        * The state of the overlay detection system (experimental).
        * 
        * @default false
        */
        public var overlayDetection:Boolean = false;
                        
        /**
        * A dictionnary holding the objects overlapping the IFrame.
        */
        protected var overlappingDict:Dictionary = new Dictionary(true);
        
        /**
        * The count of the objects overlapping the IFrame.
        */
        protected var overlapCount:int = 0;
        
        /**
        * Triggered when the object is added to the stage.
        */
        protected function systemManager_addedHandler(event:Event):void
        {
            // A display object was added somewhere
            var displayObj:DisplayObject = event.target as DisplayObject;
            if (displayObj.parent == systemManager && displayObj.name != "cursorHolder")
            {
                // If the object is a direct child of systemManager (i.e it floats) and isn't the cursor, 
                // check to see if it overlaps me after it's been drawn
                this.callLater(checkOverlay, [displayObj]);
            }
        }

        /**
        * Triggered when the object is removed from the stage.
        */
        protected function systemManager_removedHandler(event:Event):void
        {
            // A display object was removed somewhere
            var displayObj:DisplayObject = event.target as DisplayObject;
            if (displayObj.parent == systemManager && overlappingDict[displayObj])
            {
                logger.debug("iframe {0} heard REMOVE for {1}", frameId, displayObj.toString());
                // If the object is a direct child of systemManager and was an overlapping object, remove it
                delete overlappingDict[displayObj];
                if (--overlapCount == 0)
                {
                    visible = validForDisplay;
                }
                
                if (displayObj is UIComponent)
                {
                    // Remove listeners for hide and show events on overlappiung UIComponents
                    UIComponent(displayObj).removeEventListener(FlexEvent.HIDE, overlay_hideShowHandler);
                    UIComponent(displayObj).removeEventListener(FlexEvent.SHOW, overlay_hideShowHandler);
                }
            }
        }

        /**
        * Triggered when an overlapping object is shown or hidden.
        */
        protected function overlay_hideShowHandler(event:FlexEvent):void
        {
            var displayObj:DisplayObject = event.target as DisplayObject;
            if (event.type == FlexEvent.SHOW && !overlappingDict[displayObj])
            {
                logger.debug("iframe {0} heard SHOW for {1}", frameId, displayObj.toString());
                overlappingDict[displayObj] = displayObj;
                overlapCount++;
                visible = false;
            }
            else if (event.type == FlexEvent.HIDE && overlappingDict[displayObj])
            {
                logger.debug("iframe {0} heard HIDE for {1}", frameId, displayObj.toString());
                delete overlappingDict[displayObj];
                if (--overlapCount == 0)
                {
                    visible = validForDisplay;
                }
            }
        }

        /**
        * Check to see if the given DisplayObject overlaps this object.
        * If so, add it to a dictionary of overlapping objects and update
        * this object's visibility.
        */
        protected function checkOverlay(displayObj:DisplayObject):void
        {            
            if (this.hitTestStageObject(displayObj))
            {
                logger.debug("iframe {0} detected overlap of {1}", frameId, displayObj.toString());
                overlappingDict[displayObj] = displayObj;
                overlapCount++;
                visible = false;
                
                if (displayObj is UIComponent)
                {
                    // Listen for hide and show events on overlapping UIComponents
                    // (ComboBox dropdowns for example aren't removed after use; they're just hidden)
                    UIComponent(displayObj).addEventListener(FlexEvent.HIDE, overlay_hideShowHandler, false, 0, true);
                    UIComponent(displayObj).addEventListener(FlexEvent.SHOW, overlay_hideShowHandler, false, 0, true);
                }
            }
        }

        /**
        * The native hitTestObject method seems to have some issues depending on
        * the situation. This is a custom implementation to work around that.
        * This method assumes that the passed DisplayObject is a direct child
        * of the stage and therefore has x and y coordinates that are already global
        */
        protected function hitTestStageObject(o:DisplayObject):Boolean
        {
            var overlapX:Boolean = false;
            var overlapY:Boolean = false;
            
            var localMe:Point = new Point(this.x, this.y);
            var globalMe:Point = this.parent.localToGlobal(localMe);
            
            var myLeft:int = globalMe.x;
            var myRight:int = globalMe.x + this.width;
            var oLeft:int = o.x;
            var oRight:int = o.x + o.width;
            
            // Does object's left edge fall between my left and right edges?
            overlapX = oLeft >= myLeft && oLeft <= myRight;
            // Or does my left edge fall between object's left and right edges?
            overlapX ||= oLeft <= myLeft && oRight >= myLeft;
            
            var myTop:int = globalMe.y;
            var myBottom:int = globalMe.y + this.height;
            var oTop:int = o.y;
            var oBottom:int = o.y + o.height;
            
            // Does object's top edge fall between my top and bottom edges?
            overlapY = oTop >= myTop && oTop <= myBottom;
            // Or does my top edge fall between object's top and bottom edges?
            overlapY ||= oTop <= myTop && oBottom >= myTop;
            
            return overlapX && overlapY;
        }


        // =========================================================================================
        // IFrame function call
        // =========================================================================================
                
        /**
        * Calls a function of the specified name defined on the IFrame document
        * (like document.functionName = function () {...} ), passing it an array of arguments.
        * May not work if the iframe contents are in a different domain due to security.
        * 
        * If the frame contents are loaded when this method is called, it will return any
        * results from the function immediately to the caller (as well as to the callback
        * function, if defined). Otherwise, the call will be queued, this method will return
        * null, and results will be passed to the callback function after the frame loads
        * and the queued function call executes.
        * 
        * @param functionName String Name of function to call
        * @param args Array List of arguments to pass as an array
        * @param callback Function to call (if any) with results of IFrame function execution
        */
        public function callIFrameFunction(functionName:String,
                                           args:Array = null,
                                           callback:Function = null):String
        {
            if (!source)
            {
                throw new Error("No iframe to call functions on");
            }
            if (iframeContentHost != appHost)
            {
                var msg:String = "Warning: attempt to call function " + functionName + 
                                 " on iframe " + frameId + " may fail due to cross-domain security.";
                logger.debug(msg);
            }
            
            if (frameLoaded)
            {
                // Call the function immediately
                var result:Object = ExternalInterface.call(IFrameExternalCalls.FUNCTION_CALLIFRAMEFUNCTION,
                                                           iframeId,
                                                           functionName,
                                                           args);
                if (callback != null)
                {
                    callback(result);
                }
                return String(result);
            }
            else
            {
                // Queue the function for call once the iframe has loaded
                var queuedCall:Object = {functionName: functionName, args: args, callback:callback};
                functionQueue.push(queuedCall);
                return null;
            }
        }


        // =========================================================================================
        // Debug mode
        // =========================================================================================
        
        /**
        * The state of the debug mode.
        */
        private var _debug:Boolean = false;
        
        /**
        * The target for the logger.
        */
        private var logTarget:TraceTarget;
        
        /**
        * The class logger.
        */
        private static var logger:ILogger = Log.getLogger("IFrame");
                
        /**
        * Get the state of the debug mode.
        */
        public function get debug():Boolean
        {
            return _debug;
        }
        
        /**
        * Set the state of the debug mode.
        */
        public function set debug(value:Boolean):void
        {
            if (value == debug)
                return;
            
            if (value)
            {
                if (!logTarget)
                    logTarget = new TraceTarget();
                logTarget.addLogger(logger);
            }
            else
            {
                if (logTarget)
                    logTarget.removeLogger(logger);
            }
            
            _debug = value;
        }
        
    }
}
