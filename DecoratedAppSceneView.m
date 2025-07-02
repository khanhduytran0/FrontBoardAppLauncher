#import "DecoratedAppSceneView.h"
#import "AppSceneViewController.h"
#import "UIKitPrivate+MultitaskSupport.h"
#import "PiPManager.h"
#import <objc/runtime.h>

@interface RBSTarget : NSObject
@end
@implementation RBSTarget(hook)
+ (instancetype)hook_targetWithPid:(pid_t)pid environmentIdentifier:(NSString *)environmentIdentifier {
    if([environmentIdentifier containsString:@"LiveProcess"]) {
        environmentIdentifier = [NSString stringWithFormat:@"LiveProcess:%d", pid];
    }
    return [self hook_targetWithPid:pid environmentIdentifier:environmentIdentifier];
}
@end

void swizzleClass(Class class, SEL originalAction, SEL swizzledAction) {
    method_exchangeImplementations(class_getClassMethod(class, originalAction), class_getClassMethod(class, swizzledAction));
}

static int hook_return_2(void) {
    return 2;
}
__attribute__((constructor))
void UIKitFixesInit(void) {
    // Fix _UIPrototypingMenuSlider not continually updating its value on iOS 17+
    Class _UIFluidSliderInteraction = objc_getClass("_UIFluidSliderInteraction");
    if(_UIFluidSliderInteraction) {
        method_setImplementation(class_getInstanceMethod(_UIFluidSliderInteraction, @selector(_state)), (IMP)hook_return_2);
    }
    // TODO: Fix keyboard focus
    swizzleClass(RBSTarget.class, @selector(targetWithPid:environmentIdentifier:), @selector(hook_targetWithPid:environmentIdentifier:));
}

@interface DecoratedAppSceneView()
@property(nonatomic) AppSceneViewController* appSceneView;
@property(nonatomic) NSString *sceneID;
@property(nonatomic) NSString* windowName;
@property(nonatomic) int pid;
@property(nonatomic) CGFloat scaleRatio;

@end

@implementation DecoratedAppSceneView
- (instancetype)initWithApp:(LSApplicationProxy *)app windowName:(NSString*)windowName {
    self = [super initWithFrame:CGRectMake(0, 100, 320, 480 + 44)];
    self.scaleRatio = 1.0;
    NSArray *menuItems = @[
        [UIAction actionWithTitle:@"Copy PID" image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction * _Nonnull action) {
            UIPasteboard.generalPasteboard.string = @(self.pid).stringValue;
        }],
        [UIAction actionWithTitle:@"Enable PiP" image:[UIImage systemImageNamed:@"pip.enter"] identifier:nil handler:^(UIAction * _Nonnull action) {
            if ([PiPManager.shared isPiPWithView:self.appSceneView.view]) {
                [PiPManager.shared stopPiP];
            } else {
                [PiPManager.shared startPiPWithView:self.appSceneView.view contentView:self.contentView];
            }
        }],
        [UICustomViewMenuElement elementWithViewProvider:^UIView *(UICustomViewMenuElement *element) {
            return [self scaleSliderViewWithTitle:@"Scale" min:0.5 max:2.0 value:self.scaleRatio stepInterval:0.01];
        }]
    ];
    
    if(@available(iOS 16.0, *)) {
        __weak typeof(self) weakSelf = self;
        [self.navigationItem setTitleMenuProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions){
            NSString *pidText = [NSString stringWithFormat:@"PID: %d", self.pid];
            return [UIMenu menuWithTitle:pidText children:menuItems];
        }];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(closeWindow)];
    self.windowName = windowName;
    self.navigationItem.title = windowName;
    
    NSString *bundleID = app.bundleIdentifier;
    //self.transitionContext = [UIApplicationSceneTransitionContext new];
    RBSProcessIdentity* identity = [RBSProcessIdentity identityForEmbeddedApplicationIdentifier:bundleID];
    RBSProcessPredicate* predicate = [RBSProcessPredicate predicateMatchingIdentity:identity];
    FBProcessManager *manager = FBProcessManager.sharedInstance;
    FBApplicationProcessLaunchTransaction *transaction = [[FBApplicationProcessLaunchTransaction alloc] initWithProcessIdentity:identity executionContextProvider:^id(void){
        FBMutableProcessExecutionContext *context = [FBMutableProcessExecutionContext new];
        context.identity = identity;
        context.environment = @{}; // environment variables
        //context.waitForDebugger = NO;
        //context.disableASLR = NO;
        context.launchIntent = 4;
        //context.watchdogProvider = SBSceneWatchdogProvider
        return [manager launchProcessWithContext:context];
    }];
    
    [transaction setCompletionBlock:^{
        AppSceneViewController* appSceneView = [[AppSceneViewController alloc] initWithApp:app frame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height) delegate:self];
        appSceneView.view.layer.anchorPoint = CGPointMake(0, 0);
        appSceneView.view.layer.position = CGPointMake(0, 0);
        self.appSceneView = appSceneView;
        self.pid = appSceneView.pid;
        NSLog(@"Presenting app scene from PID %d", self.pid);
        [self.contentView insertSubview:appSceneView.view atIndex:0];
        if(@available(iOS 16.0, *)) {} else {
            [self iOS15SetupTitleMenu:menuItems];
        }
    }];
    [transaction begin];
    
    return self;
}

