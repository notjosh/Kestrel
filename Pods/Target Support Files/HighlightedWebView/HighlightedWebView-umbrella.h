#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DHMatchedText.h"
#import "DHScrollbarHighlighter.h"
#import "DHSearchQuery.h"
#import "DHWebView.h"

FOUNDATION_EXPORT double HighlightedWebViewVersionNumber;
FOUNDATION_EXPORT const unsigned char HighlightedWebViewVersionString[];

