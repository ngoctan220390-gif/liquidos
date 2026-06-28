#import <Foundation/Foundation.h>

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    NSLog(@"[LiquidOS] Tweak loaded successfully!");
}

%end