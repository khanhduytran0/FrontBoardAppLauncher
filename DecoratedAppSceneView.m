#import "DecoratedAppSceneView.h"

@implementation DecoratedAppSceneView
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

    - (void)closeWindow {
        self.layer.masksToBounds = NO;
        [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionCurlUp animations:^{
            self.hidden = YES;
        } completion:^(BOOL b){
            [[FBSceneManager sharedInstance] destroyScene:self.sceneID withTransitionContext:nil];
            if(self.presenter){
                [self.presenter deactivate];
                [self.presenter invalidate];
                self.presenter = nil;
            }
            [self removeFromSuperview];
        }];
    }

    - (void)resizeWindow:(UIPanGestureRecognizer*)sender {
        [super resizeWindow:sender];

        self.settings.frame = self.bounds;
        [self.presenter.scene updateSettings:self.settings withTransitionContext:self.transitionContext completion:nil];
    }
@end
