WebGLBrowser - an iOS browser shim with WebGL
========

Early last year [James Darpinian](https://twitter.com/modeless) discovered the hidden property required to get WebGL
toggled on in UIWebView on iOS. We hacked together some shims that made it possible to run WebGL pages and although
the underlying WebKit implementation of WebGL had some issues it was good enough for testing.

Flash forward to today: I lost the shim I had written and wanted to test some WebGL content on a touch device. I
found a great article by [Nathan de Vries](http://atnan.com/blog/2011/11/03/enabling-and-using-webgl-on-ios/) that
goes in depth through the process James did so long ago, and it inspired me to whip up something a bit more useful
than what I had before.

So, here it is. It's super hacky, unreleasable on the App Store (due to the use of private APIs), and since WebGL
is not officially supported on iOS often fails in interesting ways. Unfortunately the performance characteristics
of this shim are not indicative of what Mobile Safari would behave as with WebGL content (when/if it's enabled), as
Apple has disabled their JIT for apps using UIWebView. GPU-heavy apps should be fairly close to real perf, though,
despite some likely inefficient compositing capping the framerate at just under $ass fps.

In theory, one can grab the latest Xcode with iOS SDK, build, and run on their device with no changes. Should work
on both iPhone and iPad with iOS5+.

Features:

* Add bookmarks for quickly returning to a URL
* Fullscreen mode (hit the home button and reopen to return to normal mode)
* WebGL!
* AirPlay mirroring works (there's a bit of a lag, but the framerate is good)

Notes
---------

* Q3BSP runs at 60FPS on my iPhone 4S and iPad 2 - nice!
* WebGL Aquarium is slow (20-25FPS) - likely due to some scaling tricks used
  * Avoid scaling your canvas with CSS or doing canvas->canvas draws
* Some demos don't work because people are using platform detection
  * Use feature detection!
* JSON parsing is slow - demos that parse large JSON blobs for models/etc will take awhile to load

WebGL Conformance Tests
---------
I ran a few of the conformance test suites. Unfortunately the test runner hides the output at the end, so I can't
see all of the results.

* 1.0.0: 5626 of 5649 passed, 1 timed out
  * The video test timed out
* 1.0.1:
  * drawingBufferWidth/Height are undefined
  * Many programs fail to link, causing many test errors
  * Looks like there are some deletion errors (not properly clearing state/cleaning bindings)
  * Long variable name handling in shaders ir broken
  * gl.getParameter(gl.COMPRESSED_TEXTURE_FORMATS) == null
  * gl.getProgramParameter(gl.LINK_STATUS) == true | null (not false!) - likely the same for shaders
  * CORS handling is broken (looks like it doesn't check at all)
  * pixelStorei has issues (likely being ignored)
  * NPOT cubemaps broken
  * Uploading custom mip levels is brokenish
  * TypedArrays has a few errors with wrapping ArrayBuffer in ArrayBufferView (and no Float64Array)
    * conformance/typedarrays/array-unit-tests.html
  * copyTexImage2D has issues
* 1.0.2: Crash!