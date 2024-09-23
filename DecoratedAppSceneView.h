#import "UIKitPrivate.h"
#import "DecoratedFloatingView.h"

@interface DecoratedAppSceneView : DecoratedFloatingView
@property(nonatomic) _UIScenePresenter *presenter;
@property(nonatomic) UIMutableApplicationSceneSettings *settings;
@property(nonatomic) UIApplicationSceneTransitionContext *transitionContext;

- (instancetype)initWithBundleID:(NSString *)bundleID;
@end
