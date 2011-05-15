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
    /**
    * A static class that holds the calls that can be made to the <code>ExternalInterface</code>
    * by the <code>IFrame</code> class.
    * 
    * @author Alistair Rutherford (www.netthreads.co.uk)
    * @author Christophe Conraets (http://coenraets.org)
    * @author Brian Deitte (http://www.deitte.com)
    * @author Ryan Bell
    * @author Max
    * @author Julien Nicoulaud (http://www.twitter.com/nicoulaj)
    */
    public class IFrameExternalCalls
    {

        /**
        * The name of the JavaScript function that creates an IFrame.
        */
        public static var FUNCTION_CREATEIFRAME:String = "createIFrame";

        /**
        * The JavaScript code to call to insert the function that creates an IFrame in the DOM.
        */
        public static var INSERT_FUNCTION_CREATEIFRAME:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_CREATEIFRAME + "==null)" + 
                "{" + 
                    FUNCTION_CREATEIFRAME + " = function (frameID, overflowAssignment)" +
                    "{ " +
                        "var bodyID = document.getElementsByTagName(\"body\")[0];" +
                        "var newDiv = document.createElement('div');" +
                        "newDiv.id = frameID;" +
                        "newDiv.style.position ='absolute';" +
                        "newDiv.style.backgroundColor = '#FFFFFF';" + 
                        "newDiv.style.border = '0px';" +
                        "newDiv.style.overflow = overflowAssignment;" +
                        "newDiv.style.display = 'none';" +
                        "bodyID.appendChild(newDiv);" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that moves an IFrame.
        */
        public static var FUNCTION_MOVEIFRAME:String = "moveIFrame";

        /**
        * The JavaScript code to call to insert the function that moves an IFrame in the DOM.
        */
        public static var INSERT_FUNCTION_MOVEIFRAME:String = 
            "document.insertScript = function () " +
            "{ " +
                "if (document." + FUNCTION_MOVEIFRAME + "==null) " +
                "{ " +
                    FUNCTION_MOVEIFRAME + " = function(frameID,iframeID,x,y,w,h,objectID) " + 
                    "{" +
                        "var frameRef = document.getElementById(frameID); " +
                        "var swfObject = document.getElementById(objectID); " +
                        "frameRef.style.left = x + swfObject.offsetLeft + 'px'; " + 
                        "frameRef.style.top = y + swfObject.offsetTop + 'px'; " +
                        "frameRef.style.width = w + 'px'; " +
                        "frameRef.style.height = h + 'px'; " +
                        "var iFrameRef = document.getElementById(iframeID); " +
                        "iFrameRef.width = w;" +
                        "iFrameRef.height = h;" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that hides an IFrame.
        */
        public static var FUNCTION_HIDEIFRAME:String = "hideIFrame";
    
        /**
        * The JavaScript code to call to insert the function that hides an IFrame in the DOM.
        */
        public static var INSERT_FUNCTION_HIDEIFRAME:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_HIDEIFRAME + "==null)" +
                "{" +
                    FUNCTION_HIDEIFRAME + " = function (frameID, iframeID)" +
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
                            "iframeDoc.body.style.display = 'none';" +
                        "}" +
                        "document.getElementById(frameID).style.display = 'none';" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that shows an IFrame.
        */
        public static var FUNCTION_SHOWIFRAME:String = "showIFrame";

        /**
        * The JavaScript code to call to insert the function that shows an IFrame in the DOM.
        */
        public static var INSERT_FUNCTION_SHOWIFRAME:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_SHOWIFRAME + "==null)" +
                "{" +
                    FUNCTION_SHOWIFRAME + " = function (frameID, iframeID)" +
                    "{" +
                        "var iframeRef = document.getElementById(iframeID);" +
                        "document.getElementById(frameID).style.display='block';" +
                        "var iframeDoc;" +
                        "if (iframeRef.contentWindow) {" +
                            "iframeDoc = iframeRef.contentWindow.document;" +
                        "} else if (iframeRef.contentDocument) {" +
                            "iframeDoc = iframeRef.contentDocument;" +
                        "} else if (iframeRef.document) {" +
                            "iframeDoc = iframeRef.document;" +
                        "}" +
                        "if (iframeDoc) {" +
                            "iframeDoc.body.style.display='block';" +
                        "}" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that hides a Div.
        */
        public static var FUNCTION_HIDEDIV:String = "hideDiv";

        /**
        * The JavaScript code to call to insert the function that hides a Div in the DOM.
        */
        public static var INSERT_FUNCTION_HIDEDIV:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_HIDEDIV + "==null)" +
                "{" +
                    FUNCTION_HIDEDIV + " = function (frameID)" +
                    "{" +
                        "document.getElementById(frameID).style.display='none';" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that shows a Div.
        */
        public static var FUNCTION_SHOWDIV:String = "showDiv";

        /**
        * The JavaScript code to call to insert the function that shows a Div in the DOM.
        */
        public static var INSERT_FUNCTION_SHOWDIV:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_SHOWDIV + "==null)" +
                "{" +
                    FUNCTION_SHOWDIV + " = function (frameID)" +
                    "{" +
                        "document.getElementById(frameID).style.display = 'block';" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that loads an Iframe.
        */     
        public static var FUNCTION_LOADIFRAME:String = "loadIFrame";

        /**
        * The JavaScript code to call to insert the function that loads an Iframe in the DOM.
        */
        public static var INSERT_FUNCTION_LOADIFRAME:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_LOADIFRAME + "==null)" +
                "{" +
                    FUNCTION_LOADIFRAME + " = function (frameID, iframeID, url, embedID, scrollPolicy)" +
                    "{" +
                        "document.getElementById(frameID).innerHTML = " + 
                            "\"<iframe id='\"+iframeID+\"' " + 
                                      "src='\"+url+\"' " + 
                                      "name='\"+iframeID+\"' " + 
                                      "onLoad='\"+embedID+\".\"+frameID+\"_load();' " +
                                      "scrolling='\"+scrollPolicy+\"' " +
                                      "frameborder='0'>" + 
                              "</iframe>\";" + 
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that loads content into a Div.
        */
        public static var FUNCTION_LOADDIV_CONTENT:String = "loadDivContent";

        /**
        * The JavaScript code to call to insert the function that loads content into a Div in the
        * DOM.
        */
        public static var INSERT_FUNCTION_LOADDIV_CONTENT:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_LOADDIV_CONTENT + "==null)" +
                "{" +
                    FUNCTION_LOADDIV_CONTENT + " = function (frameID, iframeID, content)" +
                    "{" +
                        "document.getElementById(frameID).innerHTML = \"<div id='\"+iframeID+\"' frameborder='0'>\"+content+\"</div>\";" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that calls a function on an IFrame.
        */
        public static var FUNCTION_CALLIFRAMEFUNCTION:String = "callIFrameFunction";

        /**
        * The JavaScript code to call to insert the function that calls a function on an IFrame in
        * the DOM.
        */
        public static var INSERT_FUNCTION_CALLIFRAMEFUNCTION:String =
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_CALLIFRAMEFUNCTION + "==null)" +
                "{" +
                    FUNCTION_CALLIFRAMEFUNCTION + " = function (iframeID, functionName, args)" +
                    "{" +
                        "var iframeRef=document.getElementById(iframeID);" +
						"var iframeWin;" +
                        "if (iframeRef.contentWindow) {" +
                            "iframeWin = iframeRef.contentWindow;" +
                        "} else if (iframeRef.contentDocument) {" +
                            "iframeWin = iframeRef.contentDocument.window;" +
                        "} else if (iframeRef.window) {" +
                            "iframeWin = iframeRef.window;" +
                        "}" +
                        "if (iframeWin.wrappedJSObject != undefined) {" +
                            "iframeWin = iframeDoc.wrappedJSObject;" +
                        "}" +
                        "return iframeWin[functionName](args);" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that removes an IFrame.
        */
        public static var FUNCTION_REMOVEIFRAME:String = "removeIFrame";
        
        /**
        * The JavaScript code to call to insert the function that removes an IFrame in the DOM.
        */
        public static var INSERT_FUNCTION_REMOVEIFRAME:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_REMOVEIFRAME + "==null)" + 
                "{" + 
                    FUNCTION_REMOVEIFRAME + " = function (frameID)" +
                    "{ " +
                        "var iFrameDiv = document.getElementById(frameID);" +
                        "iFrameDiv.parentNode.removeChild(iFrameDiv);" +
                    "}" +
                "}" +
            "}";


        /**
        * The name of the JavaScript function that brings an IFrame to the front.
        */
        public static var FUNCTION_BRING_IFRAME_TO_FRONT:String = "bringIFrameToFront";

        /**
        * The JavaScript code to call to insert the function that moves an IFrame in the DOM.
        */
        public static var INSERT_FUNCTION_BRING_IFRAME_TO_FRONT:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_BRING_IFRAME_TO_FRONT + "==null)" +
                "{" +
                    "var oldFrame=null;" +
                    FUNCTION_BRING_IFRAME_TO_FRONT + " = function(frameID) " + 
                    "{" +
                        "var frameRef=document.getElementById(frameID);" +
                        "if (oldFrame!=frameRef) {" + 
                            "if (oldFrame) {" + 
                                "oldFrame.style.zIndex=\"99\";" + 
                            "}" + 
                            "frameRef.style.zIndex=\"100\";" + 
                            "oldFrame = frameRef;" + 
                        "}" + 
                    "}" +
                "}" +
            "}";


        /**
         * The name of the function that prompts the DOM objects to find the SWF object id.
         */
        public static var FUNCTION_ASK_FOR_EMBED_OBJECT_ID:String = "askForEmbedObjectId";
                
        /**
         * The Javascript code to call to insert the function that prompts the DOM objects
         * to find the SWF object id.
         */
        public static var INSERT_FUNCTION_ASK_FOR_EMBED_OBJECT_ID:String =
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_ASK_FOR_EMBED_OBJECT_ID + "==null)" +
                "{ " +
                    FUNCTION_ASK_FOR_EMBED_OBJECT_ID + " = function(randomString) " + 
                    "{ " + 
                        "try { " + 
                            "var embeds = document.getElementsByTagName('embed'); " + 
                            "for (var i = 0; i < embeds.length; i++) { " + 
                                "var isTheGoodOne = embeds[i].checkObjectId(embeds[i].getAttribute('id'),randomString); " + 
                                "if(isTheGoodOne) { " + 
                                    "return embeds[i].getAttribute('id'); " + 
                                "} " +
                            "} " +
                            "var objects = document.getElementsByTagName('object'); " + 
                            "for(i = 0; i < objects.length; i++) { " + 
                                "var isTheGoodOne = objects[i].checkObjectId(objects[i].getAttribute('id'),randomString); " + 
                                "if(isTheGoodOne) { " + 
                                    "return objects[i].getAttribute('id'); " + 
                                "} " + 
                            "} " +
                        "} catch(e) {} " +
                        "return null; " + 
                    "} " +
                "} " + 
            "}";


        /**
         * The name of the Javascript function that gets the browser measured width.
         */
        public static var FUNCTION_GET_BROWSER_MEASURED_WIDTH:String = "getBrowserMeasuredWidth";
                
        /**
         * The Javascript code to call to insert the function that gets the browser measured width.
         */
        public static var INSERT_FUNCTION_GET_BROWSER_MEASURED_WIDTH:String =
            "document.insertScript = function () " +
            "{ " +
                "if (document." + FUNCTION_GET_BROWSER_MEASURED_WIDTH + "==null) " +
                "{ " +
                    FUNCTION_GET_BROWSER_MEASURED_WIDTH + " = function(objectID) " + 
                    "{ " + 
                        "return document.getElementById(objectID).offsetWidth; " +
                    "} " +
                "} " + 
            "}";


        /**
         * The name of the Javascript function that setups the 'resize' event listener.
         */
        public static var FUNCTION_SETUP_RESIZE_EVENT_LISTENER:String = "setupResizeEventListener";
        
        /**
         * The Javascript code to call to insert the function that setups the 'resize' event
         * listener.
         * 
         * When a 'resize' event is received, it is queued and the Flex application is not notified
         * unless there is no new 'resize' event in the next 10 milliseconds. This is to prevent
         * unexpected behaviours with *beloved* Internet Explorer sending bursts of events.
         */
        public static function INSERT_FUNCTION_SETUP_RESIZE_EVENT_LISTENER(frameId:String):String
        {
            return "document.insertScript = function ()" +
                   "{ " +
                       "if (document." + FUNCTION_SETUP_RESIZE_EVENT_LISTENER + "==null)" +
                       "{ " +
                           FUNCTION_SETUP_RESIZE_EVENT_LISTENER + " = function() " + 
                           "{ " + 
                               "if (window.addEventListener) { " +
                                   "window.addEventListener(\"resize\", on" + frameId + "Resize, false); " +
                               "} else if (window.attachEvent) { " +
                                   "window.attachEvent(\"onresize\", on" + frameId + "Resize); " +
                               "} " +
                           "} " +
                       "} " + 
                       "if (document.on" + frameId + "Resize==null)" +
                       "{ " +
                            "var resizeTimeout" + frameId + "; " +
                            "function on" + frameId + "Resize(e) " + 
                            "{ " +
							     "window.clearTimeout(resizeTimeout" + frameId + ");" +
							     "resizeTimeout" + frameId + " = window.setTimeout('notify" + frameId + "Resize();', 10); " +
							"} " +
                       "} " + 
                       "if (document.notify" + frameId + "Resize==null)" +
                       "{ " +
                           "notify" + frameId + "Resize = function() " + 
                           "{ " + 
                               "document.getElementById('" + IFrame.applicationId + "')." + frameId + "_resize(); " +
                           "} " +
                       "} " + 
                   "} ";
        }


        /**
         * The name of the Javascript function that prints the IFrame.
         */
        public static var FUNCTION_PRINT_IFRAME:String = "printIFrame";

        /**
         * The Javascript code to call to insert the function that prints the IFrame.
         */
        public static var INSERT_FUNCTION_PRINT_IFRAME:String =
           "document.insertScript = function ()" +
           "{" +
               "if (document." + FUNCTION_PRINT_IFRAME + "==null)" + 
               "{" +
                   FUNCTION_PRINT_IFRAME + " = function (iframeID)" +
                   "{" +
                       "try" +
                       "{" +
                           "if (navigator.appName.indexOf('Microsoft') != -1)" +
                           "{" +
                               "document[iframeID].focus();" +
                               "document[iframeID].print();" +                         
                           "}" +
                           "else" +
                           "{" +
                               "for (var i=0; i < window.frames.length; i++)" +
                               "{" +
                                   "if (window.frames[i].name == iframeID)" +
                                   "{" +
                                       "window.frames[i].focus();" +
                                       "window.frames[i].print();" +
                                   "}" +
                               "}" +
                           "}" +
                       "}" +
                       "catch(e)" +
                       "{" +
                           "alert(e.name + ': ' + e.message);" +
                       "}" +
                   "}" +
                "}" +
            "}";


        /**
         * The name of the Javascript function that loads the IFrame's last page in the history.
         */
        public static var FUNCTION_HISTORY_BACK:String = "historyBack";

        /**
         * The Javascript code to call to insert the function that loads the IFrame's last page
         * in the history.
         */
        public static var INSERT_FUNCTION_HISTORY_BACK:String =
           "document.insertScript = function ()" +
           "{" +
               "if (document." + FUNCTION_HISTORY_BACK + "==null)" + 
               "{" +
                   FUNCTION_HISTORY_BACK + " = function (iframeID)" +
                   "{" +
                        "frames[iframeID].history.go(-1); " +
                   "}" +
                "}" +
            "}";


        /**
         * The name of the Javascript function that loads the IFrame's next page in the history.
         */
        public static var FUNCTION_HISTORY_FORWARD:String = "historyForward";

        /**
         * The Javascript code to call to insert the function that loads the IFrame's next page
         * in the history.
         */
        public static var INSERT_FUNCTION_HISTORY_FORWARD:String =
           "document.insertScript = function ()" +
           "{" +
               "if (document." + FUNCTION_HISTORY_FORWARD + "==null)" + 
               "{" +
                   FUNCTION_HISTORY_FORWARD + " = function (iframeID)" +
                   "{" +
                        "frames[iframeID].history.go(1); " +
                   "}" +
                "}" +
            "}";

    }
}
