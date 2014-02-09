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

NSTimer *timer = nil;
double timeout = 2.7;

- (void)hideCursor {
    void CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
    int _CGSDefaultConnection();
    CFStringRef propertyString;

    NSLog(@"Hiding cursor");
    // Hack to make background cursor setting work
    propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingUTF8);
    CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
    CFRelease(propertyString);
    // Hide the cursor and wait
    CGDisplayHideCursor(kCGDirectMainDisplay);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    timer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                             target:self selector:@selector(hideCursor)
                                           userInfo:nil repeats:NO];
    [timer setTolerance:0.1]; // Save power

    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    
    NSStatusItem *theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    
    [theItem setTitle: NSLocalizedString(@"Tablet",@"")];
    [theItem setHighlightMode:YES];
//    [theItem setMenu:_menu];

    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent *event) {
        //setAcceptsMouseMovedEvents
        if ([timer isValid]) {
            [timer invalidate];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:timeout
                            target:self selector:@selector(hideCursor)
                            userInfo:nil repeats:NO];
        [timer setTolerance:0.1]; // Save power
        CGDisplayShowCursor(kCGDirectMainDisplay);
    }];
}

@end
