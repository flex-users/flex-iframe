 ***************************************************************************************************
 * Copyright (c) 2007-2010 flex-iframe contributors
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
 ***************************************************************************************************

 Find more documentation at the project home page: http://code.google.com/p/flex-iframe/

 ===================================================================================================
  How to use flex-iframe
 ===================================================================================================

 * First of all, read the FAQ: http://code.google.com/p/flex-iframe/wiki/FAQ
 * Get the library, 3 solutions:
     - Get a swc build of the library on the project home page
     - Build it from the sources (see "How to build flex-iframe from the sources")
     - Use Maven (see http://code.google.com/p/flex-iframe/wiki/Maven)
 * Drop it on your Flex project's libs/ directory
 * Start using it with the namespace ("http://code.google.com/p/flex-iframe/") or by importing the
   package directly ("import com.google.code.flexiframe.*;").
 * Modify your html template and add the parameter wmode="opaque" to the embeds. You can find
   examples by viewing the source of the project's samples.


 ===================================================================================================
  How to build flex-iframe from the sources
 ===================================================================================================

 * Check out the folder flexiframe/ as a project in Flex Builder/Eclipse.
 * Build the project.
 * The flexiframe.swc library file is in the build/ directory.


 ===================================================================================================
  How to run the examples
 ===================================================================================================

 * First follow "How to build flex-iframe from the sources".
 * Check out the folders in examples/ as separate projects. Each of them is preconfigured to use the
   "flexiframe" project swc build directly (they will look for
   WORKSPACE/flexiframe/build/flexiframe.swc).


 ===================================================================================================
  For contributors
 ===================================================================================================

 * Checkout the projects flexiframe/ and all the examples in your workspace, and make sure all the
   examples work before committing any changes.
 * There is a preconfigured launch configuration to generate the asdoc (asdoc.launch). Go to:
   Run > External Tools > External Tools Configurations, select "asdoc" and run it to update the
   documentation.
 * Before tagging a release, please make sure to generate the asdoc, and update the example builds.
