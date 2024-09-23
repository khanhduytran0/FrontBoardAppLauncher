#import "DecoratedAppSceneView.h"
#import "LauncherViewController.h"
#import "ViewController.h"

@interface ViewController ()
@property(nonatomic) FBApplicationProcessLaunchTransaction *transaction;
@property(nonatomic) UIScenePresentationManager *presentationManager;
@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    //self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.title = @"FrontBoardAppLauncher";

    LauncherViewController *launcherVC = [LauncherViewController new];
    
UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController:launcherVC];
    navigationVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self addChildViewController:navigationVC];

    DecoratedFloatingView *launcherView = [[DecoratedFloatingView alloc] initWithFrame:CGRectMake(0, 0, 400, 400) navigationBar:navigationVC.navigationBar];
    launcherView.center = self.view.center;
    launcherView.navigationItem.title = @"FrontBoardAppLauncher";
    [launcherView insertSubview:navigationVC.view atIndex:0];
    [self.view addSubview:launcherView];
}

@end
