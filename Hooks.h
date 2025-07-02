//
//  Hooks.h
//  
//
//  Created by Duy Tran on 29/6/25.
//

@import ObjectiveC;

typedef struct {
    id displayIdentity;
    BOOL showsOnTop;
    BOOL ignoresHitTest;
    BOOL shouldCreateContextAsSecure;
    BOOL shouldUseRemoteContext;
    BOOL alwaysGetsContexts;
    BOOL isWindowServerHostingManaged;
    BOOL keepContextInBackground;
    BOOL isHostingPortalViews;
    BOOL allowsOcclusionDetectionOverride;
} UIWindowBindingDescription;

void swizzle(Class class, SEL originalAction, SEL swizzledAction);
