/**
 * Copyright (c) 2007-2011 flex-iframe contributors
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
    import mx.core.FlexGlobals;
    import mx.core.IChildList;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.events.IndexChangedEvent;
    import mx.events.MoveEvent;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.logging.LogEventLevel;
    import mx.logging.targets.TraceTarget;
    import mx.managers.ISystemManager;
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
     * @author Julien Nicoulaud (http://www.twitter.com/nicoulaj)
     */
    public class IFrame extends Container
    {

        /**
         * Build a new IFrame.
         *
         * @param id a String identifying the IFrame. Must be unique for every instance of the
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
        public function IFrame(id:String=null)
        {
            // Call super class constructor
            super();

            // Assign the unique id
            if (id != null)
            {
                this.id=id;
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
         * Value for the 'auto' scroll policy.
         */
        public static const SCROLL_POLICY_AUTO : String = "auto";

        /**
         * Value for the 'on' scroll policy.
         */
        public static const SCROLL_POLICY_ON : String = "yes";

        /**
         * Value for the 'off' scroll policy.
         */
        public static const SCROLL_POLICY_OFF : String = "no";

        /**
         * The scrolling policy applied to the iframe.
         */
        public var scrollPolicy : String = SCROLL_POLICY_AUTO;

        /**
         * Track IDs in use throughout the app for iframe instances in order to detect and
         * prevent collisions.
         */
        public static var idList:Object=new Object();

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
         * The top level Flex application.
         */
        protected var _application;

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
        protected var _validForDisplay:Boolean=true;

        /**
         * The visibility of parent containers.
         *
         * @default true
         */
        protected var _parentVisibility:Boolean = true;
        
        /**
         * Wether the frame is added or not.
         *
         * @default false
         */
        protected var _frameAdded:Boolean=false;

        /**
         * Wether the frame is loaded or not.
         *
         * @default false
         */
        protected var _frameLoaded:Boolean=false;

        /**
         * The queued functions waiting for the frame to be loaded.
         */
        protected var _functionQueue:Array=[];

        /**
         * The browser zoom ratio
         */
        protected var _browserScaling:Number=1;

        /**
         * Manually-set visibility value
         *
         * @default true
         */
        protected var explicitVisibleValue:Boolean=true;


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

            // Resolve the top level Flex application.
            if(Application.application != null)
            {
                _application = Application.application;
            }
            else
            {
                _application = FlexGlobals.topLevelApplication;
            }

            // Get the host info to check for cross-domain issues
            if (!_appHost)
            {
                var url:String=_application.url;
                if (url)
                {
                    _appHost=URLUtil.getProtocol(url) + "://" + URLUtil.getServerNameWithPort(url);
                }
                else
                {
                    _appHost="unknown";
                }
            }

            // Generate unique id's for frame div name
            var idSuffix:int=0;
            while (idList[id + idSuffix])
            {
                idSuffix++;
            }
            _frameId=id + idSuffix;
            _iframeId="iframe_" + _frameId;
            idList[_frameId]=true;

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
                _loadIndicator=UIComponent(new loadIndicatorClass());
                addChild(_loadIndicator);
            }
            else
            {
                logger.info("No load indicator class specified.");
            }

			updateFrameVisibility(true);
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
                    _loadIndicator.visible=false;
                }
                updateFrameVisibility(true);
            }
            else if (_loadIndicator)
            {
                logger.debug("Frame with id '{0}' not loaded, showing the load indicator.", _frameId);
                _loadIndicator.visible=true;
                var w:int=_loadIndicator.measuredWidth;
                var h:int=_loadIndicator.measuredHeight;
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
                    _frameLoaded=false;
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

        /**
         * Sets actual size
         *
         * When component is sized by its parent, and overlay
         * detection is enabled, checks for existing pop-ups
         */
        override public function setActualSize(w:Number, h:Number):void
        {
            super.setActualSize(w, h);

            // check for existing popups I may be appearing underneath
            if (overlayDetection)
                checkExistingPopUps();
        }

        // Event handlers

        /**
         * Triggered by addition of this object to the stage.
         *
         * @param event Event trigger
         */
        protected function handleAdd(event:Event=null):void
        {
            logger.debug("The component for the IFrame with id '{0}' has been added from the stage.", _frameId);

            // Hook the systemManager to provide overlaying object detection
            if (overlayDetection)
            {
                logger.info("Listening to the stage component additions to detect overlapping objects.");
                systemManager.addEventListener(Event.ADDED, systemManager_addedHandler);
                systemManager.addEventListener(Event.REMOVED, systemManager_removedHandler);
            }

            _frameAdded = true;
            updateFrameVisibility(true);
        }

        /**
         * Triggered by removal of this object from the stage.
         *
         * @param event Event trigger
         */
        protected function handleRemove(event:Event=null):void
        {
            logger.debug("The component for the IFrame with id '{0}' has been removed from the stage.", _frameId);

            // Remove systemManager hooks for overlay detection
            if (overlayDetection)
            {
                systemManager.removeEventListener(Event.ADDED, systemManager_addedHandler);
                systemManager.removeEventListener(Event.REMOVED, systemManager_removedHandler);
            }
            
            _frameAdded = false;
            updateFrameVisibility(false);
        }

        /**
         * Triggered by one of our listeners seeded all the way up the display
         * list to catch a 'changed' event which might hide or display this object.
         *
         * @param event Event trigger
         */
        protected function handleChange(event:Event):void
        {
            var target:Object=event.target;

            if (event is IndexChangedEvent)
            {
                var changedEvent:IndexChangedEvent=IndexChangedEvent(event);
                var newIndex:Number=changedEvent.newIndex;

                var result:Boolean=updateFrameVisibility(checkDisplay(target, newIndex));
                logger.debug("Frame {0} set visible to {1} on IndexChangedEvent", _frameId, result);
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
            _frameLoaded=true;

            // Execute any queued function calls now that the frame is loaded
            var queuedCall:Object;
            while (_functionQueue.length > 0)
            {
                queuedCall=_functionQueue.pop();
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
		protected function checkDisplay(target:Object = null, newIndex:Number = -1):Boolean
		{

			if (target is Container)
			{

				var container:DisplayObjectContainer=DisplayObjectContainer(target);

				// Update current setting
				settingDict[container]=newIndex;

			}

			var valid:Boolean=true;

			for (var item:Object in containerDict)
			{
				var index:Number=lookupIndex(item as Container);
				var setting:Number=lookupSetting(item as Container);
				valid=valid && (index == setting);
			}


			// Remember this state so we can re-check later without a new IndexChangedEvent
			_validForDisplay=valid;
			return valid;
		}

        /**
         * Adjust frame position to match the exposed area in the application.
         */
        protected function adjustPosition(recalculateBrowserScaling:Boolean=false):void
        {
            var globalPt:Point=localToGlobal(new Point());

            // If needed, recalculate the browser zoom
            if (recalculateBrowserScaling)
            {
                var browserMeasuredWidth:Number=getBrowserMeasuredWidth();

                if (browserMeasuredWidth > 0)
                {
                    _browserScaling=browserMeasuredWidth / _application.width;
                }
            }

            // Place the iframe
            moveIFrame(Math.round(globalPt.x * _browserScaling), Math.round(globalPt.y * _browserScaling), Math.round(this.width * _browserScaling), Math.round(this.height * _browserScaling));
        }

        /**
         * Set source url
         *
         * @param source Frame contents
         */
        public function set source(source:String):void
        {
            if (source)
            {
                _source=source;

                // mark unloaded now so calls in this frame will be queued
                _frameLoaded=false;
                invalidateProperties();

                // Get the host info to check for cross-domain issues
                _iframeContentHost=URLUtil.getProtocol(source) + "://" + URLUtil.getServerNameWithPort(source);
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
                _content=value;

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
         * Request visibility update of html frame.
         *
         * @param value Boolean desired visibility state
         * @return The actual resulting visibility after applying rules
         */
        protected function updateFrameVisibility(value:Boolean):Boolean
        {
            logger.debug("IFrame with id '{0}' visibility set to '{1}'", _frameId, value);

			// Check that this frame should currently be visible
			var isCurrentlyVisible:Boolean = checkDisplay();

            // all of the following must be true for the iframe/div to be displayed:
            // - the calling code is trying to show it
            // - all parent navigators are set to correct index for this child to show
            // - the frame has been added
            // - overlay detection, if enabled, is not tracking any overlapping popups
            // - .visible has not explicitly been set to false (or .hidden to true) on this component
            // - if there's a load indicator defined, the iframe content has finished loading
            if (isCurrentlyVisible && value && _validForDisplay && _parentVisibility && _frameAdded && (!overlayDetection || overlapCount == 0) && explicitVisibleValue == true && (_frameLoaded || (!_frameLoaded && loadIndicatorClass == null)))
            {
                // if we have an iframe in the same domain as the app, call the
                // specialized functions to update visibility inside the iframe
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
                return true;
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
                return false;
            }
        }

        /**
         * Manually sets visibility of html iframe.
         *
         * @param value Boolean flag
         */
        override public function set visible(value:Boolean):void
        {
            if (explicitVisibleValue != value)
            {
                super.visible=value;
                explicitVisibleValue=value;
                updateFrameVisibility(value);
            }
        }


        // =========================================================================================
        // Application objects hierarchy path
        // =========================================================================================

        /**
         * The dictionnary of the hierarchy of the parent containers.
         */
        protected var containerDict:Object=null;

        /**
         * The dictionnary of the child indexes in the hierarchy of the parent containers.
         */
        protected var settingDict:Object=null;

        /**
         * The z-index of this component off the system root
         */
        protected var rootIndex:int=-1;

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
            containerDict=new Dictionary();
            settingDict=new Dictionary();

            var current:DisplayObjectContainer=parent;
            var previous:DisplayObjectContainer=this;

            while (current != null)
            {
                if (current is Container)
                {
                    if (current.contains(previous))
                    {
                        var childIndex:Number=current.getChildIndex(previous);

                        // Store child index against container
                        containerDict[current]=childIndex;
                        settingDict[current]=current.hasOwnProperty("selectedIndex") ? current["selectedIndex"] : childIndex;

                        // Tag on a change listener
                        current.addEventListener(IndexChangedEvent.CHANGE, handleChange);
                        current.addEventListener(MoveEvent.MOVE, handleMove);
                        current.addEventListener(FlexEvent.SHOW, handleShowHide);
                        current.addEventListener(FlexEvent.HIDE, handleShowHide);
                    }

                }
                else if (current is ISystemManager)
                {
                    // remember where we are off the system manager root
                    if (ISystemManager(current).rawChildren.contains(previous))
                    {
                        rootIndex=ISystemManager(current).rawChildren.getChildIndex(previous);
                    }
                }

                previous=current;
                current=current.parent;
            }
        }

        /**
         * Triggered by one of our listeners seeded all the way up the display
         * list to catch a 'show' and 'hide' events which might hide or display this object.
         *
         * @param event Event trigger
         */
        protected function handleShowHide(event:FlexEvent):void
        {
            var valid:Boolean = true;

            for (var item:Object in containerDict)
            {
                valid = valid && item.visible;
            }

            _parentVisibility = valid;

            var result:Boolean = updateFrameVisibility(valid);
            logger.debug("Frame {0} set visible to {1} on {2} event", _frameId, result, event.type);
        }


        /**
         * Return index of child item on path down to this object. If not
         * found then return -1;
         *
         * @param target Container object
         */
        public function lookupIndex(target:Container):Number
        {
            var index:Number=-1;

            try
            {
                index=containerDict[target];
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
            var index:Number=-1;

            try
            {
                index=settingDict[target];
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
        public var overlayDetection:Boolean=false;

        /**
         * A dictionnary holding the objects overlapping the IFrame.
         */
        protected var overlappingDict:Dictionary=new Dictionary(true);

        /**
         * The count of the objects overlapping the IFrame.
         */
        protected var overlapCount:int=0;

        /**
         * Called to check for existing pop-ups when the component
         * appears or changes size
         */
        protected function checkExistingPopUps():void
        {
            // run through each child of systemManager and if it's a popup, check it for overlay
            var sm:ISystemManager=systemManager;
            var n:int=sm.rawChildren.numChildren;
            for (var i:int=0; i < n; i++)
            {
                var child:UIComponent=sm.rawChildren.getChildAt(i) as UIComponent;
                if (child && child.isPopUp)
                {
                    checkOverlay(child);
                }
            }
        }

        /**
         * Triggered when the object is added to the stage.
         */
        protected function systemManager_addedHandler(event:Event):void
        {
            // A display object was added somewhere
            var displayObj:DisplayObject=event.target as DisplayObject;
            if (displayObj.parent == systemManager && displayObj.name != "cursorHolder" && !(displayObj is ToolTip))
            {
                // If the object is a direct child of systemManager (i.e it floats) and isn't the cursor,
                // or a tooltip, check to see if it overlaps me after it's been drawn
                this.callLater(checkOverlay, [displayObj]);
            }
        }

        /**
         * Triggered when the object is removed from the stage.
         */
        protected function systemManager_removedHandler(event:Event):void
        {
            // A display object was removed somewhere
            var displayObj:DisplayObject=event.target as DisplayObject;
            if (displayObj.parent == systemManager && overlappingDict[displayObj])
            {
                logger.debug("iframe {0} heard REMOVE for {1}", _frameId, displayObj.toString());
                // If the object is a direct child of systemManager and was an overlapping object, remove it
                delete overlappingDict[displayObj];
                if (--overlapCount == 0)
                {
                    updateFrameVisibility(true);
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
            var displayObj:DisplayObject=event.target as DisplayObject;
            if (event.type == FlexEvent.SHOW && !overlappingDict[displayObj])
            {
                logger.debug("iframe {0} heard SHOW for {1}", _frameId, displayObj.toString());
                overlappingDict[displayObj]=displayObj;
                overlapCount++;
                updateFrameVisibility(false);
            }
            else if (event.type == FlexEvent.HIDE && overlappingDict[displayObj])
            {
                logger.debug("iframe {0} heard HIDE for {1}", _frameId, displayObj.toString());
                delete overlappingDict[displayObj];
                if (--overlapCount == 0)
                {
                    updateFrameVisibility(true);
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
            if (displayObj.parent != systemManager)
                return; // item has been removed since we heard it added

            if (isInFrontOfMe(displayObj) && !isAncestor(displayObj) && hitTestStageObject(displayObj))
            {
                if (displayObj.visible)
                {
                    if (!overlappingDict[displayObj])
                    {
                        logger.debug("iframe {0} detected overlap of {1}", _frameId, displayObj.toString());
                        overlappingDict[displayObj]=displayObj;
                        overlapCount++;
                    }
                    updateFrameVisibility(false);
                }

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
         * Checks whether a top-level object has a higher Z-index off
         * the root than the Iframe container (in other words,
         * whether it's on a layer above this object)
         */
        protected function isInFrontOfMe(obj:DisplayObject):Boolean
        {
            var rootItems:IChildList=systemManager.rawChildren;
            return (this.rootIndex < rootItems.getChildIndex(obj));
        }

        /**
         * Use display object ancestry table already built
         * to check whether an object is a container of this
         * component or one of its ancestors
         */
        protected function isAncestor(obj:DisplayObject):Boolean
        {
            for (var item:Object in containerDict)
            {
                if (obj == item)
                    return true;
            }
            return false;
        }

        /**
         * The native hitTestObject method seems to have some issues depending on
         * the situation. This is a custom implementation to work around that.
         * This method assumes that the passed DisplayObject is a direct child
         * of the stage and therefore has x and y coordinates that are already global
         */
        protected function hitTestStageObject(o:DisplayObject):Boolean
        {
            var overlapX:Boolean=false;
            var overlapY:Boolean=false;

            var localMe:Point=new Point(this.x, this.y);
            var globalMe:Point=this.parent.localToGlobal(localMe);

            var myLeft:int=globalMe.x;
            var myRight:int=globalMe.x + this.width;
            var oLeft:int=o.x;
            var oRight:int=o.x + o.width;

            // Does object's left edge fall between my left and right edges?
            overlapX=oLeft >= myLeft && oLeft <= myRight;
            // Or does my left edge fall between object's left and right edges?
            overlapX||=oLeft <= myLeft && oRight >= myLeft;

            var myTop:int=globalMe.y;
            var myBottom:int=globalMe.y + this.height;
            var oTop:int=o.y;
            var oBottom:int=o.y + o.height;

            // Does object's top edge fall between my top and bottom edges?
            overlapY=oTop >= myTop && oTop <= myBottom;
            // Or does my top edge fall between object's top and bottom edges?
            overlapY||=oTop <= myTop && oBottom >= myTop;

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
        public function callIFrameFunction(functionName:String, args:Array=null, callback:Function=null):String
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
                logger.info("frame id {0} now attempting to call internal iframe document function {1}", _frameId, functionName);
                var result:Object=ExternalInterface.call(IFrameExternalCalls.FUNCTION_CALLIFRAMEFUNCTION, _iframeId, functionName, args);
                if (callback != null)
                {
                    callback(result);
                }
                return String(result);
            }
            else
            {
                // Queue the function for call once the iframe has loaded
                var queuedCall:Object={functionName: functionName, args: args, callback: callback};
                _functionQueue.push(queuedCall);
                return null;
            }
        }

        /**
         * If you provide the name of JavaScript function here, that function will
         * be called as a notification whenever the frame is hidden or shown due to
         * tab index changes, overlay detection (if enabled), etc. It will be
         * passed an array containing 1 item, the value true (if being shown)
         * or false (if being hidden).
         *
         * This uses the same mechanism as callIFrameFunction, so the function
         * should be defined the same way as others you want to call through
         * this method
         */
        public var visibilityNotificationFunction:String;


        // =========================================================================================
        // SWF embed object tracking
        // =========================================================================================

        /**
         * The SWF embed object id.
         */
        public static var applicationId:String=null;

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
                    randomIdentificationString=Math.ceil(Math.random() * 9999 * 1000);
                    ExternalInterface.addCallback('checkObjectId', checkObjectId);
                    var result:Object=ExternalInterface.call(IFrameExternalCalls.FUNCTION_ASK_FOR_EMBED_OBJECT_ID, randomIdentificationString.toString());
                    if (result != null)
                    {
                        applicationId=String(result);
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
            return randomIdentificationString == randomCode ? true : false;
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
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_CREATEIFRAME, _frameId, (scrollPolicy == SCROLL_POLICY_OFF)?"hidden":"auto");
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
            if (visibilityNotificationFunction)
                callIFrameFunction(visibilityNotificationFunction, [false]);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_HIDEIFRAME, _frameId, _iframeId);
        }

        /**
         * Show the IFrame.
         */
        protected function showIFrame():void
        {
            logger.info("Showing IFrame with id '{0}'.", _frameId);
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_SHOWIFRAME, _frameId, _iframeId);
            if (visibilityNotificationFunction)
                callIFrameFunction(visibilityNotificationFunction, [true]);
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
            ExternalInterface.call(IFrameExternalCalls.FUNCTION_LOADIFRAME, _frameId, _iframeId, source, applicationId, scrollPolicy);
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
            var result:Object=ExternalInterface.call(IFrameExternalCalls.FUNCTION_GET_BROWSER_MEASURED_WIDTH, applicationId);
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
        protected var _debug:Boolean=false;

        /**
         * The target for the logger.
         */
        protected var logTarget:TraceTarget;

        /**
         * The class logger.
         */
        protected var logger:ILogger=Log.getLogger("flex-iframe");

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
                    logTarget=new TraceTarget();
                    logTarget.includeLevel=true;
                    logTarget.includeTime=true;
                    logTarget.level=LogEventLevel.ALL;
                    logTarget.filters=["flex-iframe"];
                }
                logTarget.addLogger(logger);
            }
            else
            {
                if (logTarget)
                    logTarget.removeLogger(logger);
            }

            _debug=value;
        }

    }
}
