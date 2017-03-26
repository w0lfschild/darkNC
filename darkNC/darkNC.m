//
//  darkNC.m
//  darkNC
//
//  Created by Wolfgang Baird on 3/11/17.
//  Copyright © 2017 Wolfgang Baird. All rights reserved.
//

@import AppKit;
#import "ZKSwizzle.h"

static const char * const newBackground = nil;

@interface _WB_DNC_NotificationClear : NSObject
@end

@interface _WB_DNC_NCNotificationCenterWindowController : NSWindowController
@end

@interface _WB_DNC_NCThirdPartyDisclosuresViewController : NSViewController
@end

@interface CABackdropLayer : CALayer
@end

@implementation _WB_DNC_NotificationClear

+(void)load {
    NSUInteger osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    if (osx_ver >= 12) {
        ZKSwizzle(_WB_DNC_NCNotificationCenterWindowController, NCNotificationCenterWindowController);
        ZKSwizzle(_WB_DNC_NCThirdPartyDisclosuresViewController, NCThirdPartyDisclosuresViewController);
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

- (void)wb_changeBackgroundColor {
    NSVisualEffectView *aview = ZKHookIvar(self, NSVisualEffectView*, "_texturedBackground");
    CALayer *alayer = ZKHookIvar(aview, CALayer*, "_materialLayer");
    CALayer *tlayer = ZKHookIvar(alayer, CALayer*, "_tintLayer");
    CABackdropLayer *blayer = ZKHookIvar(alayer, CABackdropLayer*, "_backdropLayer");
    
    NSVisualEffectView *darkNCBackground = objc_getAssociatedObject(self, newBackground);
    
    if (darkNCBackground == nil) {
        darkNCBackground = [[NSVisualEffectView alloc] initWithFrame:aview.frame];
        [darkNCBackground setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
        [aview addSubview:darkNCBackground positioned:NSWindowBelow relativeTo:nil];
        objc_setAssociatedObject(self, newBackground, darkNCBackground, OBJC_ASSOCIATION_RETAIN);
    }
    
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    if ([osxMode isEqualToString:@"Dark"]) {
        [tlayer setHidden:true];
        [blayer setHidden:true];
        [darkNCBackground setHidden:false];
    } else {
        [tlayer setHidden:false];
        [blayer setHidden:false];
        [darkNCBackground setHidden:true];
    }
}

- (void)tabChanged:(id)arg1 {
    [self wb_changeBackgroundColor];
    [self wb_changeTextColor:ZKHookIvar(self, NSView*, "_contentView")];
    ZKOrig(void, arg1);
}

- (void)willBeShown {
    [self wb_changeBackgroundColor];
    [self wb_changeTextColor:ZKHookIvar(self, NSView*, "_contentView")];
    ZKOrig(void);
}

@end

@implementation _WB_DNC_NCThirdPartyDisclosuresViewController

- (void)_updateView {
    NSTextView *view = ZKHookIvar(self, NSTextView*, "_textView");
    [view setHidden:true];
    // Nothing
}

@end
