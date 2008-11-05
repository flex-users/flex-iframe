// -----------------------------------------------------------------------
// IFrame.as, Alistair Rutherford, www.netthreads.co.uk
// -----------------------------------------------------------------------
// Revision  Date      Who    Notes
// --------  ----      ---    -----
// 1.0       16/09/07  AJR    .Initial version
// 1.1       29/09/07  AJR    .Fixed bug where the frame wasn't resizing itself
//                             when the source url was assigned.
// 1.2       14/12/07  Max    .http://16-bits.com/HTMLTest/HTMLTest.html
//                             I modified it a little bit so that you can also set 
//                             a content property instead of source to display a div 
//                             container instead of iFrame.
// 1.3       22/09/08  RAB    .Frame will now move with the Flex component
//                             (for example, dragging a popup TitleWindow parent)
//                             It does this by seeding a second event listener up
//                             the displayList for MoveEvent.MOVE

//                            .Fixed issue where frame might not display if it
//                             was visible at component creation and not a child 
//                             of a navigator control like TabNavigator,
//                             ViewStack or Accordion

//                            .IFrame now registers an onLoad callback for its
//                             iframe element and will dispatch a 'frameLoad' flash
//                             event when the browser reports iframe content load

//                            .Added callIFrameFunction that allows calling of
//                             JavaScript functions defined on the IFrame content's
//                             document object, if everything is in the same domain
//                             (if the iframe hasn't fully loaded yet, the call will
//                             be queued and executed once it has loaded)

//                            .Added option for IFrame component to try and detect
//                             new global objects such as alerts, tooltips and 
//                             pop up windows that are added on top of it and hide the
//                             browser iframe temporarily. This option must be
//                             explicitly enabled with the overlayDetection property
//                             as it's a total hack with no guarantees of working

//                            .Added 'debug' property to component that can be
//                             used to switch trace statements on and off and
//                             changed all traces to go through a logger

//                            .Added property "loadIndicatorClass". If this is
//                             defined, iframe will create an instance of this
//                             class and use it to display a centered indicator
//                             over the iframe container while its contents are
//                             being loaded by the browser

//                            .IFrame will now ensure that it's using a unique
//                             id within the application by tracking all IFrame
//                             component ids in use with a static var and
//                             appending a unique number to the end if needed.
//                             This allows use of IFrame within a reusable MXML 
//                             component that gets instantiated more than once

// 1.3.1     13/10/08  RAB    .Fixed issue where parent document body could be
//                             accidentally set to invisible when using content
//                             div mode

// 1.3.2     20/10/08  RAB    .Added checks for cross-domain security violations.
//                             Fixes a problem with hiding and showing iframes with
//                             content from a different domain, and will now log
//                             a warning in debug mode when attempting to call 
//                             a function inside an iframe in a different domain

// 1.3.3     05/11/08  RAB    .Fixed issue where iframe in nested ViewStacks (or
//                             related components like TabNavigator) could become 
//                             visible when it shouldn't.
//                            .Debug mode can now be turned on or off at any time
//                             instead of being locked in when createChildren runs
//                            .Fixed issue with incorrect switching when iframe
//                             was created in ViewStack child on the fly due to
//                             creationPolicy="auto"

//
// -----------------------------------------------------------------------
// This component is based on the work of:
// 
// Christophe Conraets 
// www.coenraets.org
//
// and
//
// Brian Deitte
// http://www.deitte.com/archives/2006/08/finally_updated.htm
//
// -----------------------------------------------------------------------
// I have made some additions to the original code
//
// - javascript support functions are now generated by the component and
// inserted directly into the DOM.
//
// - Component generates it's own div and iframe element and inserts them
// into the DOM.
//
// - When the component is created the display list is traversed from the 
// component down to the root element. At each traversal a test is made to 
// see if current component is a container. If it is a container then the 
// child of the element which leads back to the component is determined and 
// a note madeof the appropriate 'index' on the path. The index is stored 
// against a reference to the Container in a Dictionary. Also the container
// is 'seeded' with an event handler so that if the container triggers an
// IndexChangedEvent.CHANGE (i.e. when you click on a tab in a tab navigator)
// the path of 'index' values down to the component can be checked. If the
// path indicates that the indexes 'line up' to expose the component then
// the view is made visible. I hope I have explained this correctly :)
// -----------------------------------------------------------------------
// 
// -----------------------------------------------------------------------

