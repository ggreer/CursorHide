//
//  AppDelegate.m
//  CursorHide
//
//  Created by Geoff Greer on 2/8/14.
//  Copyright (c) 2014 Geoff Greer. All rights reserved.
//

#include <ApplicationServices/ApplicationServices.h>
#include <AppKit/NSStatusBar.h>

#import "AppDelegate.h"

@implementation AppDelegate

- (void)hideCursor {
    // Hide the cursor and wait
    CGDisplayHideCursor(kCGDirectMainDisplay);
    [statusItem setTitle: NSLocalizedString(@"Hidden",@"")];
}

- (void)startTimer {
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                             target:self selector:@selector(hideCursor)
                                           userInfo:nil repeats:NO];
    [timer setTolerance:0.1]; // Save power
}

- (void)propStringHack {
    void CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
    int _CGSDefaultConnection();
    CFStringRef propertyString;
    // Hack to make background cursor setting work
    propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingUTF8);
    CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
    CFRelease(propertyString);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setTitle: NSLocalizedString(@"Cursor",@"")];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:_statusMenu];

    // TODO: load/save timeout from user preference
    timeout = 2.7;
    [self startTimer];

    [self propStringHack];

    NSUInteger resetTimerMask = NSMouseMovedMask | NSLeftMouseDownMask | NSRightMouseDownMask;
    // TODO: really really inefficient. maybe there's an event that doesn't fire every time the mouse moves a pixel
    [NSEvent addGlobalMonitorForEventsMatchingMask:resetTimerMask handler:^(NSEvent *event) {
        //setAcceptsMouseMovedEvents
        // Instead of destroying/creating a timer on each mouse move event, just use nextEventMatchingMask
        CGError err = CGDisplayShowCursor(kCGDirectMainDisplay);
        if (err) {
            NSLog(@"Error showing cursor: %u", err);
        }
        [statusItem setTitle: NSLocalizedString(@"Shown",@"")];
        [self startTimer];
    }];
}

@end
