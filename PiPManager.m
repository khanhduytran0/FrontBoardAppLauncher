//
//  PiPManager.m
//  LiveContainer
//
//  Created by s s on 2025/6/3.
//
#include "PiPManager.h"

@interface PiPManager()
@property(nonatomic, strong) AVPictureInPictureVideoCallViewController *pipVideoCallViewController;
@property(nonatomic, strong) AVPictureInPictureController *pipController;
@property(nonatomic) UIView* displayingView;
@property(nonatomic) UIView* contentView;
//@property(nonatomic) NSExtension* extension;
@end


@implementation PiPManager
static PiPManager* sharedInstance = nil;

+ (instancetype)shared {
    if(!sharedInstance)
        sharedInstance = [[self alloc] init];
    return sharedInstance;
}

- (BOOL)isPiP {
    return self.pipController.isPictureInPictureActive;
}

- (BOOL)isPiPWithView:(UIView*)view {
    return self.pipController.isPictureInPictureActive && self.displayingView == view;
}

- (instancetype)init {
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:1 error:&error];
    

    
    return self;
}

- (void)startPiPWithView:(UIView*)view contentView:(UIView*)contentView {
    [self.pipController stopPictureInPicture];
    if(self.contentView) {
        [self.contentView insertSubview:self.displayingView atIndex:0];
        self.displayingView.transform = CGAffineTransformIdentity;
        self.contentView = nil;
        self.displayingView = nil;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.pipController isPictureInPictureActive] * 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.pipVideoCallViewController = [AVPictureInPictureVideoCallViewController new];
        self.pipVideoCallViewController.preferredContentSize = view.bounds.size;
        AVPictureInPictureControllerContentSource* contentSource =  [[AVPictureInPictureControllerContentSource alloc] initWithActiveVideoCallSourceView:contentView contentViewController:self.pipVideoCallViewController];
        self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
        self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
        self.pipController.delegate = self;
        [self.pipController setValue:@1 forKey:@"controlsStyle"];
        self.displayingView = view;
        self.contentView = contentView;
        //self.extension = extension;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pipController startPictureInPicture];
        });
    });

}

- (void)stopPiP {
    [self.pipController stopPictureInPicture];
}

// PIP delegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    UIWindow *firstWindow = [UIApplication sharedApplication].windows.firstObject;
    [firstWindow addSubview:self.displayingView];
    [firstWindow.layer addObserver:self
                                forKeyPath:@"bounds"
                                   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                   context:NULL];
    self.pipVideoCallViewController.preferredContentSize = self.displayingView.bounds.size;
    // Remove UIApplicationDidEnterBackgroundNotification so apps like YouTube can continue playing video
    //[NSNotificationCenter.defaultCenter removeObserver:self.extension name:UIApplicationDidEnterBackgroundNotification object:UIApplication.sharedApplication];
}



- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self.contentView insertSubview:self.displayingView atIndex:0];
    self.displayingView.transform = CGAffineTransformIdentity;
    // Re-add UIApplicationDidEnterBackgroundNotification
    //[NSNotificationCenter.defaultCenter addObserver:self.extension selector:@selector(_hostDidEnterBackgroundNote:) name:UIApplicationDidEnterBackgroundNotification object:UIApplication.sharedApplication];
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"%@", error.description);
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(NSObject*)object change:(NSDictionary<NSString *,id> *) change context:(void *) context {
    CGRect rect = [change[@"new"] CGRectValue];
    CGAffineTransform transform1 = CGAffineTransformScale(CGAffineTransformIdentity, rect.size.width / self.displayingView.bounds.size.width,rect.size.height / self.displayingView.bounds.size.height);
    self.displayingView.transform = transform1;
}

@end
