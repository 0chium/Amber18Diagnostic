#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@interface SBUIFlashlightController : NSObject
+ (instancetype)sharedInstance;
- (void)turnFlashlightOnForReason:(NSString *)reason;
@end

__attribute__((constructor))
static void Amber18NativeFlashlightProbeLoaded(void)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        SBUIFlashlightController *flashlight =
            [SBUIFlashlightController sharedInstance];

        if (flashlight != nil) {
            [flashlight turnFlashlightOnForReason:@"Control Center"];
        }
    });
}
