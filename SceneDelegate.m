#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "ViewController.h"
#import "UIKitPrivate+MultitaskSupport.h"
#import <objc/runtime.h>
#import "Hooks.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)appDelegate:(AppDelegate *)delegate createFloatingSceneFromScene:(UIWindowScene *)windowScene {
    delegate.binder = [[UIRootWindowScenePresentationBinder alloc] initWithPriority:0 displayConfiguration:windowScene._effectiveSettings.displayConfiguration];
    
    FBSMutableSceneDefinition *definition = [FBSMutableSceneDefinition definition];
    definition.identity = [FBSSceneIdentity identityForIdentifier:NSBundle.mainBundle.bundleIdentifier];
    definition.clientIdentity = [FBSSceneClientIdentity localIdentity];
    definition.specification = [UIApplicationSceneSpecification specification];
    FBSMutableSceneParameters *parameters = [FBSMutableSceneParameters parametersForSpecification:definition.specification];

    UIMutableApplicationSceneSettings *settings = windowScene._effectiveSettings.mutableCopy;
    settings.deactivationReasons = 0;
    settings.foreground = YES;
    settings.interruptionPolicy = 0;
    parameters.settings = settings;
    parameters.clientSettings = windowScene._effectiveUIClientSettings;

    FBScene *scene = [[FBSceneManager sharedInstance] createSceneWithDefinition:definition initialParameters:parameters];
    [delegate.binder addScene:scene];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    
    AppDelegate *delegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    if(!delegate.binder) {
        [self appDelegate:delegate createFloatingSceneFromScene:windowScene];
    }
    
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    self.window.rootViewController = [ViewController new];
    [self.window makeKeyAndVisible];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

@end
