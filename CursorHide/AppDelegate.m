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

- (void)propStringHack {
    void CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
    int _CGSDefaultConnection();
    CFStringRef propertyString;

    // Hack to make background cursor setting work
    propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingUTF8);
    CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
    CFRelease(propertyString);
}

- (void)reloadSettings {
    timeout = [defaults doubleForKey: @"cursorHideTimeout"];
    //TODO cursorHideAutoStart, cursorHideHideOnScroll
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [self reloadSettings];
}

- (void)hideCursor {
    CGDisplayHideCursor(kCGDirectMainDisplay);
}

- (void)startTimer {
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval: timeout
                                             target: self
                                           selector: @selector(hideCursor)
                                           userInfo: nil
                                            repeats: NO];
    [timer setTolerance: 0.1]; // Save power
}

- (IBAction)toggle:(id)sender {
    enabled = !enabled;
    if (enabled) {
        [statusItem setImage: [NSImage imageNamed:@"cursor"]];
        [_state setTitle: @"Disable"];
    } else {
        [statusItem setImage: [NSImage imageNamed:@"cursor_translucent"]];
        [_state setTitle: @"Enable"];
    }
}

- (IBAction)quit:(id)sender {
    [defaults synchronize];
    exit(0);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [bar statusItemWithLength: NSVariableStatusItemLength];
    [statusItem setImage: [NSImage imageNamed:@"cursor"]];
    [statusItem setHighlightMode: YES];
    [statusItem setMenu: _menu];

    defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults: @{ @"cursorHideTimeout": @2.6,
                                   @"cursorHideAutoStart": @true,
                                   @"cursorHideHideOnScroll": @false}];
    [self reloadSettings];
    [defaults addObserver: self
               forKeyPath: @"cursorHideTimeout"
                  options: NSKeyValueObservingOptionNew
                  context: NULL];

    enabled = true;

    [self propStringHack];
    [self startTimer];

    NSUInteger resetTimerMask = NSMouseMovedMask | NSLeftMouseDownMask | NSRightMouseDownMask;
    // TODO: really really inefficient. maybe there's an event that doesn't fire every time the mouse moves a pixel
    [NSEvent addGlobalMonitorForEventsMatchingMask:resetTimerMask handler:^(NSEvent *event) {
        //setAcceptsMouseMovedEvents
        // Instead of destroying/creating a timer on each mouse move event, just use nextEventMatchingMask
        CGError err = CGDisplayShowCursor(kCGDirectMainDisplay);
        if (err) {
            NSLog(@"Error showing cursor: %u", err);
        }
        [self startTimer];
    }];
}

@end
