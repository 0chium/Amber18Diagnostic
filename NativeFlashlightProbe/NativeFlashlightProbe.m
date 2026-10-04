#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <notify.h>

@interface SBUIFlashlightController : NSObject
+ (instancetype)sharedInstance;
- (void)turnFlashlightOnForReason:(NSString *)reason;
@end

static const char *kAmber18ProbeNotification =
    "com.ochium.amber18diagnostic.probe";

__attribute__((constructor))
static void Amber18NativeFlashlightProbeLoaded(void)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        notify_post(kAmber18ProbeNotification);

        SBUIFlashlightController *flashlight =
            [SBUIFlashlightController sharedInstance];

        if (flashlight != nil) {
            [flashlight turnFlashlightOnForReason:@"Control Center"];
        }
    });
}
