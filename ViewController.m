#import "ViewController.h"
#include <dlfcn.h>
#include <mach/mach.h>
#include <sys/mman.h>

void showDialog(UIViewController *viewController, NSString* title, NSString* message) {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
        message:message
        preferredStyle:UIAlertControllerStyleAlert];
    //text.dataDetectorTypes = UIDataDetectorTypeLink;
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];

    [viewController presentViewController:alert animated:YES completion:nil];
}

@interface DecoratedAppSceneView : UIView
@property(nonatomic) UINavigationBar *navigationBar;
@property(nonatomic) UIView *resizeHandle;

@property(nonatomic) _UIScenePresenter *presenter;
@property(nonatomic) UIMutableApplicationSceneSettings *settings;
@property(nonatomic) UIApplicationSceneTransitionContext *transitionContext;

- (instancetype)initWithPresenter:(_UIScenePresenter *)presenter;
@end

@implementation DecoratedAppSceneView
- (instancetype)initWithBundleID:(NSString *)bundleID {
    self = [super initWithFrame:CGRectMake(0, 100, 400, 400)];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.transitionContext = [UIApplicationSceneTransitionContext new];

    // Navigation bar
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navigationBar.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [self.navigationBar.standardAppearance configureWithTransparentBackground];
    self.navigationBar.standardAppearance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:bundleID];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(closeWindow)];
    self.navigationBar.items = @[navigationItem];
    [self addSubview:self.navigationBar];
    UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveWindow:)];
    moveGesture.minimumNumberOfTouches = 1;
    moveGesture.maximumNumberOfTouches = 1;
    [self.navigationBar addGestureRecognizer:moveGesture];

    // Resize handle (idea stolen from Notes debugging window)
    self.resizeHandle = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 30, self.frame.size.height - 30, 60, 60)];
    self.resizeHandle.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.resizeHandle.transform = CGAffineTransformMakeRotation(M_PI_4);
    [self addSubview:self.resizeHandle];
    UIPanGestureRecognizer *resizeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeWindow:)];
    resizeGesture.minimumNumberOfTouches = 1;
    resizeGesture.maximumNumberOfTouches = 1;
    [self.resizeHandle addGestureRecognizer:resizeGesture];

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
        RBSProcessHandle* processHandle = [RBSProcessHandle handleForPredicate:predicate error:nil];
        [manager registerProcessForAuditToken:processHandle.auditToken];
        NSString *identifier = [NSString stringWithFormat:@"sceneID:%@-%@", bundleID, @"default"];

        FBSMutableSceneDefinition *definition = [FBSMutableSceneDefinition definition];
        definition.identity = [FBSSceneIdentity identityForIdentifier:identifier];
        definition.clientIdentity = [FBSSceneClientIdentity identityForProcessIdentity:identity];
        definition.specification = [UIApplicationSceneSpecification specification];
        FBSMutableSceneParameters *parameters = [FBSMutableSceneParameters parametersForSpecification:definition.specification];

        UIMutableApplicationSceneSettings *settings = [UIMutableApplicationSceneSettings new];
        settings.canShowAlerts = YES;
        settings.cornerRadiusConfiguration = [[BSCornerRadiusConfiguration alloc] initWithTopLeft:self.layer.cornerRadius bottomLeft:self.layer.cornerRadius bottomRight:self.layer.cornerRadius topRight:self.layer.cornerRadius];
        settings.displayConfiguration = UIScreen.mainScreen.displayConfiguration;
        settings.foreground = YES;
        settings.frame = self.bounds;
        settings.interfaceOrientation = UIInterfaceOrientationPortrait;
        //settings.interruptionPolicy = 2; // reconnect
        settings.level = 1;
        settings.peripheryInsets = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0, 0, 0);
        settings.persistenceIdentifier = NSUUID.UUID.UUIDString;
        settings.safeAreaInsetsPortrait = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0, 0, 0);
        //settings.statusBarDisabled = 1;
        //settings.previewMaximumSize = 
        //settings.deviceOrientationEventsEnabled = YES;
        self.settings = settings;
        parameters.settings = settings;

        UIMutableApplicationSceneClientSettings *clientSettings = [UIMutableApplicationSceneClientSettings new];
        clientSettings.interfaceOrientation = UIInterfaceOrientationPortrait;
        clientSettings.statusBarStyle = 0;
        parameters.clientSettings = clientSettings;

        FBScene *scene = [[FBSceneManager sharedInstance] createSceneWithDefinition:definition initialParameters:parameters];

        // TODO: get app display name
        navigationItem.title = scene.clientProcess.name;

        self.presenter = [scene.uiPresentationManager createPresenterWithIdentifier:identifier];
        [self.presenter activate];
        [self insertSubview:self.presenter.presentationView atIndex:0];
    }];
    [transaction begin];
    return self;
}

- (void)closeWindow {
    self.layer.masksToBounds = NO;
    [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionCurlUp //CrossDissolve
    animations:^{
        self.hidden = YES;
    } completion:^(BOOL b){
        [self.presenter deactivate];
        [self.presenter invalidate];
        [self removeFromSuperview];
    }];
}

- (void)moveWindow:(UIPanGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.superview bringSubviewToFront:self];
    }

    CGPoint point = [sender translationInView:self];
    [sender setTranslation:CGPointZero inView:self];

    self.center = CGPointMake(self.center.x + point.x, self.center.y + point.y);
}

- (void)resizeWindow:(UIPanGestureRecognizer*)sender {
    CGPoint point = [sender translationInView:self];
    [sender setTranslation:CGPointZero inView:self];

    CGRect frame = self.frame;
    frame.size.width += point.x;
    frame.size.height += point.y;
    self.frame = frame;
    self.resizeHandle.center = CGPointMake(self.resizeHandle.center.x + point.x, self.resizeHandle.center.y + point.y);

    self.settings.frame = self.bounds;
    [self.presenter.scene updateSettings:self.settings withTransitionContext:self.transitionContext completion:nil];
}
@end

@interface ViewController ()
@property(nonatomic) FBApplicationProcessLaunchTransaction *transaction;
@property(nonatomic) UIScenePresentationManager *presentationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.title = @"FrontBoardAppLauncher";

    [self.view addSubview:[[DecoratedAppSceneView alloc] initWithBundleID:@"com.opa334.TrollStore"]];
    [self.view addSubview:[[DecoratedAppSceneView alloc] initWithBundleID:@"com.apple.tips"]];
    [self.view addSubview:[[DecoratedAppSceneView alloc] initWithBundleID:@"com.apple.mobilesafari"]];
    [self.view addSubview:[[DecoratedAppSceneView alloc] initWithBundleID:@"com.apple.Preferences"]];
}

@end
