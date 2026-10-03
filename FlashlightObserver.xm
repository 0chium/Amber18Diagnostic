#import <Foundation/Foundation.h>

%hook SBUIFlashlightController

- (void)turnFlashlightOnForReason:(id)reason
{
    NSLog(@"[Amber18] turnFlashlightOnForReason: class=%@ value=%@",
          reason ? NSStringFromClass([reason class]) : @"(nil)",
          reason);

    %orig;
}

- (void)turnFlashlightOffForReason:(id)reason
{
    NSLog(@"[Amber18] turnFlashlightOffForReason: class=%@ value=%@",
          reason ? NSStringFromClass([reason class]) : @"(nil)",
          reason);

    %orig;
}

%end
