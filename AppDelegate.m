#import "AppDelegate.h"
#import "ViewController.h"

@interface UIRootSceneWindow : UIWindow
@end

@implementation UIRootSceneWindow(hook)
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.backgroundColor = UIColor.clearColor.CGColor;
}

- (CGFloat)windowLevel {
    return 10000;
}
@end

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    FBSMutableSceneDefinition *definition = [FBSMutableSceneDefinition definition];
    definition.identity = [FBSSceneIdentity identityForIdentifier:NSBundle.mainBundle.bundleIdentifier];
    definition.clientIdentity = [FBSSceneClientIdentity localIdentity];
    definition.specification = [UIApplicationSceneSpecification specification];
    FBSMutableSceneParameters *parameters = [FBSMutableSceneParameters parametersForSpecification:definition.specification];

    UIMutableApplicationSceneSettings *settings = [UIMutableApplicationSceneSettings new];
    settings.displayConfiguration = UIScreen.mainScreen.displayConfiguration;
    settings.frame = [UIScreen.mainScreen _referenceBounds];
    settings.level = 1;
    settings.foreground = YES;
    settings.interfaceOrientation = UIInterfaceOrientationPortrait;
    settings.deviceOrientationEventsEnabled = YES;
    [settings.ignoreOcclusionReasons addObject:@"SystemApp"];
    parameters.settings = settings;

        UIMutableApplicationSceneClientSettings *clientSettings = [UIMutableApplicationSceneClientSettings new];
    clientSettings.interfaceOrientation = UIInterfaceOrientationPortrait;
    clientSettings.statusBarStyle = 0;
    parameters.clientSettings = clientSettings;

    FBScene *scene = [[FBSceneManager sharedInstance] createSceneWithDefinition:definition initialParameters:parameters];
    self.binder = [[UIRootWindowScenePresentationBinder alloc] initWithPriority:0 displayConfiguration:settings.displayConfiguration];
    [self.binder addScene:scene];
    return self;
}

#pragma mark - UISceneSession lifecycle
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

@end
