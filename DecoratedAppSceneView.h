#import "UIKitPrivate.h"
#import "DecoratedFloatingView.h"

@interface DecoratedAppSceneView : DecoratedFloatingView
    @property(nonatomic) _UIScenePresenter *presenter;
    @property(nonatomic) UIMutableApplicationSceneSettings *settings;
    @property(nonatomic) UIApplicationSceneTransitionContext *transitionContext;
    @property(nonatomic) NSString *sceneID;

    - (instancetype)initWithBundleID:(LSApplicationProxy *)app;
@end
