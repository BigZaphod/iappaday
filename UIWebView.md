# UIWebView Notes #

Had to hack the UIWebView.h file a bit, but then I got it to compile and embedded a UIWebView inside of a UIScroller to give a very Safari-like experience.

`[webView setEnabledGestures: 2]` seemed to make pinch zooming work, but the size of my frame didn't adjust to compensate, so it was a bit messy.  Probably there's an easy fix someplace.

And don't forget to link against `-framework WebKit`.