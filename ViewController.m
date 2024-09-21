#import "ViewController.h"
#import "UIKitPrivate.h"
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

@interface UIScenePresentationContext : NSObject
- (UIScenePresentationContext *)_initWithDefaultValues;
@end

@interface _UISceneLayerHostContainerView : UIView
- (instancetype)initWithScene:(FBScene *)scene debugDescription:(NSString *)desc;
- (void)_setPresentationContext:(UIScenePresentationContext *)context;
@end

@interface UIApplication()
- (void)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

@interface ViewController ()
@property(nonatomic) FBApplicationProcessLaunchTransaction *transaction;
@property(nonatomic) UIScenePresentationManager *presentationManager;
@property(nonatomic) _UIScenePresenter *presenter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.title = @"FrontBoardAppLauncher";

    NSString *bundleID = @"com.apple.mobilesafari";
    RBSProcessIdentity* identity = [RBSProcessIdentity identityForEmbeddedApplicationIdentifier:bundleID];
    RBSProcessPredicate* predicate = [RBSProcessPredicate predicateMatchingIdentity:identity];

    FBProcessManager *manager = FBProcessManager.sharedInstance;
    self.transaction = [[FBApplicationProcessLaunchTransaction alloc] initWithProcessIdentity:identity executionContextProvider:^id(void){
        FBMutableProcessExecutionContext *context = [FBMutableProcessExecutionContext new];
        context.identity = identity;
        context.environment = @{}; // environment variables
        //context.waitForDebugger = NO;
        //context.disableASLR = NO;
        //context.checkForLeaks = NO;
        //context.arguments = nil;
        //context.disableASLR = NO;
        //context.standardOutputURL = nil;
        //context.standardErrorURL = nil;
        context.launchIntent = 4;
        //context.watchdogProvider = SBSceneWatchdogProvider
        return [manager launchProcessWithContext:context];
    }];

    [self.transaction setCompletionBlock:^{
        RBSProcessHandle* processHandle = [RBSProcessHandle handleForPredicate:predicate error:nil];
        [manager registerProcessForAuditToken:processHandle.auditToken];
        NSString *identifier = [NSString stringWithFormat:@"sceneID:%@-%@", bundleID, @"default"];

        // FBSDisplayConfiguration
        id displayConfig = UIScreen.mainScreen.displayConfiguration;

        FBSMutableSceneDefinition *definition = [FBSMutableSceneDefinition definition];
        definition.identity = [FBSSceneIdentity identityForIdentifier:identifier];
        definition.clientIdentity = [FBSSceneClientIdentity identityForProcessIdentity:identity];
        definition.specification = [UIApplicationSceneSpecification specification];
        FBSMutableSceneParameters *parameters = [FBSMutableSceneParameters parametersForSpecification:definition.specification];

        UIMutableApplicationSceneSettings *settings = [UIMutableApplicationSceneSettings new];
        settings.canShowAlerts = YES;
        settings.displayConfiguration = displayConfig;
        settings.foreground = YES;
        settings.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 100);
        settings.interfaceOrientation = UIInterfaceOrientationPortrait;
        //settings.interruptionPolicy = 2; // reconnect
        settings.level = 1;
        settings.persistenceIdentifier = NSUUID.UUID.UUIDString;
        //settings.statusBarDisabled = 1;
        //settings.previewMaximumSize = 
        //settings.deviceOrientationEventsEnabled = YES;
        parameters.settings = settings;

        UIMutableApplicationSceneClientSettings *clientSettings = [UIMutableApplicationSceneClientSettings new];
        clientSettings.interfaceOrientation = UIInterfaceOrientationPortrait;
        clientSettings.statusBarStyle = 0;
        parameters.clientSettings = clientSettings;

        FBScene *scene = [[FBSceneManager sharedInstance] createSceneWithDefinition:definition initialParameters:parameters];
        self.presentationManager = scene.uiPresentationManager;
        self.presenter = [self.presentationManager createPresenterWithIdentifier:identifier];
        [self.view addSubview:self.presenter.presentationView];
        [self.presenter activate];
    }];
    [self.transaction begin];
}

@end