- (void)iOS15SetupTitleMenu:(NSArray<UIMenuElement *> *)menuItems {
    // https://github.com/LiveContainer/LiveContainer/commit/6ad506b7aef92d639178f17d88bbd0b77cfe2c69#diff-e3748f6b0b007ce504c448dfa3e22869c3a360a455672fc310083bc6a1e361a3
    UIImageSymbolConfiguration* sc1 = [UIImageSymbolConfiguration configurationWithPaletteColors:@[UIColor.secondaryLabelColor,UIColor.secondarySystemFillColor]];
    
    UIImageSymbolConfiguration* sc2 = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleMedium];
    UIImageSymbolConfiguration* sc = [sc1 configurationByApplyingConfiguration:sc2];
    UIImage* dropDownImage = [UIImage systemImageNamed:@"chevron.down.circle.fill" withConfiguration:sc];
    
    UIButtonConfiguration* bc = [UIButtonConfiguration plainButtonConfiguration];
    bc.imagePadding = 4;
    bc.imagePlacement = NSDirectionalRectEdgeTrailing;
    bc.titleTextAttributesTransformer = ^(NSDictionary<NSAttributedStringKey, id> *incoming) {
        NSMutableDictionary<NSAttributedStringKey, id> *outgoing = [incoming mutableCopy];
        outgoing[NSFontAttributeName] = self.navigationBar._defaultTitleFont;
        return outgoing;
    };
    UIButton *titleView = [UIButton buttonWithConfiguration:bc primaryAction:nil];
    
    [titleView setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
    [titleView setTitleColor:UIColor.secondaryLabelColor forState:UIControlStateHighlighted];
    //[UIFont boldSystemFontOfSize:_doneButton.titleLabel.font.pointSize]];
    titleView.showsMenuAsPrimaryAction = YES;
    [titleView setTitle:self.windowName forState:UIControlStateNormal];
    [titleView setImage:dropDownImage forState:UIControlStateNormal];
    
    NSString *pidText = [NSString stringWithFormat:@"PID: %d", self.pid];
    titleView.menu = [UIMenu menuWithTitle:pidText children:menuItems];
    
    self.navigationBar.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [self.navigationBar.standardAppearance configureWithTransparentBackground];
    self.navigationBar.standardAppearance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.navigationItem.titleView = titleView;
}

// Stolen from UIKitester
- (UIView *)scaleSliderViewWithTitle:(NSString *)title min:(CGFloat)minValue max:(CGFloat)maxValue value:(CGFloat)initialValue stepInterval:(CGFloat)step {
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.exclusiveTouch = YES;
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 0.0;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:10.0],
        [stackView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-8.0],
        [stackView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:16.0],
        [stackView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-16.0]
    ]];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont boldSystemFontOfSize:12.0];
    [stackView addArrangedSubview:label];
    
    _UIPrototypingMenuSlider *slider = [[_UIPrototypingMenuSlider alloc] init];
    slider.minimumValue = minValue;
    slider.maximumValue = maxValue;
    slider.value = initialValue;
    slider.stepSize = step;
    
    NSLayoutConstraint *sliderHeight = [slider.heightAnchor constraintEqualToConstant:40.0];
    sliderHeight.active = YES;
    
    [stackView addArrangedSubview:slider];
    
    [slider addTarget:self action:@selector(scaleSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    return containerView;
}

- (void)scaleSliderChanged:(_UIPrototypingMenuSlider *)slider {
    self.scaleRatio = slider.value;
    CGSize size = self.contentView.bounds.size;
    self.contentView.layer.sublayerTransform = CATransform3DMakeScale(_scaleRatio, _scaleRatio, 1.0);
    [self.appSceneView resizeWindowWithFrame:CGRectMake(0, 0, size.width / _scaleRatio, size.height / _scaleRatio)];
}

- (void)closeWindow {
    [self.appSceneView closeWindow];
}

- (void)resizeWindow:(UIPanGestureRecognizer*)sender {
    [super resizeWindow:sender];
    CGSize size = self.contentView.bounds.size;
    [self.appSceneView resizeWindowWithFrame:CGRectMake(0, 0, size.width / _scaleRatio, size.height / _scaleRatio)];
}

- (void)appDidExit {
    self.layer.masksToBounds = NO;
    [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        self.hidden = YES;
    } completion:^(BOOL b){
        [self removeFromSuperview];
    }];
}
@end
