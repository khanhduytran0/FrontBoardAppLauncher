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

    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"FrontBoardAppLauncher"];
    navigationBar.items = @[navigationItem];
    
    LauncherViewController *launcherVC = [LauncherViewController new];
    launcherVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self addChildViewController:launcherVC];

    DecoratedFloatingView *launcherView = [[DecoratedFloatingView alloc] initWithFrame:CGRectMake(0, 0, 400, 400) navigationBar:navigationBar];
    launcherView.center = self.view.center;
    [launcherView.contentView insertSubview:launcherVC.view atIndex:0];
    [self.view addSubview:launcherView];
    launcherVC.view.frame = launcherView.bounds;
    [launcherVC didMoveToParentViewController:self];
}

@end
