//
//  AppSceneView.m
//  LiveContainer
//
//  Created by s s on 2025/5/17.
//
#import "AppSceneViewController.h"
#import "PiPManager.h"

@implementation AppSceneViewController {
    int resizeDebounceToken;
    CGRect currentFrame;
    bool isNativeWindow;
    NSUUID* identifier;
}

/*
 - (instancetype)initWithBundleID:(LSApplicationProxy *)app{
     self = [super initWithFrame:CGRectMake(0, 100, 400, 400)];

     self.navigationBar.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
     [self.navigationBar.standardAppearance configureWithTransparentBackground];
     self.navigationBar.standardAppearance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(closeWindow)];

     NSString *bundleID = app.bundleIdentifier;
     self.transitionContext = [UIApplicationSceneTransitionContext new];
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
         // At this point, the process is spawned and we're ready to create a scene to render in our app
         RBSProcessHandle* processHandle = [RBSProcessHandle handleForPredicate:predicate error:nil];
         [manager registerProcessForAuditToken:processHandle.auditToken];
         // NSString *identifier = [NSString stringWithFormat:@"sceneID:%@-%@", bundleID, @"default"];
         self.sceneID = [NSString stringWithFormat:@"sceneID:%@-%@", bundleID, @"default"];

         FBSMutableSceneDefinition *definition = [FBSMutableSceneDefinition definition];
         definition.identity = [FBSSceneIdentity identityForIdentifier:self.sceneID];
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

         self.navigationItem.title = app.localizedName;

         self.presenter = [scene.uiPresentationManager createPresenterWithIdentifier:self.sceneID];
         [self.presenter activate];
         [self insertSubview:self.presenter.presentationView atIndex:0];
     }];
     [transaction begin];
     return self;
 }
 */

- (instancetype)initWithApp:(LSApplicationProxy *)app frame:(CGRect)frame delegate:(id<AppSceneViewDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    currentFrame = frame;
    self.delegate = delegate;
    isNativeWindow = NO;//[[[NSUserDefaults alloc] initWithSuiteName:[LCUtils appGroupID]] integerForKey:@"LCMultitaskMode" ] == 1;
    
    NSString *bundleID = app.bundleIdentifier;
    //self.transitionContext = [UIApplicationSceneTransitionContext new];
    RBSProcessIdentity* identity = [RBSProcessIdentity identityForEmbeddedApplicationIdentifier:bundleID];
    RBSProcessPredicate* predicate = [RBSProcessPredicate predicateMatchingIdentity:identity];
    FBProcessManager *manager = FBProcessManager.sharedInstance;
    
    // At this point, the process is spawned and we're ready to create a scene to render in our app
    RBSProcessHandle* processHandle = [PrivClass(RBSProcessHandle) handleForPredicate:predicate error:nil];
    self.pid = processHandle.pid;
    if(!self.isAppRunning) return self;
    [manager registerProcessForAuditToken:processHandle.auditToken];
    // NSString *identifier = [NSString stringWithFormat:@"sceneID:%@-%@", bundleID, @"default"];
    self.sceneID = [NSString stringWithFormat:@"sceneID:%@-%@", bundleID, @"default"];
    
    FBSMutableSceneDefinition *definition = [PrivClass(FBSMutableSceneDefinition) definition];
    definition.identity = [PrivClass(FBSSceneIdentity) identityForIdentifier:self.sceneID];
    definition.clientIdentity = [PrivClass(FBSSceneClientIdentity) identityForProcessIdentity:processHandle.identity];
    definition.specification = [UIApplicationSceneSpecification specification];
    FBSMutableSceneParameters *parameters = [PrivClass(FBSMutableSceneParameters) parametersForSpecification:definition.specification];
    
    UIMutableApplicationSceneSettings *settings = [UIMutableApplicationSceneSettings new];
    settings.canShowAlerts = YES;
    settings.cornerRadiusConfiguration = [[PrivClass(BSCornerRadiusConfiguration) alloc] initWithTopLeft:self.view.layer.cornerRadius bottomLeft:self.view.layer.cornerRadius bottomRight:self.view.layer.cornerRadius topRight:self.view.layer.cornerRadius];
    settings.displayConfiguration = UIScreen.mainScreen.displayConfiguration;
    settings.foreground = YES;
    
    settings.deviceOrientation = UIDevice.currentDevice.orientation;
    settings.interfaceOrientation = UIApplication.sharedApplication.statusBarOrientation;
    if(UIInterfaceOrientationIsLandscape(settings.interfaceOrientation)) {
        settings.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    } else {
        settings.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    //settings.interruptionPolicy = 2; // reconnect
    settings.level = 1;
    settings.persistenceIdentifier = NSUUID.UUID.UUIDString;
    if(isNativeWindow) {
        UIEdgeInsets defaultInsets = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
        settings.peripheryInsets = defaultInsets;
        settings.safeAreaInsetsPortrait = defaultInsets;
    } else {
        // it seems some apps don't honor these settings so we don't cover the top of the app
        settings.peripheryInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        settings.safeAreaInsetsPortrait = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    
    settings.statusBarDisabled = !isNativeWindow;
    //settings.previewMaximumSize =
    //settings.deviceOrientationEventsEnabled = YES;
    self.settings = settings;
    parameters.settings = settings;
    
    UIMutableApplicationSceneClientSettings *clientSettings = [UIMutableApplicationSceneClientSettings new];
    clientSettings.interfaceOrientation = UIInterfaceOrientationPortrait;
    clientSettings.statusBarStyle = 0;
    parameters.clientSettings = clientSettings;
    
    FBScene *scene = [[PrivClass(FBSceneManager) sharedInstance] createSceneWithDefinition:definition initialParameters:parameters];
    
    self.presenter = [scene.uiPresentationManager createPresenterWithIdentifier:self.sceneID];
    [self.presenter modifyPresentationContext:^(UIMutableScenePresentationContext *context) {
        context.appearanceStyle = 2;
    }];
    [self.presenter activate];
    
    self.view = self.presenter.presentationView;
    return self;
}

// this method should not be called in native window mode
- (void)resizeWindowWithFrame:(CGRect)frame {
    __block int currentDebounceToken = self->resizeDebounceToken + 1;
    self->resizeDebounceToken = currentDebounceToken;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        if(currentDebounceToken != self->resizeDebounceToken) {
            return;
        }
        self->currentFrame = frame;
        [self.presenter.scene updateSettingsWithBlock:^(UIMutableApplicationSceneSettings *settings) {
            settings.deviceOrientation = UIDevice.currentDevice.orientation;
            settings.interfaceOrientation = self.view.window.windowScene.interfaceOrientation;
            if(UIInterfaceOrientationIsLandscape(settings.interfaceOrientation)) {
                CGRect frame2 = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
                settings.frame = frame2;
            } else {
                settings.frame = frame;
            }
        }];
    });
}

