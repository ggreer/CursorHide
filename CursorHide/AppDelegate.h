//
//  AppDelegate.h
//  CursorHide
//
//  Created by Geoff Greer on 2/8/14.
//  Copyright (c) 2014 Geoff Greer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem *statusItem;
    NSTimer *timer;
    NSUserDefaults *defaults;
    double timeout;
    bool enabled;
}

@property (assign) IBOutlet NSMenu *menu;
@property (assign) IBOutlet NSMenuItem *state;

- (void)propStringHack;
- (void)reloadSettings;

- (void)hideCursor;
- (void)startTimer;

- (IBAction)toggle:(id)sender;
- (IBAction)quit:(id)sender;

@end
