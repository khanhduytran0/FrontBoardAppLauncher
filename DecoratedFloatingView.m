#import "DecoratedFloatingView.h"

@implementation DecoratedFloatingView

- (instancetype)initWithFrame:(CGRect)frame {
    // Navigation bar
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Unnamed window"];
    navigationBar.items = @[navigationItem];
    return [self initWithFrame:frame navigationBar:navigationBar];
}

- (instancetype)initWithFrame:(CGRect)frame navigationBar:(UINavigationBar *)navigationBar {
    self = [super initWithFrame:frame];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;

    self.navigationBar = navigationBar;
    self.navigationItem = navigationBar.items.firstObject;
    if (!self.navigationBar.superview) {
        [self addSubview:self.navigationBar];
    }

    UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveWindow:)];
    moveGesture.minimumNumberOfTouches = 1;
    moveGesture.maximumNumberOfTouches = 1;
    [self.navigationBar addGestureRecognizer:moveGesture];

    // Resize handle (idea stolen from Notes debugging window)
    self.resizeHandle = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 30, self.frame.size.height - 30, 60, 60)];
    self.resizeHandle.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.resizeHandle.transform = CGAffineTransformMakeRotation(M_PI_4);
    [self addSubview:self.resizeHandle];
    UIPanGestureRecognizer *resizeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeWindow:)];
    resizeGesture.minimumNumberOfTouches = 1;
    resizeGesture.maximumNumberOfTouches = 1;
    [self.resizeHandle addGestureRecognizer:resizeGesture];
    return self;
}

- (void)moveWindow:(UIPanGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.superview 

bringSubviewToFront:self];
    }

    CGPoint point = [sender translationInView:self];
    [sender setTranslation:CGPointZero inView:self];

    self.center = CGPointMake(self.center.x + point.x, self.center.y + point.y);
}

- (void)resizeWindow:(UIPanGestureRecognizer*)sender {
    CGPoint point = [sender translationInView:self];
    [sender setTranslation:CGPointZero inView:self];

    CGRect frame = self.frame;
    frame.size.width = MAX(50, frame.size.width + point.x);
    frame.size.height = MAX(50, frame.size.height + point.y);
    self.frame = frame;
    self.resizeHandle.center = CGPointMake(self.resizeHandle.center.x + point.x, self.resizeHandle.center.y + point.y);
}

@end
