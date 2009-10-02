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
    import mx.core.Application;

    /**
    * A static class that holds the calls that can be made to the <code>ExternalInterface</code>
    * by the <code>IFrame</code> class.
    * 
    * @author Julien Nicoulaud
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
                    FUNCTION_CREATEIFRAME + " = function (frameID)" +
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


        /**
        * The name of the JavaScript function that moves an IFrame.
        */
        public static var FUNCTION_MOVEIFRAME:String = "moveIFrame";

        /**
        * The JavaScript code to call to insert the function that moves an IFrame in the DOM.
        */
        public static var INSERT_FUNCTION_MOVEIFRAME:String = 
            "document.insertScript = function ()" +
            "{ " +
                "if (document." + FUNCTION_MOVEIFRAME + "==null)" +
                "{" +
                    FUNCTION_MOVEIFRAME + " = function(frameID, iframeID, x,y,w,h) " + 
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
                            "iframeDoc.body.style.visibility='hidden';" +
                        "}" +
                        "document.getElementById(frameID).style.visibility='hidden';" +
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
                    FUNCTION_HIDEDIV + " = function (frameID, iframeID)" +
                    "{" +
                        "document.getElementById(frameID).style.visibility='hidden';" +
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
                    "showDiv = function (frameID, iframeID)" +
                    "{" +
                        "document.getElementById(frameID).style.visibility='visible';" +
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
                    FUNCTION_LOADIFRAME + " = function (frameID, iframeID, url)" +
                    "{" +
                        "document.getElementById(frameID).innerHTML = \"<iframe id='\"+iframeID+\"' src='\"+url+\"' onLoad='" +
                        Application.application.id + ".\"+frameID+\"_load()' frameborder='0'></iframe>\";" + 
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
    }
}
