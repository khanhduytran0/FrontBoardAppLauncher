//
//  FBSSceneSettings.m
//  
//
//  Created by Duy Tran on 29/6/25.
//

#import "Hooks.h"
#import "UIKitPrivate+MultitaskSupport.h"

extern CGFloat UIHUDWindowLevel;

@implementation UIApplication (hook)
+ (CGFloat)preferredWindowLevel {
    return 1000.0;
}
@end

@implementation UIWindow(hook)
- (BOOL)_allowsOcclusionDetectionOverride {
    return YES;
}

- (BOOL)_extendsScreenSceneLifetime {
    return YES;
}

- (BOOL)_touchesInsideShouldHideCalloutBar {
    return NO;
}

- (BOOL)_transformLayerIncludesScreenRotation {
    return YES;
}

- (BOOL)_usesWindowServerHitTesting {
    return YES;
}

- (id)_layerForCoordinateSpaceConversion {
    return self.layer;
}

- (UIWindowBindingDescription)hook__bindingDescription {
    UIWindowBindingDescription desc = [self hook__bindingDescription];
    desc.showsOnTop = YES;
    return desc;
}

// Fixup scaling
- (void)_configureRootLayer:(CALayer *)rootLayer sceneTransformLayer:(CALayer *)sceneTransformLayer transformLayer:(CALayer *)transformLayer {
    UIScreen *screen = [self screen];
    if(!screen) {
        screen = self.windowScene.screen; // Fallback to windowScene's screen if available
    }
    CGRect unjailedBounds = [screen _unjailedReferenceBounds]; // Private UIScreen method
    double screenScale = screen.scale;
    double screenRotation = [screen _rotation]; // Private UIScreen method
    
    // Calculate center of bounds
    double centerX = unjailedBounds.origin.x + unjailedBounds.size.width * 0.5;
    double centerY = unjailedBounds.origin.y + unjailedBounds.size.height * 0.5;
    
    CGPoint renderingCenter = [[screen displayConfiguration] renderingCenter];
    
    // Apply rotation and scale to the rootLayer
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(-screenRotation);
    CGAffineTransform scaleTransform = CGAffineTransformScale(rotationTransform, screenScale, screenScale);
    CGAffineTransform currentRootLayerTransform = scaleTransform;
    rootLayer.position = renderingCenter;
    rootLayer.affineTransform = currentRootLayerTransform;
    rootLayer.bounds = unjailedBounds;
    
    sceneTransformLayer.affineTransform = CGAffineTransformIdentity;
    sceneTransformLayer.position = CGPointMake(centerX, centerY);
    sceneTransformLayer.bounds = unjailedBounds;
    
    transformLayer.affineTransform = CGAffineTransformIdentity;
    transformLayer.position = CGPointMake(centerX, centerY);
    transformLayer.bounds = unjailedBounds; // Re-set bounds after potential rotation
    transformLayer.masksToBounds = YES;
}
@end


@interface FBSWorkspaceScenesClient : NSObject
@end
static BOOL shouldAllowNextUpdate = NO;
@implementation FBSWorkspaceScenesClient(hook)
- (void)hook_sceneID:(id)sceneID updateWithSettingsDiff:(id)diff transitionContext:(id)context completion:(id)completion {
    if(!diff) {
        [self hook_sceneID:sceneID updateWithSettingsDiff:diff transitionContext:context completion:completion];
        return;
    }
    // query 6 for foreground state
    BSSettings *changes = [diff valueForKey:@"changes"];
    // query 3 for deactivation reasons
    BSSettings *otherChanges = [diff valueForKeyPath:@"otherSettingsDiff.changes"];
    if([changes boolForSetting:6] || (![changes.allSettings containsIndex:6] && [[otherChanges objectForSetting:3] intValue] == 0)) {
        NSLog(@"Allowing next update for diff %@", diff);
        [self hook_sceneID:sceneID updateWithSettingsDiff:diff transitionContext:context completion:completion];
    }
}
@end

void swizzle(Class class, SEL originalAction, SEL swizzledAction) {
    method_exchangeImplementations(class_getInstanceMethod(class, originalAction), class_getInstanceMethod(class, swizzledAction));
}

__attribute__((constructor))
static void hook_init() {
    //method_setImplementation(class_getInstanceMethod(NSClassFromString(@"UIKeyboardVisualModeManager"), @selector(windowingModeEnabled)), (IMP)returnTrue);
    swizzle(UIWindow.class, @selector(_bindingDescription), @selector(hook__bindingDescription));
    swizzle(FBSWorkspaceScenesClient.class, @selector(sceneID:updateWithSettingsDiff:transitionContext:completion:), @selector(hook_sceneID:updateWithSettingsDiff:transitionContext:completion:));
}
