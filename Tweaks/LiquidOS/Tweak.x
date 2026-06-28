#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

static UIView *liquidIsland = nil;
static UILabel *titleLabel = nil;

#pragma mark - Window

static UIWindow *GetMainWindow(void)
{
    if (@available(iOS 13.0, *))
    {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes)
        {
            if (![scene isKindOfClass:[UIWindowScene class]])
                continue;

            UIWindowScene *windowScene = (UIWindowScene *)scene;

            for (UIWindow *window in windowScene.windows)
            {
                if (window.isKeyWindow)
                    return window;
            }
        }
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return UIApplication.sharedApplication.keyWindow;
#pragma clang diagnostic pop
}

#pragma mark - Island

static void CreateIsland(void)
{
    if (liquidIsland)
        return;

    UIWindow *window = GetMainWindow();

    if (!window)
        return;

    CGFloat width = 160.0;
    CGFloat height = 38.0;

    CGFloat x = (UIScreen.mainScreen.bounds.size.width - width) / 2.0;
    CGFloat y = 8.0;

    liquidIsland = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];

    // OLED Black
    liquidIsland.backgroundColor = UIColor.blackColor;

    // Capsule
    liquidIsland.layer.cornerRadius = height / 2.0;
    liquidIsland.layer.masksToBounds = NO;

    // Liquid Glass Border
    liquidIsland.layer.borderWidth = 0.5;
    liquidIsland.layer.borderColor =
    [UIColor colorWithWhite:1 alpha:0.08].CGColor;

    // Soft Shadow
    liquidIsland.layer.shadowColor = UIColor.blackColor.CGColor;
    liquidIsland.layer.shadowOpacity = 0.35;
    liquidIsland.layer.shadowRadius = 18;
    liquidIsland.layer.shadowOffset = CGSizeMake(0,6);

    // Highlight
    CAGradientLayer *highlight = [CAGradientLayer layer];
    highlight.frame = CGRectMake(0,0,width,height/2.2);
    highlight.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.12].CGColor,
        (__bridge id)[UIColor clearColor].CGColor
    ];
    highlight.startPoint = CGPointMake(0.5,0);
    highlight.endPoint = CGPointMake(0.5,1);
    highlight.cornerRadius = height/2;

    [liquidIsland.layer addSublayer:highlight];

    titleLabel = [[UILabel alloc] initWithFrame:liquidIsland.bounds];
    titleLabel.text = @"LiquidOS";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];

    [liquidIsland addSubview:titleLabel];

    liquidIsland.alpha = 0.0;
    liquidIsland.transform = CGAffineTransformMakeScale(0.82,0.82);

    [window addSubview:liquidIsland];
}

static void SetIslandText(NSString *text)
{
    if (!titleLabel)
        return;

    titleLabel.text = text;
}

static void ShowIsland(void)
{
    if (!liquidIsland)
        return;

    [UIView animateWithDuration:0.45
                          delay:0
         usingSpringWithDamping:0.82
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

        liquidIsland.alpha = 1.0;
        liquidIsland.transform = CGAffineTransformIdentity;

    } completion:nil];
}

static void HideIsland(void)
{
    if (!liquidIsland)
        return;

    [UIView animateWithDuration:0.30
                     animations:^{

        liquidIsland.alpha = 0.0;
        liquidIsland.transform =
        CGAffineTransformMakeScale(0.92,0.92);

    }];
}

#pragma mark - Hook

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application
{
    %orig;

    NSLog(@"[LiquidOS] Loaded");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 2 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{

        CreateIsland();

        SetIslandText(@"LiquidOS");

        ShowIsland();

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     3 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{

            HideIsland();

        });

    });
}

%end