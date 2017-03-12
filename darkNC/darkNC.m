//
//  darkNC.m
//  darkNC
//
//  Created by Wolfgang Baird on 3/11/17.
//  Copyright © 2017 Wolfgang Baird. All rights reserved.
//

@import AppKit;
#import "ZKSwizzle.h"

@interface _WB_DNC_NotificationClear : NSObject
@end

@interface _WB_DNC_NCNotificationCenterWindowController : NSWindowController
@end

@interface _WB_DNC_NCWindow : NSPanel
@end

@interface _WB_DNC_NCThirdPartyDisclosuresViewController : NSViewController
@end

@implementation _WB_DNC_NotificationClear

+(void)load {
    NSUInteger osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    if (osx_ver >= 12) {
        ZKSwizzle(_WB_DNC_NCNotificationCenterWindowController, NCNotificationCenterWindowController);
        ZKSwizzle(_WB_DNC_NCWindow, _NCWindow);
    }
    NSLog(@"Notification Clear Loaded");
}

@end

@implementation _WB_DNC_NCNotificationCenterWindowController

- (void)wb_changeTextColor:(NSView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (NSView *subview in subviews) {
        
        // Do what you want to do with the subview
        if ([subview respondsToSelector:@selector(setTextColor:)]) {
            NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
            if ([osxMode isEqualToString:@"Dark"])
                [(NSTextView*)subview setTextColor:[NSColor whiteColor]];
            else
                [(NSTextView*)subview setTextColor:[NSColor blackColor]];
            [subview display];
        }
        
        // List the subviews of subview
        [self wb_changeTextColor:subview];
    }
}

- (void)tabChanged:(id)arg1 {
    [self wb_changeTextColor:ZKHookIvar(self, NSView*, "_contentView")];
    ZKOrig(void, arg1);
}

- (void)willBeShown {
    [self wb_changeTextColor:ZKHookIvar(self, NSView*, "_contentView")];
    ZKOrig(void);
}

@end

@implementation _WB_DNC_NCWindow

- (BOOL)inLiveResize {
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    if ([osxMode isEqualToString:@"Dark"])
        self.backgroundColor = [NSColor colorWithSRGBRed:0.0 green: 0.0 blue: 0.0 alpha:0.65];
    else
        self.backgroundColor = [NSColor clearColor];
    return ZKOrig(BOOL);
}

@end
