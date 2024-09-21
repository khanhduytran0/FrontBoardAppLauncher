#import <UIKit/UIKit.h>

typedef struct {
	unsigned val[8];
} SCD_Struct_RB3;

// BoardServices
@interface BSSettings : NSObject
@end

@interface BSTransaction : NSObject
- (void)addChildTransaction:(id)transaction;
- (void)begin;
- (void)setCompletionBlock:(dispatch_block_t)block;
@end

// FrontBoard

@class RBSProcessIdentity, FBProcessExecutableSlice, UIScenePresentationManager, _UIScenePresenter;

@interface FBApplicationProcessLaunchTransaction : BSTransaction
- (instancetype) initWithProcessIdentity:(RBSProcessIdentity *)identity executionContextProvider:(id)providerBlock;
- (void)_begin;
@end

@interface FBProcessExecutionContext : NSObject
@end

@interface FBMutableProcessExecutionContext : FBProcessExecutionContext

@property (nonatomic,copy) RBSProcessIdentity * identity; 
@property (nonatomic,copy) NSArray * arguments; 
@property (nonatomic,copy) NSDictionary * environment; 
@property (nonatomic,retain) NSURL * standardOutputURL; 
@property (nonatomic,retain) NSURL * standardErrorURL; 
@property (assign,nonatomic) BOOL waitForDebugger; 
@property (assign,nonatomic) BOOL disableASLR; 
@property (assign,nonatomic) BOOL checkForLeaks; 
@property (assign,nonatomic) long long launchIntent; 
//@property (nonatomic,retain) id<FBProcessWatchdogProviding> watchdogProvider; 
@property (nonatomic,copy) NSString * overrideExecutablePath; 
//@property (nonatomic,retain) FBProcessExecutableSlice * overrideExecutableSlice; 
@property (nonatomic,copy) id completion; 
-(id)copyWithZone:(NSZone*)arg1 ;
@end

@interface FBScene : NSObject
- (UIScenePresentationManager *)uiPresentationManager;
@end

@interface FBDisplayManager : NSObject
+ (instancetype)sharedInstance;
- (id)mainConfiguration;
@end

@interface FBSSceneClientIdentity : NSObject
+ (instancetype)identityForBundleID:(NSString *)bundleID;
+ (instancetype)identityForProcessIdentity:(RBSProcessIdentity *)identity;
@end

@interface FBProcessManager : NSObject
+ (instancetype)sharedInstance;
- (FBProcessExecutionContext *)launchProcessWithContext:(FBMutableProcessExecutionContext *)context;
- (void)registerProcessForAuditToken:(SCD_Struct_RB3)token;
@end

@interface FBSSceneSpecification : NSObject
+ (instancetype)specification;
@end

// RunningBoardServices
@interface RBSProcessIdentity : NSObject
+ (instancetype)identityForEmbeddedApplicationIdentifier:(NSString *)identifier;
@end

@interface RBSProcessPredicate
+ (instancetype)predicateMatchingIdentity:(RBSProcessIdentity *)identity;
@end

@interface RBSProcessHandle
+ (instancetype)handleForPredicate:(RBSProcessPredicate *)predicate error:(NSError **)error;
- (SCD_Struct_RB3)auditToken;
@end

@interface UIApplicationSceneSpecification : FBSSceneSpecification
@end

@interface FBSSceneIdentity : NSObject
+ (instancetype)identityForIdentifier:(NSString *)id;
@end

// FBSSceneSettings
@interface UIMutableApplicationSceneSettings : NSObject
@property(nonatomic, assign, readwrite) BOOL canShowAlerts;
@property(nonatomic, assign) BOOL deviceOrientationEventsEnabled;
@property(nonatomic, assign, readwrite) NSInteger interruptionPolicy;
@property(nonatomic, strong, readwrite) NSString *persistenceIdentifier;
- (CGRect)frame;
- (NSMutableSet *)ignoreOcclusionReasons;
- (void)setDisplayConfiguration:(id)c;
- (void)setForeground:(BOOL)f;
- (void)setFrame:(CGRect)frame;
- (void)setLevel:(NSInteger)level;
- (void)setStatusBarDisabled:(BOOL)disabled;
- (void)setInterfaceOrientation:(NSInteger)o;
- (BSSettings *)otherSettings;
@end

@interface UIMutableApplicationSceneClientSettings : NSObject
@property(nonatomic, assign) NSInteger interfaceOrientation;
@property(nonatomic, assign) NSInteger statusBarStyle;
@end

@interface FBSSceneParameters : NSObject
@property(nonatomic, copy) UIMutableApplicationSceneSettings *settings;
@property(nonatomic, copy) UIMutableApplicationSceneClientSettings *clientSettings;
+ (instancetype)parametersForSpecification:(FBSSceneSpecification *)spec;
//- (void)updateSettingsWithBlock:(id)block;
@end

@interface FBSMutableSceneParameters : FBSSceneParameters
//- (void)updateClientSettingsWithBlock:(id)block;
@end

@interface FBSMutableSceneDefinition : NSObject
@property(nonatomic, copy) FBSSceneClientIdentity *clientIdentity;
@property(nonatomic, copy) FBSSceneIdentity *identity;
@property(nonatomic, copy) FBSSceneSpecification *specification;
+ (instancetype)definition;
@end

@interface FBSceneManager : NSObject
+ (instancetype)sharedInstance;
- (FBScene *)createSceneWithDefinition:(id)def initialParameters:(id)params;
@end

// UIKit
@interface UIWindow(private)
- (instancetype)_initWithFrame:(CGRect)frame attached:(BOOL)attached;
- (void)orderFront:(id)arg1;
@end

@interface UIScreen(private)
- (CGRect)_referenceBounds;
- (id)displayConfiguration;
@end

@interface UIScenePresentationBinder : NSObject
- (void)addScene:(id)scene;
@end

@interface UIScenePresentationManager : NSObject
- (instancetype)_initWithScene:(FBScene *)scene;
- (_UIScenePresenter *)createPresenterWithIdentifier:(NSString *)identifier;
@end

@interface _UIScenePresenterOwner : NSObject
- (instancetype)initWithScenePresentationManager:(UIScenePresentationManager *)manager context:(FBScene *)scene;
@end

@interface _UIScenePresentationView : UIView
//- (instancetype)initWithPresenter:(_UIScenePresenter *)presenter;
@end

@interface _UIScenePresenter : NSObject
@property (nonatomic, assign, readonly) _UIScenePresentationView *presentationView;
- (instancetype)initWithOwner:(_UIScenePresenterOwner *)manager identifier:(NSString *)scene sortContext:(NSNumber *)context;
- (void)activate;
@end

@interface UIRootWindowScenePresentationBinder : UIScenePresentationBinder
- (instancetype)initWithPriority:(int)pro displayConfiguration:(id)c;
@end

// PreviewsServicesUI
@interface UVInjectedScene: NSObject
@property(nonatomic, assign, readonly) FBScene *scene;
@property(nonatomic, assign, readonly) NSString *sceneIdentifier;
+ (instancetype)injectInProcess:(NSInteger)pid error:(NSError **)error;
+ (instancetype)_injectInProcessHandle:(RBSProcessHandle *)process error:(NSError **)error;
@end

@interface UVSceneHost : UIView
+ (instancetype)createWithInjectedScene:(UVInjectedScene *)scene error:(NSError **)error;
@end