- (void)closeWindow {
    __weak typeof(self) weakSelf = self;
    NSString *key = [NSString stringWithFormat:@"AppSceneViewController:%p", self];
    [self.view.window.windowScene _unregisterSettingsDiffActionArrayForKey:key];
    [[PrivClass(FBSceneManager) sharedInstance] destroyScene:key withTransitionContext:nil];
    if(self.presenter){
        [self.presenter deactivate];
        [self.presenter invalidate];
        self.presenter = nil;
    }
    if(self.isAppRunning) {
        // FIXME: need to check if there are no other scenes hosted by SpringBoard
        kill(_pid, SIGTERM);
        NSLog(@"sent sigterm");
        if(self.isAppRunning) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                kill(_pid, SIGKILL);
            });
        }
    }
    [self.delegate appDidExit];
    self.delegate = nil;
}

- (void)_performActionsForUIScene:(UIScene *)scene withUpdatedFBSScene:(id)fbsScene settingsDiff:(FBSSceneSettingsDiff *)diff fromSettings:(UIApplicationSceneSettings *)settings transitionContext:(id)context lifecycleActionType:(uint32_t)actionType {
    [self displayAppTerminatedTextIfNeeded];
    if(!diff) return;
    UIMutableApplicationSceneSettings *baseSettings = [diff settingsByApplyingToMutableCopyOfSettings:settings];
    
    UIApplicationSceneTransitionContext *newContext = [context copy];
    newContext.actions = nil;
    if(isNativeWindow) {
        // directly update the settings
        baseSettings.interruptionPolicy = 0;
        baseSettings.safeAreaInsetsPortrait = self.view.window.safeAreaInsets;
        baseSettings.peripheryInsets = self.view.window.safeAreaInsets;
        [self.presenter.scene updateSettings:baseSettings withTransitionContext:newContext completion:nil];
    } else {
        UIMutableApplicationSceneSettings *newSettings = [self.presenter.scene.settings mutableCopy];
        newSettings.userInterfaceStyle = baseSettings.userInterfaceStyle;
        newSettings.interfaceOrientation = baseSettings.interfaceOrientation;
        newSettings.deviceOrientation = baseSettings.deviceOrientation;
        newSettings.foreground = YES;
        if(UIInterfaceOrientationIsLandscape(baseSettings.interfaceOrientation)) {
            newSettings.frame = CGRectMake(0, 0, currentFrame.size.height, currentFrame.size.width);
        } else {
            newSettings.frame = CGRectMake(0, 0, currentFrame.size.width, currentFrame.size.height);
        }
        [self.presenter.scene updateSettings:newSettings withTransitionContext:newContext completion:nil];
    }
}

- (void)displayAppTerminatedTextIfNeeded {
    if(!self.isAppRunning) {
        if(!isNativeWindow) {
            UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.numberOfLines = 0;
            label.text = @"This app has been terminated.";
            label.textAlignment = NSTextAlignmentCenter;
            [self.view.superview addSubview:label];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view.window.windowScene _registerSettingsDiffActionArray:@[self] forKey:[NSString stringWithFormat:@"AppSceneViewController:%p", self]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayAppTerminatedTextIfNeeded];
    [self.view.window.windowScene _registerSettingsDiffActionArray:@[self] forKey:[NSString stringWithFormat:@"AppSceneViewController:%p", self]];
}

- (BOOL)isAppRunning {
    return _pid > 0 && kill(_pid, 0) == 0;
}

@end
 
