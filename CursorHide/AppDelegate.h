//
//  AppDelegate.h
//  CursorHide
//
//  Created by Geoff Greer on 2/8/14.
//  Copyright (c) 2014 Geoff Greer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem * statusItem;
    NSTimer *timer;
    double timeout;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *statusMenu;

- (void)hideCursor;
- (void)propStringHack;
- (void)startTimer;

@end
