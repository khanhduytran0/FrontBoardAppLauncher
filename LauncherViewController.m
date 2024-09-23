#import "DecoratedAppSceneView.h"
#import "LauncherViewController.h"
#import "ViewController.h"

@interface LauncherViewController ()
@property(nonatomic) NSMutableArray<LSApplicationProxy *> *apps;
@end

@implementation LauncherViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.title = @"FrontBoardAppLauncher";

    self.apps = LSApplicationWorkspace.defaultWorkspace.allInstalledApplications.mutableCopy;
    [self.apps sortUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"localizedShortName" ascending:YES],
    ]];
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }

    cell.textLabel.text = self.apps[indexPath.row].localizedShortName;
    cell.detailTextLabel.text = self.apps[indexPath.row].bundleIdentifier;
    cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:cell.detailTextLabel.text format:0 scale:UIScreen.mainScreen.scale];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DecoratedAppSceneView *view = [[DecoratedAppSceneView alloc] initWithBundleID:self.apps[indexPath.row].bundleIdentifier];
    CGRect origFrame = view.frame;
    CGRect cellFrame = view.frame;

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cellFrame.origin = [cell.superview convertPoint:cell.frame.origin toView:self.navigationController.parentViewController.view];
    cellFrame.size = cell.frame.size;

    view.alpha = 0;
    view.frame = cellFrame;
    view.backgroundColor = [UIColor blackColor];
    [self.navigationController.parentViewController.view addSubview:view];
    [UIView animateWithDuration:0.4
    animations:^{
        view.alpha = 1;
        view.frame = origFrame;
    } completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apps.count;
}

@end
