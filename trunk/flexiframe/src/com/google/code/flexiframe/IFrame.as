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
    import flash.utils.getQualifiedClassName;

    import mx.controls.ToolTip;
    import mx.core.Application;
    import mx.core.Container;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.events.IndexChangedEvent;
    import mx.events.MoveEvent;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.logging.LogEventLevel;
    import mx.logging.targets.TraceTarget;
    import mx.utils.URLUtil;

    /**
     * The event dispatched when the IFrame is loaded.
     *
     * @eventType flash.events.Event
     */
    [Event(name="frameLoad", type="flash.events.Event")]

    /**
     * The icon file for the IFrame component.
     *
     * Appears in FlexBuilder's outline and design views.
     */
    [IconFile("assets/flex-iframe-logo-16.png")]

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
         *
         * @param id: a String identifying the IFrame. Must be unique for every instance of the
         *            IFrame class.
         *
         * @example Declare an IFrame in MXML.
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
         *
         * @example Declare an IFrame in ActionScript.
         * <listing version="3.0">
         * import com.google.code.flexiframe.IFrame;
         *
         * ...
         *
         * var frame : IFrame = new IFrame("aUniqueIdForThisIFrameInstance");
         * </listing>
         */
        public function IFrame(id:String = null)
        {
            // Call super class constructor
            super();

            // Assign the unique id
            if (id != null)
            {
                this.id = id;
            }

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
        protected static var _appHost:String;

        /**
         * IFrame content host.
         *
         * Used to check potential cross-domain issues.
         */
        protected var _iframeContentHost:String;

        /**
         * The source of the IFrame.
         */
        protected var _source:String;

        /**
         * The content of the IFrame.
         */
        protected var _content:String;

        /**
         * The frame ID.
         */
        protected var _frameId:String;

        /**
         * The IFrame ID.
         */
        protected var _iframeId:String;

        /**
         * The validity of the frame for the display.
         *
         * @default true
         */
        protected var _validForDisplay:Boolean = true;

        /**
         * Wether the frame is loaded or not.
         *
         * @default false
         */
        protected var _frameLoaded:Boolean = false;

        /**
         * Force the iFrame to stay hidden whatever happens.
         *
         * @default false
         */
        protected var _hidden:Boolean = false;

        /**
         * The queued functions waiting for the frame to be loaded.
         */
        protected var _functionQueue:Array = [];

        /**
         * The browser zoom ratio
         */
        protected var _browserScaling:Number = 1;


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
                throw new Error("ExternalInterface is not available in this container. Internet " + "Explorer ActiveX, Firefox, Mozilla 1.7.5 and greater, or other " + "browsers that support NPRuntime are required.");
            }

            // Get the host info to check for cross-domain issues
            if (!_appHost)
            {
                var url:String = Application.application.url;
                if (url)
                {
                    _appHost = URLUtil.getProtocol(url) + "://" + URLUtil.getServerNameWithPort(url);
                }
                else
                {
                    _appHost = "unknown";
                }
            }

            // Generate unique id's for frame div name
            var idSuffix:int = 0;
            while (idList[id + idSuffix])
            {
                idSuffix++;
            }
            _frameId = id + idSuffix;
            _iframeId = "iframe_" + _frameId;
            idList[_frameId] = true;

            // Setup the communication with the browser
            setupExternalInterface();

            // Insert frame into DOM
            createIFrame();

            // Build the parent containers list
            buildContainerList();

            // Place and size the iframe
            adjustPosition(true);

            // Setup the load indicator if it was specified.
            if (loadIndicatorClass)
            {
                logger.info("A load indicator class was specified: {0}", getQualifiedClassName(loadIndicatorClass));
                _loadIndicator = UIComponent(new loadIndicatorClass());
                addChild(_loadIndicator);
            }
            else
            {
                logger.info("No load indicator class specified.");
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

            if (_frameLoaded)
            {
                if (_loadIndicator)
                {
                    logger.debug("Frame with id '{0}' loaded, hiding the load indicator.", _frameId);
                    _loadIndicator.visible = false;
                }
                visible = !hidden;
            }
            else if (_loadIndicator)
            {
                logger.debug("Frame with id '{0}' not loaded, showing the load indicator.", _frameId);
                _loadIndicator.visible = true;
                var w:int = _loadIndicator.measuredWidth;
                var h:int = _loadIndicator.measuredHeight;
                _loadIndicator.setActualSize(w, h);
                _loadIndicator.move((this.width - w) / 2, (this.height - h) / 2);
            }

            // make sure we are allowed to display before doing the work of positioning the frame
            if (_validForDisplay)
            {
                adjustPosition();
            }
        }

        /**
         * Triggered by change to component properties.
         */
        override protected function commitProperties():void
        {
            super.commitProperties();

            if (source)
            {
                if (!_frameLoaded)
                {
                    _frameLoaded = false;
                    loadIFrame();
                }
                else
                {
                    logger.debug("The IFrame with id '{0}' is already loaded.", _frameId);
                }
                // Trigger re-layout of iframe contents.                
                invalidateDisplayList();
            }
            else if (content)
            {
                loadDivContent();

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
        protected function handleAdd(event:Event = null):void
        {
            logger.debug("The component for the IFrame with id '{0}' has been added from the stage.", _frameId);

            // Hook the systemManager to provide overlaying object detection
            if (overlayDetection)
            {
                logger.info("Listening to the stage component additions to detect overlapping objects.");
                systemManager.addEventListener(Event.ADDED, systemManager_addedHandler);
                systemManager.addEventListener(Event.REMOVED, systemManager_removedHandler);
            }
            visible = !hidden;
        }

        /**
         * Triggered by removal of this object from the stage.
         *
         * @param event Event trigger
         */
        protected function handleRemove(event:Event = null):void
        {
            logger.debug("The component for the IFrame with id '{0}' has been removed from the stage.", _frameId);

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

                visible = !hidden && checkDisplay(target, newIndex);
                logger.debug("Frame {0} set visible to {1} on IndexChangedEvent", _frameId, visible);
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
            // This will cause adjustPosition() to be called in the next validation cycle
            invalidateDisplayList();
        }

        /**
         * Trigered when the IFrame is loaded.
         */
        protected function handleFrameLoad():void
        {
            logger.info("Browser reports frame with id {0} loaded.", _frameId);
            _frameLoaded = true;
            visible = !hidden;

            // Execute any queued function calls now that the frame is loaded
            var queuedCall:Object;
            while (_functionQueue.length > 0)
            {
                queuedCall = _functionQueue.pop();
                logger.debug("frame id {0} calling queued function {1}", _frameId, queuedCall.functionName);
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
                    valid = valid && (index == setting);
                }
            }

            // Remember this state so we can re-check later without a new IndexChangedEvent
            _validForDisplay = valid;
            return valid;
        }

        /**
         * Adjust frame position to match the exposed area in the application.
         */
        protected function adjustPosition(recalculateBrowserScaling:Boolean = false):void
        {
            var localPt:Point = new Point(0, 0);
            var globalPt:Point = this.localToGlobal(localPt);

            // If needed, recalculate the browser zoom
            if (recalculateBrowserScaling)
            {
                var browserMeasuredWidth:Number = getBrowserMeasuredWidth();

                if (browserMeasuredWidth > 0)
                {
                    _browserScaling = browserMeasuredWidth / Application.application.width;
                }
            }

            // Place the iframe
            moveIFrame(globalPt.x * _browserScaling, globalPt.y * _browserScaling, this.width * _browserScaling, this.height * _browserScaling);
        }

        /**
         * Set source url
         *
         * @param url Frame contents
         */
        public function set source(source:String):void
        {
            if (source)
            {
                _source = source;

                // mark unloaded now so calls in this frame will be queued
                _frameLoaded = false;
                invalidateProperties();

                // Get the host info to check for cross-domain issues
                _iframeContentHost = URLUtil.getProtocol(source) + "://" + URLUtil.getServerNameWithPort(source);
            }
        }

        /**
         * Return url of frame contents
         */
        public function get source():String
        {
            return _source;
        }

        /**
         * Set content string
         */
        public function set content(value:String):void
        {
            if (value)
            {
                _content = value;

                invalidateProperties();
            }
        }

        /**
         * Return content string of div contents
         */
        public function get content():String
        {
            return _content;
        }

        /**
         * Sets visibility of html iframe. Rtn calls inserted javascript functions.
         *
         * @param visible Boolean flag
         */
        override public function set visible(value:Boolean):void
        {
            logger.debug("IFrame with id '{0}' visibility set to '{1}'", _frameId, value);

            super.visible = value;

            // if we have an iframe in the same domain as the app, call the
            // specialized functions to update visibility inside the iframe
            if (visible && _validForDisplay && (_frameLoaded || (!_frameLoaded && loadIndicatorClass == null)))
            {
                if (source && _iframeContentHost == _appHost)
                {
                    showIFrame();
                }
                else
                {
                    showDiv();
                }

                // make sure position and status indicators get updated when revealed
                invalidateDisplayList();

            }
            else
            {
                if (source && _iframeContentHost == _appHost)
                {
                    hideIFrame();
                }
                else
                {
                    hideDiv();
                }
            }
        }

        /**
         * Force the IFrame to stay hidden, whatever happens.
         */
        public function set hidden(value:Boolean):void
        {
            _hidden = value;

            if (value)
            {
                if (visible)
                {
                    visible = false;
                }
            }
            else
            {
                visible = _validForDisplay && _frameLoaded && (!overlayDetection || (overlayDetection && overlapCount == 0));
            }
        }

        /**
         * Get the state of the "hidden" mode.
         */
        public function get hidden():Boolean
        {
            return _hidden;
        }


        // =========================================================================================
        // Application objects hierarchy path
        // =========================================================================================

        /**
         * The dictionnary of the hierarchy of the parent containers.
         */
        protected var containerDict:Object = null;

        /**
         * The dictionnary of the child indexes in the hierarchy of the parent containers.
         */
        protected var settingDict:Object = null;

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

            while (current != null)
            {
                if (current is Container)
                {
                    if (current.contains(previous))
                    {
                        var childIndex:Number = current.getChildIndex(previous);

                        // Store child index against container
                        containerDict[current] = childIndex;
                        settingDict[current] = current.hasOwnProperty("selectedIndex") ? current["selectedIndex"] : childIndex;

                        // Tag on a change listener             
                        current.addEventListener(IndexChangedEvent.CHANGE, handleChange);
                        current.addEventListener(MoveEvent.MOVE, handleMove);
                    }

                }

                previous = current;
                current = current.parent;
            }
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
            if (displayObj.parent == systemManager && displayObj.name != "cursorHolder" && !(displayObj is ToolTip))
            {
                // If the object is a direct child of systemManager (i.e it floats) and isn't the cursor, 
                // or a tooltip, check to see if it overlaps me after it's been drawn
                this.callLater(checkOverlay, [ displayObj ]);
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
                logger.debug("iframe {0} heard REMOVE for {1}", _frameId, displayObj.toString());
                // If the object is a direct child of systemManager and was an overlapping object, remove it
                delete overlappingDict[displayObj];
                if (--overlapCount == 0)
                {
                    visible = !hidden && _validForDisplay;
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
                logger.debug("iframe {0} heard SHOW for {1}", _frameId, displayObj.toString());
                overlappingDict[displayObj] = displayObj;
                overlapCount++;
                visible = false;
            }
            else if (event.type == FlexEvent.HIDE && overlappingDict[displayObj])
            {
                logger.debug("iframe {0} heard HIDE for {1}", _frameId, displayObj.toString());
                delete overlappingDict[displayObj];
                if (--overlapCount == 0)
                {
                    visible = !hidden && _validForDisplay;
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
                logger.debug("iframe {0} detected overlap of {1}", _frameId, displayObj.toString());
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
        public function callIFrameFunction(functionName:String, args:Array = null, callback:Function = null):String
        {
            if (!source)
            {
                throw new Error("No IFrame to call functions on");
            }

            if (_iframeContentHost != _appHost)
            {
                logger.warn("Warning: attempt to call function '{0}' on IFrame '{1}' may fail due to cross-domain security.", functionName, _frameId);
            }

            if (_frameLoaded)
            {
                // Call the function immediately
                var result:Object = ExternalInterface.call(IFrameExternalCalls.FUNCTION_CALLIFRAMEFUNCTION, _iframeId, functionName, args);
                if (callback != null)
                {
                    callback(result);
                }
                return String(result);
            }
            else
            {
                // Queue the function for call once the iframe has loaded
                var queuedCall:Object = { functionName: functionName, args: args, callback: callback };
                _functionQueue.push(queuedCall);
                return null;
            }
        }


        // =========================================================================================
        // SWF embed object tracking
        // =========================================================================================

        /**
         * The SWF embed object id.
         */
        public static var applicationId:String = null;

        /**
         * The random string used to identify the right object.
         */
        protected var randomIdentificationString:Number;

        /**
         * Get the embed object id.
         */
        protected function resolveEmbedObjectId():void
        {
            if (applicationId == null)
            {
                try
                {
                    randomIdentificationString = Math.ceil(Math.random() * 9999 * 1000);
                    ExternalInterface.addCallback('checkObjectId', checkObjectId);
                    var result:Object = ExternalInterface.call(IFrameExternalCalls.FUNCTION_ASK_FOR_EMBED_OBJECT_ID, randomIdentificationString.toString());
                    if (result != null)
                    {
                        applicationId = String(result);
                        logger.info("Resolved the SWF embed object id to '{0}'.", applicationId);
                    }
                    else
                    {
                        logger.error('Could not resolve the SWF embed object Id.');
                    }
                }
                catch (error:Error)
                {
                    logger.error(error.errorID + ": " + error.name + " - " + error.message);
                }
            }
        }

        /**
         * Receive information about a DOM object and test if this is this SWF object.
         */
        protected function checkObjectId(id:String, randomCode:Number):Boolean
        {
            if (randomIdentificationString == randomCode)
            {
                return true;
            }
            return false;
        }


        // =========================================================================================
        // Calls to ExternalInterface
        // =========================================================================================

        /**
         * Inserts the Javascript functions in the DOM, setups the callback and javascripts event
         * listeners.
         */
        protected function setupExternalInterface():void
        {
            logger.info("Inserting Javascript functions in the DOM.");

            // Add the functions to the DOM if they aren't already there.
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_CREATEIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_MOVEIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_HIDEIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_SHOWIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_HIDEDIV);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_SHOWDIV);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_LOADIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_LOADDIV_CONTENT);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_CALLIFRAMEFUNCTION);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_REMOVEIFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_GET_BROWSER_MEASURED_WIDTH);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_PRINT_IFRAME);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_HISTORY_BACK);
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_HISTORY_FORWARD);

            // Resolve the SWF embed object id in the DOM.
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_ASK_FOR_EMBED_OBJECT_ID);
            resolveEmbedObjectId();

            // Register a uniquely-named load event callback for this frame.
            ExternalInterface.addCallback(_frameId + "_load", handleFrameLoad);

            // Setup the browser resize event listener.
            ExternalInterface.call(IFrameExternalCalls.INSERT_FUNCTION_SETUP_RESIZE_EVENT_LISTENER(_frameId));
            setupBrowserResizeEventListener();
            ExternalInterface.addCallback(_frameId + "_resize", function():void
                {
                    adjustPosition(true);
                });
        }

        /**
         * Create the IFrame.
         */
        protected function createIFrame():void
        {
            logger.info("Creating IFrame with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_CREATEIFRAME, _frameId);
        }

        /**
         * Move the IFrame.
         */
        protected function moveIFrame(x:int, y:int, width:int, height:int):void
        {
            logger.info("Moving IFrame with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_MOVEIFRAME, _frameId, _iframeId, x, y, width, height, applicationId);
        }

        /**
         * Hide the IFrame.
         */
        protected function hideIFrame():void
        {
            logger.info("Hiding IFrame with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_HIDEIFRAME, _frameId, _iframeId);
        }

        /**
         * Show the IFrame.
         */
        protected function showIFrame():void
        {
            logger.info("Showing IFrame with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_SHOWIFRAME, _frameId, _iframeId);
        }

        /**
         * Hide the div.
         */
        protected function hideDiv():void
        {
            logger.info("Hiding div with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_HIDEDIV, _frameId);
        }

        /**
         * Show the div.
         */
        protected function showDiv():void
        {
            logger.info("Showing div id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_SHOWDIV, _frameId);
        }

        /**
         * Show the IFrame.
         */
        protected function loadIFrame():void
        {
            logger.info("Loading IFrame with id '{0}', on SWF embed object with id '{1}'.", _frameId, applicationId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_LOADIFRAME, _frameId, _iframeId, source, applicationId);
        }

        /**
         * Load content into a div.
         */
        protected function loadDivContent():void
        {
            logger.info("Loading content on IFrame with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_LOADDIV_CONTENT, _frameId, _iframeId, content);
        }

        /**
         * Remove the IFrame.
         */
        public function removeIFrame():void
        {
            logger.info("Removing IFrame with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_REMOVEIFRAME, _frameId);
        }

        /**
         * Bring the IFrame to the front.
         */
        public function bringIFrameToFront():void
        {
            logger.info("Bring to front IFrame with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_BRING_IFRAME_TO_FRONT, _frameId);
        }

        /**
         * Get the browser measured width.
         */
        protected function getBrowserMeasuredWidth():Number
        {
            logger.info("Get browser measured width.");
            var result:Object = ExternalInterface.call(IFrameExternalCalls.FUNCTION_GET_BROWSER_MEASURED_WIDTH,applicationId);
            if (result != null)
            {
                return new Number(result);
            }
            return new Number(0);
        }

        /**
         * Setup the Browser resize event listener.
         */
        protected function setupBrowserResizeEventListener():void
        {
            logger.info("Setup the Browser resize event listener.");
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_SETUP_RESIZE_EVENT_LISTENER);
        }

        /**
         * Print the content of the IFrame.
         */
        public function printIFrame():void
        {
            logger.info("Print the iFrame with id '{0}'.", _iframeId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_PRINT_IFRAME, _iframeId);
        }

        /**
         * Load the IFrame's last page in the navigation history.
         */
        public function historyBack():void
        {
            logger.info("History back for the iFrame with id '{0}'.", _iframeId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_HISTORY_BACK, _iframeId);
        }

        /**
         * Load the IFrame's next page in the navigation history.
         */
        public function historyForward():void
        {
            logger.info("History forward for the iFrame with id '{0}'.", _iframeId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_HISTORY_FORWARD, _iframeId);
        }


        // =========================================================================================
        // Debug mode
        // =========================================================================================

        /**
         * The state of the debug mode.
         */
        protected var _debug:Boolean = false;

        /**
         * The target for the logger.
         */
        protected var logTarget:TraceTarget;

        /**
         * The class logger.
         */
        protected var logger:ILogger = Log.getLogger("Flex-IFrame");

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
                {
                    logTarget = new TraceTarget();
                    logTarget.includeLevel = true;
                    logTarget.includeTime = true;
                    logTarget.level = LogEventLevel.ALL;
                    logTarget.filters = [ "Flex-IFrame" ];
                }
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