package
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.external.ExternalInterface;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import mx.core.Application;
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
	
	[Event(name="frameLoad", type="flash.events.Event")] 

	public class IFrame extends Container
	{
        public var overlayDetection:Boolean = false;
        
        private var logTarget:TraceTarget;
        
        private var __source: String;
        private var __content: String;
        private var frameId:String;
        private var iframeId:String;
        
        private var validForDisplay:Boolean = true;

        private var containerDict:Object = null;
        private var settingDict:Object = null;

        private var frameLoaded:Boolean = false;
        private var functionQueue:Array = [];
        
        private static var logger:ILogger = Log.getLogger("com.plus.arutherford.ccgi.IFrame");

        /**
        * Here we define javascript functions which will be inserted into the DOM
        * 
        */
        private static var FUNCTION_CREATEIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
                "if (document.createIFrame==null)" + 
                "{" + 
                    "createIFrame = function (frameID)" +
                	"{ " +
                        "var bodyID = document.getElementsByTagName(\"body\")[0];" +
                        "var newDiv = document.createElement('div');" +
                        "newDiv.id = frameID;" +
                        "newDiv.style.position ='absolute';" +
                        "newDiv.style.backgroundColor = 'transparent';" + 
                        "newDiv.style.border = '0px';" +
                        "newDiv.style.visibility = 'hidden';" +
                        "bodyID.appendChild(newDiv);" +
                    "}" +
                "}" +
            "}";
        
        private static var FUNCTION_MOVEIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.moveIFrame==null)" +
	            "{" +
	                "moveIFrame = function(frameID, iframeID, x,y,w,h) " + 
	                "{" +
	                    "var frameRef=document.getElementById(frameID);" +
	                    "frameRef.style.left=x;" + 
	                    "frameRef.style.top=y;" +
	                    "var iFrameRef=document.getElementById(iframeID);" +
	                	"iFrameRef.width=w;" +
	                	"iFrameRef.height=h;" +
		            "}" +
                "}" +
            "}";

        private static var FUNCTION_HIDEIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.hideIFrame==null)" +
	            "{" +
	                "hideIFrame = function (frameID, iframeID)" +
                    "{" +
                        "var iframeRef = document.getElementById(iframeID);" +
                        "var iframeDoc;" +
						"if (iframeRef.contentWindow) {" +
							"iframeDoc = iframeRef.contentWindow.document;" +
   						"} else if (iframeRef.contentDocument) {" +
							"iframeDoc = iframeRef.contentDocument;" +
						"} else if (iframeRef.document) {" +
							"iframeDoc = iframeRef.document;" +
						"}" +
						"if (iframeDoc) {" +
							"iframeDoc.body.style.visibility='hidden';" +
						"}" +
                        "document.getElementById(frameID).style.visibility='hidden';" +
                    "}" +
                "}" +
            "}";

        private static var FUNCTION_SHOWIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.showIFrame==null)" +
	            "{" +
	                "showIFrame = function (frameID, iframeID)" +
                    "{" +
                        "var iframeRef = document.getElementById(iframeID);" +
                        "document.getElementById(frameID).style.visibility='visible';" +
                        
                        "var iframeDoc;" +
						"if (iframeRef.contentWindow) {" +
							"iframeDoc = iframeRef.contentWindow.document;" +
   						"} else if (iframeRef.contentDocument) {" +
							"iframeDoc = iframeRef.contentDocument;" +
						"} else if (iframeRef.document) {" +
							"iframeDoc = iframeRef.document;" +
						"}" +
						"if (iframeDoc) {" +
							"iframeDoc.body.style.visibility='visible';" +
						"}" +
                    "}" +
                "}" +
            "}";
            
        private static var FUNCTION_HIDEDIV:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.hideDiv==null)" +
	            "{" +
	                "hideDiv = function (frameID, iframeID)" +
                    "{" +
                        "document.getElementById(frameID).style.visibility='hidden';" +
                    "}" +
                "}" +
            "}";

        private static var FUNCTION_SHOWDIV:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.showDiv==null)" +
	            "{" +
	                "showDiv = function (frameID, iframeID)" +
                    "{" +
                        "document.getElementById(frameID).style.visibility='visible';" +
                    "}" +
                "}" +
            "}";
            
        private static var FUNCTION_LOADIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.loadIFrame==null)" +
	            "{" +
	                "loadIFrame = function (frameID, iframeID, url)" +
                    "{" +
                        "document.getElementById(frameID).innerHTML = \"<iframe id='\"+iframeID+\"' src='\"+url+\"' onLoad='"
                        	+ Application.application.id + ".\"+frameID+\"_load()' frameborder='0'></iframe>\";" + 
                    "}" +
                "}" +
            "}";
            
       	private static var FUNCTION_LOADDIV_CONTENT:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.loadDivContent==null)" +
	            "{" +
	                "loadDivContent = function (frameID, iframeID, content)" +
                    "{" +
                    	"document.getElementById(frameID).innerHTML = \"<div id='\"+iframeID+\"' frameborder='0'>\"+content+\"</div>\";" +
                    "}" +
                "}" +
            "}";
            
        private static var FUNCTION_CALLIFRAMEFUNCTION:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.callIFrameFunction==null)" +
	            "{" +
	                "callIFrameFunction = function (iframeID, functionName, args)" +
                    "{" +
                    	"var iframeRef=document.getElementById(iframeID);" +
                    	"var iframeDoc;" +
                    	"if (iframeRef.contentDocument) {" +
							"iframeDoc = iframeRef.contentDocument;" +
						"} else if (iframeRef.contentWindow) {" +
							"iframeDoc = iframeRef.contentWindow.document;" +
						"} else if (iframeRef.document) {" +
							"iframeDoc = iframeRef.document;" +
						"}" +
						"if (iframeDoc.wrappedJSObject != undefined) {" +
							"iframeDoc = iframeDoc.wrappedJSObject;" +
						"}" +
						"return iframeDoc[functionName](args);" +
                    "}" +
                "}" +
            "}";
        
        /**
        * Track IDs in use throughout the app for iframe
        * instances in order to detect and prevent collisions
        * 
        */
	    public static var idList:Object = new Object();
	    
	    private static var appHost:String;
	   	private var iframeContentHost:String;
        
        /**
        * Constructor
        * 
        */
	    public function IFrame()
	    {
	        super();
	        this.addEventListener(Event.REMOVED_FROM_STAGE, handleRemove);
	        this.addEventListener(Event.ADDED_TO_STAGE, handleAdd);
	    }
	    
	    private var _debug:Boolean = false;
	    
	    public function get debug():Boolean
	    {
	    	return _debug;
	    }
	    
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
		
        /**
        * Generate DOM elements and build display path.
        * 
        */
        override protected function createChildren():void
        {
            super.createChildren();
            
            if (! ExternalInterface.available)
            {
                throw new Error("ExternalInterface is not available in this container. Internet Explorer ActiveX, Firefox, Mozilla 1.7.5 and greater, or other browsers that support NPRuntime are required.");
            }
            
//            if (debug)
//            {
//            	logTarget = new TraceTarget();
//            	logTarget.addLogger(logger);
//            }
            
            // Get the host info to check for cross-domain issues
            if (!appHost)
            {
            	BrowserManager.getInstance().initForHistoryManager();
		        var url:String = BrowserManager.getInstance().url;
		        appHost = URLUtil.getProtocol(url) + "://" 
		        	+ URLUtil.getServerNameWithPort(url);
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
            ExternalInterface.call(FUNCTION_CREATEIFRAME);
            ExternalInterface.call(FUNCTION_MOVEIFRAME);
            ExternalInterface.call(FUNCTION_HIDEIFRAME);
            ExternalInterface.call(FUNCTION_SHOWIFRAME);
            ExternalInterface.call(FUNCTION_SHOWDIV);
            ExternalInterface.call(FUNCTION_HIDEDIV);
            ExternalInterface.call(FUNCTION_LOADIFRAME);
            ExternalInterface.call(FUNCTION_LOADDIV_CONTENT);
            ExternalInterface.call(FUNCTION_CALLIFRAMEFUNCTION);

            // Insert frame into DOM using our precreated function 'createIFrame'
            ExternalInterface.call("createIFrame", frameId);
           	
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
        * Build list of container objects on the display list path all the way down
        * to this object. We will seed the container classes we find with an event
        * listener which will be used to test if this object is to be displayed or not.
        *
        */
        private function buildContainerList():void
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
        * Triggered by removal of this object from the stage
        * 
        * @param event Event trigger
        *
        */
        private function handleRemove(event:Event):void
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
        * Triggered by addition of this object to the stage
        * 
        * @param event Event trigger
        *
        */
        private function handleAdd(event:Event):void
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
        * Triggered by one of our listeners seeded all the way up the display
        * list to catch a 'changed' event which might hide or display this object.
        * 
        * @param event Event trigger
        *
        */
        private function handleChange(event:Event):void
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
        *
        */
        private function handleMove(event:Event):void
        {
            //moveIFrame();
            invalidateDisplayList(); 
            //this will cause moveIFrame() to be called in the next validation cycle
        }
        
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
        private function checkDisplay(target:Object, newIndex:Number):Boolean
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
        * Return index of child item on path down to this object. If not
        * found then return -1;
        *
        * @param target Container object
        * 
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
        * 
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
        
        /**
        * Adjust frame position to match the exposed area in the application.
        * 
        */
        private function moveIFrame(): void
        {

            var localPt:Point = new Point(0, 0);
            var globalPt:Point = this.localToGlobal(localPt);

            ExternalInterface.call("moveIFrame", frameId, iframeId, globalPt.x, globalPt.y, this.width, this.height);
            logger.debug("move iframe id {0}", frameId);
        }

        /**
        * Triggered by change to component properties.
        * 
        */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
            if (source)
            {
	            frameLoaded = false;
	            ExternalInterface.call("loadIFrame", frameId, iframeId, source);
				logger.debug("load Iframe id {0}", frameId);
				// Trigger re-layout of iframe contents.	            
	            invalidateDisplayList();
            } 
            else if (content) 
            {
            	ExternalInterface.call("loadDivContent", frameId, iframeId, content);
				logger.debug("load Content id {0}", frameId);
				// Trigger re-layout of iframe contents.	            
	            invalidateDisplayList();
            }
		}
		
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
		
        /**
        * Triggered when display contents change. Adjusts frame layout.
        * 
        * @param unscaledWidth
        * @param unscaledHeight
        * 
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
        * Set source url
        * 
        * @param url Frame contents
        * 
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
				iframeContentHost = URLUtil.getProtocol(source) + "://"
					 + URLUtil.getServerNameWithPort(source);     
            }
        }

        /**
        * Return url of frame contents
        * 
        */
        public function get source(): String
        {
            return __source;
        }
        
         /**
        * Set content string
        * 
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
        * 
        */
        public function get content(): String
        {
            return __content;
        }
        
        /**
        * Sets visibility of html iframe. Rtn calls inserted javascript functions.
        * 
        * @param visible Boolean flag
        * 
        */
        override public function set visible(value: Boolean): void
        {
            super.visible = value;

			// if we have an iframe in the same domain as the app, call the
			// specialized functions to update visibility inside the iframe
            if (visible && validForDisplay)
            {
                if (source && iframeContentHost == appHost)
                	ExternalInterface.call("showIFrame",frameId,iframeId);
                else
                	ExternalInterface.call("showDiv",frameId,iframeId);
                logger.debug("show iframe id {0}", frameId);
                
                // make sure position and status indicators get updated when revealed
                invalidateDisplayList();
                
            }
            else 
            {
            	if (source && iframeContentHost == appHost)
                	ExternalInterface.call("hideIFrame",frameId,iframeId);
                else
                	ExternalInterface.call("hideDiv",frameId,iframeId);
                logger.debug("hide iframe id {0}", frameId);
            }
        }
        
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
        * 
        */
        public function callIFrameFunction(functionName:String, args:Array = null, callback:Function = null):String
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
            	var result:Object = ExternalInterface.call("callIFrameFunction", iframeId, functionName, args);
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
        
        // --------------------------------------------------------------------
        //  Loading indicator
        // --------------------------------------------------------------------
        /**
        * A UIComponent class to display centered over the iframe container while
        * the browser is loading its content. Should implement measuredHeight
        * and measuredWidth in order to be properly sized
        */
        public var loadIndicatorClass:Class;
        
        protected var _loadIndicator:UIComponent;
        
        
        // --------------------------------------------------------------------
        //  Overlaying object detection
        // --------------------------------------------------------------------
        
        private var overlappingDict:Dictionary = new Dictionary(true);
		private var overlapCount:int = 0;
		
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
        * 
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
        * 
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
	}
}