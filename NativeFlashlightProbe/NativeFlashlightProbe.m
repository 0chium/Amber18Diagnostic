#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@interface SBUIFlashlightController : NSObject
+ (instancetype)sharedInstance;
- (float)width;
@end

__attribute__((constructor))
static void Amber18NativeFlashlightProbeLoaded(void)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        SBUIFlashlightController *flashlight =
            [SBUIFlashlightController sharedInstance];

        if (flashlight == nil)
            return;

        float width = [flashlight width];

        NSString *output = [NSString stringWithFormat:
            @"SBUIFlashlightController width = %.9f\n",
            width];

        [output writeToFile:@"/var/mobile/Documents/AmberWidth.txt"
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
    });
}
